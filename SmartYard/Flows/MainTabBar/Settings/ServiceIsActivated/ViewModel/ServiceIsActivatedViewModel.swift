//
//  ServiceIsActivatedViewModel.swift
//  SmartYard
//
//  Created by admin on 11/02/2020.
//  Copyright © 2021 LanTa. All rights reserved.
//

import RxSwift
import RxCocoa
import XCoordinator

class ServiceIsActivatedViewModel: BaseViewModel {
    
    private let router: WeakRouter<SettingsRoute>
    
    private let service: SettingsServiceType
    private let issueService: IssueService
    private let contractName: String?
    private let address: String
    
    let activityTracker = ActivityTracker()
    let errorTracker = ErrorTracker()
    
    init(
        router: WeakRouter<SettingsRoute>,
        service: SettingsServiceType,
        issueService: IssueService,
        contractName: String?,
        address: String
    ) {
        self.router = router
        self.service = service
        self.issueService = issueService
        self.contractName = contractName
        self.address = address
    }
    
    func transform(_ input: Input) -> Output {
        input.dismissTrigger
            .drive(
                onNext: { [weak self] in
                    self?.router.trigger(.dismiss)
                }
            )
            .disposed(by: disposeBag)
        
        input.changePlanTrigger
            .drive(
                onNext: { [weak self] _ in
                    var userInfo = [AnyHashable: Any]()
                    
                    userInfo[NotificationKeys.serviceActionKey] = SettingsServiceAction.changeTariff.rawValue
                    
                    if let contractName = self?.contractName {
                        userInfo[NotificationKeys.contractNameKey] = contractName
                    }
                    
                    if let service = self?.service.rawValue {
                        userInfo[NotificationKeys.serviceTypeKey] = service
                    }
                    
                    NotificationCenter.default.post(name: .chatRequested, object: nil, userInfo: userInfo)
                    
                    self?.router.trigger(.dismiss)
                }
            )
            .disposed(by: disposeBag)
        
        return Output(
            service: .just(service),
            isLoading: activityTracker.asDriver()
        )
    }
    
}

extension ServiceIsActivatedViewModel {
    
    struct Input {
        let dismissTrigger: Driver<Void>
        let changePlanTrigger: Driver<Void>
    }

    struct Output {
        let service: Driver<SettingsServiceType>
        let isLoading: Driver<Bool>
    }
    
}
