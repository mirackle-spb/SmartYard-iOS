//
//  PaymentPopupViewModel.swift
//  SmartYard
//
//  Created by Mad Brains on 14.05.2020.
//  Copyright © 2021 LanTa. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import XCoordinator
import UIKit

class PaymentPopupViewModel: BaseViewModel {
    
    private let apiWrapper: APIWrapper
    private let clientId: String
    private var router: WeakRouter<PaymentsRoute>
    
    
    private let recommendedSum: BehaviorSubject<Double?>
    private let contractNumber: BehaviorSubject<String?>
    
    init(
        apiWrapper: APIWrapper,
        clientId: String,
        recommendedSum: Double?,
        contractNumber: String?,
        router: WeakRouter<PaymentsRoute>
    ) {
        self.apiWrapper = apiWrapper
        self.clientId = clientId
        self.recommendedSum = BehaviorSubject<Double?>(value: recommendedSum)
        self.contractNumber = BehaviorSubject<String?>(value: contractNumber)
        self.router = router
    }
    
    // swiftlint:disable:next function_body_length
    func transform(_ input: Input) -> Output {
        // let activityTracker = ActivityTracker()
        let errorTracker = ErrorTracker()
        
        let isPaySuccessTrigger = PublishSubject<Bool>()
        
        input.payProcess
            .flatMapLatest { [weak self] args -> Driver<(Data?, PayPrepareResponseData?)?> in
                let (token, amount) = args
                
                guard let self = self, let pennyAmount = amount.double() else {
                    isPaySuccessTrigger.onNext(false)
                    return .empty()
                }
                
                return self.apiWrapper.payPrepare(
                        clientId: self.clientId,
                        amount: String(pennyAmount * 100)
                    )
                    .trackError(errorTracker)
                    .map {
                        guard let response = $0 else {
                            isPaySuccessTrigger.onNext(false)
                            return nil
                        }
                        
                        return (token, response)
                    }
                    .asDriver(onErrorJustReturn: nil)
            }
            .flatMapLatest { [weak self] args -> Driver<(String, SberbankPayProcessResponseData)?> in
                guard let self = self,
                      let (token, response) = args,
                      let orderNumber = response,
                      let uToken = token?.base64EncodedString(),
                      !uToken.isEmpty
                else {
                    isPaySuccessTrigger.onNext(false)
                    return .empty()
                }

                return
                    self.apiWrapper.sberbankPayProcess(
                            merchant: "lanta",
                            orderNumber: orderNumber,
                            paymentToken: uToken
                        )
                        .trackError(errorTracker)
                        .map {
                            guard let response = $0, response.success else {
                                isPaySuccessTrigger.onNext(false)
                                return nil
                            }
                            
                            return (orderNumber, response)
                        }
                        .asDriverOnErrorJustComplete()

            }
            .flatMapLatest { [weak self] args -> Driver<PayProcessResponseData?> in
                guard let self = self,
                      let (innerPaymentId, response) = args,
                      let sberbankOrderId = response.data?.orderId
                else {
                    isPaySuccessTrigger.onNext(false)
                    return .empty()
                }
            
                return self.apiWrapper.payProcess(
                        paymentId: innerPaymentId,
                        sbId: sberbankOrderId
                    )
                    .trackError(errorTracker)
                    .asDriver(onErrorJustReturn: nil)
            }
            .drive(
                onNext: { _ in
                    isPaySuccessTrigger.onNext(true)
                }
            )
            .disposed(by: disposeBag)
        
        input.cardProcess
            .flatMapLatest { [weak self] amount -> Driver<(String, PayPrepareResponseData?)?> in
                
                guard let self = self else {
                    return .empty()
                }
                
                let amountString = String(format: "%.0f", amount.doubleValue * 100)
                
                return self.apiWrapper.payPrepare(
                        clientId: self.clientId,
                        amount: amountString
                    )
                    .trackError(errorTracker)
                    .map {
                        guard let response = $0 else {
                            return nil
                        }
                        
                        return (amountString, response)
                    }
                    .asDriver(onErrorJustReturn: nil)
            }
            .flatMapLatest { [weak self] args -> Driver<(String, PayRegisterResponseData)?> in
                guard let self = self,
                      let (amount, response) = args,
                      let orderNumber = response
                else {
                    return .empty()
                }

                return
                    self.apiWrapper.payRegisterProcess(orderNumber: orderNumber, amount: amount)
                        .trackError(errorTracker)
                        .map {
                            guard let response = $0 else {
                                return nil
                            }
                            
                            return (orderNumber, response)
                        }
                        .asDriverOnErrorJustComplete()

            }
            .drive(
                onNext: { [weak self] args in
                    guard let self = self,
                          let (_, data) = args,
                          let url = URL(string: data.formUrl)
                    else {
                              return
                          }
                    print(url)
                    
                    UIApplication.shared.open(url)
                    self.router.trigger(.dismiss)
                    // self.router.trigger(.webView(url: url))
                    // self.router.trigger(.dismissAndOpen(url: url))
                    
                }
            )
            .disposed(by: disposeBag)
        
        return Output(
            isPaySuccessTrigger: isPaySuccessTrigger.asDriver(onErrorJustReturn: false),
            recommendedSum: recommendedSum.asDriver(onErrorJustReturn: nil),
            contractNumber: contractNumber.asDriver(onErrorJustReturn: nil)
        )
    }
    
}

extension PaymentPopupViewModel {
    
    struct Input {
        let payProcess: Driver<(Data?, String)>
        let cardProcess: Driver<NSDecimalNumber>
    }
    
    struct Output {
        let isPaySuccessTrigger: Driver<Bool>
        let recommendedSum: Driver<Double?>
        let contractNumber: Driver<String?>
    }
    
}
