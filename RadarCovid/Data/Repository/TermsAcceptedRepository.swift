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
class TermsAcceptedRepository {
    
    private var userDefaults: UserDefaults
    private let termsAcceptedKey = "UserDefaultsTermsAccepted.accepted"
    private let termsAcceptedVersion = "UserDefaultsTermsAccepted.version"

    
    init() {
        self.userDefaults = UserDefaults.standard
        
    }
    
    private var termsVersion: String {
        get {
            return userDefaults.string(forKey: termsAcceptedVersion)
                ??
                (
                    self.termsAccepted
                        ? "1.0.0"
                        : "0.0.0"
                )
        }
        set (newVal){
            userDefaults.setValue(newVal, forKey: termsAcceptedVersion)
        }
    }
    
    private func versionIsEqualOrMajor() -> Bool {
        let comparision = self.termsVersion.compare(
            (UserDefaultsSettingsRepository().getSettings()?.parameters?.legalTermsVersion ?? "0.0.0")
            , options: .numeric
        )
        return comparision == ComparisonResult.orderedDescending
            || comparision == ComparisonResult.orderedSame
    }
    
    var termsAccepted: Bool {
        get {
            userDefaults.bool(forKey: termsAcceptedKey)
                ? true
                : self.versionIsEqualOrMajor()
        }
        set(newVal) {
            userDefaults.setValue(newVal, forKey: termsAcceptedKey)
            if newVal {
                self.termsVersion = UserDefaultsSettingsRepository().getSettings()?.parameters?.legalTermsVersion ?? "0.0.0"
            }
        }
    }
    
}


