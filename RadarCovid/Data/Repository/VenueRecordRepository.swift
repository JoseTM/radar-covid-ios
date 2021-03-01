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

protocol VenueRecordRepository {
    func getCurrentVenue() -> Observable<VenueRecord?>
    func save(current: VenueRecord) -> Observable<VenueRecord>
    func getVisited()-> Observable<[VenueRecord]?>
    func save(visit: VenueRecord) -> Observable<VenueRecord>
    func removeVisited() -> Observable<Void>
    func removeCurrent() -> Observable<Void>
}

class KeyStoreVenueRecordRepository : KeyStoreRepository, VenueRecordRepository {

    private static let kCurrentVenueKey = KeychainKey(key: "UserDefaultsVenueRecordRepository.currentVenue", type: VenueRecord.self)
    
    private static let kVisitedList = KeychainKey(key: "UserDefaultsVenueRecordRepository.currentVenue", type: [VenueRecord].self)
    
    
    func getCurrentVenue() -> Observable<VenueRecord?> {
        get(key: KeyStoreVenueRecordRepository.kCurrentVenueKey)
    }
    
    func save(current: VenueRecord) -> Observable<VenueRecord> {
        save(key: KeyStoreVenueRecordRepository.kCurrentVenueKey, value: current)
    }
    
    func removeCurrent() -> Observable<Void> {
        delete(key: KeyStoreVenueRecordRepository.kCurrentVenueKey)
    }
    
    func getVisited() -> Observable<[VenueRecord]?> {
        get(key: KeyStoreVenueRecordRepository.kVisitedList)
    }
    
    func save(visit: VenueRecord) -> Observable<VenueRecord> {
        getVisited().flatMap { [weak self] visited -> Observable<VenueRecord>in
            var visited = visited ?? []
            visited.append(visit)
            return self?.save(key: KeyStoreVenueRecordRepository.kVisitedList, value: visited)
                .map { _ in visit } ?? .empty()
        }
    }
    
    func removeVisited() -> Observable<Void> {
        delete(key: KeyStoreVenueRecordRepository.kVisitedList)
    }
    
    
}
