//
//  Date+Extensions.swift
//  FellowBloggerV2
//
//  Created by Jian Ting Li on 3/13/19.
//  Copyright © 2019 Jian Ting Li. All rights reserved.
//

import Foundation

extension Date {
    // get an ISO timestamp
    static func getISOTimestamp() -> String {
        let isoDateFormatter = ISO8601DateFormatter()
        let timestamp = isoDateFormatter.string(from: Date())
        return timestamp
    }
}
