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


class TauSoundRecorderManager extends TauSoundManager
        implements MethodCallHandler
{

        static Context              androidContext;
        static TauSoundRecorderManager TauSoundRecorderPlugin; // singleton


        static final String ERR_UNKNOWN               = "ERR_UNKNOWN";
        static final String ERR_RECORDER_IS_NULL      = "ERR_RECORDER_IS_NULL";
        static final String ERR_RECORDER_IS_RECORDING = "ERR_RECORDER_IS_RECORDING";


        public static void attachFlautoRecorder ( Context ctx, BinaryMessenger messenger )
        {
                if (TauSoundRecorderPlugin == null) {
                        TauSoundRecorderPlugin = new TauSoundRecorderManager();
                }
                MethodChannel channel = new MethodChannel ( messenger, "xyz.canardoux.tau_recorder" );
                TauSoundRecorderPlugin.init( channel);
                channel.setMethodCallHandler ( TauSoundRecorderPlugin );
                androidContext = ctx;
        }



        TauSoundRecorderManager getManager ()
        {
                return TauSoundRecorderPlugin;
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

                TauSoundRecorder aRecorder = (TauSoundRecorder) getSession( call);
                switch ( call.method )
                {
                        case "openRecorder":
                        {
                                aRecorder = new TauSoundRecorder ( call );
                                initSession( call, aRecorder );
                                aRecorder.openRecorder ( call, result );
                        }
                        break;

                        case "closeRecorder":
                        {
                                aRecorder.closeRecorder ( call, result );
                        }
                        break;

                        case "isEncoderSupported":
                        {
                                aRecorder.isEncoderSupported ( call, result );
                        }
                        break;

                        case "setAudioFocus":
                        {
                                aRecorder.setAudioFocus( call, result );
                        }
                        break;

                        case "startRecorder":
                        {
                                aRecorder.startRecorder ( call, result );
                        }
                        break;

                        case "stopRecorder":
                        {
                                aRecorder.stopRecorder ( call, result );
                        }
                        break;


                        case "setSubscriptionDuration":
                        {
                                aRecorder.setSubscriptionDuration ( call, result );
                        }
                        break;

                        case "pauseRecorder":
                        {
                                aRecorder.pauseRecorder ( call, result );
                        }
                        break;


                        case "resumeRecorder":
                        {
                                aRecorder.resumeRecorder ( call, result );
                        }
                        break;

                        case "getRecordURL":
                        {
                                aRecorder.getRecordURL ( call, result );
                        }
                        break;

                        case "deleteRecord":
                        {
                                aRecorder.deleteRecord ( call, result );
                        }
                        break;

                        case "setLogLevel":
                        {
                                aRecorder.setLogLevel ( call, result );
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


