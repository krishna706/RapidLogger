//  RapidLogger.m
//
//  Created by RadhaKrishna on 24/05/16.
//  Copyright © 2016 Radha. All rights reserved.

import Foundation

func print(_ items: Any..., separator:String = " ", terminator:String = "\n") {
    let outPut = items.map {"\($0)"}.joined(separator: separator)
    RapidLogger.sharedController().printLog(outPut)
    NSLog("\(outPut)")
}
