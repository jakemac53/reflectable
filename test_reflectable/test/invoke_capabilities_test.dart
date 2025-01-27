// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library test_reflectable.test.invoke_capabilities_test;

import 'package:unittest/unittest.dart';
import 'package:reflectable/reflectable.dart' as r;
import 'package:reflectable/capability.dart' as c;

// Tests that reflection is constrained according to different kinds of
// capabilities.
// TODO(eernst): Add test cases using metadata when that's supported.

const String methodRegExp = r'[Ff].*r=?$';

class InvokingReflector extends r.Reflectable {
  const InvokingReflector() : super(c.invokingCapability);
}

class InstanceInvokeReflector extends r.Reflectable {
  const InstanceInvokeReflector() : super(c.instanceInvokeCapability);
}

class StaticInvokeReflector extends r.Reflectable {
  const StaticInvokeReflector() : super(c.staticInvokeCapability);
}

class InvokingFrReflector extends r.Reflectable {
  const InvokingFrReflector()
      : super(const c.InvokingCapability(methodRegExp));
}

class InstanceInvokeFrReflector extends r.Reflectable {
  const InstanceInvokeFrReflector()
      : super(const c.InstanceInvokeCapability(methodRegExp));
}

class StaticInvokeFrReflector extends r.Reflectable {
  const StaticInvokeFrReflector()
      : super(const c.StaticInvokeCapability(methodRegExp));
}

const invokingReflector = const InvokingReflector();
const instanceInvokeReflector = const InstanceInvokeReflector();
const staticInvokeReflector = const StaticInvokeReflector();
const invokingFrReflector = const InvokingFrReflector();
const instanceInvokeFrReflector = const InstanceInvokeFrReflector();
const staticInvokeFrReflector = const StaticInvokeFrReflector();

final Map<Type, String> description = <Type, String>{
  InvokingReflector: "Invoking",
  InstanceInvokeReflector: "InstanceInvoke",
  StaticInvokeReflector: "StaticInvoke",
  InvokingFrReflector: "InvokingFr",
  InstanceInvokeFrReflector: "InstanceInvokeFr",
  StaticInvokeFrReflector: "StaticInvokeFr"
};

@invokingReflector
@instanceInvokeReflector
@invokingFrReflector
@instanceInvokeFrReflector
class A {
  int foo() => 42;
  int foobar() => 43;
  int get getFoo => 44;
  int get getFoobar => 45;
  set setFoo(int x) => field = x;
  set setFoobar(int x) => field = x;
  int field = 46;
  void reset() {
    field = 46;
  }
}

@invokingReflector
@staticInvokeReflector
@invokingFrReflector
@staticInvokeFrReflector
class B {
  static int foo() => 42;
  static int foobar() => 43;
  static int get getFoo => 44;
  static int get getFoobar => 45;
  static void set setFoo(int x) {
    field = x;
  }
  static void set setFoobar(int x) {
    field = x;
  }
  static int field = 46;
  static void reset() {
    field = 46;
  }
}

class BSubclass extends A {}

class BImplementer implements A {
  int foo() => 142;
  int foobar() => 143;
  int get getFoo => 144;
  int get getFoobar => 145;
  void set setFoo(int x) {
    field = x + 100;
  }
  void set setFoobar(int x) {
    field = x + 100;
  }
  int field = 146;
  void reset() {
    field = 146;
  }
}

Matcher throwsNoSuchCapabilityError = throwsA(isNoSuchCapabilityError);
Matcher isNoSuchCapabilityError = new isInstanceOf<c.NoSuchCapabilityError>();

void testInstance(r.Reflectable mirrorSystem, A reflectee,
    {bool broad: false}) {
  test("Instance invocation: ${description[mirrorSystem.runtimeType]}", () {
    reflectee.reset();
    r.InstanceMirror instanceMirror = mirrorSystem.reflect(reflectee);
    if (broad) {
      expect(instanceMirror.invoke("foo", []), 42);
    } else {
      expect(() {
        instanceMirror.invoke("foo", []);
      }, throwsNoSuchCapabilityError);
    }
    expect(instanceMirror.invoke("foobar", []), 43);
    if (broad) {
      expect(instanceMirror.invokeGetter("getFoo"), 44);
    } else {
      expect(() {
        instanceMirror.invokeGetter("getFoo");
      }, throwsNoSuchCapabilityError);
    }
    expect(instanceMirror.invokeGetter("getFoobar"), 45);
    expect(reflectee.field, 46);
    if (broad) {
      expect(instanceMirror.invokeSetter("setFoo=", 100), 100);
      expect(reflectee.field, 100);
    } else {
      expect(() {
        instanceMirror.invokeSetter("setFoo=", 100);
      }, throwsNoSuchCapabilityError);
      expect(reflectee.field, 46);
    }
    expect(instanceMirror.invokeSetter("setFoobar=", 100), 100);
    expect(reflectee.field, 100);
    expect(() => instanceMirror.invoke("nonExisting", []),
        broad ? throwsNoSuchMethodError : throwsNoSuchCapabilityError);
  });
}

void testStatic(r.Reflectable mirrorSystem, Type reflectee,
    void classResetter(), int classGetter(), {bool broad: false}) {
  test("Static invocation: ${description[mirrorSystem.runtimeType]}", () {
    classResetter();
    r.ClassMirror classMirror = mirrorSystem.reflectType(reflectee);
    if (broad) {
      expect(classMirror.invoke("foo", []), 42);
    } else {
      expect(() {
        classMirror.invoke("foo", []);
      }, throwsNoSuchCapabilityError);
    }
    expect(classMirror.invoke("foobar", []), 43);
    if (broad) {
      expect(classMirror.invokeGetter("getFoo"), 44);
    } else {
      expect(() {
        classMirror.invokeGetter("getFoo");
      }, throwsNoSuchCapabilityError);
    }
    expect(classMirror.invokeGetter("getFoobar"), 45);
    expect(B.field, 46);
    if (broad) {
      expect(classMirror.invokeSetter("setFoo=", 100), 100);
      expect(classGetter(), 100);
    } else {
      expect(() {
        classMirror.invokeSetter("setFoo=", 100);
      }, throwsNoSuchCapabilityError);
      expect(classGetter(), 46);
    }
    expect(classMirror.invokeSetter("setFoobar=", 100), 100);
    expect(classGetter(), 100);
    expect(() => classMirror.invoke("nonExisting", []),
        broad ? throwsNoSuchMethodError : throwsNoSuchCapabilityError);
  });
}

void testReflect(r.Reflectable mirrorSystem, B reflectee) {
  test("Can't reflect instance of subclass of annotated class", () {
    expect(() {
      mirrorSystem.reflect(new BSubclass());
    }, throwsNoSuchCapabilityError);
  });
  test("Can't reflect instance of subtype of annotated class", () {
    expect(() {
      mirrorSystem.reflect(new BImplementer());
    }, throwsNoSuchCapabilityError);
  });
  test("Can't reflect instance of unnanotated class", () {
    expect(() {
      mirrorSystem.reflect(new Object());
    }, throwsNoSuchCapabilityError);
  });
}

void main() {
  A a = new A();
  testInstance(invokingReflector, a, broad: true);
  testInstance(instanceInvokeReflector, a, broad: true);
  testInstance(invokingFrReflector, a);
  testInstance(instanceInvokeFrReflector, a);

  void reset() => B.reset();
  int field() => B.field;

  testStatic(invokingReflector, B, reset, field, broad: true);
  testStatic(staticInvokeReflector, B, reset, field, broad: true);
  testStatic(invokingFrReflector, B, reset, field);
  testStatic(staticInvokeFrReflector, B, reset, field);
}
