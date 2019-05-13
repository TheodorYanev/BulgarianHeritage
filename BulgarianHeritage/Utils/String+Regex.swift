//
//  String+Regex.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 26.04.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import Foundation

extension String {
    
    func matches(regex: String) -> Bool {
        let regexPredicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return regexPredicate.evaluate(with: self)
    }
    
}
