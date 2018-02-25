//
//  UserDefaults+Extension.swift
//  TinkoffPoints
//
//  Created by Дмитрий Белоусов on 26.02.2018.
//  Copyright © 2018 Дмитрий Белоусов. All rights reserved.
//

import Foundation


extension UserDefaults
{
    func setPartnersModifyDate(_ date: Date) {
        self.set(date.timeIntervalSince1970, forKey: "partmers_last_modified")
    }
    
    func partnersLastModified() -> Date {
        let timestamp = self.double(forKey: "partmers_last_modified")
        
        return Date(timeIntervalSince1970: timestamp)
    }
}
