import 'dart:convert';
import 'package:http/http.dart' as http;

class VodafoneService {
  static const Map<String, String> _base = {
    'User-Agent': 'okhttp/4.11.0',
    'Connection': 'Keep-Alive',
    'Accept-Encoding': 'gzip',
    'x-agent-operatingsystem': '13',
    'clientId': 'AnaVodafoneAndroid',
    'Accept-Language': 'ar',
    'x-agent-device': 'OPPO CPH2235',
    'x-agent-version': '2024.7.2.1',
    'x-agent-build': '1050',
    'digitalId': '24S0M31T0I9RK',
  };

  Future<Map<String, dynamic>> getSeamlessToken() async {
    final url = Uri.parse('http://mobile.vodafone.com.eg/checkSeamless/realms/vf-realm/protocol/openid-connect/auth?client_id=ana-vodafone-app-seamless');
    final res = await http.get(url, headers: _base);
    return json.decode(res.body);
  }

  Future<String?> getAccessToken(String seamlessToken) async {
    final url = Uri.parse('https://mobile.vodafone.com.eg/auth/realms/vf-realm/protocol/openid-connect/token');
    final headers = {..._base, 'Accept': 'application/json', 'silentLogin': 'true', 'seamlessToken': seamlessToken, 'firstTimeLogin': 'true'};
    final res = await http.post(url, headers: headers, body: {
      'grant_type': 'password',
      'client_secret': 'b86e30a8-ae29-467a-a71f-65c73f2ff5e3',
      'client_id': 'cash-app',
    });
    return json.decode(res.body)['access_token'];
  }

  Future<Map<String, dynamic>> chargeCard({
    required String productId,
    required String receiver,
    required String pin,
    required String senderMsisdn,
    required String accessToken,
  }) async {
    final url = Uri.parse('https://mobile.vodafone.com.eg/services/dxl/pom/productOrder');
    final headers = {
      ..._base,
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'api-host': 'ProductOrderingManagement',
      'useCase': 'CashFakkaAndMared',
      'api-version': 'v2',
      'msisdn': senderMsisdn.startsWith('0') ? senderMsisdn : '0$senderMsisdn',
      'Authorization': 'Bearer $accessToken',
    };
    final body = json.encode({
      'channel': {'name': 'MobileApp'},
      'orderItem': [{
        'action': 'insert',
        'id': productId,
        'product': {
          'characteristic': [
            {'name': 'PaymentMethod', 'value': 'VFCash'},
            {'name': 'USE_EMONEY', 'value': 'False'},
            {'name': 'MerchantCode', 'value': ''},
          ],
          'id': productId,
          'relatedParty': [
            {'id': senderMsisdn, 'name': 'MSISDN', 'role': 'Subscriber'},
            {'id': receiver, 'name': 'Receiver', 'role': 'Receiver'},
          ],
        },
        '@type': productId,
        'eCode': 0,
      }],
      'relatedParty': [{'id': pin, 'name': 'pin', 'role': 'Requestor'}],
      '@type': 'CashFakkaAndMared',
    });
    final res = await http.post(url, headers: headers, body: body);
    return json.decode(res.body);
  }
}
