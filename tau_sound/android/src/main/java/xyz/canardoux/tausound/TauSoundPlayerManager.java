package xyz.canardoux.tausound;
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



import android.content.Context;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

class TauSoundPlayerManager extends TauSoundManager
        implements MethodCallHandler
{
        final static String TAG = "FlutterPlayerPlugin";
        static Context            androidContext;
        static TauSoundPlayerManager TauSoundPlayerPlugin; // singleton


        public static void attachFlautoPlayer (
                Context ctx, BinaryMessenger messenger
        )
        {
                if (TauSoundPlayerPlugin == null) {
                        TauSoundPlayerPlugin = new TauSoundPlayerManager();
                }
                MethodChannel channel = new MethodChannel ( messenger, "xyz.canardoux.tau_player" );
                TauSoundPlayerPlugin.init(channel);
                channel.setMethodCallHandler ( TauSoundPlayerPlugin );
                androidContext = ctx;
        }



        TauSoundPlayerManager getManager ()
        {
                return TauSoundPlayerPlugin;
        }

        @Override
        public void onMethodCall ( final MethodCall call, final Result result )
        {
                switch ( call.method )
                {
                        case "resetPlugin":
                        {
                                resetPlugin(call, result);
                                return;
                        }
                }

                TauSoundPlayer aPlayer = (TauSoundPlayer)getSession(call);
                switch ( call.method )
                {
                        case "openPlayer":
                        {
                                //int withUI = call.argument("withUI");
                                aPlayer = new TauSoundPlayer (call );
                                initSession( call, aPlayer);
                                aPlayer.openPlayer ( call, result );

                        }
                        break;

                        case "closePlayer":
                        {
                                aPlayer.closePlayer ( call, result );
                        }
                        break;

                        case "isDecoderSupported":
                        {
                                aPlayer.isDecoderSupported ( call, result );
                        }
                        break;

                        case "setAudioFocus":
                        {
                                aPlayer.setAudioFocus( call, result );
                        }
                        break;


                        case "getPlayerState":
                        {
                                aPlayer.getPlayerState( call, result );
                        }
                        break;

                        case "getResourcePath":
                        {
                                aPlayer.getResourcePath( call, result );
                        }
                        break;


                        case "setUIProgressBar":
                        {
                                aPlayer.setUIProgressBar( call, result );
                        }
                        break;

                        case "nowPlaying":
                        {
                                aPlayer.nowPlaying( call, result );
                        }
                        break;

                        case "getProgress":
                        {
                                aPlayer.getProgress ( call, result );
                        }
                        break;

                        case "startPlayer":
                        {
                                aPlayer.startPlayer ( call, result );
                        }
                        break;

                        case "startPlayerFromMic":
                        {
                                aPlayer.startPlayerFromMic ( call, result );
                        }
                        break;

 
                        case "stopPlayer":
                        {
                                aPlayer.stopPlayer ( call, result );
                        }
                        break;


                        case "pausePlayer":
                        {
                                aPlayer.pausePlayer ( call, result );
                        }
                        break;

                        case "resumePlayer":
                        {
                                aPlayer.resumePlayer ( call, result );
                        }
                        break;

                        case "seekToPlayer":
                        {
                                aPlayer.seekToPlayer ( call, result );
                        }
                        break;

                        case "setVolume":
                        {
                                aPlayer.setVolume ( call, result );
                        }
                        break;

                        case "setSpeed":
                        {
                                aPlayer.setSpeed ( call, result );
                        }
                        break;

                        case "setSubscriptionDuration":
                        {
                                aPlayer.setSubscriptionDuration ( call, result );
                        }
                        break;

                        case "androidAudioFocusRequest":
                        {
                                aPlayer.androidAudioFocusRequest ( call, result );
                        }
                        break;

                        case "setActive":
                        {
                                aPlayer.setActive ( call, result );
                        }
                        break;

                        case "feed":
                        {
                                aPlayer.feed ( call, result );
                        }
                        break;

                        case "setLogLevel":
                        {
                                aPlayer.setLogLevel ( call, result );
                        }
                        break;

                        default:
                        {
                                result.notImplemented ();
                        }
                        break;
                }
        }

}
