//

// Copyright (c) 2020 Gobierno de España
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
// SPDX-License-Identifier: MPL-2.0
//

import UIKit
import RxSwift
import RxCocoa

class SettingViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var languageSelectorButton: UIButton!
    
    var router: AppRouter?
    var viewModel: SettingViewModel?

    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.setFontTextStyle()
        setupView()
        setupAccessibility()
    }
    
    private func setupAccessibility() {
        languageSelectorButton.isAccessibilityElement = true
        languageSelectorButton.accessibilityLabel = "ACC_BUTTON_SELECTOR_SELECT".localized
        languageSelectorButton.accessibilityHint = "ACC_HINT".localized
    }
    
    @IBAction func onLanguageSelectionAction(_ sender: Any) {
        showLanguageSelection()
    }
    
    private func setupView() {        
        viewModel?.getCurrenLenguageLocalizable()
            .bind(to: languageSelectorButton.rx.title())
            .disposed(by: disposeBag)
            
        let leftImageSelectorButton:CGFloat = ((self.languageSelectorButton.frame.size.width / 2) + 30)
        self.languageSelectorButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: leftImageSelectorButton , bottom: 0, right: 0)
    }
    
    private func showLanguageSelection() {
        guard let viewModel = self.viewModel else { return }
        
        isDisableAccesibility(isDisabble: true)
        self.navigationController?.topViewController?.view.showTransparentBackground(withColor: UIColor.blueyGrey90, alpha:  1) {
            SelectorView.initWithParentViewController(viewController: self,
                                                      title: "SETTINGS_LANGUAGE_TITLE".localized,
                                                      getArray:{ [weak self] () -> Observable<[SelectorItem]> in
                
                return Observable.create { [weak self] observer in
                    viewModel.getLenguages().subscribe(onNext: {(value) in
                        observer.onNext(SelectorHelperViewModel.generateTransformation(val: value))
                        observer.onCompleted()
                    }).disposed(by: self?.disposeBag ?? DisposeBag())
                    return Disposables.create {
                    }
                }
            }, getSelectedItem: { () -> Observable<SelectorItem> in
                
                return Observable.create { [weak self] observer in
                    viewModel.getCurrenLenguageLocalizable().subscribe(onNext: {(value) in
                        observer.onNext(SelectorHelperViewModel.generateTransformation(val: ItemLocale(id: viewModel.getCurrenLenguage(), description: value)))
                        observer.onCompleted()
                    }).disposed(by: self?.disposeBag ?? DisposeBag())
                    return Disposables.create {
                    }
                }
            }, delegateOutput: self)
        }
    }
    
    private func isDisableAccesibility(isDisabble: Bool) {
        self.scrollView.isHidden = isDisabble
        
        if let tab = self.parent as? TabBarController {
            tab.isDissableAccesibility(isDisabble: isDisabble)
        }
    }
}

extension SettingViewController: SelectorProtocol {
    
    func userSelectorSelected(selectorItem: SelectorItem, completionCloseView: @escaping (Bool) -> Void) {
        
        if selectorItem.id != self.viewModel?.getCurrenLenguage() {

            self.showAlertCancelContinue(title: "LOCALE_CHANGE_LANGUAGE".localized,
                                                          message: "LOCALE_CHANGE_WARNING".localized,
                                                          buttonOkTitle: "ALERT_OK_BUTTON".localized,
                                                          buttonCancelTitle: "ALERT_CANCEL_BUTTON".localized,
                                                          buttonOkVoiceover: "ACC_BUTTON_ALERT_OK".localized,
                                                          buttonCancelVoiceover: "ACC_BUTTON_ALERT_CANCEL".localized,
                                                          okHandler: { _ in
                                                            completionCloseView(true)
                                                            self.viewModel?.setCurrentLocale(key: selectorItem.id)
                                                            self.router?.route(to: Routes.changeLanguage, from: self)
                                                          }, cancelHandler: { _ in
                                                            completionCloseView(false)
                                                          })
        } else {
            completionCloseView(true)
        }
    }
    
    func hiddenSelectorSelectionView() {
        isDisableAccesibility(isDisabble: false)
    }
}
