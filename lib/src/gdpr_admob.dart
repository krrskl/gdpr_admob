import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class GdprAdmob {
  Future<FormError?> initialize(
      {DebugGeography mode = DebugGeography.debugGeographyEea,
      required List<String> testIdentifiers}) async {
    final completer = Completer<FormError?>();

    final params = ConsentRequestParameters(
      consentDebugSettings: ConsentDebugSettings(
        debugGeography: mode,
        testIdentifiers: testIdentifiers,
        // Or DebugGeography.debugGeographyNotEea to simulate outside of the EEA
      ),
    );
    ConsentInformation.instance.requestConsentInfoUpdate(params, () async {
      if (await ConsentInformation.instance.isConsentFormAvailable()) {
        await _loadConsentForm(testIdentifiers);
      } else {
        // There is no message to display,
        // so initialize the components here.
        await _initialize(testIdentifiers);
      }

      completer.complete();
    }, (error) {
      completer.complete(error);
    });

    return completer.future;
  }

  Future<FormError?> _loadConsentForm(List<String> testIdentifiers) async {
    final completer = Completer<FormError?>();

    ConsentForm.loadConsentForm((consentForm) async {
      final status = await ConsentInformation.instance.getConsentStatus();
      if (status == ConsentStatus.required) {
        consentForm.show((formError) {
          completer.complete(_loadConsentForm(testIdentifiers));
        });
      } else {
        // The user has chosen an option,
        // it's time to initialize the ads component.
        await _initialize(testIdentifiers);
        completer.complete();
      }
    }, (FormError? error) {
      completer.complete(error);
    });

    return completer.future;
  }

  Future<void> _initialize(List<String> testIdentifiers) async {
    await MobileAds.instance.initialize().then((InitializationStatus status) {
      MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
            tagForChildDirectedTreatment:
                TagForChildDirectedTreatment.unspecified,
            testDeviceIds: testIdentifiers),
      );
    });
  }

  /// Returns the current consent status.
  ///
  /// This value is cached by the underlying mechanisms and not exactly reliable.
  Future<String> getConsentStatus() async {
    final status = await ConsentInformation.instance.getConsentStatus();
    switch (status) {
      case ConsentStatus.obtained:
        return "obtained";
      case ConsentStatus.required:
        return "required";
      case ConsentStatus.notRequired:
        return "notRequired";
      case ConsentStatus.unknown:
        return "unknown";
    }
  }

  /// Reset the consent status.
  Future resetConsentStatus() async {
    return await ConsentInformation.instance.reset();
  }
}
