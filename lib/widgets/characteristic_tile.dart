import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import "../utils/snackbar.dart";

import "descriptor_tile.dart";

class CharacteristicTile extends StatefulWidget {
  final BluetoothCharacteristic characteristic;
  final List<DescriptorTile> descriptorTiles;

  const CharacteristicTile({Key? key, required this.characteristic, required this.descriptorTiles}) : super(key: key);

  @override
  State<CharacteristicTile> createState() => _CharacteristicTileState();
}

class _CharacteristicTileState extends State<CharacteristicTile> {
  List<int> _value = [];

  late StreamSubscription<List<int>> _lastValueSubscription;

  @override
  void initState() {
    super.initState();
    _lastValueSubscription = widget.characteristic.lastValueStream.listen((value) {
      _value = value;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _lastValueSubscription.cancel();
    super.dispose();
  }

  BluetoothCharacteristic get c => widget.characteristic;

  List<int> _getRandomBytes() {
    final math = Random();
    return [math.nextInt(255), math.nextInt(255), math.nextInt(255), math.nextInt(255)];
  }

  Future onReadPressed() async {
    try {
      await c.read();
      Snackbar.show(ABC.c, "Read: Success", success: true);
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Read Error:", e), success: false);
    }
  }

  static const longMessage = r"""
    # Miscellaneous
    *.class
    *.log
    *.pyc
    *.swp
    .DS_Store
    .atom/
    .buildlog/
    .history
    .svn/
    migrate_working_dir/

    # IntelliJ related
    *.iml
    *.ipr
    *.iws
    .idea/

    # The .vscode folder contains launch configuration and tasks you configure in
    # VS Code which you may wish to be included in version control, so this line
    # is commented out by default.
    #.vscode/

    # Flutter/Dart/Pub related
    **/doc/api/
    **/ios/Flutter/.last_build_id
    .dart_tool/
    .flutter-plugins
    .flutter-plugins-dependencies
    .pub-cache/
    .pub/
    /build/

    # Symbolication related
    app.*.symbols

    # Obfuscation related
    app.*.map.json

    # Android Studio will place build artifacts here
    /android/app/debug
    /android/app/profile
    /android/app/release

    // This is a basic Flutter widget test.
    //
    // To perform an interaction with a widget in your test, use the WidgetTester
    // utility in the flutter_test package. For example, you can send tap and scroll
    // gestures. You can also use WidgetTester to find child widgets in the widget
    // tree, read text, and verify that the values of widget properties are correct.

    import 'package:flutter/material.dart';
    import 'package:flutter_test/flutter_test.dart';

    import 'package:bluetooth_test/main.dart';

    void main() {
      testWidgets('Counter increments smoke test', (WidgetTester tester) async {
        // Build our app and trigger a frame.
        await tester.pumpWidget(const MyApp());

        // Verify that our counter starts at 0.
        expect(find.text('0'), findsOneWidget);
        expect(find.text('1'), findsNothing);

        // Tap the '+' icon and trigger a frame.
        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();

        // Verify that our counter has incremented.
        expect(find.text('0'), findsNothing);
        expect(find.text('1'), findsOneWidget);
      });
    }

    # Project-level configuration.
    cmake_minimum_required(VERSION 3.14)
    project(bluetooth_test LANGUAGES CXX)

    # The name of the executable created for the application. Change this to change
    # the on-disk name of your application.
    set(BINARY_NAME "bluetooth_test")

    # Explicitly opt in to modern CMake behaviors to avoid warnings with recent
    # versions of CMake.
    cmake_policy(VERSION 3.14...3.25)

    # Define build configuration option.
    get_property(IS_MULTICONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
    if(IS_MULTICONFIG)
      set(CMAKE_CONFIGURATION_TYPES "Debug;Profile;Release"
        CACHE STRING "" FORCE)
    else()
      if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
        set(CMAKE_BUILD_TYPE "Debug" CACHE
          STRING "Flutter build mode" FORCE)
        set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
          "Debug" "Profile" "Release")
      endif()
    endif()
    # Define settings for the Profile build mode.
    set(CMAKE_EXE_LINKER_FLAGS_PROFILE "${CMAKE_EXE_LINKER_FLAGS_RELEASE}")
    set(CMAKE_SHARED_LINKER_FLAGS_PROFILE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE}")
    set(CMAKE_C_FLAGS_PROFILE "${CMAKE_C_FLAGS_RELEASE}")
    set(CMAKE_CXX_FLAGS_PROFILE "${CMAKE_CXX_FLAGS_RELEASE}")

    # Use Unicode for all projects.
    add_definitions(-DUNICODE -D_UNICODE)

    # Compilation settings that should be applied to most targets.
    #
    # Be cautious about adding new options here, as plugins use this function by
    # default. In most cases, you should add new options to specific targets instead
    # of modifying this function.
    function(APPLY_STANDARD_SETTINGS TARGET)
      target_compile_features(${TARGET} PUBLIC cxx_std_17)
      target_compile_options(${TARGET} PRIVATE /W4 /WX /wd"4100")
      target_compile_options(${TARGET} PRIVATE /EHsc)
      target_compile_definitions(${TARGET} PRIVATE "_HAS_EXCEPTIONS=0")
      target_compile_definitions(${TARGET} PRIVATE "$<$<CONFIG:Debug>:_DEBUG>")
    endfunction()

    # Flutter library and tool build rules.
    set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")
    add_subdirectory(${FLUTTER_MANAGED_DIR})

    # Application build; see runner/CMakeLists.txt.
    add_subdirectory("runner")


    # Generated plugin build rules, which manage building the plugins and adding
    # them to the application.
    include(flutter/generated_plugins.cmake)


    # === Installation ===
    # Support files are copied into place next to the executable, so that it can
    # run in place. This is done instead of making a separate bundle (as on Linux)
    # so that building and running from within Visual Studio will work.
    set(BUILD_BUNDLE_DIR "$<TARGET_FILE_DIR:${BINARY_NAME}>")
    # Make the "install" step default, as it's required to run.
    set(CMAKE_VS_INCLUDE_INSTALL_TO_DEFAULT_BUILD 1)
    if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
      set(CMAKE_INSTALL_PREFIX "${BUILD_BUNDLE_DIR}" CACHE PATH "..." FORCE)
    endif()

    set(INSTALL_BUNDLE_DATA_DIR "${CMAKE_INSTALL_PREFIX}/data")
    set(INSTALL_BUNDLE_LIB_DIR "${CMAKE_INSTALL_PREFIX}")

    install(TARGETS ${BINARY_NAME} RUNTIME DESTINATION "${CMAKE_INSTALL_PREFIX}"
      COMPONENT Runtime)

    install(FILES "${FLUTTER_ICU_DATA_FILE}" DESTINATION "${INSTALL_BUNDLE_DATA_DIR}"
      COMPONENT Runtime)

    install(FILES "${FLUTTER_LIBRARY}" DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
      COMPONENT Runtime)

    if(PLUGIN_BUNDLED_LIBRARIES)
      install(FILES "${PLUGIN_BUNDLED_LIBRARIES}"
        DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
        COMPONENT Runtime)
    endif()

    # Copy the native assets provided by the build.dart from all packages.
    set(NATIVE_ASSETS_DIR "${PROJECT_BUILD_DIR}native_assets/windows/")
    install(DIRECTORY "${NATIVE_ASSETS_DIR}"
      DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
      COMPONENT Runtime)

    # Fully re-copy the assets directory on each build to avoid having stale files
    # from a previous install.
    set(FLUTTER_ASSET_DIR_NAME "flutter_assets")
    install(CODE "
      file(REMOVE_RECURSE \"${INSTALL_BUNDLE_DATA_DIR}/${FLUTTER_ASSET_DIR_NAME}\")
      " COMPONENT Runtime)
    install(DIRECTORY "${PROJECT_BUILD_DIR}/${FLUTTER_ASSET_DIR_NAME}"
      DESTINATION "${INSTALL_BUNDLE_DATA_DIR}" COMPONENT Runtime)

    # Install the AOT library on non-Debug builds only.
    install(FILES "${AOT_LIBRARY}" DESTINATION "${INSTALL_BUNDLE_DATA_DIR}"
      CONFIGURATIONS Profile;Release
      COMPONENT Runtime)
  """;

  Future onWritePressed() async {
    try {
      var packetLength = longMessage.length ~/ c.device.mtuNow;

      if ((longMessage.length % c.device.mtuNow) != 0) {
        packetLength++;
      }

      for (var i = 0; i < packetLength; i++) {
        await c.write(utf8.encode(longMessage).sublist(i * c.device.mtuNow, (i+1) * c.device.mtuNow), withoutResponse: c.properties.writeWithoutResponse);
      }

      if ((longMessage.length % c.device.mtuNow) != 0) {
        await c.write(utf8.encode(longMessage).sublist(packetLength * c.device.mtuNow), withoutResponse: c.properties.writeWithoutResponse);
      }

      // await c.write(_getRandomBytes(), withoutResponse: c.properties.writeWithoutResponse);
      Snackbar.show(ABC.c, "Write: Success", success: true);
      if (c.properties.read) {
        await c.read();
      }
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Write Error:", e), success: false);
    }
  }

  Future onSubscribePressed() async {
    try {
      String op = c.isNotifying == false ? "Subscribe" : "Unubscribe";
      await c.setNotifyValue(c.isNotifying == false);
      Snackbar.show(ABC.c, "$op : Success", success: true);
      if (c.properties.read) {
        await c.read();
      }
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Subscribe Error:", e), success: false);
    }
  }

  Widget buildUuid(BuildContext context) {
    String uuid = '0x${widget.characteristic.uuid.str.toUpperCase()}';
    return Text(uuid, style: TextStyle(fontSize: 13));
  }

  Widget buildValue(BuildContext context) {
    String data = _value.toString();
    return Text(data, style: TextStyle(fontSize: 13, color: Colors.grey));
  }

  Widget buildReadButton(BuildContext context) {
    return TextButton(
        child: Text("Read"),
        onPressed: () async {
          await onReadPressed();
          if (mounted) {
            setState(() {});
          }
        });
  }

  Widget buildWriteButton(BuildContext context) {
    bool withoutResp = widget.characteristic.properties.writeWithoutResponse;
    return TextButton(
        child: Text(withoutResp ? "WriteNoResp" : "Write"),
        onPressed: () async {
          await onWritePressed();
          if (mounted) {
            setState(() {});
          }
        });
  }

  Widget buildSubscribeButton(BuildContext context) {
    bool isNotifying = widget.characteristic.isNotifying;
    return TextButton(
        child: Text(isNotifying ? "Unsubscribe" : "Subscribe"),
        onPressed: () async {
          await onSubscribePressed();
          if (mounted) {
            setState(() {});
          }
        });
  }

  Widget buildButtonRow(BuildContext context) {
    bool read = widget.characteristic.properties.read;
    bool write = widget.characteristic.properties.write;
    bool notify = widget.characteristic.properties.notify;
    bool indicate = widget.characteristic.properties.indicate;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (read) buildReadButton(context),
        if (write) buildWriteButton(context),
        if (notify || indicate) buildSubscribeButton(context),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: ListTile(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Characteristic'),
            buildUuid(context),
            buildValue(context),
          ],
        ),
        subtitle: buildButtonRow(context),
        contentPadding: const EdgeInsets.all(0.0),
      ),
      children: widget.descriptorTiles,
    );
  }
}
