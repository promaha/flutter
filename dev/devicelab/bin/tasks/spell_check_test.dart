// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_devicelab/framework/devices.dart';
import 'package:flutter_devicelab/framework/framework.dart';
import 'package:flutter_devicelab/framework/task_result.dart';
import 'package:flutter_devicelab/tasks/integration_tests.dart';

Future<void> main() async {
  deviceOperatingSystem = DeviceOperatingSystem.android;
<<<<<<< HEAD:dev/devicelab/bin/tasks/flavors_test_win.dart
  await task(() async {
    await createFlavorsTest().call();
    await createIntegrationTestFlavorsTest().call();

    return TaskResult.success(null);
  });
=======
  await task(createSpellCheckIntegrationTest());
>>>>>>> 67457e669f79e9f8d13d7a68fe09775fefbb79f4:dev/devicelab/bin/tasks/spell_check_test.dart
}
