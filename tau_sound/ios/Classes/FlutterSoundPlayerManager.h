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


#ifndef FlutterSoundPlayerManager_h
#define FlutterSoundPlayerManager_h

#import "FlutterSoundManager.h"

extern void FlutterSoundPlayerReg(NSObject<FlutterPluginRegistrar>* registrar);

@interface FlutterSoundPlayerManager : FlutterSoundManager 
{
}
extern FlutterSoundPlayerManager* flutterSoundPlayerManager; // Singleton

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar;
- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result;

@end

#endif //FlutterSoundPlayerManager_h 
