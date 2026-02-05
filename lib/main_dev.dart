import 'package:flutter/material.dart';
import 'main_common.dart';
import 'app_config.dart';

void main() async {
  AppConfig.initialize(Flavor.dev); // dev flavor
  await mainCommon();
}
