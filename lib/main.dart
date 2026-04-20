import 'package:dariziflow_app/app/app.dart';
import 'package:dariziflow_app/data/services/notifications_service.dart';
import 'package:dariziflow_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GetStorage.init();
  await Get.putAsync(() => NotificationService().init());
  runApp(const MyApp());
}
