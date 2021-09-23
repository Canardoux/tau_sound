/*
 * Copyright 2018, 2019, 2020, 2021 Dooboolab.
 *
 * This file is part of Flutter-Sound.
 *
 * Flutter-Sound is free software: you can redistribute it and/or modify
 * it under the terms of the Mozilla Public License version 2 (MPL2.0), as published by
 * the Mozilla organization.
 *
 * Flutter-Sound is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * MPL General Public License for more details.
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'dart:async';
import 'dart:html' as html;

import 'package:meta/meta.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:tau_web/tau_web_player.dart';
import 'package:tau_web/tau_web_recorder.dart';

import 'dart:async';

import 'package:flutter/foundation.dart';



import 'dart:async';
import 'dart:html' as html;

class ImportJsLibraryWeb {
        /// Injects the library by its [url]
        static Future<void> import(String url) {
                return _importJSLibraries([url]);
        }

        static html.ScriptElement _createScriptTag(String library) {
                final html.ScriptElement script = html.ScriptElement()
                        ..type = "text/javascript"
                        ..charset = "utf-8"
                        ..async = true
                //..defer = true
                        ..src = library;
                return script;
        }

        /// Injects a bunch of libraries in the <head> and returns a
        /// Future that resolves when all load.
        static Future<void> _importJSLibraries(List<String> libraries) {
                final List<Future<void>> loading = <Future<void>>[];
                final head = html.querySelector('head')!;

                libraries.forEach((String library) {
                        if (!isImported(library)) {
                                final scriptTag = _createScriptTag(library);
                                head.children.add(scriptTag);
                                loading.add(scriptTag.onLoad.first);
                        }
                });

                return Future.wait(loading);
        }

        static bool _isLoaded(html.Element head, String url) {
                if (url.startsWith("./")) {
                        url = url.replaceFirst("./", "");
                }
                for (var element in head.children) {
                        if (element is html.ScriptElement) {
                                if (element.src.endsWith(url)) {
                                        return true;
                                }
                        }
                }
                return false;
        }

        static bool isImported(String url) {
                final html.Element  head = html.querySelector('head')!;
                return _isLoaded(head, url);
        }
}


class ImportJsLibrary {
        static Future<void> import(String url) {
                if (kIsWeb)
                        return ImportJsLibraryWeb.import(url);
                else
                        return Future.value(null);
        }

        static bool isImported(String url) {
                if (kIsWeb) {
                        return ImportJsLibraryWeb.isImported(url);
                } else {
                        return false;
                }
        }

        static registerWith(dynamic _) {
                // useful for flutter registrar
        }
}

String _libraryUrl(String url, String pluginName) {
        if (url.startsWith("./")) {
                url = url.replaceFirst("./", "");
                return "./assets/packages/$pluginName/$url";
        }
        if (url.startsWith("assets/")) {
                return "./assets/packages/$pluginName/$url";
        } else {
                return url;
        }
}

void importJsLibrary({required String url, required String flutterPluginName}) {
        if (flutterPluginName == null) {
                ImportJsLibrary.import(url);
        } else {
                ImportJsLibrary.import(_libraryUrl(url, flutterPluginName));
        }
}

bool isJsLibraryImported(String url, {required String flutterPluginName}) {
        if (flutterPluginName == null) {
                return ImportJsLibrary.isImported(url);
        } else {
                return ImportJsLibrary.isImported(_libraryUrl(url, flutterPluginName));
        }
}



/// The web implementation of [FlutterSoundRecorderPlatform].
///
/// This class implements the `package:FlutterSoundPlayerPlatform` functionality for the web.
class TauWebPlugin //extends FlutterSoundPlatform
{
        /// Registers this class as the default instance of [FlutterSoundPlatform].
        static void registerWith(Registrar registrar)
        {
                FlutterSoundPlayerWeb.registerWith(registrar);
                FlutterSoundRecorderWeb.registerWith(registrar);
                importJsLibrary(url: "./howler/howler.js", flutterPluginName: "tau_web");
                importJsLibrary(url: "./src/tau_core.js", flutterPluginName: "tau_web");
                importJsLibrary(url: "./src/tau_core_player.js", flutterPluginName: "tau_web");
                importJsLibrary(url: "./src/tau_core_recorder.js", flutterPluginName: "tau_web");

        }
}
