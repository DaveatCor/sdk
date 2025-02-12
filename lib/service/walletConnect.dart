import 'dart:async';
import 'dart:convert';

import 'package:polkawallet_sdk/service/index.dart';

class ServiceWalletConnect {
  ServiceWalletConnect(this.serviceRoot);

  final SubstrateService serviceRoot;

  void initClient(
    String uri,
    String address,
    int chainId, {
    required Function(Map) onPairing,
    required Function(Map) onPaired,
    required Function(Map) onCallRequest,
    required Function(String) onDisconnect,
    Map? cachedSession,
  }) {
    if (cachedSession != null) {
      serviceRoot.webView!.evalJavascript(
          'walletConnect.reConnectSession(${jsonEncode(cachedSession)})');
    } else {
      serviceRoot.webView!.evalJavascript(
          'walletConnect.initConnect("$uri", "$address", $chainId)');
    }
    serviceRoot.webView!.addMsgHandler("wallet_connect_message", (data) {
      final event = data['event'];
      switch (event) {
        case 'session_request':
          onPairing(data['peerMeta']);
          break;
        case 'connect':
          onPaired(data['session']);
          break;
        case 'call_request':
          onCallRequest(data);
          break;
        case 'disconnect':
          onDisconnect(uri);
          break;
      }
    });
  }

  Future<void> disconnect() async {
    await serviceRoot.webView!.evalJavascript('walletConnect.disconnect()');
    serviceRoot.webView!.removeMsgHandler("wallet_connect_message");
  }

  Future<void> confirmPairing(bool approve) async {
    await serviceRoot.webView!
        .evalJavascript('walletConnect.confirmConnect($approve)');
  }

  Future<Map> confirmPayload(
      int id, bool approve, String password, Map gasOptions) async {
    final Map? res = await serviceRoot.webView!.evalJavascript(
        'walletConnect.confirmCallRequest($id, $approve, "$password", ${jsonEncode(gasOptions)})');
    return res ?? {};
  }

  Future<void> changeAccount(String address) async {
    await serviceRoot.webView!
        .evalJavascript('walletConnect.updateSession({address: "$address"})');
  }

  Future<void> changeNetwork(int chainId, String address) async {
    await serviceRoot.webView!.evalJavascript(
        'walletConnect.updateSession({address: "$address", chainId: $chainId})');
  }
}
