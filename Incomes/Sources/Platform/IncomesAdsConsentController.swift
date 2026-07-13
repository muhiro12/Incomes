import Foundation
import GoogleMobileAdsWrapper
import MHPlatform
import Observation
import UserMessagingPlatform

@MainActor
@Observable
final class IncomesAdsConsentController {
    nonisolated static let loggingCategory = "AdsConsent"

    private(set) var isAdsReady = false
    private(set) var isPrivacyOptionsRequired = false

    private let logger: MHLogger
    private let mobileAdsController: GoogleMobileAdsController?

    private var isAdsEligible = false
    private var hasUpdatedConsentInformation = false
    private var hasRequestedConsent = false
    private var hasStartedRequiredFormFlow = false
    private var hasStartedMobileAds = false

    var isConfigured: Bool {
        mobileAdsController != nil
    }

    init(
        adUnitID: String?,
        logger: MHLogger
    ) {
        self.logger = logger

        let normalizedAdUnitID = adUnitID?.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        if let normalizedAdUnitID,
           normalizedAdUnitID.isEmpty == false {
            mobileAdsController = .init(adUnitID: normalizedAdUnitID)
        } else {
            mobileAdsController = nil
        }
    }

    func requestConsentAndStartAdsIfAllowed() {
        guard isConfigured,
              hasRequestedConsent == false else {
            return
        }

        hasRequestedConsent = true
        logger.notice("ads_consent.update_requested")

        ConsentInformation.shared.requestConsentInfoUpdate(
            with: RequestParameters()
        ) { [weak self] error in
            Task { @MainActor in
                self?.handleConsentInformationUpdate(error: error)
            }
        }
    }

    func setAdsEligibility(_ isEligible: Bool) {
        isAdsEligible = isEligible
        presentRequiredFormIfEligible()
        refreshConsentStateAndStartAdsIfAllowed()
    }

    func presentPrivacyOptions(
        completion: @escaping @MainActor (Error?) -> Void
    ) {
        ConsentForm.presentPrivacyOptionsForm(from: nil) { [weak self] error in
            Task { @MainActor in
                self?.handlePrivacyOptionsPresentation(error: error)
                completion(error)
            }
        }
    }

    func makeStartAds() -> MHAppRuntime.StartAds? {
        guard isConfigured else {
            return nil
        }

        return { [weak self] in
            Task { @MainActor in
                self?.requestConsentAndStartAdsIfAllowed()
            }
        }
    }

    func makeNativeAdFactory() -> MHRuntimeNativeAdViewFactory? {
        guard let mobileAdsController else {
            return nil
        }

        return .init { size in
            IncomesConsentManagedNativeAdView(
                consentController: self,
                mobileAdsController: mobileAdsController,
                size: size
            )
        }
    }
}

private extension IncomesAdsConsentController {
    func handleConsentInformationUpdate(error: Error?) {
        if let error {
            logger.warning(
                "ads_consent.update_failed",
                metadata: IncomesLogging.errorMetadata(error)
            )
            refreshConsentStateAndStartAdsIfAllowed()
            return
        }

        hasUpdatedConsentInformation = true
        logger.notice("ads_consent.update_completed")
        refreshConsentStateAndStartAdsIfAllowed()
        presentRequiredFormIfEligible()
    }

    func presentRequiredFormIfEligible() {
        guard isAdsEligible,
              hasUpdatedConsentInformation,
              hasStartedRequiredFormFlow == false else {
            return
        }

        hasStartedRequiredFormFlow = true
        ConsentForm.loadAndPresentIfRequired(from: nil) { [weak self] error in
            Task { @MainActor in
                self?.handleRequiredFormPresentation(error: error)
            }
        }
    }

    func handleRequiredFormPresentation(error: Error?) {
        if let error {
            logger.warning(
                "ads_consent.required_form_failed",
                metadata: IncomesLogging.errorMetadata(error)
            )
        } else {
            logger.notice("ads_consent.required_form_completed")
        }

        refreshConsentStateAndStartAdsIfAllowed()
    }

    func handlePrivacyOptionsPresentation(error: Error?) {
        if let error {
            logger.warning(
                "ads_consent.privacy_options_failed",
                metadata: IncomesLogging.errorMetadata(error)
            )
        } else {
            logger.notice("ads_consent.privacy_options_completed")
        }

        refreshConsentStateAndStartAdsIfAllowed()
    }

    func refreshConsentStateAndStartAdsIfAllowed() {
        let consentInformation = ConsentInformation.shared
        isPrivacyOptionsRequired = consentInformation.privacyOptionsRequirementStatus == .required

        guard consentInformation.canRequestAds else {
            isAdsReady = false
            logger.notice("ads_consent.ads_blocked")
            return
        }

        guard isAdsEligible else {
            isAdsReady = false
            logger.notice("ads_consent.ads_disabled_by_premium")
            return
        }

        if hasStartedMobileAds == false {
            mobileAdsController?.start()
            hasStartedMobileAds = true
            logger.notice("ads_consent.ads_started")
        }

        isAdsReady = hasStartedMobileAds
    }
}
