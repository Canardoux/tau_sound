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

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:tau_sound/tau_sound.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'demo_active_codec.dart';
/*
 * Copyright 2018, 2019, 2020 Dooboolab.
 *
 * This file is part of Flutter-Sound.
 *
 * Flutter-Sound is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3, as published by
 * the Free Software Foundation.
 *
 * Flutter-Sound is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Flutter-Sound.  If not, see <https://www.gnu.org/licenses/>.
 */
import 'demo_common.dart';

///
@deprecated
class AssetPlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SoundPlayerUI.fromLoader(
      (_) => createAssetTrack(),
      showTitle: true,
      audioFocus: AudioFocus.requestFocusAndDuckOthers,
    );
  }

  ///
  Future<Track> createAssetTrack() async {
    Track track;
    var dataBuffer =
        (await rootBundle.load(assetSample[ActiveCodec().codec!.index]))
            .buffer
            .asUint8List();
    track = Track(
      dataBuffer: dataBuffer,
      codec: ActiveCodec().codec!,
    );

    track.trackTitle = 'Asset playback.';
    track.trackAuthor = 'By flutter_sound';

    if (kIsWeb) {
      track.albumArtAsset = null;
    } else if (Platform.isIOS) {
      track.albumArtAsset = 'AppIcon';
    } else if (Platform.isAndroid) {
      track.albumArtAsset = 'AppIcon.png';
    }
    return track;
  }
}
