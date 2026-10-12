import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terminal/logic/controller/cliCard/terminalController.dart';
import 'package:terminal/routes/routes_string.dart';

class TerminalView extends StatelessWidget {
  final TerminalController controller = Get.find<TerminalController>();
  final Color primaryColor = const Color(0xFFFF7A00);
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  TerminalView({super.key});

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Device Terminal",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, color: Colors.white),
            onPressed: () => controller.clearLogs(),
            tooltip: "Clear Terminal",
          ),
          IconButton(
            icon: const Icon(Icons.link_off, color: Colors.white),
            onPressed: () async {
              await controller.disconnectDevice(); // create this in controller
              Get.offAllNamed(Routes.cliCard);
            },
            tooltip: "Disconnect",
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header Selection ---
                  const Text("Select Start Header",
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey)),
                  const SizedBox(height: 8),
                  Obx(() => Wrap(
                        spacing: 10,
                        children: controller.headerMap.keys.map((label) {
                          bool isSelected =
                              controller.selectedHeader.value == label;
                          return ChoiceChip(
                            label: Text(label),
                            selected: isSelected,
                            selectedColor: primaryColor,
                            labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold),
                            onSelected: (selected) => controller
                                .selectedHeader.value = selected ? label : "",
                          );
                        }).toList(),
                      )),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                  ),

                  // --- Channel ID Selection ---
                  const Text("Select Channel ID",
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey)),
                  const SizedBox(height: 8),
                  // Inside TerminalView
                  Obx(() => Wrap(
                        spacing: 10,
                        children: controller.channelMap.keys.map((channel) {
                          // This comparison now works because both are "0"
                          bool isSelected =
                              controller.selectedChannel.value == channel;

                          return ChoiceChip(
                            label: Text("Channel $channel"),
                            selected: isSelected,
                            selectedColor: Colors.blueGrey[600],
                            onSelected: (selected) {
                              if (selected) {
                                controller.selectedChannel.value = channel;
                              }
                            },
                          );
                        }).toList(),
                      )),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4))
                  ],
                ),
                child: Obx(() {
                  if (controller.logs.isNotEmpty) _scrollToBottom();

                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: controller.logs.length,
                    itemBuilder: (context, index) {
                      final log = controller.logs[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: SelectableText(
                          log['msg'] ?? "",
                          style: TextStyle(
                            color: log['color'] ?? Colors.greenAccent,
                            fontFamily: 'monospace',
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 12, right: 12, bottom: 16, top: 4),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: primaryColor.withOpacity(0.5)),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2))
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    const Icon(Icons.terminal, color: Colors.grey, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(() {
                        return Row(
                          children: [
                            if (controller.selectedHeader.value.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Text(
                                  "Header ${controller.selectedHeader.value}:",
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            Expanded(
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  textSelectionTheme:
                                      const TextSelectionThemeData(
                                    selectionColor: Colors.blue,
                                    selectionHandleColor: Colors.blue,
                                    cursorColor: Colors.black,
                                  ),
                                ),
                                child: TextField(
                                  controller: _inputController,
                                  cursorColor: Colors.black,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'monospace',
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                  onSubmitted: (value) => _handleSend(),
                                ),
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.history,
                                  color: Colors.black),
                              itemBuilder: (context) {
                                return controller.commandHistory.map((cmd) {
                                  return PopupMenuItem<String>(
                                    value: cmd,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(child: Text(cmd)),
                                        GestureDetector(
                                          onTap: () {
                                            // Remove the command from history
                                            controller.commandHistory
                                                .remove(cmd);
                                            // Refresh the UI if using setState or GetX
                                            controller.update();
                                            Get.back(); // if using GetX's update() method
                                          },
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.red,
                                            size: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList();
                              },
                              onSelected: (value) {
                                _inputController.text = value;
                              },
                            )
                          ],
                        );
                      }),
                    ),
                    Obx(() => controller.isWaitingForResponse.value
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Color(0xFFFF7A00))),
                          )
                        : IconButton(
                            icon: Icon(Icons.send_rounded, color: primaryColor),
                            onPressed: _handleSend,
                          )),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSend() {
    if (_inputController.text.trim().isNotEmpty) {
      controller.sendCommand(_inputController.text.trim());
      _inputController.clear();
    }
  }
}
