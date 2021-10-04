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

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tau_sound/tau_sound.dart';
import 'package:just_audio/just_audio.dart';

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

const String _exampleAudioFilePathMP3 =
    'https://file-examples-com.github.io/uploads/2017/11/file_example_MP3_700KB.mp3';

///
typedef Fn = void Function();

/// Example app.
class StreamLoopJustAudio extends StatefulWidget {
  @override
  _StreamLoopJustAudioState createState() => _StreamLoopJustAudioState();
}

class _StreamLoopJustAudioState extends State<StreamLoopJustAudio> {
  TauPlayer? _mPlayer = TauPlayer();
  TauRecorder? _mRecorder = TauRecorder();
  bool _isInited = false;
  StreamController<TauFood> totoStream = StreamController<TauFood>();
  final _player = AudioPlayer();

  Future<void> init() async {
    await _mRecorder!.open(        from: InputDeviceNode.mic(),
        to: OutputStreamNode(
          totoStream.sink,
          codec: Pcm(
            AudioFormat.raw,
            nbChannels: NbChannels.mono,
            endianness: Endianness.littleEndian,
            depth: Depth.int16,
            sampleRate: _sampleRateRecorder,
          ),
        ));
    await _mPlayer!.open(      from: InputStreamNode(totoStream.stream,
        codec: Pcm(AudioFormat.raw,
            depth: Depth.int16,
            endianness: Endianness.littleEndian,
            nbChannels: NbChannels.mono,
            sampleRate: _sampleRatePlayer)),
      to: OutputDeviceNode.speaker(),
    );
    //await _player.setUrl(_exampleAudioFilePathMP3);
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
    );

    await _mRecorder!.record(
);
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

  void justAudio() async {
    await _player.setUrl(_exampleAudioFilePathMP3);
    await _player.play();
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
            child: ElevatedButton(
              onPressed: justAudio,
              //color: Colors.white,
              //disabledColor: Colors.grey,
              child: Text('Just Audio'),
            ),
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
