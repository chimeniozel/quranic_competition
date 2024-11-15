import 'package:permission_handler/permission_handler.dart';

// Future<void> requestPermission({required Permission permissin}) async {
//   // final status = await permissin.status;
//   // if(status.isGranted){
//   //   print('Permission already granted');

//   // } else if(status.isDenied) {
//   //   if(await permissin.request().isGranted){
//   //     print('Permission granted');
//   //   } else {
//   //     print('Permission denied');
//   //   }
//   // } else {
//   //   print('Permission is denied');
//   // }
//   PermissionStatus status = await Permission.storage.request();
//   if (status.isGranted) {
//     // Proceed with the operation
//     print('Permission granted');
//   } else if (status.isPermanentlyDenied) {
//     // Open app settings to let the user grant permission manually
//     await openAppSettings();
//   }
// }

Future<void> performExternalStorageTask() async {
  // Check and request permission if not already granted
  if (await Permission.manageExternalStorage.isGranted) {
    // Permission is granted; proceed with the main task
    await yourMainTask();
  } else {
    // Request the permission
    var status = await Permission.manageExternalStorage.request();

    if (status.isGranted) {
      // Permission granted; proceed with the main task
      await yourMainTask();
    } else {
      // Permission denied; handle this case
      print("Permission denied for MANAGE_EXTERNAL_STORAGE.");
      // Show a message to the user or log an error
    }
  }
}

// Replace this function with your main functionality
Future<void> yourMainTask() async {
  // Code that requires external storage access goes here
  print("Performing external storage task...");
  // Example: Access files, read data, or perform your specific task
}

