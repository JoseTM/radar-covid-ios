//

// Copyright (c) 2020 Gobierno de España
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
// SPDX-License-Identifier: MPL-2.0
//

import Foundation

class UserDefaultsRepository {
    
    private(set) var userDefaults: UserDefaults

    private(set) var encoder = JSONEncoder()
    private(set) var decoder = JSONDecoder()

    init() {
        userDefaults = UserDefaults(suiteName: Bundle.main.bundleIdentifier) ?? UserDefaults.standard
    }
}

