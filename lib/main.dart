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