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

package xyz.canardoux.tausound;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothProfile;
import android.content.Context;
import android.media.AudioFocusRequest;
import android.media.AudioManager;
import android.os.Build;
import xyz.canardoux.TauNative.*;
import xyz.canardoux.TauNative.Flauto.t_LOG_LEVEL;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;




public abstract class TauSoundSession
{
	int slotNo;

	void init( int slot)
	{
		slotNo = slot;
	}

	abstract TauSoundManager getPlugin ();

	void releaseSession()
	{
		getPlugin().freeSlot(slotNo);
	}

	abstract int getStatus();

	abstract void reset(final MethodCall call, final MethodChannel.Result result);

	void invokeMethodWithString ( String methodName, boolean success, String arg )
	{
		Map<String, Object> dic = new HashMap<String, Object>();
		dic.put ( "slotNo", slotNo );
		dic.put ( "state", getStatus() );
		dic.put ( "arg", arg );
		dic.put ( "success", success );
		getPlugin ().invokeMethod ( methodName, dic );
	}

	void invokeMethodWithDouble ( String methodName, boolean success, double arg )
	{
		Map<String, Object> dic = new HashMap<String, Object> ();
		dic.put ( "slotNo", slotNo );
		dic.put ( "state", getStatus() );
		dic.put ( "arg", arg );
		dic.put ( "success", success );
		getPlugin ().invokeMethod ( methodName, dic );
	}


	void invokeMethodWithInteger ( String methodName, boolean success, int arg )
	{
		Map<String, Object> dic = new HashMap<String, Object> ();
		dic.put ( "slotNo", slotNo );
		dic.put ( "state", getStatus() );
		dic.put ( "arg", arg );
		dic.put ( "success", success );
		getPlugin ().invokeMethod ( methodName, dic );
	}


	void invokeMethodWithBoolean ( String methodName, boolean success, boolean arg )
	{
		Map<String, Object> dic = new HashMap<String, Object> ();
		dic.put ( "slotNo", slotNo );
		dic.put ( "state", getStatus() );
		dic.put ( "arg", arg );
		dic.put ( "success", success );
		getPlugin ().invokeMethod ( methodName, dic );
	}

	void invokeMethodWithMap ( String methodName, boolean success, Map<String, Object>  dic )
	{
		dic.put ( "slotNo", slotNo );
		dic.put ( "state", getStatus() );
		dic.put ( "success", success );
		getPlugin ().invokeMethod ( methodName, dic );
	}

	public void log(xyz.canardoux.TauNative.Flauto.t_LOG_LEVEL level, String msg)
	{
		Map<String, Object> dic = new HashMap<String, Object> ();
		dic.put ( "slotNo", slotNo );
		dic.put ( "state", getStatus() );
		dic.put ( "level", level.ordinal() );
		dic.put ("msg", msg);
		dic.put ( "success", true );
		getPlugin ().invokeMethod ( "log", dic );

	}

}
