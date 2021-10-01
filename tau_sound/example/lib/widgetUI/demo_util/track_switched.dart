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

import 'package:flutter/material.dart';

import 'demo_player_state.dart';

/// UI widget from the TrackPlayer specific settings
/// Allow Tracks and Hush Others
@deprecated
class TrackSwitch extends StatefulWidget {
  final void Function(bool useOSUI) _switchPlayer;

  /// ctor
  const TrackSwitch({
    Key? key,
    required bool isAudioPlayer,
    required void Function(bool userOSUI) switchPlayer,
  })  : _isAudioPlayer = isAudioPlayer,
        _switchPlayer = switchPlayer,
        super(key: key);

  final bool _isAudioPlayer;

  @override
  _TrackSwitchState createState() => _TrackSwitchState();
}

@deprecated
class _TrackSwitchState extends State<TrackSwitch> {
  _TrackSwitchState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Text('Use OS Media Player:'),
          ),
          Switch(
            value: widget._isAudioPlayer,
            onChanged: (allow) =>
                onAudioPlayerSwitchChanged(allowTracks: allow),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Text('Hush Others:'),
          ),
          Switch(
            value: PlayerState().hushOthers!,
            onChanged: (hushOthers) =>
                hushOthersSwitchChanged(hushOthers: hushOthers),
          ),
        ],
      ),
    );
  }

  void onAudioPlayerSwitchChanged({bool allowTracks = false}) async {
    widget._switchPlayer(allowTracks);
  }

  void hushOthersSwitchChanged({bool? hushOthers}) {
    PlayerState().setHush(hushOthers: hushOthers);
  }
}
