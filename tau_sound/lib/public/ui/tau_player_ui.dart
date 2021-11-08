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
import 'package:tau_sound_lite/tau_sound.dart';

///
///
/// {@category UI_Widgets}
class TauPlayerUI extends StatefulWidget {
  /// An onpened TauPlayer
  final TauPlayer player;

  /// If you want to have speed selector, you should pass a list of
  /// speeds the player can use, the first value of the list should be the normal player speed.
  final List<double>? speeds;

  /// If you are using LITE version, TauPlayer will only show the audio
  /// duration after you start the player, if you know the exactly audio duration
  /// in ms, you can pass it in this param, the player will start showing the time
  /// duration coverted to minutes and seconds.
  final Duration? duration;

  /// The default time in Duration in which player will
  /// update its slider and timer progress. Default is 500ms.
  final Duration? playerRefreshDuration;

  /// The Play/Pause icon size. Default is 45.
  final double? iconSize;

  /// The Play/Pause icon color. Default is your app primary color.
  final Color? playPauseColor;

  /// When this is set to true, player will always show
  /// the button to change audio speed. Default is false, speed control will only
  /// appear when the player is in playing state.
  final bool alwaysShowPlayerSpeed;

  /// Customize the slider any way you want by passing a
  /// SliderThemeData in this parameter
  final SliderThemeData? sliderThemeData;

  /// A callback from TauPlayerUI that notifies when user changed the player speed
  final Function(double speed)? onSpeedChanged;

  /// The play/pause onTap function, here you control what the player
  /// should do when user press the play/pause button.
  final Future<void> Function(TauPlayer tauPlayer) onTap;

  /// A callback from TauPlayerUI that notifies when user clicks in the Slider to change actual audio position
  final Function(double position)? onPositionChanged;

  /// A Flag to set if player should show progressbar or not, default is TRUE
  final bool? showProgressBar;

  /// Style for player position label
  final TextStyle? playerPositionTextStyle;

  /// Style for player duration label
  final TextStyle? playerDurationTextStyle;

  ///
  ///
  ///
  const TauPlayerUI({
    required this.player,
    required this.onTap,
    this.onSpeedChanged,
    this.onPositionChanged,
    this.showProgressBar = true,
    this.playerDurationTextStyle,
    this.playerPositionTextStyle,
    this.iconSize = 45,
    this.playerRefreshDuration = const Duration(milliseconds: 500),
    this.playPauseColor,
    this.alwaysShowPlayerSpeed = false,
    this.speeds,
    this.duration,
    this.sliderThemeData,
    Key? key,
  }) : super(key: key);

  ///
  ///
  ///
  @override
  _TauPlayerUIState createState() => _TauPlayerUIState();
}

///
///
///
class _TauPlayerUIState extends State<TauPlayerUI>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Duration? _actualPlayerPosition;
  Duration? _audioDuration;
  double? _actualSpeed;
  int _speedIndex = 0;

  ///
  ///
  ///
  @override
  void initState() {
    super.initState();
    if (!widget.player.isOpen) {
      throw Exception('Player must be open before build TauPlayerUI');
    }

    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));

    _audioDuration = widget.duration;
    widget.player.setSubscriptionDuration(widget.playerRefreshDuration!);

    if (widget.speeds != null && widget.speeds!.isNotEmpty) {
      _actualSpeed = widget.speeds![_speedIndex];
    }
    widget.player.onPlayerStateChanged.listen((event) {
      switch (event) {
        case PlayerState.isStopped:
        case PlayerState.isPaused:
          _animationController!.reverse();
          break;
        case PlayerState.isPlaying:
        default:
          _animationController!.forward();
          break;
      }
    });
  }

  ///
  ///
  ///
  @override
  void reassemble() {
    super.reassemble();
    widget.player.stop();
  }

  ///
  ///
  ///
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlaybackDisposition>(
      stream: widget.player.onProgress,
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          _audioDuration = snapshot.data!.duration;
          _actualPlayerPosition = snapshot.data!.position;
        }

        return Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Material(
              color: Colors.transparent,
              shape: CircleBorder(),
              child: InkWell(
                onTap: () async {
                  await widget.onTap(widget.player);
                },
                child: AnimatedIcon(
                  icon: AnimatedIcons.play_pause,
                  progress: _animationController!,
                  size: widget.iconSize ?? 45,
                  color:
                      widget.playPauseColor ?? Theme.of(context).primaryColor,
                ),
              ),
            ),
            if (widget.showProgressBar! &&
                (snapshot.data != null &&
                    !snapshot.data!.duration.inMilliseconds.isNegative))
              Expanded(
                child: Theme(
                  data: ThemeData(
                    sliderTheme: widget.sliderThemeData ??
                        SliderThemeData(
                          trackHeight: 5,
                          thumbColor: Theme.of(context).primaryColor,
                          activeTrackColor:
                              Theme.of(context).toggleableActiveColor,
                          inactiveTrackColor:
                              Theme.of(context).unselectedWidgetColor,
                        ),
                  ),
                  child: _audioDuration != null &&
                          _audioDuration!.inMilliseconds > 0
                      ? Slider.adaptive(
                          value: _actualPlayerPosition == null
                              ? 0.0
                              : _actualPlayerPosition!.inMilliseconds
                                  .toDouble(),
                          max: _audioDuration == null
                              ? 0
                              : _audioDuration!.inMilliseconds.toDouble(),
                          onChanged: _onChanged,
                          onChangeStart: _onChanged,
                          onChangeEnd: _onChanged,
                        )
                      : SizedBox(),
                ),
              ),
            if (widget.speeds != null && widget.speeds!.isNotEmpty)
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: widget.alwaysShowPlayerSpeed
                    ? 35
                    : widget.player.isPlaying
                        ? 35
                        : 0,
                padding: EdgeInsets.zero,
                margin: EdgeInsets.zero,
                curve: Curves.easeIn,
                child: ElevatedButton(
                  onPressed: () {
                    _speedIndex++;
                    if (_speedIndex == widget.speeds!.length) {
                      _speedIndex = 0;
                    }
                    _actualSpeed = widget.speeds![_speedIndex];
                    widget.player.setSpeed(_actualSpeed!);
                    if (widget.onSpeedChanged != null) {
                      widget.onSpeedChanged!(_actualSpeed!);
                    }
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.zero,
                  ),
                  child: FittedBox(
                    child: Text(
                      '${_actualSpeed}x',
                    ),
                  ),
                ),
              ),
            SizedBox(
              width: 10,
            ),
            if (_audioDuration != null && _audioDuration!.inMilliseconds > 0)
              Column(
                children: <Widget>[
                  Text(
                    '${_convertDurationToTime(snapshot.data?.position)}',
                    style: widget.playerPositionTextStyle,
                  ),
                  Text(
                    '${_convertDurationToTime(_audioDuration)}',
                    style: widget.playerDurationTextStyle,
                  )
                ],
              )
            else if (snapshot.data != null &&
                snapshot.data!.position.inSeconds > 0)
              Text(
                _convertDurationToTime(snapshot.data?.position),
                style: widget.playerPositionTextStyle,
              )
          ],
        );
      },
    );
  }

  void _onChanged(double position) {
    setState(() {
      _actualPlayerPosition = Duration(
        milliseconds: position.toInt(),
      );
      widget.player.seekTo(
        _actualPlayerPosition!,
      );
    });
    if (widget.onPositionChanged != null) {
      widget.onPositionChanged!(position);
    }
  }

  ///
  ///
  ///
  String _convertDurationToTime(Duration? duration) {
    if (duration == null) {
      return '00:00';
    }
    var minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    var seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
