//
//  PaymentsTestCase.swift
//  stellarsdkTests
//
//  Created by Rogobete Christian on 10.02.18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import XCTest
import stellarsdk

class PaymentsTestCase: XCTestCase {
    let sdk = StellarSDK()
    var streamItem:OperationsStreamItem? = nil
    let testKeyPair = try! KeyPair.generateRandomKeyPair()
    let IOMIssuingAccountKeyPair = try! KeyPair.generateRandomKeyPair()
    let testTransactionHash:String? = nil
    var up = false

    override func setUp() {
        super.setUp()
        if up {
            return
        }
        let expectation = XCTestExpectation(description: "accounts prepared for tests")

        let testAccountId = testKeyPair.accountId
        let issuingAccountId = IOMIssuingAccountKeyPair.accountId
        
        let IOMAsset = ChangeTrustAsset(canonicalForm: "IOM:" + issuingAccountId)!
        let changeTrustOp = ChangeTrustOperation(sourceAccountId:testAccountId, asset:IOMAsset, limit: 100000000)
        let manageDataOp = ManageDataOperation(sourceAccountId: issuingAccountId, name: "config.memo_required", data: Data(base64Encoded: "MQ=="))
        
        sdk.accounts.createTestAccount(accountId: testAccountId) { (response) -> (Void) in
            switch response {
            case .success(_):
                self.sdk.accounts.createTestAccount(accountId: issuingAccountId) { (response) -> (Void) in
                    switch response {
                    case .success(_):
                        self.sdk.accounts.getAccountDetails(accountId: testAccountId) { (response) -> (Void) in
                            switch response {
                            case .success(let accountResponse):
                                do {
                                    let transaction = try Transaction(sourceAccount: accountResponse,
                                                                      operations: [changeTrustOp, manageDataOp],
                                                                      memo: Memo.none)
                                    try transaction.sign(keyPair: self.testKeyPair, network: Network.testnet)
                                    try transaction.sign(keyPair: self.IOMIssuingAccountKeyPair, network: Network.testnet)
                                    
                                    try self.sdk.transactions.submitTransaction(transaction: transaction) { (response) -> (Void) in
                                        switch response {
                                        case .success(let response):
                                            print("setUp: Transaction successfully sent. Hash:\(response.transactionHash)")
                                            self.up = true
                                            expectation.fulfill()
                                        default:
                                            XCTAssert(false)
                                        }
                                    }
                                } catch {
                                    XCTAssert(false)
                                }
                            case .failure(_):
                                XCTAssert(false)
                            }
                        }
                    case .failure(_):
                        XCTAssert(false)
                    }
                }
            case .failure(_):
                XCTAssert(false)
            }
        }
        wait(for: [expectation], timeout: 25.0)
    }
    
    private func createTestAccount() {
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetPayments() {
        let expectation = XCTestExpectation(description: "Test get payments and paging")
        
        sdk.payments.getPayments { (response) -> (Void) in
            switch response {
            case .success(let paymentsResponse):
                // load next page
                paymentsResponse.getNextPage(){ (response) -> (Void) in
                    switch response {
                    case .success(let nextPaymentsResponse):
                        // load previous page, should contain the same payments as the first page
                        nextPaymentsResponse.getPreviousPage(){ (response) -> (Void) in
                            switch response {
                            case .success(let prevPaymentsResponse):
                                let payment1 = paymentsResponse.records.first
                                let payment2 = prevPaymentsResponse.records.last // because ordering is asc now.
                                XCTAssertTrue(payment1?.id == payment2?.id)
                                XCTAssertTrue(payment1?.sourceAccount == payment2?.sourceAccount)
                                XCTAssertTrue(payment1?.sourceAccount == payment2?.sourceAccount)
                                XCTAssertTrue(payment1?.operationTypeString == payment2?.operationTypeString)
                                XCTAssertTrue(payment1?.operationType == payment2?.operationType)
                                XCTAssertTrue(payment1?.createdAt == payment2?.createdAt)
                                XCTAssertTrue(payment1?.transactionHash == payment2?.transactionHash)
                                XCTAssert(true)
                                expectation.fulfill()
                            case .failure(let error):
                                StellarSDKLog.printHorizonRequestErrorMessage(tag:"testGetPayments", horizonRequestError: error)
                                XCTAssert(false)
                            }
                        }
                    case .failure(let error):
                        StellarSDKLog.printHorizonRequestErrorMessage(tag:"testGetPayments", horizonRequestError: error)
                        XCTAssert(false)
                    }
                }
            case .failure(let error):
                StellarSDKLog.printHorizonRequestErrorMessage(tag:"testGetPayments", horizonRequestError: error)
                XCTAssert(false)
            }
        }
        
        wait(for: [expectation], timeout: 15.0)
    }
    
    func testGetPaymentsForAccount() {
        let expectation = XCTestExpectation(description: "Get payments for account")
        let accID = testKeyPair.accountId
        print(accID)
        sdk.payments.getPayments (forAccount: accID, includeFailed:true, join:"transactions") { (response) -> (Void) in
            switch response {
            case .success(_):
                XCTAssert(true)
            case .failure(let error):
                StellarSDKLog.printHorizonRequestErrorMessage(tag:"testGetPaymentsForAccount", horizonRequestError: error)
                XCTAssert(false)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 15.0)
    }
    
    func testGetPaymentsForLedger() {
        let expectation = XCTestExpectation(description: "Get payments for ledger")
        
        sdk.payments.getPayments(forLedger: "194461", includeFailed:true, join:"transactions") { (response) -> (Void) in
            switch response {
            case .success(_):
                XCTAssert(true)
            case .failure(let error):
                StellarSDKLog.printHorizonRequestErrorMessage(tag:"testGetPaymentsForLedgert", horizonRequestError: error)
                XCTAssert(false)
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 15.0)
    }
    
    func testGetPaymentsForTransaction() {
        let expectation = XCTestExpectation(description: "Get payments for transaction")
        
        sdk.transactions.getTransactions(forAccount: testKeyPair.accountId) { (response) -> (Void) in
            switch response {
            case .success(let transactionsResponse):
                print(transactionsResponse.records.first!.id)
                self.sdk.payments.getPayments(forTransaction: transactionsResponse.records.first!.id, includeFailed: true, join:"transactions") { (response) -> (Void) in
                    switch response {
                    case .success(let payments):
                        XCTAssert(payments.records.count > 0)
                    case .failure(let error):
                        StellarSDKLog.printHorizonRequestErrorMessage(tag:"GPFT Test", horizonRequestError: error)
                        XCTAssert(false)
                    }
                    expectation.fulfill()
                }
            case .failure(let error):
                StellarSDKLog.printHorizonRequestErrorMessage(tag:"testGetPaymentsForLedgert", horizonRequestError: error)
                XCTAssert(false)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 15.0)
    }
    
    func testSendAndReceiveNativePayment() {
        
        let expectation = XCTestExpectation(description: "Native payment successfully sent and received")
        
        let sourceAccountKeyPair = testKeyPair
        let destinationAccountId = IOMIssuingAccountKeyPair.accountId
        
        streamItem = sdk.payments.stream(for: .paymentsForAccount(account: destinationAccountId, cursor: "now"))
        streamItem?.onReceive { (response) -> (Void) in
            switch response {
            case .open:
                break
            case .response(let id, let operationResponse):
                if let paymentResponse = operationResponse as? PaymentOperationResponse {
                    print("Payment of \(paymentResponse.amount) XLM from \(paymentResponse.sourceAccount) received -  id \(id)" )
                    self.streamItem?.closeStream()
                    self.streamItem = nil
                    XCTAssert(true)
                    expectation.fulfill()
                }
            case .error(let error):
                if let horizonRequestError = error as? HorizonRequestError {
                    StellarSDKLog.printHorizonRequestErrorMessage(tag:"testSendAndReceiveNativePayment", horizonRequestError:horizonRequestError)
                } else {
                    print("Error \(error?.localizedDescription ?? "")")
                }
            }
        }
        
        sdk.accounts.getAccountDetails(accountId: sourceAccountKeyPair.accountId) { (response) -> (Void) in
            switch response {
            case .success(let accountResponse):
                let muxSource = MuxedAccount(keyPair: sourceAccountKeyPair, sequenceNumber: accountResponse.sequenceNumber, id: 1278881)
                let muxDest = try! MuxedAccount(accountId: destinationAccountId, id:9919191919)
                
                let paymentOperation = try! PaymentOperation(sourceAccountId: muxSource.accountId,
                                                        destinationAccountId: muxDest.accountId,
                                                        asset: Asset(type: AssetType.ASSET_TYPE_NATIVE)!,
                                                        amount: 1.5)
                
                let transaction = try! Transaction(sourceAccount: muxSource,
                                                  operations: [paymentOperation],
                                                  memo: Memo.init(text: "test"))
                try! transaction.sign(keyPair: sourceAccountKeyPair, network: Network.testnet)
                
                try! self.sdk.transactions.submitTransaction(transaction: transaction) { (response) -> (Void) in
                    switch response {
                    case .success(let response):
                        print("testSendAndReceiveNativePayment: Transaction successfully sent. Hash \(response.transactionHash)")
                    default:
                        XCTAssert(false)
                        expectation.fulfill()
                    }
                }
            case .failure(_):
                XCTAssert(false)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 15.0)
    }
    
    func testSendAndReceiveNativePaymentWithPreconditions() {
        
        let expectation = XCTestExpectation(description: "Native payment successfully sent and received")
        let sourceAccountKeyPair = testKeyPair
        let destinationAccountId = IOMIssuingAccountKeyPair.accountId
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { // wait for ledger to close

            self.streamItem = self.sdk.payments.stream(for: .paymentsForAccount(account: destinationAccountId, cursor: "now"))
            self.streamItem?.onReceive { (response) -> (Void) in
                switch response {
                case .open:
                    break
                case .response(let id, let operationResponse):
                    if let paymentResponse = operationResponse as? PaymentOperationResponse {
                        print("Payment of \(paymentResponse.amount) XLM from \(paymentResponse.sourceAccount) received -  id \(id)" )
                        self.streamItem?.closeStream()
                        self.streamItem = nil
                        XCTAssert(true)
                        expectation.fulfill()
                    }
                case .error(let error):
                    if let horizonRequestError = error as? HorizonRequestError {
                        StellarSDKLog.printHorizonRequestErrorMessage(tag:"testSendAndReceiveNativePaymentWithPreconditions", horizonRequestError:horizonRequestError)
                    } else {
                        print("Error \(error?.localizedDescription ?? "")")
                    }
                }
            }
            
            self.sdk.accounts.getAccountDetails(accountId: sourceAccountKeyPair.accountId) { (response) -> (Void) in
                switch response {
                case .success(let accountResponse):
                    let muxSource = MuxedAccount(keyPair: sourceAccountKeyPair, sequenceNumber: accountResponse.sequenceNumber, id: 1278881)
                    let muxDest = try! MuxedAccount(accountId: destinationAccountId, id:9919191919)
                    
                    let paymentOperation = try! PaymentOperation(sourceAccountId: muxSource.accountId,
                                                            destinationAccountId: muxDest.accountId,
                                                            asset: Asset(type: AssetType.ASSET_TYPE_NATIVE)!,
                                                            amount: 1.5)
                    
                    let lb = LedgerBounds(minLedger: 892052, maxLedger: 1892052)
                    let tb = TimeBounds(minTime: 1652110741, maxTime: 1752110741)
                    
                    let precond = TransactionPreconditions(ledgerBounds: lb, timeBounds: tb, minSeqNumber: accountResponse.sequenceNumber, minSeqAge: 1, minSeqLedgerGap: 1)

                    let transaction = try! Transaction(sourceAccount: muxSource,
                                                      operations: [paymentOperation],
                                                      memo: Memo.init(text: "test"),
                                                      preconditions:precond)
                    try! transaction.sign(keyPair: sourceAccountKeyPair, network: Network.testnet)
                    
                    try! self.sdk.transactions.submitTransaction(transaction: transaction) { (response) -> (Void) in
                        switch response {
                        case .success(let response):
                            print("testSendAndReceiveNativePaymentWithPreconditions: Transaction successfully sent. Hash \(response.transactionHash)")
                        default:
                            XCTAssert(false)
                            expectation.fulfill()
                        }
                    }
                case .failure(let error):
                    StellarSDKLog.printHorizonRequestErrorMessage(tag:"testSendAndReceiveNativePaymentWithPreconditions", horizonRequestError:error)
                    XCTAssert(false)
                    expectation.fulfill()
                }
            }
        }
        wait(for: [expectation], timeout: 35.0)
    }
    
    func testSendAndReceiveNonNativePayment() {
        
        let expectation = XCTestExpectation(description: "Non native payment successfully sent and received")
        
        let sourceKeyPair = IOMIssuingAccountKeyPair
        let destinationAccountId = testKeyPair.accountId
        let IOMAsset = Asset(canonicalForm: "IOM:" + IOMIssuingAccountKeyPair.accountId)!
        
        streamItem = sdk.payments.stream(for: .paymentsForAccount(account: destinationAccountId, cursor: "now"))
        streamItem?.onReceive { (response) -> (Void) in
            switch response {
            case .open:
                break
            case .response(let id, let operationResponse):
                if let paymentResponse = operationResponse as? PaymentOperationResponse {
                    if paymentResponse.assetCode == IOMAsset.code {
                        print("Payment of \(paymentResponse.amount) IOM from \(paymentResponse.sourceAccount) received -  id \(id)" )
                        XCTAssert(true)
                        expectation.fulfill()
                    }
                }
            case .error(let error):
                if let horizonRequestError = error as? HorizonRequestError {
                    StellarSDKLog.printHorizonRequestErrorMessage(tag:"testSendAndReceiveNonNativePayment", horizonRequestError:horizonRequestError)
                } else {
                    print("Error \(error?.localizedDescription ?? "")")
                }
            }
        }
        
        sdk.accounts.getAccountDetails(accountId: sourceKeyPair.accountId) { (response) -> (Void) in
            switch response {
            case .success(let accountResponse):
                let muxSource = MuxedAccount(keyPair: sourceKeyPair, sequenceNumber: accountResponse.sequenceNumber, id: 1278881)
                let muxDest = try! MuxedAccount(accountId: destinationAccountId, id:9919191919)
                
                let paymentOperation = try! PaymentOperation(sourceAccountId: muxSource.accountId,
                                                        destinationAccountId: muxDest.accountId,
                                                        asset: IOMAsset,
                                                        amount: 2.5)
                
                let transaction = try! Transaction(sourceAccount: muxSource,
                                                  operations: [paymentOperation],
                                                  memo: Memo.none)
                try! transaction.sign(keyPair: sourceKeyPair, network: Network.testnet)
                
                try! self.sdk.transactions.submitTransaction(transaction: transaction) { (response) -> (Void) in
                    switch response {
                    case .success(let response):
                        print("testSendAndReceiveNonNativePayment: Transaction successfully sent. Hash:\(response.transactionHash)")
                    default:
                        XCTAssert(false)
                        expectation.fulfill()
                    }
                }
            case .failure(let error):
                StellarSDKLog.printHorizonRequestErrorMessage(tag:"SRNNP Test", horizonRequestError:error)
                XCTAssert(false)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 15.0)
    }
    
    
    func testDestinationRequiresMemo() {
        
        let expectation = XCTestExpectation(description: "Native payment can not be sent because destination requires memo")
        
        let sourceAccountKeyPair = testKeyPair
        let sourceAccountId = sourceAccountKeyPair.accountId
        let destinationAccountId = IOMIssuingAccountKeyPair.accountId
        
        sdk.accounts.getAccountDetails(accountId: sourceAccountKeyPair.accountId) { (response) -> (Void) in
            switch response {
            case .success(let accountResponse):
                let paymentOperationOne = try! PaymentOperation(sourceAccountId: sourceAccountId,
                                                                destinationAccountId: sourceAccountId,
                                                                asset: Asset(type: AssetType.ASSET_TYPE_NATIVE)!,
                                                                amount: 1.5)
                let paymentOperationTwo = try! PaymentOperation(sourceAccountId: sourceAccountId,
                                                           destinationAccountId: destinationAccountId,
                                                           asset: Asset(type: AssetType.ASSET_TYPE_NATIVE)!,
                                                           amount: 1.5)
                let transaction = try! Transaction(sourceAccount: accountResponse,
                                                  operations: [paymentOperationOne, paymentOperationTwo],
                                                  memo: Memo.none)
                try! transaction.sign(keyPair: sourceAccountKeyPair, network: Network.testnet)
                
                try! self.sdk.transactions.submitTransaction(transaction: transaction) { (response) -> (Void) in
                    switch response {
                    case .success(_):
                        print("testDestinationRequiresMemo: Transaction successfully sent")
                        XCTAssert(false)
                        expectation.fulfill()
                    case .destinationRequiresMemo(let destinationAccountId):
                        print("testDestinationRequiresMemo: Destination requires memo \(destinationAccountId)")
                        XCTAssert(true)
                        expectation.fulfill()
                    case .failure(let error):
                        StellarSDKLog.printHorizonRequestErrorMessage(tag:"testDestinationRequiresMemo", horizonRequestError:error)
                        XCTAssert(false)
                        expectation.fulfill()
                    }
                }
            case .failure(let error):
                StellarSDKLog.printHorizonRequestErrorMessage(tag:"testDestinationRequiresMemo", horizonRequestError:error)
                XCTAssert(false)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 15.0)
    }
}
