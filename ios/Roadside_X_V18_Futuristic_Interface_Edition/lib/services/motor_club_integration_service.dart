import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/motor_club.dart';

class IntegrationResult {
  const IntegrationResult({
    required this.ok,
    required this.message,
    this.statusCode,
  });
  final bool ok;
  final String message;
  final int? statusCode;
}

class MotorClubIntegrationService {
  const MotorClubIntegrationService();

  Future<IntegrationResult> testConnector(PartnerConnector connector) async {
    if (connector.mode == IntegrationMode.manual ||
        connector.mode == IntegrationMode.csv ||
        connector.mode == IntegrationMode.email) {
      return const IntegrationResult(
        ok: true,
        message: 'Local connector configuration is valid.',
      );
    }
    final endpoint = Uri.tryParse(connector.endpoint.trim());
    if (endpoint == null || !endpoint.hasScheme) {
      return const IntegrationResult(
        ok: false,
        message: 'Enter a valid HTTPS endpoint supplied by the partner.',
      );
    }
    try {
      final response = await http
          .get(endpoint, headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 12));
      return IntegrationResult(
        ok: response.statusCode >= 200 && response.statusCode < 400,
        statusCode: response.statusCode,
        message: 'Partner endpoint responded with HTTP ${response.statusCode}.',
      );
    } catch (error) {
      return IntegrationResult(
        ok: false,
        message: 'Connection test failed: $error',
      );
    }
  }

  String exportDispatchJson(ClubDispatch dispatch) =>
      const JsonEncoder.withIndent('  ').convert(dispatch.toJson());
}
