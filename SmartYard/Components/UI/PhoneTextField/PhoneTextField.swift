//
//  PhoneTextField.swift
//  SmartYard
//
//  Created by Mad Brains on 05.02.2020.
//  Copyright © 2021 LanTa. All rights reserved.
//

import Foundation
import UIKit
import PMNibLinkableView
import RxSwift
import RxCocoa

class PhoneTextField: PMNibLinkableView {
    
    @IBOutlet private weak var containerView: UIView!
    
    private(set) var text = ""
    
    @IBOutlet private weak var firstNumView: NumberFieldView!
    @IBOutlet private weak var secondNumView: NumberFieldView!
    @IBOutlet private weak var thirdNumView: NumberFieldView!
    
    @IBOutlet private weak var fourthNumView: NumberFieldView!
    @IBOutlet private weak var fifthNumView: NumberFieldView!
    @IBOutlet private weak var sixthNumView: NumberFieldView!
    
    @IBOutlet private weak var seventhNumView: NumberFieldView!
    @IBOutlet private weak var eighthNumView: NumberFieldView!
    @IBOutlet private weak var ninthNumView: NumberFieldView!
    @IBOutlet private weak var tenthNumView: NumberFieldView!
    
    @IBOutlet fileprivate weak var fakeTextField: UITextField!
    
    private var numberViewsCollection: [NumberFieldView] {
        return [
            firstNumView, secondNumView, thirdNumView,
            fourthNumView, fifthNumView, sixthNumView,
            seventhNumView, eighthNumView, ninthNumView,
            tenthNumView
        ]
    }
    
    private let disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureFakeTextField()
        addViewTapGesture()
        bind()
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        return fakeTextField.becomeFirstResponder()
    }
    
    func fetchInputNumber() -> String? {
        return fakeTextField.text
    }
    
    @objc private func didPressNumberField() {
        if fakeTextField.text?.count == Constants.phoneLengthWithoutPrefix {
            reset()
        }
        
        fakeTextField.becomeFirstResponder()
    }
    
    private func bind() {
        fakeTextField.rx.text.changed
            .subscribe(
                onNext: { [weak self] text in
                    guard let self = self else {
                        return
                    }
                    
                    self.fillNumberFields(with: text)
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func addViewTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didPressNumberField))
        tapGesture.cancelsTouchesInView = false
        containerView.addGestureRecognizer(tapGesture)
    }
    
    private func fillNumberFields(with text: String?) {
        numberViewsCollection.enumerated().forEach { offset, element in
            guard element.fetchValue() != text?[safe: offset]?.string else {
                return
            }
            
            element.setNewValue(value: text?[safe: offset]?.string)
        }
    }
    
    private func reset() {
        fakeTextField.clear()
        
        numberViewsCollection.forEach { view in
            view.clear()
        }
    }
    
    private func configureFakeTextField() {
        fakeTextField.delegate = self
        fakeTextField.smartInsertDeleteType = UITextSmartInsertDeleteType.no
        fakeTextField.keyboardType = .numberPad
        fakeTextField.autocorrectionType = .no
    }
    
}

extension PhoneTextField: UITextFieldDelegate {
    
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let textFieldText = textField.text,
              let rangeOfTextToReplace = Range(range, in: textFieldText)
        else {
              return false
        }
        
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        
        return count <= Constants.phoneLengthWithoutPrefix
    }
    
}

extension Reactive where Base: PhoneTextField {
    
    var textControlProperty: ControlProperty<String?> {
        return base.fakeTextField.rx.text
    }
    
}
