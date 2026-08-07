import 'package:flutter/material.dart';
import 'package:nexus_smart_center/data/repositories/api_repository.dart';

class AddDeviceViewModel extends ChangeNotifier {
  final ApiRepository _apiRepository;

  AddDeviceViewModel({required ApiRepository apiRepository})
    : _apiRepository = apiRepository;
}
