// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_devicelab/framework/devices.dart';
import 'package:flutter_devicelab/framework/framework.dart';
<<<<<<<< HEAD:dev/devicelab/bin/tasks/ios_picture_cache_complexity_scoring_perf__timeline_summary.dart
import 'package:flutter_devicelab/tasks/perf_tests.dart';

Future<void> main() async {
  deviceOperatingSystem = DeviceOperatingSystem.ios;
  await task(createPictureCacheComplexityScoringPerfTest());
========
import 'package:flutter_devicelab/tasks/integration_tests.dart';

Future<void> main() async {
  deviceOperatingSystem = DeviceOperatingSystem.ios;
  await task(createWideGamutTest());
>>>>>>>> 67457e669f79e9f8d13d7a68fe09775fefbb79f4:dev/devicelab/bin/tasks/wide_gamut_ios.dart
}
