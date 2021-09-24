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

/// -----------------------------------------------------------------
/// This header file is deprecated.
/// It is replaced by file `tau.dart`
/// -----------------------------------------------------------------

/// For internal code. Do not use.
///
/// The possible states of the players and recorders
/// @nodoc
@deprecated
enum Initialized {
  /// The object has been created but is not initialized
  notInitialized,

  /// The object is initialized and can be fully used
  fullyInitialized,
}
