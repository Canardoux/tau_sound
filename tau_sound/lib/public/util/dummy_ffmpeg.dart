/*
 * Copyright 2018, 2019, 2020, 2021 Dooboolab.
 *
 * This file is part of Flutter-Sound.
 *
 * Flutter-Sound is free software: you can redistribute it and/or modify
 * it under the terms of the Mozilla Public License version 2 (MPL2.0), as published by
 * the Mozilla organization.
 *
 * Flutter-Sound is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * MPL General Public License for more details.
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

/// ----------
///
/// This is a dummy Flutter_ffmpeg module used in the LITE flavor of Flutter Sound.
///
/// --------------------
///

import 'dart:async';

/// @nodoc
@deprecated
class FlutterFFprobe {
  Future<int> executeWithArguments(List<dynamic> arguments) async => 0;
  Future<MediaInformation> getMediaInformation(String path) async =>
      MediaInformation();
}

/// @nodoc
@deprecated
class FlutterFFmpeg {
  Future<int> executeWithArguments(List<dynamic>? arguments) async => 0;
}

/// @nodoc
@deprecated
class MediaInformation {
  Map getAllProperties() => {};
}

/// @nodoc
@deprecated
class FlutterFFmpegConfig {
  Future<String> getLastCommandOutput() async => 'Error';
  Future<int> getLastReturnCode() async => 0;
}
