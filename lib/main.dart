// import 'dart:isolate';
//
// void main() {
//   createIsolate();
// }
//
// Future createIsolate() async {
//   /// Where I listen to the message from Mike's port
//   ReceivePort myReceivePort = ReceivePort();
//
//   /// Spawn an isolate, passing my receivePort sendPort
//   Isolate.spawn<SendPort>(heavyComputationTask, myReceivePort.sendPort);
//
//   /// Mike sends a senderPort for me to enable me to send him a message via his sendPort.
//   /// I receive Mike's senderPort via my receivePort
//   SendPort mikeSendPort = await myReceivePort.first;
//
//   /// I set up another receivePort to receive Mike's response.
//   ReceivePort mikeResponseReceivePort = ReceivePort();
//
//   /// I send Mike a message using mikeSendPort. I send him a list,
//   /// which includes my message, preferred type of coffee, and finally
//   /// a sendPort from mikeResponseReceivePort that enables Mike to send a message back to me.
//   mikeSendPort.send([
//     "Mike, I'm taking an Espresso coffee",
//     "Espresso",
//     mikeResponseReceivePort.sendPort
//   ]);
//
//   /// I get Mike's response by listening to mikeResponseReceivePort
//   final mikeResponse = await mikeResponseReceivePort.first;
//   print("MIKE'S RESPONSE: ==== $mikeResponse");
// }
//
// void heavyComputationTask(SendPort mySendPort) async {
//   /// Set up a receiver port for Mike
//   ReceivePort mikeReceivePort = ReceivePort();
//
//   /// Send Mike receivePort sendPort via mySendPort
//   mySendPort.send(mikeReceivePort.sendPort);
//
//   /// Listen to messages sent to Mike's receive port
//   await for (var message in mikeReceivePort) {
//     if (message is List) {
//       final myMessage = message[0];
//       final coffeeType = message[1];
//       print(myMessage);
//
//       /// Get Mike's response sendPort
//       final SendPort mikeResponseSendPort = message[2];
//
//       /// Send Mike's response via mikeResponseSendPort
//       mikeResponseSendPort.send("You're taking $coffeeType, and I'm taking Latte");
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:isolate_handler/isolate_handler.dart';

final isolates = IsolateHandler();
int counter = 0;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Start the isolate at the `entryPoint` function.
  isolates.spawn<int>(entryPoint,
      name: "counter",
      // Executed every time data is received from the spawned isolate.
      onReceive: setCounter,
      // Executed once when spawned isolate is ready for communication.
      onInitialized: () => isolates.send(counter, to: "counter")
  );
}

// Set new count and display current count.
void setCounter(int count) {
  counter = count;
  print("Counter is now $counter");
}

// This function happens in the isolate.
// Important: `entryPoint` should be either at root level or a static function.
// Otherwise it will throw an exception.
void entryPoint(Map<String, dynamic> context) {
  // Calling initialize from the entry point with the context is
  // required if communication is desired. It returns a messenger which
  // allows listening and sending information to the main isolate.
  final messenger = HandledIsolate.initialize(context);

  // Triggered every time data is received from the main isolate.
  messenger.listen((count) async {
    // Add one to the count and send the new value back to the main
    // isolate.
    for (int i = 0; i < 1000; i++) {
      messenger.send(++count);
      await Future.delayed(const Duration(seconds: 1));
    }
  });
}