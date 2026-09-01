import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nexus_smart_center/data/repositories/api_repository.dart';
import 'package:nexus_smart_center/data/repositories/auth_repository.dart';

enum ClaimStatus { idle, loading, claimSuccess, error }

class AddDeviceViewModel extends ChangeNotifier {
  final ApiRepository _apiRepository;
  final AuthRepository _authRepository;

  AddDeviceViewModel({
    required ApiRepository apiRepository,
    required AuthRepository authRepository,
  }) : _apiRepository = apiRepository,
       _authRepository = authRepository;

  ClaimStatus _claimStatus = ClaimStatus.idle;
  ClaimStatus get claimStatus => _claimStatus;

  String? _messageError;
  String? get messageError => _messageError;

  void claimHandler(dynamic data) {
    print(data);
    if (data['success'] == true && data['status'] == 'CLAIMED') {
      _claimStatus = ClaimStatus.claimSuccess;
      notifyListeners();
    }
  }

  Future<String> returnDeviceId() async {
    return 'SWITCH-AVSBSGTTFEFS';
  }

  Future<dynamic> getClaimToken(String deviceId) async {
    final tokenId = await _authRepository.getIdToken();

    return _apiRepository.claimToken(tokenId!, deviceId);
  }

  Future<bool> tokenClaimToDevice(dynamic data) async {
    return true;
  }

  Future<void> initClaimDevice() async {
    _claimStatus = ClaimStatus.loading;
    _messageError = null;

    notifyListeners();

    try {
      final deviceId = await returnDeviceId();

      final tokenClaim = await getClaimToken(deviceId);

      final success = await (tokenClaim);

      if (success) {
        await onClaimStatus(deviceId);
      }
    } catch (e) {
      _claimStatus = ClaimStatus.error;
      _messageError = e.toString();
      notifyListeners();
    }
  }

  Future<void> onClaimStatus(String deviceId) async {
    await _apiRepository.onEvent('claim_result', claimHandler);

    await _apiRepository.emitEvent('claim', {'uid': deviceId});
  }
}
