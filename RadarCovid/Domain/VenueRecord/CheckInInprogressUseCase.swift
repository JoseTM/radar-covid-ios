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

protocol CheckInInProgressUseCase {
    func checkStauts() -> Observable<Void>
    var maxCheckInHours: Int { get set }
}

class CheckInInProgressUseCaseImpl: CheckInInProgressUseCase {
    
    private let secondsAnHour = 60 * 60
    
    var maxCheckInHours: Int = 6
    var reminderIntervalHours: Int = 3
    
    private let notificationHandler: NotificationHandler
    private let venueRecordRepository: VenueRecordRepository
    private let appStateHandler: AppStateHandler
    private let qrCheckRepository: QrCheckRepository
    
    init(notificationHandler: NotificationHandler,
         venueRecordRepository: VenueRecordRepository,
         qrCheckRepository: QrCheckRepository,
         appStateHandler: AppStateHandler) {
        self.notificationHandler = notificationHandler
        self.venueRecordRepository = venueRecordRepository
        self.appStateHandler = appStateHandler
        self.qrCheckRepository = qrCheckRepository
    }
    
    func checkStauts() -> Observable<Void> {
        
        venueRecordRepository.getCurrentVenue().flatMap { [weak self] currentVenue -> Observable<Void> in
            guard let self = self else { return .empty() }
            if let currentVenue = currentVenue {
                self.sendReminder(currentVenue)
                return self.checkIfAutoCheckOut(currentVenue)
            }
            return .just(Void())
        }
    }
    
    private func checkIfAutoCheckOut(_ currentVenue: VenueRecord) -> Observable<Void> {
        var editVenue = currentVenue
        
        if appStateHandler.state != .active && isOutdated(venueRecord: currentVenue, interval: maxCheckInHours) {
            return self.venueRecordRepository.removeCurrent().flatMap {  _ -> Observable<Void> in
                editVenue.checkOutDate = Date()
                return self.venueRecordRepository.save(visit: editVenue).map { _ in Void() }
            }
        }
        return .just(Void())
    }
    
    private func sendReminder(_ currentVenue: VenueRecord) {
        let date = qrCheckRepository.getLastReminder()
        if checkIfSendReminder(venueRecord: currentVenue, lastReminder: date) {
            notificationHandler.scheduleCheckInReminderNotification()
        }
    }
        
    private func isOutdated(date: Date, interval: Int) -> Bool {
        date.addingTimeInterval(Double(interval * secondsAnHour)) < Date()
    }
    
    private func isOutdated(venueRecord: VenueRecord, interval: Int) -> Bool {
        isOutdated(date: venueRecord.checkInDate, interval: interval)
    }
        
    private func checkIfSendReminder(venueRecord: VenueRecord, lastReminder: Date?) -> Bool {
        if let lastReminder = lastReminder {
            return isOutdated(date: lastReminder, interval: reminderIntervalHours)
        }
        return isOutdated(venueRecord: venueRecord, interval: reminderIntervalHours)
    }
    
    
}
 
