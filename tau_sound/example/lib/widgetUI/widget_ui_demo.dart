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

import 'demo_util/demo3_body.dart';

// If you update the following test, please update also the Examples/README.md file and the comment inside the dart file.
/*
 * This is a Demo of an App which uses the Flutter Sound UI Widgets.
 *
 * My own feeling is that this Demo is really too much complicated for doing something very simple.
 * There is too many dependencies and too many sources.
 *
 * I really hope that someone will write soon another simpler Demo App.
 */

/// Example app.
@deprecated
class WidgetUIDemo extends StatefulWidget {
  @override
  _WidgetUIDemoState createState() => _WidgetUIDemoState();
}

@deprecated
class _WidgetUIDemoState extends State<WidgetUIDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text('Widget UI Demo'),
      ),
      body: MainBody(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
