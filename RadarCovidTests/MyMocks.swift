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
import RxSwift
import UIKit

@testable import Radar_COVID

class MockExpositionInfoRepository: ExpositionInfoRepository {
    
    var expositionInfo: ExpositionInfo?
    var changedToHealthy: Bool?
    
    func getExpositionInfo() -> ExpositionInfo? {
        expositionInfo
    }
    
    func save(expositionInfo: ExpositionInfo) {
        
    }
    
    func clearData() {
        
    }
    
    func resetMock() {
        expositionInfo = nil
        changedToHealthy = nil
    }
    
    func isChangedToHealthy() -> Bool? {
        return changedToHealthy
    }
    
    func setChangedToHealthy(changed: Bool) {
        changedToHealthy = changed
    }
    
}

class MockSettingsRepository: SettingsRepository {
    
    var settings:  Settings?
    
    func getSettings() -> Settings? {
        settings
    }
    
    func save(settings: Settings?) {
       
    }
    func resetMock() {
        settings = nil
    }
    
}

class MockResetDataUseCase : ResetDataUseCase {
    func resetInfectionStatus() -> Observable<Void> {
        .empty()
    }
    
    
    var exposureDaysCalls: Int = 0
    
    func reset() -> Observable<Void> {
        .empty()
    }
    
    func resetExposureDays() -> Observable<Void> {
        exposureDaysCalls += 1
        return .just(())
    }
    
    func resetMock() {
        exposureDaysCalls = 0
    }
    
    
}

class AlertControllerMock: AlertController {
    
    func showAlertOk(title: String, message: String, buttonTitle: String, _ callback: (() -> Void)?) {
        showAlertOkCalls += 1
        self.title = title
        self.message = message
    }
    
    func showAlertCancelContinue(title: NSAttributedString, message: NSAttributedString, buttonOkTitle: String, buttonCancelTitle: String, buttonOkVoiceover: String?, buttonCancelVoiceover: String?, okHandler: (() -> Void)?, cancelHandler: (() -> Void)?) {
    }
    
    func showAlertCancelContinue(title: NSAttributedString, message: NSAttributedString, buttonOkTitle: String, buttonCancelTitle: String, buttonOkVoiceover: String?, buttonCancelVoiceover: String?, okHandler: (() -> Void)?) {

    }
    
    
    var showAlertOkCalls: Int = 0
    
    var title: String?
    var message: String?
    
    
    func resetMock() {
        showAlertOkCalls = 0
        title = nil
        message = nil
    }
    
}

class ErrorRecorderMock: ErrorRecorder {
    var recordCalls: Int = 0
    var error: Error?
    
    func record(error: Error) {
        recordCalls += 1
        self.error = error
    }
    func resetMock() {
        recordCalls = 0
        error = nil
    }
    
}
