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

/*
 *
 * ```streamLoop()``` is a very simple example which connect the TauRecorder sink
 * to the TauPlayer Stream.
 * Of course, we do not play to the loudspeaker to avoid a very unpleasant Larsen effect.
 * This example does not use a new StreamController, but use directly `foodStreamController`
 * from flutter_sound_player.dart.
 *
 */

const int _sampleRateRecorder = 48000;
const int _sampleRatePlayer = 48000; // same speed than the recorder

///
typedef Fn = void Function();

/// Example app.
class StreamLoop extends StatefulWidget {
  @override
  _StreamLoopState createState() => _StreamLoopState();
}

class _StreamLoopState extends State<StreamLoop> {
  TauPlayer? _mPlayer = TauPlayer();
  TauRecorder? _mRecorder = TauRecorder();
  bool _isInited = false;
  StreamController<TauFood> totoStream = StreamController<TauFood>();

  Future<void> init() async {
    await _mRecorder!.open();
    await _mPlayer!.open();
  }

  @override
  void initState() {
    super.initState();
    // Be careful : openAudioSession return a Future.
    // Do not access your TauPlayer or TauRecorder before the completion of the Future
    init().then((value) {
      setState(() {
        _isInited = true;
      });
    });
  }

  Future<void> release() async {
    await stopPlayer();
    await _mPlayer!.close();
    _mPlayer = null;

    await stopRecorder();
    await _mRecorder!.close();
    _mRecorder = null;
  }

  @override
  void dispose() {
    release();
    super.dispose();
  }

  Future<void>? stopRecorder() {
    if (_mRecorder != null) {
      return _mRecorder!.stop();
    }
    return null;
  }

  Future<void>? stopPlayer() {
    if (_mPlayer != null) {
      return _mPlayer!.stop();
    }
    return null;
  }

  Future<void> record() async {
    totoStream = StreamController<TauFood>();
    await _mPlayer!.play(
      from: InputStream(totoStream.stream, codec: Pcm(AudioFormat.raw, depth: Depth.int16, endianness: Endianness.littleEndian, nbChannels: NbChannels.mono, sampleRate: _sampleRatePlayer)),
      to: DefaultOutputDevice(),
    );

    await _mRecorder!.record(from: DefaultInputDevice(), to: OutputStream(totoStream.sink, codec: Pcm(AudioFormat.raw, nbChannels: NbChannels.mono, endianness: Endianness.littleEndian, depth: Depth.int16, sampleRate: _sampleRateRecorder, ), ) );
    setState(() {});
  }

  Future<void> stop() async {
    if (_mRecorder != null) {
      await _mRecorder!.stop();
    }
    if (_mPlayer != null) {
      await _mPlayer!.stop();
    }
    setState(() {});
  }

  Fn? getRecFn() {
    if (!_isInited) {
      return null;
    }
    return _mRecorder!.isRecording ? stop : record;
  }

  // ----------------------------------------------------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    Widget makeBody() {
      return Column(
        children: [
          Container(
            margin: const EdgeInsets.all(3),
            padding: const EdgeInsets.all(3),
            height: 80,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color(0xFFFAF0E6),
              border: Border.all(
                color: Colors.indigo,
                width: 3,
              ),
            ),
            child: Row(children: [
              ElevatedButton(
                onPressed: getRecFn(),
                //color: Colors.white,
                //disabledColor: Colors.grey,
                child: Text(_mRecorder!.isRecording ? 'Stop' : 'Record'),
              ),
              SizedBox(
                width: 20,
              ),
              Text(_mRecorder!.isRecording
                  ? 'Playback to your headset!'
                  : 'Recorder is stopped'),
            ]),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text('Stream Loop'),
      ),
      body: makeBody(),
    );
  }
}
