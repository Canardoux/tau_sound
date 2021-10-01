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

// The three interfaces to the platform
// ------------------------------------

/// ------------------------------------------------------------------
/// # The Flutter Sound library
///
/// Flutter Sound is composed with four main modules/classes
/// - [FlutterSound]. This is the main Flutter Sound module.
/// - [FlutterSoundPlayer]. Everything about the playback functions
/// - [FlutterSoundRecorder]. Everything about the recording functions
/// - [FlutterSoundHelper]. Some utilities to manage audio data.
/// And two modules for the Widget UI
/// - [SoundPlayerUI]
/// - [SoundRecorderUI]
/// ------------------------------------------------------------------
//library flutter_sound;

// The interfaces to the platforms specific implementations
// --------------------------------------------------------
//export 'package:flutter_sound_platform_interface/flutter_sound_platform_interface.dart';

/// everything : no documentation
/// @nodoc
library everything;

export 'package:tau_platform_interface/tau_platform_interface.dart';

/// Deprecated
export 'deprecated/flutter_sound_header.dart';
export 'deprecated/flutter_sound_helper.dart';
export 'deprecated/flutter_sound_player.dart';
export 'deprecated/flutter_sound_recorder.dart';

/// Main
///library tau;
export 'public/tau.dart';
export 'public/tau_player.dart';
export 'public/tau_recorder.dart';
export 'public/tau_node.dart';
export 'public/tau_codec.dart';

///
///library UI;
export 'deprecated/ui/recorder_playback_controller.dart';
export 'deprecated/ui/sound_player_ui.dart';
export 'deprecated/ui/sound_recorder_ui.dart';

///
///library util;
export 'public/util/tau_helper.dart';
