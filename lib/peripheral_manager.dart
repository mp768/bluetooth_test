import 'dart:typed_data';

import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';

class PeripheralServer {
  final peripheral = PeripheralManager.instance;

  Future<void> startPeripheral() async {
    const serviceUuid = "12345678-1234-5678-1234-567812345678"; // Generate a unique UUID for your service
    const characteristicUuid = "87654321-4321-6789-4321-678943216789"; // Generate a unique UUID for your characteristic

    // Define a characteristic that allows writes
    final characteristic = GattCharacteristic(
      uuid: UUID.fromString(characteristicUuid),
      properties: [ GattCharacteristicProperty.read, GattCharacteristicProperty.write, GattCharacteristicProperty.notify ],
      descriptors: [],
      value: Uint8List(0),
    );

    final advertisement = Advertisement(
      name: "This is a bluetooth server",
      serviceUUIDs: [ UUID.fromString(serviceUuid) ]
    );

    await peripheral.addService(GattService(uuid: UUID.fromString(serviceUuid), characteristics: [characteristic]));

    await peripheral.startAdvertising(advertisement);

    peripheral.characteristicWritten.listen((event) { 
      print("Recieved Data: ${event.value.toString()}");
    });

    print('Peripheral is advertising...');
  }

  Future<void> stopPeripheral() async {
    await peripheral.stopAdvertising();
    // Optionally, remove services and clean up resources as needed
  }
}
