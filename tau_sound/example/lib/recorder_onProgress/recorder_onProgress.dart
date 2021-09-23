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

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';

/*
 *
 * This is a very simple example for Flutter Sound beginners,
 * that show how to record, and then playback a file.
 *
 * This example is really basic.
 *
 */

///
typedef Fn = void Function();

/// Example app.
class RecorderOnProgress extends StatefulWidget {
  @override
  _RecorderOnProgressState createState() => _RecorderOnProgressState();
}

class _RecorderOnProgressState extends State<RecorderOnProgress> {
  final TauRecorder _mRecorder = TauRecorder();
  TauCodec _codec = Aac(AudioFormat.mp4);
  String _mPath = 'tau_file.mp4';
  bool _mRecorderIsInited = false;
  double _mSubscriptionDuration = 0;
  int pos = 0;
  double dbLevel = 0;

  @override
  void initState() {
    super.initState();
    init().then((value) {
      setState(() {
        _mRecorderIsInited = true;
      });
    });
  }

  @override
  void dispose() {
    stopRecorder(_mRecorder);
    // Be careful : you must `close` the audio session when you have finished with it.
    _mRecorder.close();

    super.dispose();
  }

  Future<void> openTheRecorder() async {
    if (!kIsWeb) {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException('Microphone permission not granted');
      }
    }
    await _mRecorder.open();
    if (!await _mRecorder.isEncoderSupported(_codec) && kIsWeb) {
      _codec = Opus(AudioFormat.webm);
      _mPath = 'tau_file.webm';
      if (!await _mRecorder.isEncoderSupported(_codec) && kIsWeb) {
        _mRecorderIsInited = true;
        return;
      }
    }
    _mRecorderIsInited = true;
  }

  void _onProgressRecorder(Duration position, double decibels)
  {
    setState(() {
      pos = position.inMilliseconds;
        dbLevel = decibels as double;
    });

  }


  Future<void> init() async {
    await openTheRecorder();
  }

  Future<Uint8List> getAssetData(String path) async {
    var asset = await rootBundle.load(path);
    return asset.buffer.asUint8List();
  }

  // -------  Here is the code to playback  -----------------------

  void record(TauRecorder? recorder) async {
    await recorder!.record(
        from: DefaultInputDevice(),
        to: OutputFile(_mPath, codec: _codec,),
        onProgress: _onProgressRecorder,
        interval: Duration(milliseconds: _mSubscriptionDuration.floor()),
        );
    setState(() {});
  }

  Future<void> stopRecorder(TauRecorder recorder) async {
    await recorder.stop();
  }


  // --------------------- UI -------------------

  Fn? getPlaybackFn(TauRecorder? recorder) {
    if (!_mRecorderIsInited) {
      return null;
    }
    return recorder!.isStopped
        ? () {
            record(recorder);
          }
        : () {
            stopRecorder(recorder).then((value) => setState(() {}));
          };
  }

  @override
  Widget build(BuildContext context) {
    Widget makeBody() {
      //return Column(
      //children: [
      return Container(
        margin: const EdgeInsets.all(3),
        padding: const EdgeInsets.all(3),
        height: 140,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Color(0xFFFAF0E6),
          border: Border.all(
            color: Colors.indigo,
            width: 3,
          ),
        ),
        child: Column(children: [
          Row(children: [
            ElevatedButton(
              onPressed: getPlaybackFn(_mRecorder),
              child: Text(_mRecorder.isRecording ? 'Stop' : 'Record'),
            ),
            SizedBox(
              width: 10,
            ),
            Text(_mRecorder.isRecording ? '' : 'Stopped'),
            SizedBox(
              width: 20,
            ),
            Text('Pos: $pos  dbLevel: ${((dbLevel * 100.0).floor()) / 100}'),
          ]),
          Text('Subscription Duration:'),
          Slider(
            value: _mSubscriptionDuration,
            min: 0.0,
            max: 2000.0,
            onChanged: (double d){
              _mSubscriptionDuration = d;
              setState(() {

              });
            },
            //divisions: 100
          ),
        ]),
        //),
        //],
      );
    }

    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text('Recorder onProgress'),
      ),
      body: makeBody(),
    );
  }
}
