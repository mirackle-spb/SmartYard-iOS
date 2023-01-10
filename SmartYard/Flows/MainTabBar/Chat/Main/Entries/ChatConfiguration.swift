//
//  ChatConfiguration.swift
//  SmartYard
//
//  Created by admin on 31/03/2020.
//  Copyright © 2021 LanTa. All rights reserved.
//

struct ChatConfiguration: Equatable {
    
    let id = AccessService.shared.chatId
    let domain = AccessService.shared.chatDomain
    
    let language: String?
    let clientId: String?
    
}
