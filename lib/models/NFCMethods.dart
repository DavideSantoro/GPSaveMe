// ignore_for_file: file_names
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import '../screens/SignUpNumber.dart';
import 'Status.dart';

Future<bool> isNFCAvailable() async {
  // Check availability
  bool b = await NfcManager.instance.isAvailable();
  return b;
}

getNFC(BuildContext context) async {
  ValueNotifier<dynamic> result = ValueNotifier(null);

  NfcManager.instance.startSession(
    onDiscovered: (NfcTag tag) async {
      result.value = tag.data;
      await pushReview(context);
    },
  );
}

ndefWrite(BuildContext context) async {
  ValueNotifier<dynamic> result = ValueNotifier(null);
  NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
    var ndef = Ndef.from(tag);
    if (ndef == null || !ndef.isWritable) {
      result.value = 'Tag is not ndef writable';
      NfcManager.instance.stopSession(errorMessage: result.value);
      return;
    }

    NdefMessage message = NdefMessage([
      NdefRecord.createText(u!.phoneNumber),
      NdefRecord.createUri(Uri.parse('https://flutter.dev')),
      NdefRecord.createMime(
          'text/plain', Uint8List.fromList(u!.phoneNumber.codeUnits)),
      NdefRecord.createExternal(
          'com.example', 'mytype', Uint8List.fromList('mydata'.codeUnits)),
    ]);

    try {
      await ndef.write(message);
      result.value = 'Success to "Ndef Write"';
      NfcManager.instance.stopSession();
    } catch (e) {
      result.value = e;
      NfcManager.instance.stopSession(errorMessage: result.value.toString());
    }
    // ignore: use_build_context_synchronously
    await pushReview(context);
  });
}

pushReview(BuildContext context) async {
  Status.setAllFalse();
  await u!.deleteProposalFiles();
  await u!.restoreJson();
}
