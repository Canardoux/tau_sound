/*
 * Copyright 2021 Canardoux.
 *
 * This file is part of the τ Sound project.
 *
 * τ Sound is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Public License version 3 (GPL3.0),
 * as published by the Free Software Foundation.
 *
 * τ Sound is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * This Source Code Form is subject to the terms of the GNU Public
 * License, v. 3.0. If a copy of the GPL was not distributed with this
 * file, You can obtain one at https://www.gnu.org/licenses/.
 */

/// ----------
///
/// TauHelper module is for handling audio files and buffers.
///
/// --------------------
///
/// {@category Utilities}
library helper;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart' show Level, Logger;

import '../../tau_sound.dart';
import 'wave_header.dart';
import 'package:path_provider/path_provider.dart';

/// The TauHelper singleton for accessing the helpers functions
TauHelper tauHelper = TauHelper._internal(); // Singleton

/// TauHelper class is for handling audio files and buffers.
class TauHelper {
  /// The TauHelper Logger
  Logger logger = Logger(level: Level.debug);

// -------------------------------------------------------------------------------------------------------------

  /// The factory which returns the Singleton
  factory TauHelper() {
    return tauHelper;
  }

  /// Private constructor of the Singleton
  /* ctor */ TauHelper._internal();

//-------------------------------------------------------------------------------------------------------------

  void setLogLevel(Level theNewLogLevel) {
    logger = Logger(level: theNewLogLevel);
  }


  /// Convert a WAVE file to a Raw PCM file.
  ///
  /// Remove the WAVE header in front of the Wave file
  ///
  /// This verb is usefull to convert a Wave file to a Raw PCM file.
  ///
  /// Note that this verb is not asynchronous and does not return a Future.
  Future<void> waveToPCM({
    required String inputFile,
    required String outputFile,
    required TauCodec codec,
  }) async {
    var filIn = File(inputFile);
    var filOut = File(outputFile);
    var sink = filOut.openWrite();
    await filIn.open();
    var buffer = filIn.readAsBytesSync();
    sink.add(buffer.sublist(WaveHeader.headerLength));
    await sink.close();
  }

  /// Convert a WAVE buffer to a Raw PCM buffer.
  ///
  /// Remove WAVE header in front of the Wave buffer.
  ///
  /// Note that this verb is not asynchronous and does not return a Future.
  Uint8List waveToPCMBuffer({
    required Uint8List inputBuffer,
  }) {
    return inputBuffer.sublist(WaveHeader.headerLength);
  }

  /// Converts a raw PCM file to a WAVE file.
  ///
  /// Add a WAVE header in front of the PCM data
  /// This verb is usefull to convert a Raw PCM file to a Wave file.
  /// It adds a `Wave` envelop to the PCM file, so that the file can be played back with `startPlayer()`.
  ///
  /// Note: the parameters `numChannels` and `sampleRate` **are mandatory, and must match the actual PCM data**.
  ///
  /// [See here](doc/codec.md#note-on-raw-pcm-and-wave-files) a discussion about `Raw PCM` and `WAVE` file format.
  Future<void> pcmToWave({
    required String inputFile,
    required String outputFile,
    required Pcm codec,
  }) async {
    if (codec.audioFormat != AudioFormat.raw || codec.sampleRate == null) {
      throw Exception('Codec must be raw PCM');
    }
    var filIn = File(inputFile);
    var filOut = File(outputFile);
    var size = filIn.lengthSync();
    logger.i(
        'pcmToWave() : input = $inputFile,  output = $outputFile,  size = $size');
    var sink = filOut.openWrite();

    var header = WaveHeader(
      WaveHeader.formatPCM,
      codec.nbrChannels(), //
      codec.sampleRate!,
      16, // 16 bits per byte
      size, // total number of bytes
    );
    header.write(sink);
    await filIn.open();
    var buffer = filIn.readAsBytesSync();
    sink.add(buffer.toList());
    await sink.close();
  }

  /// Convert a raw PCM buffer to a WAVE buffer.
  ///
  /// Adds a WAVE header in front of the PCM data
  /// It adds a `Wave` envelop in front of the PCM buffer, so that the file can be played back with `startPlayerFromBuffer()`.
  Future<Uint8List> pcmToWaveBuffer({
    required Uint8List inputBuffer,
    required Pcm codec,
  }) async {
    if (codec.audioFormat != AudioFormat.raw || codec.sampleRate == null) {
      throw Exception('Codec must be raw PCM');
    }

    var size = inputBuffer.length;
    var header = WaveHeader(
      WaveHeader.formatPCM,
      codec.nbrChannels(),
      codec.sampleRate!,
      16,
      size, // total number of bytes
    );

    var buffer = <int>[];
    StreamController controller = StreamController<List<int>>();
    var sink = controller.sink as StreamSink<List<int>>;
    var stream = controller.stream as Stream<List<int>>;
    stream.listen((e) {
      var x = e.toList();
      buffer.addAll(x);
    });
    header.write(sink);
    sink.add(inputBuffer);
    await sink.close();
    await controller.close();
    return Uint8List.fromList(buffer);
  }

  Future<String> _getPath(String? path) async {
    if (path == null) {
      return '';
    }
    final index = path.indexOf('/');
    if (index >= 0) {
      return path;
    }
    var tempDir = await getTemporaryDirectory();
    var tempPath = tempDir.path;
    return tempPath + '/' + path;
  }

}