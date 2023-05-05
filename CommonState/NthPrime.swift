//
//  NthPrime.swift
//  CommonState
//
//  Created by Aleksei Sobolevskii on 2023-05-04.
//

import Foundation

public struct NthPrime {
    public var n: Int
    public var prime: Int?

    public init(n: Int, prime: Int? = nil) {
        self.n = n
        self.prime = prime
    }
}

extension NthPrime: Identifiable, Equatable {
    public var id: Int { n }
}
