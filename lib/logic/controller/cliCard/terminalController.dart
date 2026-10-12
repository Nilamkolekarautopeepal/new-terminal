import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:ap_dongle_comm/utils/commController.dart';
import 'package:ap_dongle_comm/utils/dongleComm.dart';
import 'package:ap_dongle_comm/utils/enums/command_ids.dart';
import 'package:ap_dongle_comm/utils/model/responseArrayStatusModel.dart';
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class TerminalController extends GetxController {
  var logs = <Map<String, dynamic>>[].obs;
  DongleComm? dongleComm;
  Uint8List txArray = Uint8List(4);
  Uint8List rxArray = Uint8List(4);
  CommController comm = Get.find<CommController>();
  var selectedHeader = "".obs;
  var firmwaron = "".obs;
  Timer? _responseTimeout;
  final int timeoutDuration = 3;
  final Map<String, int> headerMap = {
    "2": 0x20,
    "5": 0x50,
    "4": 0x40,
    "RP1210": -1,
  };

  final Map<String, int> channelMap = {
    "0": 0x00,
    "1": 0x01,
  };
  final box = GetStorage();
  var commandHistory = <String>[].obs;
  var selectedChannel = "0".obs;
  var isWaitingForResponse = false.obs;
  var connectivity = Get.find<CommController>().connectivity;
  var isConnected = Get.find<CommController>().isConnected;

  @override
  void onInit() {
    super.onInit();
    dongleComm = DongleComm(
        isChannel: true,
        channelId: (channelMap[selectedChannel.value] ?? 0).toString());
    loadHistory();
    if (Get.arguments != null) {
      isRp1210.value = Get.arguments['isRp1210'] ?? false;
      print(
          "📡 Connection Mode Set: ${isRp1210.value ? 'RP1210' : 'Standard WiFi'}");
    }
  }

  void loadHistory() {
    final stored = box.read<List>('commandHistory');
    if (stored != null) {
      commandHistory.assignAll(stored.cast<String>());
    }
  }

  void saveCommandHistory(String cmd) {
    commandHistory.remove(cmd);
    commandHistory.insert(0, cmd);

    if (commandHistory.length > 50) {
      commandHistory.removeLast();
    }

    // 🔥 Save to local storage
    box.write('commandHistory', commandHistory.toList());
  }

  void clearHistory() {
    commandHistory.clear();
    box.remove('commandHistory');
  }

  // void sendCommand(String userInput) async {
  //   if (dongleComm == null) {
  //     addLog("ERROR: Communication Controller not initialized", Colors.red);
  //     debugPrint("Crash prevented: dongleComm was null");
  //     return;
  //   }
  //   String cleanInput = userInput.trim().replaceAll(' ', '');
  //   saveCommandHistory(cleanInput);
  //   String keyHex = hex.encode(ascii.encode("Channel=")).toUpperCase();

  //   if (cleanInput.toUpperCase().contains(keyHex)) {
  //     try {
  //       int valuePos = cleanInput.toUpperCase().indexOf(keyHex) + keyHex.length;

  //       // Convert the UI-selected channel (e.g., "1") to ASCII Hex (e.g., "31")
  //       String selectedId = selectedChannel.value;
  //       String newChanHex = hex.encode(ascii.encode(selectedId)).toUpperCase();

  //       // Replace everything after "Channel=" with the new ASCII hex value
  //       cleanInput =
  //           cleanInput.replaceRange(valuePos, cleanInput.length, newChanHex);

  //       addLog(
  //           "Injected Channel: $selectedId (Hex: 0x$newChanHex)", Colors.cyan);
  //     } catch (e) {
  //       debugPrint("Channel injection failed: $e");
  //     }
  //   }

  //   int headerValue = headerMap[selectedHeader.value] ?? 0;
  //   isWaitingForResponse.value = true;

  //   try {
  //     if (isRp1210.value) {
  //       dongleComm!.isChannel = false;
  //       dongleComm!.channelId = null;

  //       Uint8List payload = hexToBytes(cleanInput);

  //       Uint8List fullPacket;

  //       bool isSystemCmd = cleanInput.startsWith("0000") ||
  //           cleanInput.startsWith("0009") ||
  //           cleanInput.startsWith("0022");

  //       if (isSystemCmd) {
  //         DWCommandId cmd = cleanInput.startsWith("0000")
  //             ? DWCommandId.clientConnect
  //             : DWCommandId.sendCommand;

  //         fullPacket = dongleComm!.getRP1210Command(cmd.value, payload);

  //         // Filter Logic
  //         if (cleanInput.startsWith("0009") && payload.length >= 12) {
  //           dongleComm!.rxArray = payload.sublist(8, 12);
  //         }
  //         // Flow Control Logic
  //         else if (cleanInput.startsWith("0022") && payload.length >= 12) {
  //           dongleComm!.rxArray = payload.sublist(3, 7);
  //           dongleComm!.txArray = payload.sublist(8, 12);
  //         }

  //         addLog("TX (SYS) > ${formatHex(fullPacket)}", Colors.white);
  //         Uint8List? resp = await comm.sendCommand(fullPacket);
  //         if (resp != null) {
  //           addLog("RX < ${formatHex(resp)}", Colors.greenAccent);
  //         }
  //       } else {
  //         if (dongleComm!.txArray.isEmpty) {
  //           addLog("ERROR: TX/RX IDs not set. Send Filter/FlowControl first.",
  //               Colors.orange);
  //           return;
  //         }

  //         int frameLength = cleanInput.length ~/ 2;
  //         ResponseArrayStatus result =
  //             await dongleComm!.can2xTxRx1(frameLength, cleanInput);

  //         if (result.ecuResponse != null) {
  //           Uint8List fullResp = result.ecuResponse!;
  //           addLog("RX < ${formatHex(fullResp)}", Colors.greenAccent);
  //           // if (fullResp.length >= 6) {
  //           //   Uint8List ecuOnly = fullResp.sublist(fullResp.length - 6);
  //           //   addLog("RX ECU < ${formatHex(ecuOnly)}", Colors.greenAccent);
  //           // } else {
  //           //   addLog("RX < ${formatHex(fullResp)}", Colors.greenAccent);
  //           // }
  //         }

  //         return;
  //       }
  //     } else if (headerValue == 0x40) {
  //       String hexChan =
  //           int.parse(selectedChannel.value).toRadixString(16).padLeft(2, '0');

  //       dongleComm!.isChannel = true;
  //       dongleComm!.channelId = hexChan;

  //       int frameLength = cleanInput.length ~/ 2;
  //       ResponseArrayStatus result =
  //           await dongleComm!.can2xTxRx1(frameLength, cleanInput);

  //       if (result.sentBytes != null) {
  //         addLog("TX > ${formatHex(result.sentBytes!)}", Colors.white);
  //       }

  //       if (result.ecuResponse != null) {
  //         addLog(
  //             "RX < ${formatHex(result.actualDataBytes!)}", Colors.greenAccent);
  //       }
  //     } else {
  //       Uint8List rawPayload = hexToBytes(cleanInput);
  //       int channelId = int.tryParse(selectedChannel.value) ?? 0;

  //       Uint8List finalPacket = await comm.wrapPacket(
  //         rawPayload,
  //         headerValue,
  //         channel: channelId,
  //       );

  //       addLog("TX (Wrapped) > ${formatHex(finalPacket)}", Colors.white);

  //       // Uint8List? resp = await comm.sendCommand(finalPacket);
  //       // if (resp != null) {
  //       //   addLog("RX < ${formatHex(resp)}", Colors.greenAccent);
  //       // }
  //       print("........................$finalPacket");
  //       addLog("TX (SYS) > ${formatHex(finalPacket)}", Colors.white);
  //       Uint8List? resp = await comm.sendCommand(finalPacket);
  //       addLog("TX (Wrapped) > ${formatHex(finalPacket)}", Colors.white);
  //       if (resp != null) {
  //         addLog("RX (LEN: ${resp.length}) < ${formatHex(resp)}",
  //             Colors.greenAccent);
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint("[ERROR] sendCommand: $e");
  //     addLog("ERROR: $e", Colors.red);
  //   } finally {
  //     isWaitingForResponse.value = false;
  //   }
  // }
  void sendCommand(String userInput) async {
    if (dongleComm == null) {
      addLog("ERROR: Communication Controller not initialized", Colors.red);
      return;
    }

    String cleanInput = userInput.trim().replaceAll(' ', '');
    saveCommandHistory(cleanInput);

    // --- Channel Injection Logic ---
    String keyHex = hex.encode(ascii.encode("Channel=")).toUpperCase();
    if (cleanInput.toUpperCase().contains(keyHex)) {
      try {
        int valuePos = cleanInput.toUpperCase().indexOf(keyHex) + keyHex.length;
        String selectedId = selectedChannel.value;
        String newChanHex = hex.encode(ascii.encode(selectedId)).toUpperCase();
        cleanInput =
            cleanInput.replaceRange(valuePos, cleanInput.length, newChanHex);
        addLog(
            "Injected Channel: $selectedId (Hex: 0x$newChanHex)", Colors.cyan);
      } catch (e) {
        debugPrint("Channel injection failed: $e");
      }
    }

    int headerValue = headerMap[selectedHeader.value] ?? 0;
    isWaitingForResponse.value = true;

    try {
      // PATH 1: RP1210 Mode
      if (isRp1210.value) {
        dongleComm!.isChannel = false;
        dongleComm!.channelId = null;
        Uint8List payload = hexToBytes(cleanInput);

        bool isSystemCmd = cleanInput.startsWith("0000") ||
            cleanInput.startsWith("0009") ||
            cleanInput.startsWith("0022");

        if (isSystemCmd) {
          DWCommandId cmd = cleanInput.startsWith("0000")
              ? DWCommandId.clientConnect
              : DWCommandId.sendCommand;

          Uint8List fullPacket =
              dongleComm!.getRP1210Command(cmd.value, payload);

          // Update internal logic for filters/flow control
          if (cleanInput.startsWith("0009") && payload.length >= 12) {
            dongleComm!.rxArray = payload.sublist(8, 12);
          } else if (cleanInput.startsWith("0022") && payload.length >= 12) {
            dongleComm!.rxArray = payload.sublist(3, 7);
            dongleComm!.txArray = payload.sublist(8, 12);
          }

          addLog("TX (SYS) > ${formatHex(fullPacket)}", Colors.white);
          Uint8List? resp = await comm.sendCommand(fullPacket);
          if (resp != null)
            addLog("RX < ${formatHex(resp)}", Colors.greenAccent);
        } else {
          // Standard RP1210 Data Transmission
          if (dongleComm!.txArray.isEmpty) {
            addLog("ERROR: TX/RX IDs not set. Send Filter/FlowControl first.",
                Colors.orange);
            return;
          }

          int frameLength = cleanInput.length ~/ 2;

          ResponseArrayStatus result =
              await dongleComm!.can2xTxRx(frameLength, cleanInput);

          // 🔥 Display the FULL Wrapped Packet (Header + CRC) on screen
          if (result.sentBytes != null) {
            addLog("TX FULL > ${formatHex(result.sentBytes!)}", Colors.white);
          }

          if (result.ecuResponse != null) {
            addLog(
                "RX < ${formatHex(result.ecuResponse!)}", Colors.greenAccent);
          }
        }
      }
      // PATH 2: CAN2x Header 0x40 Mode
      else if (headerValue == 0x40) {
        String hexChan =
            int.parse(selectedChannel.value).toRadixString(16).padLeft(2, '0');
        dongleComm!.isChannel = true;
        dongleComm!.channelId = hexChan;

        int frameLength = cleanInput.length ~/ 2;
        ResponseArrayStatus result =
            await dongleComm!.can2xTxRx(frameLength, cleanInput);

        if (result.sentBytes != null) {
          addLog("TX FULL > ${formatHex(result.sentBytes!)}", Colors.white);
        }

        if (result.ecuResponse != null) {
          addLog(
              "RX < ${formatHex(result.actualDataBytes!)}", Colors.greenAccent);
        }
      }
      // PATH 3: Standard Wrapped Packet (WiFi/USB)
      else {
        Uint8List rawPayload = hexToBytes(cleanInput);
        int channelId = int.tryParse(selectedChannel.value) ?? 0;

        Uint8List finalPacket = await comm.wrapPacket1(
          rawPayload,
          headerValue,
          channel: channelId,
        );

        // Log TX exactly once before sending
        addLog("TX (Wrapped) > ${formatHex(finalPacket)}", Colors.white);

        Uint8List? resp = await comm.sendCommand(finalPacket);
        if (resp != null) {
          addLog("RX (LEN: ${resp.length}) < ${formatHex(resp)}",
              Colors.greenAccent);
        }
      }
    } catch (e) {
      debugPrint("[ERROR] sendCommand: $e");
      addLog("ERROR: $e", Colors.red);
    } finally {
      isWaitingForResponse.value = false;
    }
  }

  int bytesToInt(Uint8List bytes) {
    return bytes.fold(0, (val, b) => (val << 8) + b);
  }

  String formatHex(Uint8List bytes) {
    return hex
        .encode(bytes)
        .toUpperCase()
        .replaceAllMapped(RegExp(r".{2}"), (match) => "${match.group(0)} ")
        .trim();
  }

  Uint8List hexToBytes(String hex) {
    if (hex.length % 2 != 0) hex = '0$hex';
    final result = Uint8List(hex.length ~/ 2);
    for (var i = 0; i < result.length; i++) {
      result[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return result;
  }

  String bytesToHex(Uint8List bytes) {
    return bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(' ');
  }

  void addLog(String message, Color color) {
    logs.add({'msg': message, 'color': color});
  }

  void clearLogs() {
    logs.clear();
    addLog("Terminal Cleared", Colors.white24);
  }

  RxBool isRp1210 = false.obs;
  // disconnectDevice() {
  //   print("🔎 Disconnect Mode = ${isRp1210.value}");
  //   print("🔎 Controller hash: ${hashCode}");
  //   if (isRp1210.value) {
  //     print("➡ RP1210 Disconnect");
  //     dongleComm?.rp1210ClientDisconnect();
  //   } else {
  //     print("➡ Standard Reset");
  //    comm.disconnectVCI();
  //   }
  // }
  disconnectDevice() async {
    print("🔎 Disconnect Mode = ${isRp1210.value}");

    try {
      if (isRp1210.value) {
        print("➡ RP1210 Disconnect");
        await dongleComm?.rp1210ClientDisconnect();
      } else {
        print("➡ Standard Reset");
        await comm.disconnectVCI();
      }
    } catch (e) {
      print("Error during disconnect: $e");
    }

    // 🔥 IMPORTANT: Navigate back to the previous page (JobCardDetails)
    Get.back();
  }

  TerminalController() {
    print("🆕 TerminalController CREATED: ${hashCode}");
  }
  @override
  void onClose() {
    _responseTimeout?.cancel();
    super.onClose();
  }
}
