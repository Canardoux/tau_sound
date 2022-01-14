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

import android.app.Activity;
import android.content.Context;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;

import xyz.canardoux.TauNative.Flauto;

public class TauSound
	implements FlutterPlugin,
	           ActivityAware
{
	//static Context ctx;
	//static Registrar reg;
	//static Activity androidActivity;
	FlutterPlugin.FlutterPluginBinding pluginBinding;

	@Override
	public void onAttachedToEngine ( FlutterPlugin.FlutterPluginBinding binding )
	{
		this.pluginBinding = binding;
	}


	/**
	 * Plugin registration.
	 */
	public static void registerWith ( Registrar registrar )
	{
		if (registrar.activity() == null) {
			return;
		}
		//reg = registrar;
		Flauto.androidContext = registrar.context ();
		Flauto.androidActivity = registrar.activity ();

		TauSoundPlayerManager.attachFlautoPlayer ( Flauto.androidContext, registrar.messenger () );
		TauSoundRecorderManager.attachFlautoRecorder ( Flauto.androidContext, registrar.messenger ()  );
	}


	@Override
	public void onDetachedFromEngine ( FlutterPlugin.FlutterPluginBinding binding )
	{
	}

	@Override
	public void onDetachedFromActivity ()
	{
	}

	@Override
	public void onReattachedToActivityForConfigChanges (
		@NonNull
			ActivityPluginBinding binding
	                                                   )
	{

	}

	@Override
	public void onDetachedFromActivityForConfigChanges ()
	{

	}

	@Override
	public void onAttachedToActivity (
		@NonNull
			ActivityPluginBinding binding
	                                 )
	{
		Flauto.androidActivity = binding.getActivity ();

		// Only register if activity exists (the application is not running in background)
		Flauto.androidContext = pluginBinding.getApplicationContext ();
		TauSoundPlayerManager.attachFlautoPlayer ( Flauto.androidContext, pluginBinding.getBinaryMessenger () );
		TauSoundRecorderManager.attachFlautoRecorder ( Flauto.androidContext, pluginBinding.getBinaryMessenger () );
	}


}
