//
//  Utils.swift
//  PrimeTime
//
//  Created by Aleksei Sobolevskii on 2023-04-20.
//

import Foundation

func ordinal(_ n: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .ordinal
    return formatter.string(for: n) ?? ""
}
