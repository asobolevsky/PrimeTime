//
//  Utils.swift
//  CommonState
//
//  Created by Aleksei Sobolevskii on 2023-05-04.
//

import Foundation

public func ordinal(_ n: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .ordinal
    return formatter.string(for: n) ?? ""
}
