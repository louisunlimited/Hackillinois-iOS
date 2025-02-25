//
//  HITimeDataSource.swift
//  HackIllinois
//
//  Created by HackIllinois Team on 12/18/19.
//  Copyright © 2019 HackIllinois. All rights reserved.
//  This file is part of the Hackillinois iOS App.
//  The Hackillinois iOS App is open source software, released under the University of
//  Illinois/NCSA Open Source License. You should have received a copy of
//  this license in a file with the distribution.
//

import Foundation
import HIAPI
import os

final class HITimeDataSource {
    static var shared = HITimeDataSource()

    public static let defaultTimes = EventTimes(
        eventStart: Date(timeIntervalSince1970: 1645833600), // Friday, February 25, 2021 6:00:00 PM CST
        eventEnd: Date(timeIntervalSince1970: 1645999200), // Sunday, February 27, 2021 4:00:00 PM CST
        hackStart: Date(timeIntervalSince1970: 1645837200), // Friday, February 25, 2021 7:00:00 PM CST
        hackEnd: Date(timeIntervalSince1970: 1645977600), // Sunday, February 27, 2021 10:00:00 AM CST
        fridayStart: Date(timeIntervalSince1970: 1645768800), // Friday, February 25, 2021 12:00:00 AM CST
        fridayEnd: Date(timeIntervalSince1970: 1645855199), // Friday, February 25, 2021 11:59:59 PM CST
        saturdayStart: Date(timeIntervalSince1970: 1645855200), // Saturday, February 26, 2021 12:00:00 AM CST
        saturdayEnd: Date(timeIntervalSince1970: 1645941599), // Saturday, February 26, 2021 11:59:59 PM CST
        sundayStart: Date(timeIntervalSince1970: 1645941600), // Sunday, February 27, 2021 12:00:00 AM CST
        sundayEnd: Date(timeIntervalSince1970: 1646027999) // Sunday, February 27, 2021 11:59:59 PM CST
    )

    var eventTimes = HITimeDataSource.defaultTimes

    private init() {
        self.updateTimes()
    }

    ///Returns whether times have been updated or not with synchronous api call to get times
    func updateTimes() {
        let semaphore = DispatchSemaphore(value: 0)

        // Update the times of event
        TimeService.getTimes()
            .onCompletion { result in
                do {
                    let (timeContainer, _) = try result.get()
                    self.eventTimes = timeContainer.eventTimes
                } catch {
                    os_log(
                        "Unable to update event times, setting default HackIllinois 2021 times: %s",
                        log: Logger.api,
                        type: .error,
                        String(describing: error)
                    )
                }
                semaphore.signal()
            }
            .launch()

        //Synchronous API call to get times
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
    }
}
