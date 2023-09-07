import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walletconnect_flutter_v2/apis/core/pairing/utils/pairing_models.dart';
import 'package:walletconnect_flutter_v2/apis/sign_api/models/proposal_models.dart';
import 'package:walletconnect_flutter_v2/apis/sign_api/models/session_models.dart';
import 'package:walletconnect_flutter_v2/apis/sign_api/models/sign_client_models.dart';
import 'package:walletconnect_flutter_v2/apis/sign_api/sign_client.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetching Wallet Address',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late SignClient wcClient;

  @override
  void initState() {
    super.initState();
  }

  String? _walletAddress;
  Uri? uri;
  late int id;

  connectWithMetamask() async {
    //init the client:

    SignClient signClient = await SignClient.createInstance(
      //create an account on https://cloud.walletconnect.com/sign-in and get your project id to use
      projectId: "PROJECT_ID",
      metadata: const PairingMetadata(
        name: 'any name',
        description:
        'any desc',
        url: 'any link to your project',
        icons: [
          'any icon image'
        ],
      ),
    );

    //here we prepare the response we are requesting from the wallet
    ConnectResponse response = await signClient.connect(   requiredNamespaces: {
      'eip155': const RequiredNamespace(
        chains: ['eip155:5'], // Ethereum chain
        methods: ['eth_signTransaction'], // Requestable Methods
        events: ['eth_sendTransaction'], // Requestable Events
      ),


    });

    // now we launch the uri to get a response
    await launchUrl(response.uri!);

    //get the session + wallet address:
    SessionData sessionData = await response.session.future;


    String walletAddress = sessionData
        .namespaces['eip155']!.accounts.first
        .replaceAll("eip155:5:", "");

    debugPrint("myResponse: $walletAddress");

    setState(() {
      _walletAddress = walletAddress;
    });

  }


    @override
    Widget build(BuildContext context) {
      return Scaffold(
          body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'Connect to Metamask',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold),
                      ),
                      Image.network(
                        "https://penntoday.upenn.edu/sites/default/files/2022-01/cryptocurrency-main_1.jpg",
                        fit: BoxFit.contain,
                      ),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: Container(
                              height: 200,
                              width: double.infinity,
                              // decoration: BoxDecoration(
                              //   color: Colors.white.withOpacity(0.2),
                              //   borderRadius: BorderRadius.circular(40),
                              // ),
                              child: Column(
                                children: <Widget>[
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Login using your metamask to get the wallet address',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  (_walletAddress == null)
                                      ? ElevatedButton(
                                    onPressed: () => connectWithMetamask(),
                                    child: const Text ('Connect your wallet'),
                                  )
                                      : Container(
                                    margin: const EdgeInsets.all(15),
                                    child: Text(
                                      "Wallet address: $_walletAddress",
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(height: 10,)
                    ],
                  ))));
    }
  }

