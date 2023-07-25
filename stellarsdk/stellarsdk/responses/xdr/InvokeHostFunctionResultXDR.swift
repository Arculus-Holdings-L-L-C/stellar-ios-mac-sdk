//
//  InvokeHostFunctionResultXDR.swift
//  stellarsdk
//
//  Created by Christian Rogobete.
//  Copyright © 2023 Soneso. All rights reserved.
//

import Foundation

public enum InvokeHostFunctionResultCode: Int32 {
    // codes considered as "success" for the operation
    case success = 0 // success
    
    // codes considered as "failure" for the operation
    case malformed = -1
    case trapped = -2
    case resourceLimitExceeded = -3
}

public enum InvokeHostFunctionResultXDR: XDRCodable {
    case success(WrappedData32) // sha256 (InvokeHostFunctionSuccessPreImageXDR)
    case malformed
    case trapped
    case resourceLimitExceeded
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let discriminant = try container.decode(Int32.self)
        let code = InvokeHostFunctionResultCode(rawValue: discriminant)!
        
        switch code {
        case .success:
            let val = try container.decode(WrappedData32.self)
            self = .success(val)
        case .malformed:
            self = .malformed
        case .trapped:
            self = .trapped
        default:
            self = .resourceLimitExceeded
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        switch self {
        case .success(let val):
            try container.encode(val)
        case .malformed:
            break
        case .trapped:
            break
        case .resourceLimitExceeded:
            break
        }
    }
}
