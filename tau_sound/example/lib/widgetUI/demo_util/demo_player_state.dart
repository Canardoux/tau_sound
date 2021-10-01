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

/// Used to track the players state.
@deprecated
class PlayerState {
  static final PlayerState _self = PlayerState._internal();

  bool? _hushOthers = false;

  /// factory to retrieve a PlayerState
  factory PlayerState() {
    return _self;
  }

  PlayerState._internal();

  /// returns `true` if hushOthers (reduce other players volume)
  /// is enabled.
  bool? get hushOthers => _hushOthers;

  /// When we play something during whilst other audio is playing
  ///
  /// E.g. if Spotify is playing
  /// We can:
  // Stop Spotify
  // Play both our sound and Spotify
  // Or lower Spotify Sound during our playback.
  /// [setHush] controls option three.
  /// When passsing `true` to [setHush] the other auidio
  /// player's (e.g. spotify) sound is lowered.
  ///
  Future<void> setHush({bool? hushOthers}) async {
    _hushOthers = hushOthers;
  }
}
