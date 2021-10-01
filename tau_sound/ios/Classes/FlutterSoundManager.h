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


//
//  FlautoManager.h
//  Pods
//
//  Created by larpoux on 14/05/2020.
//

#ifndef FlutterSoundManager_h
#define FlutterSoundManager_h

#import <Flutter/Flutter.h>
#import <AVFoundation/AVFoundation.h>
#import <tau_native/Flauto.h>

@interface Session : NSObject
{
      int slotNo;
      BOOL hasFocus;
}

- (void)reset: (FlutterMethodCall*)call result: (FlutterResult)result;
- (int) getStatus;
- (Session*) init: (FlutterMethodCall*)call;
- (void) releaseSession;
- (void)invokeMethod: (NSString*)methodName dico: (NSDictionary*)dico ;
- (void)invokeMethod: (NSString*)methodName stringArg: (NSString*)stringArg success: (bool)success;
- (void)invokeMethod: (NSString*)methodName boolArg: (Boolean)boolArg success: (bool)success;
- (void)invokeMethod: (NSString*)methodName numberArg: (NSNumber*)arg success: (bool)success;
- (BOOL)setAudioFocus: (FlutterMethodCall*)call ;
- (int)getSlotNo;
- (void)freeSlot: (int)slotNo;
- (void)invokeMethod: (NSString*)methodName arguments: (NSDictionary*)call ;
- (void)log: (t_LOG_LEVEL)level msg: (NSString*) msg;


@end


@interface FlutterSoundManager : NSObject <FlutterPlugin>
{
        FlutterMethodChannel* channel;
}

- (Session*)getSession: (FlutterMethodCall*)call;
- (int) initPlugin: (Session*) session call:(FlutterMethodCall*)call;
- (void) resetPlugin: (FlutterMethodCall*)call result: (FlutterResult)result ;



@end



#endif /* FlutterSoundManager_h */
