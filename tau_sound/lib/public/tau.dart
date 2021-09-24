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

// The three interfaces to the platform
// ------------------------------------

/// ------------------------------------------------------------------
/// # The Flutter Sound library
///
/// Flutter Sound is composed with six main modules/classes
/// - `Tau`. This is the main Flutter Sound module.
/// - [TauPlayer]. Everything about the playback functions
/// - [TauRecorder]. Everything about the recording functions
/// - [TauHelper]. Some utilities to manage audio data.
/// ------------------------------------------------------------------
/// {@category Main}
library tau;

import 'package:logger/logger.dart' show Level, Logger;
import '../tau_sound.dart';

/// The usual file extensions used for each codecs
const List<String> ext = [
  '', // defaultCodec
  '.aac', // aacADTS
  '.opus', // opusOGG
  '.caf', // opusCAF
  '.mp3', // mp3
  '.ogg', // vorbisOGG
  '.pcm', // pcm16
  '.wav', // pcm16WAV
  '.aiff', // pcm16AIFF
  '_pcm.caf', // pcm16CAF
  '.flac', // flac
  '.mp4', // aacMP4
  '.amr', // AMR-NB
  '.amr', // amr-WB
  '.pcm', // pcm8
  '.pcm', // pcmFloat32
  '.pcm', //codec.pcmWebM,
  '.webm', // codec.opusWebM,
  '.webm', // codec.vorbisWebM,
];

/// The valid file extensions for each codecs
const List<List<String>> validExt = [
  [''], // defaultCodec
  ['.aac', '.adt', '.adts'], // aacADTS
  ['.opus', '.ogg'], // opusOGG
  ['.caf'], // opusCAF
  ['.mp3'], // mp3
  ['.ogg'], // vorbisOGG
  ['.pcm', '.aiff'], // pcm16
  ['.wav'], // pcm16WAV
  ['.aiff'], // pcm16AIFF
  ['.caf'], // pcm16CAF
  ['.flac'], // flac
  ['.mp4', '.aac', '.m4a'], // aacMP4
  ['.amr', '.3ga'], // AMR-NB
  ['.amr', '.3ga'], // amr-WB
  ['.pcm', '.aiff'], // pcm8
  ['.pcm', '.aiff'], // pcmFloat32
  ['.pcm', '.webm'], //codec.pcmWebM,
  ['.opus', '.webm'], // codec.opusWebM,
  ['.webm'], // codec.vorbisWebM,
];

/// This is **THE** main Flutter Sound class.
///
/// For future expansion. Do not use.
/// This class is not instanciable. Use the expression [FlutterSound()] when you want to get the Singleton.
///
/// This class is used to access the main functionalities of Flutter Sound.
/// @nodoc
class Tau {
  Logger _logger = Logger(level: Level.debug);

  /// The FlutterSound Logger getter
  Logger get logger => _logger;

  /// Used if the App wants to dynamically change the Log Level.
  /// Seldom used. Most of the time the Log Level is specified during the constructor.
  Future<void> setLogLevel(Level aLevel) async {
    _logger = Logger(level: aLevel);
  }

  /// the static Singleton
  static final Tau _singleton = Tau._internal();

  /// The factory which returns the Singleton
  factory Tau() {
    return _singleton;
  }

  /// Private constructor of the Singleton
  /* ctor */ Tau._internal();
}
