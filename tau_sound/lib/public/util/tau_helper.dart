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
/// TauHelper module is for handling audio files and buffers.
///
/// Most of those utilities use FFmpeg, so are not available in the LITE flavor of Flutter Sound.
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

import '../../flutter_sound.dart';
import 'wave_header.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

/// The TauHelper singleton for accessing the helpers functions
TauHelper tauHelper = TauHelper._internal(); // Singleton
const bool _hasFFmpeg = true;

/// TauHelper class is for handling audio files and buffers.
/// Most of those utilities use FFmpeg, so are not available in the LITE flavor of Flutter Sound.
class TauHelper {
  /// The TauHelper Logger
  Logger logger = Logger(level: Level.debug);

  /// The Flutter FFmpeg module
  FlutterFFmpeg? flutterFFmpeg;

  FlutterFFmpegConfig? _flutterFFmpegConfig;
  FlutterFFprobe? _flutterFFprobe;

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

  /// To know during runtime if FFmpeg is linked with the App.
  ///
  /// returns true if FFmpeg is available (probably the FULL version of Flutter Sound)
  bool isFFmpegAvailable() => (kIsWeb) ? false : _hasFFmpeg;

  /// A wrapper for the great FFmpeg application.
  ///
  /// The command `man ffmpeg` (if you have installed ffmpeg on your computer) will give you many informations.
  /// If you do not have `ffmpeg` on your computer you will find easyly on internet many documentation on this great program.
  ///
  /// We use here our own ffmpeg "execute" procedure instead of the one provided by the flutter_ffmpeg plugin,
  /// so that the developers not interested by ffmpeg can use Flutter Sound without the flutter_ffmpeg plugin
  /// and without any complain from the link-editor.
  ///
  /// Executes FFmpeg with `commandArguments` provided.
  Future<int?> executeFFmpegWithArguments(List<String?> arguments) async {
    if (!isFFmpegAvailable()) {
      return 0;
    }
    flutterFFmpeg ??= FlutterFFmpeg();
    return flutterFFmpeg!.executeWithArguments(arguments);
  }

  /// Get the error code returned by [executeFFmpegWithArguments()].
  ///
  /// We use here our own ffmpeg "getLastReturnCode" procedure instead of the one provided by the flutter_ffmpeg plugin,
  /// so that the developers not interested by ffmpeg can use Flutter Sound without the flutter_ffmpeg plugin
  /// and without any complain from the link-editor.
  ///
  /// This simple verb is used to get the result of the last FFmpeg command.
  Future<int?> getLastFFmpegReturnCode() async {
    if (!isFFmpegAvailable()) {
      return 0;
    }
    return _flutterFFmpegConfig!.getLastReturnCode();
  }

  /// Get the log code output by [executeFFmpegWithArguments()].
  ///
  /// We use here our own ffmpeg "getLastCommandOutput" procedure instead of the one provided by the flutter_ffmpeg plugin,
  /// so that the developers not interested by ffmpeg can use Flutter Sound without the flutter_ffmpeg plugin
  /// and without any complain from the link-editor.
  ///
  /// Returns log output of last executed command. Please note that disabling redirection using
  /// This method does not support executing multiple concurrent commands. If you execute multiple commands at the same time, this method will return output from all executions.
  /// `disableRedirection()` method also disables this functionality.
  Future<String?> getLastFFmpegCommandOutput() async {
    if (!isFFmpegAvailable()) {
      return null;
    }
    return _flutterFFmpegConfig!.getLastCommandOutput();
  }

  /// Various informations about the Audio specified by the `uri` parameter.
  ///
  /// The informations Map got with FFmpegGetMediaInformation() are [documented here](https://pub.dev/packages/flutter_ffmpeg).
  Future<Map<dynamic, dynamic>?> ffMpegGetMediaInformation(String uri) async {
    _flutterFFprobe ??= FlutterFFprobe();
    try {
      return (await _flutterFFprobe!.getMediaInformation(uri))
          .getAllProperties();
    } on Exception {
      return null;
    }
  }

  /// Get the duration of a sound file.
  ///
  /// This verb is used to get an estimation of the duration of a sound file.
  /// Be aware that it is just an estimation, based on the Codec used and the sample rate.
  Future<Duration?> duration(String uri) async {
    if (!isFFmpegAvailable()) return null;
    var info = await FlutterFFprobe().getMediaInformation(uri);
    if (info == null) {
      return null;
    }
    var format = info.getAllProperties()['format'];
    if (format == null) return null;
    var duration = format['duration'];
    if (duration == null) return null;
    var d = (double.parse(duration) * 1000.0).round();
    return (duration == null) ? null : Duration(milliseconds: d);
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

  /// Convert a sound file to a new format.
  ///
  /// - `inputFile` is the file path of the file you want to convert
  /// - `inputCodec` is the actual file format
  /// - `outputFile` is the path of the file you want to create
  /// - `outputCodec` is the new file format
  ///
  /// Be careful : `outfile` and `outputCodec` must be compatible. The output file extension must be a correct file extension for the new format.
  ///
  /// Note : this verb uses FFmpeg and is not available int the LITE flavor of Flutter Sound.
  Future<bool> convertFile(String? inputFile, Codec? inputCodec,
      String outputFile, Codec outputCodec) async {
    if (!isFFmpegAvailable()) return false;
    int? rc = 0;
    inputFile = await _getPath(inputFile);
    outputFile = await _getPath(outputFile);
    if (inputCodec == Codec.opusOGG &&
        outputCodec == Codec.opusCAF) // Do not need to re-encode. Just remux
    {
      rc = await FlutterFFmpeg().executeWithArguments([
        '-loglevel',
        'error',
        '-y',
        '-i',
        inputFile,
        '-c:a',
        'copy',
        outputFile,
      ]); // remux OGG to CAF
    } else {
      rc = await FlutterFFmpeg().executeWithArguments([
        '-loglevel',
        'error',
        '-y',
        '-i',
        inputFile,
        outputFile,
      ]);
    }
    return (rc == 0);
  }
}
