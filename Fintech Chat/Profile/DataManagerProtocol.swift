//
//  DataManagerProtocol.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 15/10/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import UIKit

protocol DataManager {
    func saveUserInfo(_ userInfo: UserInfo, to fileURL: URL, completion: @escaping (Error?) -> (Void))
    func loadUserInfo(from url: URL, completion: @escaping (Error?, String?, String?, String?) -> (Void))
}
