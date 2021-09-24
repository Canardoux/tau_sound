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
class InputBuffer extends InputNode {
  Uint8List inputBuffer;
  /* ctor */ InputBuffer(
    this.inputBuffer, {
    TauCodec? codec,
    TauTrack? track,
  }) {
    this.track = (track != null) ? track : TauTrack();
    this.codec = (codec != null) ? codec : DefaultCodec();
  }

  Future<InputBuffer> toWave() async {
    var pcmCodec = codec as Pcm;
    var buffer = await tauHelper.pcmToWaveBuffer(
        inputBuffer: inputBuffer, codec: pcmCodec);
    return InputBuffer(buffer,
        codec: Pcm(AudioFormat.wav,
            sampleRate: pcmCodec.sampleRate,
            nbChannels: pcmCodec.nbChannels,
            endianness: pcmCodec.endianness,
            depth: pcmCodec.depth));
  }
}

/// An InputFile  is a possible source for a Player playback
class InputFile extends InputNode {
  String uri;
  /* ctor */ InputFile(
    this.uri, {
    TauCodec? codec,
    TauTrack? track,
  }) {
    this.track = (track != null) ? track : TauTrack();
    this.codec = (codec != null) ? codec : DefaultCodec();
  }

  Future<InputFile> toWave() async {
    var pcmCodec = codec as Pcm;
    var tempDir = await getTemporaryDirectory();
    var path = '${tempDir.path}/flutter_sound_tmp.wav';
    await tauHelper.pcmToWave(
      inputFile: uri,
      outputFile: path,
      codec: pcmCodec,
    );
    return InputFile(path,
        codec: Pcm(AudioFormat.wav,
            sampleRate: pcmCodec.sampleRate,
            nbChannels: pcmCodec.nbChannels,
            endianness: pcmCodec.endianness,
            depth: pcmCodec.depth));
  }
}

/// An InputStream is a possible source for a player playback
/// The codec is always RAW-PCM
class InputStream extends InputNode {
  Stream<TauFood> stream;
  /* ctor */ InputStream(this.stream, {Pcm? codec}) {
    this.codec = (codec != null) ? codec : DefaultCodec();
  }
}

/// An InputAsset is a possible source for a player playback
class InputAsset extends InputNode {
  String path;
  /* ctor */ InputAsset(this.path);
}

/// An InputDevice can be the Mic, The Blutooth mic, ...
abstract class InputDevice extends InputNode {
  AudioSource deprecatedAudioSource = AudioSource.defaultSource;
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

/// The defaultInputDevice is a possible source for a player playback
/// The codec is platform dependant
class DefaultInputDevice extends InputDevice {
// Maybe a ctor with the codec
/* ctor */ DefaultInputDevice() {
    deprecatedAudioSource = AudioSource.defaultSource;
  }
}

/// The mic is a possible source for a player playback
/// The codec is platform dependant
class Mic extends InputDevice {
// Maybe a ctor with the codec
/* ctor */ Mic() {
    deprecatedAudioSource = AudioSource.microphone;
  }
}

/// The GeneralInputDevice is a possible source for a player playback
/// The codec is platform dependant
class GeneralInputDevice extends InputDevice {
// Maybe a ctor with the codec
/* ctor */ GeneralInputDevice(AudioSource audioSource) {
    deprecatedAudioSource = audioSource;
  }
}

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
class OutputBuffer extends OutputNode {}

/// An OutputFile is a possible sink for a Recorder
class OutputFile extends OutputNode {
  String uri;
  /* ctor */ OutputFile(this.uri, {TauCodec? codec}) {
    this.codec = (codec != null) ? codec : DefaultCodec();
  }

  Future<OutputFile> toWave() async {
    var pcmCodec = codec as Pcm;
    var tempDir = await getTemporaryDirectory();
    var path = '${tempDir.path}/flutter_sound_tmp.wav';
    await tauHelper.pcmToWave(
      inputFile: uri,
      outputFile: path,
      codec: pcmCodec,
    );
    return OutputFile(path,
        codec: Pcm(AudioFormat.wav,
            sampleRate: pcmCodec.sampleRate,
            nbChannels: pcmCodec.nbChannels,
            endianness: pcmCodec.endianness,
            depth: pcmCodec.depth));
  }
}

/// An OutputStream is a possible sink for a Recorder
/// The codec is always RAW-PCM
class OutputStream extends OutputNode {
  StreamSink<TauFood> stream;
  /* ctor */ OutputStream(this.stream, {Pcm? codec}) {
    this.codec = (codec != null) ? codec : DefaultCodec();
  }
  Pcm? getPcmCodec() => (codec is Pcm) ? codec as Pcm : null;
}

/// A Output Device can be the Speaker, the Ear Phone or a Blue Tooth Headphone
class OutputDevice extends OutputNode {}

/// The DefaultOutputDevice is a possible sink for a Recorder
class DefaultOutputDevice extends OutputDevice {}

/// The Speaker is a possible sink for a Recorder
class Speaker extends OutputDevice {}

/// The Ear phone is a possible sink for a Recorder
class Earphone extends OutputDevice {}

/// The Blue Tooth output device is a possible sink for a Recorder
class HeadPhoneBT extends OutputDevice {}

// ------------------------------------------------------ Filter Node -----------------------------------------------

/// A Filter node is a node with one or two input channels and one or two output channels
class FilterNode extends TauNode {}

/// A Mixer is a node with two input channels and one output channel
class Mixer extends FilterNode {}

/// A Splitter is a node with one input channel and two output channels
class Splitter extends FilterNode {}

/// An equalizer is a node with one input channel and one output channel
class Equalizer extends FilterNode {}

/// A Reverb is a node with one input channel and one output channel
class Reverb extends FilterNode {}

/// An App Filter is a filter implemented inside the Flutter App
class AppFilterNode extends FilterNode {}
