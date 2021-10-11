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

/// Flutter Sound nodes
/// {@category Main}
library node;

import 'dart:async';
import 'dart:core';
import 'dart:typed_data' show Uint8List;
import 'package:tau_platform_interface/tau_recorder_platform_interface.dart';
import 'package:path_provider/path_provider.dart';

import '../tau_sound.dart';

/// Tau nodes
abstract class TauNode {
  TauCodec codec = DefaultCodec();
}

// ------------------------------------------------- Input Node -------------------------------------------------------

/// An InputNode is a node with one output channel and no input channel
abstract class InputNode extends TauNode {
  TauTrack track = TauTrack();
}

/// A Track can be an InputFile or an InputBuffer
class TauTrack {
  String title;
  String author;
  String? albumArtURL;
  String? albumArtAsset;
  String? albumArtFile;
  /* ctor */ TauTrack(
      {this.title = 'A sound from Flutter Sound',
      this.author = 'τ',
      this.albumArtURL,
      this.albumArtAsset,
      this.albumArtFile});
}

/// An InputBuffer is a possible source for a Player playback
class InputBufferNode extends InputNode {
  Uint8List inputBuffer;
  /* ctor */ InputBufferNode(
    this.inputBuffer, {
    TauCodec? codec,
    TauTrack? track,
  }) {
    this.track = (track != null) ? track : TauTrack();
    this.codec = (codec != null) ? codec : DefaultCodec();
  }

  Future<InputBufferNode> toWave() async {
    var pcmCodec = codec as Pcm;
    var buffer = await tauHelper.pcmToWaveBuffer(
        inputBuffer: inputBuffer, codec: pcmCodec);
    return InputBufferNode(buffer,
        codec: Pcm(AudioFormat.wav,
            sampleRate: pcmCodec.sampleRate,
            nbChannels: pcmCodec.nbChannels,
            endianness: pcmCodec.endianness,
            depth: pcmCodec.depth));
  }
}

/// An InputFile  is a possible source for a Player playback
class InputFileNode extends InputNode {
  String uri;
  /* ctor */ InputFileNode(
    this.uri, {
    TauCodec? codec,
    TauTrack? track,
  }) {
    this.track = (track != null) ? track : TauTrack();
    this.codec = (codec != null) ? codec : DefaultCodec();
  }

  Future<InputFileNode> toWave() async {
    var pcmCodec = codec as Pcm;
    var tempDir = await getTemporaryDirectory();
    var path = '${tempDir.path}/flutter_sound_tmp.wav';
    await tauHelper.pcmToWave(
      inputFile: uri,
      outputFile: path,
      codec: pcmCodec,
    );
    return InputFileNode(path,
        codec: Pcm(AudioFormat.wav,
            sampleRate: pcmCodec.sampleRate,
            nbChannels: pcmCodec.nbChannels,
            endianness: pcmCodec.endianness,
            depth: pcmCodec.depth));
  }
}

/// An InputStream is a possible source for a player playback
/// The codec is always RAW-PCM
class InputStreamNode extends InputNode {
  Stream<TauFood> stream;
  /* ctor */ InputStreamNode(this.stream, {Pcm? codec}) {
    this.codec = (codec != null) ? codec : DefaultCodec();
  }
}

/// An InputAsset is a possible source for a player playback
class InputAssetNode extends InputNode {
  String path;
  /* ctor */ InputAssetNode(this.path);
}

/// An InputDevice can be the Mic, The Blutooth mic, ...
class InputDeviceNode extends InputNode {
  InputDeviceNode(AudioSource audioSource) {
    this.audioSource = audioSource;
  }
  AudioSource audioSource = AudioSource.defaultSource;
  InputDeviceNode.mic() {
    audioSource = AudioSource.microphone;
  }
  InputDeviceNode.headsetMic() {
    audioSource = AudioSource.headsetMic;
  }
  InputDeviceNode.defaultSource() {
    audioSource = AudioSource.defaultSource;
  }
}

/*
enum AudioSource {
  defaultSource,
  microphone,
  voiceDownlink, // (it does not work, at least on Android. Probably problems with the authorization )
  camCorder,
  remote_submix,
  unprocessed,
  voice_call,
  voice_communication,
  voice_performance,
  voice_recognition,
  voiceUpLink,// (it does not work, at least on Android. Probably problems with the authorization )
  bluetoothHFP,
  headsetMic,
  lineIn,
}
*/
/// A sound generator is a possible source for a player playback
class SoundGenerator extends InputNode {
// TODO
}

/// A Sequencer is a possible source for a player playback
class Sequencer extends InputNode {
// TODO
}

// --------------------------------------------------- Output Node -------------------------------------------------------

/// An InputNode is a node with one input channel and no output channel
class OutputNode extends TauNode {}

/// An OutputBuffer is a possible sink for a Recorder
class OutputBufferNode extends OutputNode {}

/// An OutputFile is a possible sink for a Recorder
class OutputFileNode extends OutputNode {
  String uri;
  /* ctor */ OutputFileNode(this.uri, {TauCodec? codec}) {
    this.codec = (codec != null) ? codec : DefaultCodec();
  }

  Future<OutputFileNode> toWave() async {
    var pcmCodec = codec as Pcm;
    var tempDir = await getTemporaryDirectory();
    var path = '${tempDir.path}/flutter_sound_tmp.wav';
    await tauHelper.pcmToWave(
      inputFile: uri,
      outputFile: path,
      codec: pcmCodec,
    );
    return OutputFileNode(path,
        codec: Pcm(AudioFormat.wav,
            sampleRate: pcmCodec.sampleRate,
            nbChannels: pcmCodec.nbChannels,
            endianness: pcmCodec.endianness,
            depth: pcmCodec.depth));
  }
}

/// An OutputStream is a possible sink for a Recorder
/// The codec is always RAW-PCM
class OutputStreamNode extends OutputNode {
  StreamSink<TauFood> stream;
  /* ctor */ OutputStreamNode(this.stream, {Pcm? codec}) {
    this.codec = (codec != null) ? codec : DefaultCodec();
  }
  Pcm? getPcmCodec() => (codec is Pcm) ? codec as Pcm : null;
}

/*

// Audio Flags
// -----------
const outputToSpeaker = 1;
const allowHeadset = 2;
const allowEarPiece = 4;
const allowBlueTooth = 8;
const allowAirPlay = 16;
const allowBlueToothA2DP = 32;

 */

/// A Output Device can be the Speaker, the Ear Phone or a Blue Tooth Headphone
class OutputDeviceNode extends OutputNode {
  int audioFlags = outputToSpeaker;
  OutputDeviceNode(int audioFlags) {
    this.audioFlags = audioFlags;
  }
  OutputDeviceNode.speaker() {
    audioFlags = outputToSpeaker;
  }
  OutputDeviceNode.headSet() {
    audioFlags = outputToSpeaker | allowHeadset;
  }
  OutputDeviceNode.blueToothA2DP() {
    audioFlags = outputToSpeaker | allowHeadset | allowBlueToothA2DP;
  }
  OutputDeviceNode.any() {
    audioFlags =
        outputToSpeaker | allowHeadset | allowBlueToothA2DP | allowAirPlay;
  }
}

// ------------------------------------------------------ Filter Node -----------------------------------------------

/// A Filter node is a node with one or two input channels and one or two output channels
class PassThrewNode extends TauNode {}

/// A Mixer is a node with two input channels and one output channel
class Mixer extends PassThrewNode {}

/// A Splitter is a node with one input channel and two output channels
class Splitter extends PassThrewNode {}

/// An equalizer is a node with one input channel and one output channel
class Equalizer extends PassThrewNode {}

/// A Reverb is a node with one input channel and one output channel
class Reverb extends PassThrewNode {}

/// An App Filter is a filter implemented inside the Flutter App
class AppFilterNode extends PassThrewNode {}

/// An encoder is a filter
class EncoderNode extends PassThrewNode {}

/// A decoder is a filter
class DecoderNode extends PassThrewNode {}
