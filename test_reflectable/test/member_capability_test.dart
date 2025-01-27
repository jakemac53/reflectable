// Copyright (c) 2015, the Dart Team. All rights reserved. Use of this
// source code is governed by a BSD-style license that can be found in
// the LICENSE file.

// File being transformed by the reflectable transformer.
// Uses 'reflect', with a constraint to invocation based on
// 'InvokeInstanceMemberCapability'.

library test_reflectable.test.member_capability_test;

import 'package:reflectable/reflectable.dart';
import 'package:unittest/unittest.dart';

class MyReflectable extends Reflectable {
  const MyReflectable() : super(invokingCapability);
}

class MyReflectable2 extends Reflectable {
  const MyReflectable2() : super(const InstanceInvokeCapability(r"^(x|b|b=)$"));
}

class MyReflectable3 extends Reflectable {
  const MyReflectable3() : super(const InstanceInvokeMetaCapability(Bar));
}

const myReflectable = const MyReflectable();
const myReflectable2 = const MyReflectable2();
const myReflectable3 = const MyReflectable3();

class Bar {
  const Bar();
}

@myReflectable
class Foo {
  var a = 1;
  var b = 2;
  x() => 42;
  y(int n) => "Hello $n";
}

@myReflectable2
class Foo2 {
  var a = 1;
  var b = 2;
  x() => 42;
  y(int n) => "Hello $n";
  var z;
}

@myReflectable3
class Foo3 {
  var a = 1;
  @Bar()
  var b = 2;
  x() => 42;
  @Bar()
  y(int n) => "Hello $n";
  var z;
}

main() {
  test("invokingCapability", () {
    Foo foo = new Foo();
    InstanceMirror fooMirror = myReflectable.reflect(foo);
    expect(fooMirror.invokeGetter("a"), 1);
    expect(fooMirror.invokeSetter("a", 11), 11);
    expect(fooMirror.invokeGetter("a"), 11);
    expect(fooMirror.invokeGetter("b"), 2);
    expect(fooMirror.invokeSetter("b", 12), 12);
    expect(fooMirror.invokeGetter("b"), 12);
    expect(fooMirror.invoke("y", [1]), "Hello 1");

    expect(fooMirror.invoke("x", []), 42);
    expect(fooMirror.invoke("y", [1]), "Hello 1");
  });

  test('InstanceInvokeCapability("x")', () {
    Foo2 foo = new Foo2();
    InstanceMirror fooMirror = myReflectable2.reflect(foo);
    expect(() => fooMirror.invokeGetter("a"),
        throwsA(const isInstanceOf<NoSuchCapabilityError>()));
    expect(() => fooMirror.invokeSetter("a", 11),
        throwsA(const isInstanceOf<NoSuchCapabilityError>()));
    expect(fooMirror.invokeGetter("b"), 2);
    expect(fooMirror.invokeSetter("b", 12), 12);
    expect(fooMirror.invokeGetter("b"), 12);

    expect(myReflectable2.reflect(new Foo2()).invoke("x", []), 42);
    expect(() => myReflectable2.reflect(new Foo2()).invoke("y", [3]),
        throwsA(const isInstanceOf<NoSuchCapabilityError>()));
  });

  test("InstanceInvokeMetaCapability(Bar)", () {
    Foo3 foo = new Foo3();
    InstanceMirror fooMirror = myReflectable3.reflect(foo);
    expect(() => fooMirror.invokeGetter("a"),
        throwsA(const isInstanceOf<NoSuchCapabilityError>()));
    expect(() => fooMirror.invokeSetter("a", 11),
        throwsA(const isInstanceOf<NoSuchCapabilityError>()));
    expect(fooMirror.invokeGetter("b"), 2);
    expect(fooMirror.invokeSetter("b", 12), 12);
    expect(fooMirror.invokeGetter("b"), 12);

    expect(() => myReflectable3.reflect(new Foo3()).invoke("x", []),
        throwsA(const isInstanceOf<NoSuchCapabilityError>()));
    expect(myReflectable3.reflect(new Foo3()).invoke("y", [3]), "Hello 3");
  });
}
