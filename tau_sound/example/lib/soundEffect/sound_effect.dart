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
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:tau_sound/tau_sound.dart';
import 'package:flutter/services.dart' show rootBundle;

/*
 *
 * ```startPlayerFromStream()``` can be very efficient to play sound effects. For example in a game App.
 * The App open the Audio Session and call ```startPlayerFromStream()``` during initialization.
 * When it want to play a noise, we just call the verb ```feed```
 *
 */

const int _tSampleRate = 44100;
const _bim = 'assets/noises/bim.wav';
const _bam = 'assets/noises/bam.wav';
const _boum = 'assets/noises/boum.wav';

/// Example app.
class SoundEffect extends StatefulWidget {
  @override
  _SoundEffectState createState() => _SoundEffectState();
}

class _SoundEffectState extends State<SoundEffect> {
  TauPlayer? _mPlayer = TauPlayer();
  late bool _mPlayerIsInited;
  Uint8List? bimData;
  Uint8List? bamData;
  Uint8List? boumData;
  bool busy = false;

  Future<Uint8List> getAssetData(String path) async {
    var asset = await rootBundle.load(path);
    return asset.buffer.asUint8List();
  }

  Future<void> init() async {
    var totoController = StreamController<TauFood>();
    await _mPlayer!.open(      from: InputStreamNode(
      totoController.stream,
      codec: Pcm(
        AudioFormat.raw,
        depth: Depth.int16,
        endianness: Endianness.littleEndian,
        nbChannels: NbChannels.mono,
        sampleRate: _tSampleRate,
      ),
    ),
      to: OutputDeviceNode.speaker(),
    );
    bimData = TauHelper().waveToPCMBuffer(
      inputBuffer: await getAssetData(_bim),
    );
    bamData = TauHelper().waveToPCMBuffer(
      inputBuffer: await getAssetData(_bam),
    );
    boumData = TauHelper().waveToPCMBuffer(
      inputBuffer: await getAssetData(_boum),
    );
    await _mPlayer!.play(
    );
  }

  @override
  void initState() {
    super.initState();
    init().then((value) => setState(() {
          _mPlayerIsInited = true;
        }));
  }

  @override
  void dispose() {
    _mPlayer!.stop();
    _mPlayer!.close();
    _mPlayer = null;

    super.dispose();
  }

  void play(Uint8List? data) async {
    if (!busy && _mPlayerIsInited) {
      busy = true;
      await _mPlayer!.feedFromStream(data!).then((value) => busy = false);
    }
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
                onPressed: () {
                  play(bimData);
                },
                //color: Colors.white,
                child: Text('Bim!'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  play(bamData);
                },
                //color: Colors.white,
                child: Text('Bam!'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  play(boumData);
                },
                //color: Colors.white,
                child: Text('Boum!'),
              ),
            ]),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text('Noise Effect'),
      ),
      body: makeBody(),
    );
  }
}
