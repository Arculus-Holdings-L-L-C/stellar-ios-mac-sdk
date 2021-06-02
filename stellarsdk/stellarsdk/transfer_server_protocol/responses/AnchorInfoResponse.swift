//
//  AnchorInfoResponse.swift
//  stellarsdk
//
//  Created by Razvan Chelemen on 08/09/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public struct AnchorInfoResponse: Decodable {

    public var deposit: [String:DepositAsset]
    public var withdraw: [String:WithdrawAsset]
    public var transactions: AnchorTransactionsInfo
    public var transaction: AnchorTransactionInfo?
    public var fee: AnchorFeeInfo?
    
    /// Properties to encode and decode
    private enum CodingKeys: String, CodingKey {
        case deposit = "deposit"
        case withdraw = "withdraw"
        case transactions = "transactions"
        case transaction = "transaction"
        case fee = "fee"
    }
    
    /**
     Initializer - creates a new instance by decoding from the given decoder.
     
     - Parameter decoder: The decoder containing the data
     */
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        deposit = try values.decode([String:DepositAsset].self, forKey: .deposit)
        withdraw = try values.decode([String:WithdrawAsset].self, forKey: .withdraw)
        transactions = try values.decode(AnchorTransactionsInfo.self, forKey: .transactions)
        transaction = try values.decodeIfPresent(AnchorTransactionInfo.self, forKey: .transaction)
        fee = try values.decodeIfPresent(AnchorFeeInfo.self, forKey: .fee)
    }
    
}

public struct DepositAsset: Decodable {
    
    public var enabled: Bool
    public var feeFixed: Double
    public var feePercent: Double
    public var fields: [String:AnchorField]?
    
    /// Properties to encode and decode
    private enum CodingKeys: String, CodingKey {
        case enabled = "enabled"
        case feeFixed = "fee_fixed"
        case feePercent = "fee_percent"
        case fields = "fields"
    }
    
    /**
     Initializer - creates a new instance by decoding from the given decoder.
     
     - Parameter decoder: The decoder containing the data
     */
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        enabled = try values.decode(Bool.self, forKey: .enabled)
        feeFixed = try values.decode(Double.self, forKey: .feeFixed)
        feePercent = try values.decode(Double.self, forKey: .feePercent)
        fields = try values.decodeIfPresent([String:AnchorField].self, forKey: .fields)
    }
}

public struct WithdrawAsset: Decodable {
    
    public var enabled: Bool
    public var feeFixed: Double?
    public var feePercent: Double?
    public var types: [String:WithdrawType]?
    
    /// Properties to encode and decode
    private enum CodingKeys: String, CodingKey {
        case enabled = "enabled"
        case feeFixed = "fee_fixed"
        case feePercent = "fee_percent"
        case types = "types"
    }
    
    /**
     Initializer - creates a new instance by decoding from the given decoder.
     
     - Parameter decoder: The decoder containing the data
     */
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        enabled = try values.decode(Bool.self, forKey: .enabled)
        feeFixed = try values.decodeIfPresent(Double.self, forKey: .feeFixed)
        feePercent = try values.decodeIfPresent(Double.self, forKey: .feePercent)
        types = try values.decodeIfPresent([String:WithdrawType].self, forKey: .types)
    }
}

public struct AnchorField: Decodable {
    
    public var description: String
    public var optional: Bool?
    
    /// Properties to encode and decode
    private enum CodingKeys: String, CodingKey {
        case description = "description"
        case optional = "optional"
    }
    
    /**
     Initializer - creates a new instance by decoding from the given decoder.
     
     - Parameter decoder: The decoder containing the data
     */
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        description = try values.decode(String.self, forKey: .description)
        optional = try values.decodeIfPresent(Bool.self, forKey: .optional)
    }
}

public struct WithdrawType: Decodable {
    
    public var fields: [String:AnchorField]?
    
    /// Properties to encode and decode
    private enum CodingKeys: String, CodingKey {
        case fields = "fields"
    }
    
    /**
     Initializer - creates a new instance by decoding from the given decoder.
     
     - Parameter decoder: The decoder containing the data
     */
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        fields = try values.decodeIfPresent([String:AnchorField].self, forKey: .fields)
    }
}

public struct AnchorTransactionsInfo: Decodable {
    
    public var enabled: Bool
    public var authenticationRequired:Bool?
    
    /// Properties to encode and decode
    private enum CodingKeys: String, CodingKey {
        case enabled
        case authenticationRequired = "authentication_required"
    }
    
    /**
     Initializer - creates a new instance by decoding from the given decoder.
     
     - Parameter decoder: The decoder containing the data
     */
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        enabled = try values.decode(Bool.self, forKey: .enabled)
        authenticationRequired = try values.decodeIfPresent(Bool.self, forKey: .authenticationRequired)
    }
}

public struct AnchorTransactionInfo: Decodable {
    
    public var enabled: Bool
    public var authenticationRequired:Bool?
    
    /// Properties to encode and decode
    private enum CodingKeys: String, CodingKey {
        case enabled
        case authenticationRequired = "authentication_required"
    }
    
    /**
     Initializer - creates a new instance by decoding from the given decoder.
     
     - Parameter decoder: The decoder containing the data
     */
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        enabled = try values.decode(Bool.self, forKey: .enabled)
        authenticationRequired = try values.decodeIfPresent(Bool.self, forKey: .authenticationRequired)
    }
}

public struct AnchorFeeInfo: Decodable {
    
    public var enabled: Bool
    public var authenticationRequired:Bool?
    
    /// Properties to encode and decode
    private enum CodingKeys: String, CodingKey {
        case enabled
        case authenticationRequired = "authentication_required"
    }
    
    /**
     Initializer - creates a new instance by decoding from the given decoder.
     
     - Parameter decoder: The decoder containing the data
     */
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        enabled = try values.decode(Bool.self, forKey: .enabled)
        authenticationRequired = try values.decodeIfPresent(Bool.self, forKey: .authenticationRequired)
    }
}
