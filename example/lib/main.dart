import 'package:flutter/material.dart';
import 'package:gdpr_admob/gdpr_admob.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter GDPR dialog',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GdprAdmob gdprAdmob = GdprAdmob();
  bool _isLoading = false;
  String? _errorMessage;
  String? _consentStatus;

  Future<void> _initializeGdpr() async {
    setState(() {
      _isLoading = true;
    });

    final error = await gdprAdmob.initialize(
      mode: DebugGeography.debugGeographyEea,
      testIdentifiers: ["WRITE_YOUR_TEST_DEVICE_IDENTIFIERS"],
    );

    if (error != null) {
      setState(() {
        _errorMessage = error.message;
      });
    }

    setState(() {
      getStatus();
      _isLoading = false;
    });
  }

  getStatus() async {
    final status = await gdprAdmob.getConsentStatus();
    setState(() {
      _consentStatus = status;
    });
  }

  @override
  void initState() {
    getStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Flutter GDPR dialog"),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_consentStatus != "obtained")
                    ElevatedButton(
                      onPressed: _initializeGdpr,
                      child: const Text("Show GDPR dialog"),
                    ),
                  ElevatedButton(
                    onPressed: () async {
                      await gdprAdmob.resetConsentStatus();
                      getStatus();
                    },
                    child: const Text("Reset the consent state"),
                  ),
                  if (_consentStatus != null)
                    Text('Consent Status: $_consentStatus'),
                  if (_errorMessage != null) Text('Error: $_errorMessage'),
                ],
              ),
      ),
    );
  }
}
