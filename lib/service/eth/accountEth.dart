import 'dart:convert';

import 'package:polkawallet_sdk/service/index.dart';

class ServiceAccountEth {
  ServiceAccountEth(this.serviceRoot);

  final SubstrateService serviceRoot;

  /// Get icons of addresses
  /// return svg strings
  Future<List?> getAddressIcons(List addresses) async {
    final dynamic res = await serviceRoot.webView!
        .evalJavascript('eth.account.genIcons(${jsonEncode(addresses)})');
    return res;
  }

  Future<String> getNativeTokenBalance(String address) async {
    final String? res = await serviceRoot.webView!
        .evalJavascript('eth.account.getEthBalance("$address")');
    return res ?? '0';
  }

  Future<List?> getTokenBalance(
      String address, List<String> contractAddresses) async {
    final List? res = await serviceRoot.webView!.evalJavascript(
        'eth.account.getTokenBalance("$address", ${jsonEncode(contractAddresses)})');
    return res;
  }

  /// Validate address
  /// return checksumed address or null
  Future<String?> getAddress(String address) async {
    final String? res = await serviceRoot.webView!
        .evalJavascript('eth.account.getAddress("$address")');
    return res;
  }
}
