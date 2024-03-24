import 'dart:convert';

import 'package:ble_peripheral/ble_peripheral.dart';

String peripheralMessage = "";
const serviceUuid = "0000180F-0000-1000-8000-00805F9B34FB"; // Generate a unique UUID for your service
const characteristicUuid = "00002A19-0000-1000-8000-00805F9B34FB"; // Generate a unique UUID for your characteristic

class PeripheralServer {
  // final peripheral = PeripheralManager.instance;

  Future<void> startPeripheral() async {
    // Define a characteristic that allows writes
    // final characteristic = GattCharacteristic(
    //   uuid: UUID.fromString(characteristicUuid),
    //   properties: [ GattCharacteristicProperty.read, GattCharacteristicProperty.write, GattCharacteristicProperty.notify ],
    //   descriptors: [],
    //   value: Uint8List(0),
    // );

    // final advertisement = Advertisement(
    //   name: "This is a bluetooth server",
    //   serviceUUIDs: [ UUID.fromString(serviceUuid) ]
    // );

    if (!await BlePeripheral.askBlePermission()) {
      return;
    }

    final characteristic = BleCharacteristic(
      uuid: characteristicUuid, 
      properties: [
        (CharacteristicProperties.read.index),
        (CharacteristicProperties.write.index),
      ], 
      permissions: [
        // AttributePermissions.readable.index,
		AttributePermissions.writeable.index,
      ]
    );

    await BlePeripheral.addService(
      BleService(
        uuid: serviceUuid, 
        primary: true, 
        characteristics: [ characteristic ]
      ),
      timeout: const Duration(seconds: 15),
    );

    await BlePeripheral.startAdvertising(
      services: [ serviceUuid ], 
      localName: "This is a bluetooth server"
    );

    // await peripheral.addService(GattService(uuid: UUID.fromString(serviceUuid), characteristics: [characteristic]));

    // await peripheral.startAdvertising(advertisement);

    BlePeripheral.setWriteRequestCallback((deviceId, characteristicId, offset, value) {
        // if (characteristicId == characteristicUuid) {
          print("Received Data from $deviceId: ${value.toString()}");
		      peripheralMessage += utf8.decode(value ?? []);
        // }

        return WriteRequestResult(value: value, offset: offset);
    });

    // peripheral.characteristicWritten.listen((event) { 
    //   print("Recieved Data: ${event.value.toString()}");
    // });

    print('Peripheral is advertising...');
  }

  Future<void> stopPeripheral() async {
    // await peripheral.stopAdvertising();
    await BlePeripheral.stopAdvertising();
    
    // Optionally, remove services and clean up resources as needed
  }
}
