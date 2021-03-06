//
//  IINDetailsTestCase.swift
//  IngenicoConnectKit
//
//  Created by Fabian Giger on 04-04-17.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

import XCTest
import Mockingjay
@testable import IngenicoConnectKit

class IINDetailsResponseTestCase: XCTestCase {
    
    var session = Session(clientSessionId: "client-session-id",
                          customerId: "customer-id",
                          region: .EU,
                          environment: .sandbox)
    let context = PaymentContext(amountOfMoney: PaymentAmountOfMoney(totalAmount: 3, currencyCode: .EUR),
                                      isRecurring: true,
                                      countryCode: .NL)
    
    override func setUp() {
        super.setUp()
        stub(http(.post, uri:"/client/v1/customer-id/services/getIINdetails"),
             json([
                "countryCode": "RU",
                "paymentProductId": 3,
                "coBrands": [
                    [
                        "paymentProductId":1,
                        "isAllowedInContext":true
                    ],
                    [
                        "isAllowedInContext":true
                    ]
                ]
                ])
        )
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetIINDetailsNotEnoughDigits() {
        let expectation = self.expectation(description: "Response provided")
        session.iinDetails(forPartialCreditCardNumber: "22", context: context, success: { (response) in
            XCTAssertTrue(response.status == .notEnoughDigits, "Did not get the correct response status: \(response.status)")
            expectation.fulfill()
        }) { (error) in
            XCTFail("Unexpected failure while getting IIN Details: \(error.localizedDescription)")
        }
        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }
    
    func testGetIINDetails() {
        let expectation = self.expectation(description: "Response provided")
        session.iinDetails(forPartialCreditCardNumber: "666666", context: context, success: { (response) in
            XCTAssertTrue(response.paymentProductId == "3", "Payment product ID did not match: \(String(describing: response.paymentProductId))")
            XCTAssertEqual(response.countryCode, .RU, "Country code did not match: \(String(describing: response.countryCode))")
            
            let details = IINDetail(paymentProductId: response.paymentProductId!, allowedInContext: true)
            XCTAssertTrue(details.paymentProductId == response.paymentProductId, "Payment product ID did not match.")
            XCTAssertTrue(details.allowedInContext, "allowedInContext was false.")
            XCTAssertTrue(response.coBrands.count == 1, "Unexprected result. There should be one Co Brand.")
            expectation.fulfill()
        }) { (error) in
            XCTFail("Unexpected failure while getting IIN Details: \(error.localizedDescription)")
        }
        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }
    
    
    
}
