import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

void main() {
  runApp(const ExampleApplication());
}

class ExampleApplication extends StatelessWidget {
  const ExampleApplication({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Bluetooth Serial Example'),
        ),
        body: const BluetoothScreen(),
      ),
    );
  }
}

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({Key? key}) : super(key: key);

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  List<BluetoothDevice> _devices = [];
  bool _isDiscovering = false;
  BluetoothConnection? _connection;
  String _receivedData = '';
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  Future<void> _initBluetooth() async {
    // Check if Bluetooth is available and enabled
    bool? isAvailable = await _bluetooth.isAvailable;
    bool? isEnabled = await _bluetooth.isEnabled;

    if (isAvailable != true) {
      // Handle Bluetooth not available
      return;
    }

    if (isEnabled != true) {
      // Request to enable Bluetooth
      await _bluetooth.requestEnable();
    }

    // Get bonded devices
    List<BluetoothDevice> bondedDevices = await _bluetooth.getBondedDevices();
    setState(() {
      _devices = bondedDevices;
    });
  }

  Future<void> _startDiscovery() async {
    setState(() {
      _isDiscovering = true;
      _devices.clear();
    });

    // Get already bonded devices
    List<BluetoothDevice> bondedDevices = await _bluetooth.getBondedDevices();
    setState(() {
      _devices = bondedDevices;
    });

    // Start discovery
    _bluetooth.startDiscovery().listen((BluetoothDiscoveryResult result) {
      setState(() {
        // Add device if not already in list
        if (!_devices.any((device) => device.address == result.device.address)) {
          _devices.add(result.device);
        }
      });
    }).onDone(() {
      setState(() {
        _isDiscovering = false;
      });
    });
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      BluetoothConnection connection =
          await BluetoothConnection.toAddress(device.address);

      setState(() {
        _connection = connection;
      });

      // Listen for incoming data
      connection.input!.listen((Uint8List data) {
        setState(() {
          _receivedData += String.fromCharCodes(data);
        });
      }).onDone(() {
        // Connection closed
        setState(() {
          _connection = null;
        });
      });
    } catch (exception) {
      // Handle connection error
      print('Cannot connect, exception occurred: $exception');
    }
  }

  Future<void> _sendMessage() async {
    if (_connection != null && _connection!.isConnected) {
      String message = _textController.text;
      if (message.isNotEmpty) {
        _connection!.output.add(Uint8List.fromList(message.codeUnits));
        await _connection!.output.allSent;
        _textController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Paired Devices:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: _devices.length,
              itemBuilder: (context, index) {
                BluetoothDevice device = _devices[index];
                return Card(
                  child: ListTile(
                    title: Text(device.name ?? 'Unknown Device'),
                    subtitle: Text(device.address),
                    trailing: _connection?.isConnected == true
                        ? const Icon(Icons.bluetooth_connected, color: Colors.green)
                        : null,
                    onTap: () => _connectToDevice(device),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton(
                onPressed: _isDiscovering ? null : _startDiscovery,
                child: Text(_isDiscovering ? 'Discovering...' : 'Discover Devices'),
              ),
              const SizedBox(width: 10),
              if (_connection != null)
                ElevatedButton(
                  onPressed: () {
                    _connection?.finish();
                    setState(() {
                      _connection = null;
                    });
                  },
                  child: const Text('Disconnect'),
                ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Send Message:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: 'Enter message...',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _sendMessage,
                child: const Text('Send'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Received Data:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5),
              ),
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Text(_receivedData.isEmpty ? 'No data received' : _receivedData),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _connection?.dispose();
    _textController.dispose();
    super.dispose();
  }
}
