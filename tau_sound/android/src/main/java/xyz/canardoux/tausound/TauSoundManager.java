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

import java.util.ArrayList;
import java.util.List;

import io.flutter.plugin.common.MethodChannel;

import java.util.Map;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.Result;


public class TauSoundManager
{
	public MethodChannel            channel;
	public List<TauSoundSession> slots;

	void init(MethodChannel aChannel)
	{
		if ( slots == null ) {
			slots = new ArrayList<TauSoundSession>();
		}
		channel = aChannel;
	}


	void invokeMethod ( String methodName, Map dic )
	{
		channel.invokeMethod ( methodName, dic );
	}

	void freeSlot ( int slotNo )
	{
		slots.set ( slotNo, null );
	}


	public TauSoundSession getSession(final MethodCall call)
	{
		int slotNo = call.argument ( "slotNo" );
		if ( ( slotNo < 0 ) || ( slotNo > slots.size () ) )
			throw new RuntimeException();

		if ( slotNo == slots.size () )
		{
			slots.add ( slotNo, null );
		}

		return slots.get ( slotNo );
	}

	public void initSession( final MethodCall call, TauSoundSession aPlayer)
	{
		int slot =  call.argument ( "slotNo" );
		slots.set ( slot, aPlayer );
		aPlayer.init( slot );
	}

	public void resetPlugin( final MethodCall call, final Result result )
	{
		for (int i = 0; i < slots.size () ; ++i)
		{
			if (slots.get ( i ) != null)
			{
				slots.get ( i ).reset(call, result);
			}
			slots   = new ArrayList<TauSoundSession>();
		}
		result.success(0);
	}

}
