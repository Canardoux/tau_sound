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

import 'package:tau_sound/tau_sound.dart';

/// Factory used to track what codec is currently selected.
@deprecated
class ActiveCodec {
  static final ActiveCodec _self = ActiveCodec._internal();

  Codec? _codec = Codec.aacADTS;
  bool? _encoderSupported = false;
  bool _decoderSupported = false;

  ///
  FlutterSoundRecorder? recorderModule;

  /// Factory to access the active codec.
  factory ActiveCodec() {
    return _self;
  }
  ActiveCodec._internal();

  /// Set the active code for the the recording and player modules.
  void setCodec({required bool withUI, Codec? codec}) async {
    var player = FlutterSoundPlayer();
    if (withUI) {
      await player.openAudioSession(
          focus: AudioFocus.requestFocusAndDuckOthers, withUI: true);
      _encoderSupported = await recorderModule!.isEncoderSupported(codec!);
      _decoderSupported = await player.isDecoderSupported(codec);
    } else {
      await player.openAudioSession(
          focus: AudioFocus.requestFocusAndDuckOthers);
      _encoderSupported = await recorderModule!.isEncoderSupported(codec!);
      _decoderSupported = await player.isDecoderSupported(codec);
    }
    _codec = codec;
  }

  /// `true` if the active coded is supported by the recorder
  bool? get encoderSupported => _encoderSupported;

  /// `true` if the active coded is supported by the player
  bool get decoderSupported => _decoderSupported;

  /// returns the active codec.
  Codec? get codec => _codec;
}
