import 'package:flutter/material.dart';
import 'dart:async';

class Console extends StatefulWidget {
  const Console({super.key});

  @override
  State<Console> createState() => ConsoleState();
}

enum ConsoleLogType {
  error,
  info,
}

enum ConsoleLogSender {
  user,
  cpu,
}

class ConsoleLog {
  final ConsoleLogType type;
  final DateTime time;
  final String message;
  final ConsoleLogSender sender;

  ConsoleLog({
    required this.sender,
    required this.message,
    this.type = ConsoleLogType.info,
    DateTime? time
  }) : time = time ?? DateTime.now();
}

final cpuMessage = ConsoleLog(sender: ConsoleLogSender.cpu, message: "Computer says no", type: ConsoleLogType.error);
final loadingMessage = ConsoleLog(sender: ConsoleLogSender.cpu, message: "...");

class ConsoleState extends State<Console> {
  final List<ConsoleLog> allLogs = [];
  Timer? messageTimer;
  final ScrollController scrollController = ScrollController();
  
  void addUserLog(ConsoleLog log) {
    addLog(log);
    triggerCPULog();
  }

  void addCPULog(ConsoleLog log) {
    addLog(log);
    messageTimer = null;
  }

  void addLog(ConsoleLog log) {
    setState(() {
      allLogs.add(log);
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToBottom();
    });
  }

  void triggerCPULog() {
    messageTimer?.cancel();
    setState(() {
      messageTimer = Timer(const Duration(seconds: 3), () {
        addCPULog(cpuMessage);
      });
    });
  }

  void scrollToBottom() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Expanded(child: ListView.builder(
            controller: scrollController,
            itemBuilder: (context, index) => ConsoleLogMessage(allLogs[index]),
            itemCount: allLogs.length,
          )),
          ConsoleLogSubmitter(onSubmitted: (log) {
            addUserLog(log);
          }),
        ],
      )
    );
  }
}

class ConsoleLogSubmitter extends StatefulWidget {
  final void Function(ConsoleLog) onSubmitted;

  const ConsoleLogSubmitter({super.key, required this.onSubmitted});

  @override
  State<ConsoleLogSubmitter> createState() => ConsoleLogSubmitterState();
}

class ConsoleLogSubmitterState extends State<ConsoleLogSubmitter> {
  final currentLogController = TextEditingController();

  void submitLog() {
    if(currentLogController.text.isEmpty) return;

    widget.onSubmitted(ConsoleLog(message: currentLogController.text, sender: ConsoleLogSender.user));
    currentLogController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(child: Row(
      children: [
        Expanded(child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Command"
              ),
              controller: currentLogController,
              onSubmitted: (String value) { submitLog(); }
              )
            )
          ),
        ),
        IconButton(onPressed: submitLog, icon: const Icon(Icons.send)),
      ],
    ));
  }
}

class ConsoleLogMessage extends StatelessWidget {
  final ConsoleLog log;

  const ConsoleLogMessage(this.log, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: log.sender == ConsoleLogSender.cpu ? Alignment.centerLeft : Alignment.centerRight,
      child: Card(
        surfaceTintColor: log.type == ConsoleLogType.error ? Theme.of(context).colorScheme.error : (log.sender == ConsoleLogSender.cpu ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.primary),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(log.message, style: TextStyle(color: log.type == ConsoleLogType.error ? Colors.red : Colors.black)),
        ),
      ),
    );
  }
}