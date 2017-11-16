//
//  Float+Extension.swift
//  Alzahrani
//
//  Created by Hardwin on 19/06/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation

extension Float {
    var clean: String {
        return self.truncatingRemainder(dividingBy: 2) == 0 ? String(truncatingRemainder(dividingBy: self)) : String(self)
    }
}
