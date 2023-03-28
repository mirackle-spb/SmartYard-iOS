//
//  ResetCodeResponseData.swift
//  SmartYard
//
//  Created by admin on 25/02/2020.
//  Copyright © 2021 LanTa. All rights reserved.
//

struct ResetCodeResponseData: Decodable {
    
    let code: Int

    private enum CodingKeys: String, CodingKey {
        case code
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        code = (try? container.decode(String.self, forKey: .code).int) ?? -1
       
    }
}
