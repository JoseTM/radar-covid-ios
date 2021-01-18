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

class HighExpositionViewController: BaseExposed {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var whatToDoTitleLabel: UILabel!
    @IBOutlet weak var youCouldBeLabel: UILabel!
    @IBOutlet weak var phoneView: BackgroundView!
    @IBOutlet weak var timeTableLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var covidWebLabel: UILabel!

    @IBOutlet weak var phoneViewVisibleConstraint: NSLayoutConstraint!
    @IBOutlet weak var phoneViewHiddenConstraint: NSLayoutConstraint!

    @IBOutlet weak var selectorView: BackgroundView!
    @IBOutlet weak var caSelectorLabel: UILabel!
    @IBOutlet weak var caSelectorButton: UIButton!
    @IBOutlet weak var otherSympthomsLabel: UILabel!
    @IBOutlet weak var howActLabel: UILabel!
    var settingsRepository: SettingsRepository!
    
    var ccaUseCase: CCAAUseCase!
    var since: Date?
    
    private let bgImageRed = UIImage(named: "GradientBackgroundRed")
    private let bgImageOrange = UIImage(named: "GradientBackgroundOrange")
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setupView()
        setupAccessibility()

        setLogicTextInfect()
        setCaSelector()
    }
    
    @IBAction func caaSelectAction(_ sender: Any) {
        isDisableAccesibility(isDisabble: true)
        self.navigationController?.topViewController?.view.showTransparentBackground(withColor: UIColor.blueyGrey90, alpha:  1) {
            SelectorView.initWithParentViewController(viewController: self,
                                                      title: "LOCALE_SELECTION_REGION_DEFAULT".localized,
                getArray: { [weak self] () ->  Observable<[SelectorItem]> in
                    self?.ccaUseCase.getCCAA().map { locales in SelectorHelperViewModel.generateTransformation(val: locales) } ?? .empty()
            }, getSelectedItem: { [weak self] () -> Observable<SelectorItem> in
                .just(SelectorHelperViewModel.generateTransformation(val: self?.ccaUseCase.getCurrent() ?? CaData.emptyCaData()))
            }, delegateOutput: self)
        }
    }
    
    @objc func userDidTapOtherSympthoms(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer,
                 urlString: "EXPOSITION_HIGH_OTHER_SYMPTOMS".localized.getUrlFromHref())
    }

    @objc func userDidTapHowAct(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer,
                 urlString: "EXPOSITION_HIGH_SYMPTOMS_WHAT_TO_DO".localized.getUrlFromHref())
    }
    
    @objc func onCallTap(tapGestureRecognizer: UITapGestureRecognizer) {
        open(phone: ccaUseCase.getCurrent()?.phone ?? "CONTACT_PHONE".localized)
    }

    @objc override func userDidTapLabel(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer, urlString: "MORE_INFO_EXPOSURE_HIGH".localized.getUrlFromHref())
    }
    
    @objc func userDidTapWeb(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer, urlString: ccaUseCase.getCurrent()?.web)
    }
    
    private func setupAccessibility() {

        whatToDoTitleLabel.isAccessibilityElement = true
        whatToDoTitleLabel.accessibilityTraits.insert(UIAccessibilityTraits.header)
        whatToDoTitleLabel.accessibilityLabel = "ACC_WHAT_TO_DO_TITLE".localized
        
        otherSympthomsLabel.isAccessibilityElement = true
        otherSympthomsLabel.accessibilityTraits.insert(UIAccessibilityTraits.link)
        otherSympthomsLabel.accessibilityLabel = "EXPOSITION_HIGH_OTHER_SYMPTOMS".localizedAttributed().string.replacingOccurrences(of: ">", with: "")
        otherSympthomsLabel.accessibilityHint = "ACC_HINT".localized
        
        moreInfoView.isAccessibilityElement = true
        moreInfoView.accessibilityTraits.insert(UIAccessibilityTraits.link)
        moreInfoView.accessibilityLabel = "MORE_INFO_EXPOSURE_HIGH".localizedAttributed().string.replacingOccurrences(of: ">", with: "")
        moreInfoView.accessibilityHint = "ACC_HINT".localized
        
        howActLabel.isAccessibilityElement = true
        howActLabel.accessibilityTraits.insert(UIAccessibilityTraits.link)
        howActLabel.accessibilityLabel = "EXPOSITION_HIGH_SYMPTOMS_WHAT_TO_DO".localizedAttributed().string.replacingOccurrences(of: ">", with: "")
        howActLabel.accessibilityHint = "ACC_HINT".localized
        
        phoneLabel.accessibilityTraits.insert(UIAccessibilityTraits.button)
        phoneLabel.accessibilityHint = "ACC_HINT".localized
        
        covidWebLabel.accessibilityTraits.insert(UIAccessibilityTraits.link)
        covidWebLabel.accessibilityHint = "ACC_HINT".localized
        
        caSelectorButton.accessibilityHint = "ACC_HINT".localized
        caSelectorButton.accessibilityLabel = self.caSelectorLabel.text
    }
    
    private func setupView() {

        otherSympthomsLabel.isUserInteractionEnabled = true
        howActLabel.isUserInteractionEnabled = true
        expositionBGView.image = bgImageOrange

        phoneView.isUserInteractionEnabled = true
        self.covidWebLabel.isUserInteractionEnabled = true
        self.covidWebLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                           action: #selector(userDidTapWeb(tapGestureRecognizer:))))

        self.phoneLabel.isUserInteractionEnabled = true
        self.phoneLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                             action: #selector(onCallTap(tapGestureRecognizer:))))
        otherSympthomsLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                            action: #selector(userDidTapOtherSympthoms(tapGestureRecognizer:))))
        howActLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                    action: #selector(userDidTapHowAct(tapGestureRecognizer:))))

        phoneView.image = UIImage(named: "WhiteCard")
        caSelectorLabel.text = "LOCALE_SELECTION_REGION_DEFAULT".localized
        caSelectorButton.layer.cornerRadius = 8
        caSelectorButton.layer.borderWidth = 1
        caSelectorButton.layer.borderColor = UIColor.deepLilac.cgColor
    }
    
    private func setLogicTextInfect() {
        //Text Infect
        let date = self.since ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = Date.appDateFormat
        var sinceDay = since ?? Date()
        sinceDay = sinceDay.getStartOfDay()
        
        var daysSinceLastInfection = Date().days(sinceDate: sinceDay) ?? 1
        if daysSinceLastInfection == 0 {
            daysSinceLastInfection = 1
        }
        
        let remindingDays = self.checkRemindingExpositionDays(since: sinceDay)
        let remindingDaysText =
            remindingDays <= 1
                ? "EXPOSED_EXPOSITION_COUNT_ONE_DAY".localizedAttributed(withParams: [String(remindingDays)])
                : "EXPOSED_EXPOSITION_COUNT_ANYMORE".localizedAttributed(withParams: [String(remindingDays)])
        
        let attributedText = NSMutableAttributedString.init(
            attributedString: "EXPOSITION_HIGH_DESCRIPTION"
                .localizedAttributed(
                    withParams: [String(daysSinceLastInfection), formatter.string(from: date) ]
                )
        )
        attributedText
            .append(remindingDaysText)
        youCouldBeLabel.attributedText = attributedText
        youCouldBeLabel.setMagnifierFontSize()

        
        let accesibilityText = NSMutableAttributedString.init(
            attributedString: "EXPOSITION_HIGH_DESCRIPTION"
                .localizedAttributed(
                    withParams: [ String(daysSinceLastInfection), date.getAccesibilityDate() ?? ""]
                )
        )
        accesibilityText.append(remindingDaysText)
        youCouldBeLabel.accessibilityLabel = accesibilityText.string
    }
    
    func checkRemindingExpositionDays(since: Date) -> Int {
        let minutesInAHour = 60
        let hoursInADay = 24
        let formatter = DateFormatter()
        formatter.dateFormat = Date.appDateFormat
        var sinceDay = since
        sinceDay = sinceDay.getStartOfDay()
        
        let daysSinceLastInfection = Date().days(sinceDate: sinceDay) ?? 1
        let daysForHealty = Int(settingsRepository?.getSettings()?.parameters?.timeBetweenStates?.highRiskToLowRisk ?? 0) / minutesInAHour / hoursInADay
        return daysForHealty - daysSinceLastInfection
    }
    
    private func setCaSelector() {
        
        self.selectorView.image = UIImage.init(named: "WhiteCard")
        self.selectorView.isUserInteractionEnabled = true

        guard let currentCa = self.ccaUseCase.getCurrent() else {
            self.phoneView.isHidden = true
            self.phoneViewHiddenConstraint.priority = .defaultHigh
            self.phoneViewVisibleConstraint.priority = .defaultLow
            return
        }
        
        self.phoneViewHiddenConstraint.priority = .defaultLow
        self.phoneViewVisibleConstraint.priority = .defaultHigh
        self.phoneView.isHidden = false
        self.phoneLabel.text = currentCa.phone ?? "CONTACT_PHONE".localized
        self.covidWebLabel.text = currentCa.webName ?? currentCa.web ?? ""
        
        let title = currentCa.description ?? "LOCALE_SELECTION_REGION_DEFAULT".localized
        self.caSelectorLabel.text = title
        caSelectorButton.accessibilityLabel = title
    }
    
    private func isDisableAccesibility(isDisabble: Bool) {
        self.scrollView.isHidden = isDisabble
        self.backButton?.isHidden = isDisabble
        
        if let tab = self.parent as? TabBarController {
            tab.isDissableAccesibility(isDisabble: isDisabble)
        }
    }
}

extension HighExpositionViewController: SelectorProtocol {
    
    func userSelectorSelected(selectorItem: SelectorItem, completionCloseView: @escaping (Bool) -> Void) {
        
        if let selectedCaData = selectorItem.objectOrigin as? CaData {
            ccaUseCase.setCurrent(cca: selectedCaData)
            setCaSelector()
        }
        
        completionCloseView(true)
    }
    
    func hiddenSelectorSelectionView() {
        isDisableAccesibility(isDisabble: false)
    }
}
