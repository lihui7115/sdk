// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart = 2.7

import 'package:expect/expect.dart';

/*spec:nnbd-off.class: A:direct,explicit=[A.T],needsArgs*/
/*spec:nnbd-sdk.class: A:direct,explicit=[A.T*],needsArgs*/
class A<T> {
  /*spec:nnbd-off|prod:nnbd-off.member: A.call:*/
  call(T t) {}
}

@pragma('dart2js:noInline')
test(o) => o is Function(int);

main() {
  Expect.isFalse(test(new A<int>()));
  Expect.isFalse(test(new A<String>()));
  new A().call(null); // Use .call to ensure it is live.
}
