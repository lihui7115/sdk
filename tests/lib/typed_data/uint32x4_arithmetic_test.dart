// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
// VMOptions=--deoptimization_counter_threshold=1000 --optimization-counter-threshold=10

// Library tag to be able to run in html test framework.
library uint32x4_arithmetic_test;

import "package:expect/expect.dart";
import 'dart:typed_data';

testAdd() {
  var m = new Uint32x4(0, 0, 0, 0);
  var n = new Uint32x4(-1, -1, -1, -1);
  var o = m + n;
  Expect.equals(4294967295, o.x);
  Expect.equals(4294967295, o.y);
  Expect.equals(4294967295, o.z);
  Expect.equals(4294967295, o.w);

  m = new Uint32x4(0, 0, 0, 0);
  n = new Uint32x4(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF);
  o = m + n;
  Expect.equals(4294967295, o.x);
  Expect.equals(4294967295, o.y);
  Expect.equals(4294967295, o.z);
  Expect.equals(4294967295, o.w);

  n = new Uint32x4(1, 1, 1, 1);
  m = new Uint32x4(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF);
  o = m + n;
  Expect.equals(0, o.x);
  Expect.equals(0, o.y);
  Expect.equals(0, o.z);
  Expect.equals(0, o.w);

  n = new Uint32x4(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF);
  m = new Uint32x4(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF);
  o = m + n;
  Expect.equals(4294967294, o.x);
  Expect.equals(4294967294, o.y);
  Expect.equals(4294967294, o.z);
  Expect.equals(4294967294, o.w);

  n = new Uint32x4(1, 0, 0, 0);
  m = new Uint32x4(2, 0, 0, 0);
  o = n + m;
  Expect.equals(3, o.x);
  Expect.equals(0, o.y);
  Expect.equals(0, o.z);
  Expect.equals(0, o.w);

  n = new Uint32x4(1, 3, 0, 0);
  m = new Uint32x4(2, 4, 0, 0);
  o = n + m;
  Expect.equals(3, o.x);
  Expect.equals(7, o.y);
  Expect.equals(0, o.z);
  Expect.equals(0, o.w);

  n = new Uint32x4(1, 3, 5, 0);
  m = new Uint32x4(2, 4, 6, 0);
  o = n + m;
  Expect.equals(3, o.x);
  Expect.equals(7, o.y);
  Expect.equals(11, o.z);
  Expect.equals(0, o.w);

  n = new Uint32x4(1, 3, 5, 7);
  m = new Uint32x4(2, 4, 6, 8);
  o = n + m;
  Expect.equals(3, o.x);
  Expect.equals(7, o.y);
  Expect.equals(11, o.z);
  Expect.equals(15, o.w);
}

testSub() {
  var m = new Uint32x4(0, 0, 0, 0);
  var n = new Uint32x4(1, 1, 1, 1);
  var o = m - n;
  Expect.equals(4294967295, o.x);
  Expect.equals(4294967295, o.y);
  Expect.equals(4294967295, o.z);
  Expect.equals(4294967295, o.w);

  o = n - m;
  Expect.equals(1, o.x);
  Expect.equals(1, o.y);
  Expect.equals(1, o.z);
  Expect.equals(1, o.w);
}

main() {
  for (int i = 0; i < 20; i++) {
    testAdd();
    testSub();
  }
}
