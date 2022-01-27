library tickets;
import 'dart:async';
import 'dart:typed_data';

import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart' hide Image;

class Ticket {

  bool connected = false;

  setStateConnection(bool state) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('StateConnection', state);
  } 

  getStateConnection() async{
    String state = '';
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      state = prefs.getBool('StateConnection') as String;
      return state;
    } catch (e) {
      return state;
    }
  } 

  setMacAddres(String mac) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('Mac', mac);
  }

   Future<String>getMacAdress() async{
    String mac = '';
    try {
      WidgetsFlutterBinding.ensureInitialized();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      mac = prefs.getString('Mac') as String;
      return mac;
    } catch (e) {
      return mac;
    }
  }

  Future<List> getBluetooth() async {
    final List? bluetooths = await BluetoothThermalPrinter.getBluetooths;
    // print("Print $bluetooths");
    return bluetooths!;
  }

  Future<bool> setConnect(String mac) async {
    final String? result = await BluetoothThermalPrinter.connect(mac);
    print("state conneected $result");
    if (result == "true") {
      connected = true;
    }else{
      connected = false;
    }
    return connected;
  }

  Future<void> printTicketQuickli(String nombre, int total, Map<String, String> cobros) async {
    print(cobros);
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      List<int> bytes = await getTicketQuickli(nombre, total, cobros);
      final result = await BluetoothThermalPrinter.writeBytes(bytes);
      print("Print $result");
    } else {
      print('no imprimio prro');
    }
  }
  
  Future<List<int>> getTicketQuickli(String nombre, int total, Map<String, String> cobros) async {
    List<int> bytes = [];
    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);

    final ByteData data = await rootBundle.load('assets/images/logo.png');
    final Uint8List bytesIMG = data.buffer.asUint8List();
    final Image? image = decodeImage(bytesIMG);

    //IMPRECION DE UNA IMG
    bytes += generator.image(image!);

    bytes += generator.text(
      'QUICKLY',
      styles: PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size3,
        width: PosTextSize.size3
      ),
      linesAfter: 1
    );

    bytes += generator.text(
      nombre,
      styles: PosStyles(
        align: PosAlign.left
      )
    );

    bytes += generator.text(
      'Telefono: 0000000000',
      styles: PosStyles(
        align: PosAlign.center
      )
    );

    bytes += generator.hr(ch: '*', len: 29);

    bytes += generator.row([
      PosColumn(
          text: 'No',
          width: 1,
          styles: PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: 'Item',
          width: 4,
          styles: PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: 'Precio',
          width: 3,
          styles: PosStyles(align: PosAlign.center, bold: true)),
      PosColumn(
          text: 'Total',
          width: 2,
          styles: PosStyles(align: PosAlign.right, bold: true)),
      PosColumn(
          width: 2,
          styles: PosStyles(align: PosAlign.right, bold: true)),
    ]);

    bytes += generator.hr(ch: '*',len: 29);

    cobros.forEach((key, value) {
      bytes += generator.row([
        PosColumn(
            text: 1.toString(),
            width: 1,
            styles: PosStyles(align: PosAlign.left, bold: true)),
        PosColumn(
            text: key,
            width: 4,
            styles: PosStyles(align: PosAlign.left, bold: true)),
        PosColumn(
          
            text: '\$$value',
            width: 3,
            styles: PosStyles(align: PosAlign.center, bold: true)),
        PosColumn(
            text: value,
            width: 2,
            styles: PosStyles(align: PosAlign.right, bold: true)),
        PosColumn(
            width: 2,
            styles: PosStyles(align: PosAlign.right, bold: true)),
      ]);
    });

    
    bytes += generator.hr(ch: '=', len: 29);

    bytes += generator.row([
      PosColumn(
          text: 'TOTAL',
          width: 5,
          styles:const PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          )),
      PosColumn(
          text: total.toString(),
          width: 5,
          styles:const PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size3,
            width: PosTextSize.size3,
          )),
       PosColumn(
          width: 2,
          styles: PosStyles(align: PosAlign.right, bold: true)),
    ]);

    bytes += generator.hr(ch: '=', linesAfter: 1,len: 29);

    bytes += generator.text('Gracias por su atencion!',
        styles: PosStyles(align: PosAlign.center, bold: true));

    bytes += generator.text("26-11-2020 15:22:45",
        styles: PosStyles(align: PosAlign.center), linesAfter: 1);

    bytes += generator.row([
      PosColumn(
          text:'Nota:No nos hacemos',
          width:11,
          styles:const PosStyles(
            align: PosAlign.center,
            bold: false,
          )),
       PosColumn(
          width: 1,
          styles: PosStyles(align: PosAlign.right, bold: true)),
    ]);
    bytes += generator.row([
      PosColumn(
          text:'responsables',
          width:11,
          styles:const PosStyles(
            align: PosAlign.center,
            bold: false,
          )),
       PosColumn(
          width: 1,
          styles: PosStyles(align: PosAlign.right, bold: true)),
    ]);
    bytes += generator.row([
      PosColumn(
          text:'si los acesores se llevan ',
          width:11,
          styles:const PosStyles(
            align: PosAlign.center,
            bold: false,
          )),
       PosColumn(
          width: 1,
          styles: PosStyles(align: PosAlign.right, bold: true)),
    ]);
    bytes += generator.row([
      PosColumn(
          text:'su refrigerador',
          width:11,
          styles:const PosStyles(
            align: PosAlign.center,
            bold: false,
          )),
       PosColumn(
          width: 1,
          styles: PosStyles(align: PosAlign.right, bold: true)),
    ]);
    bytes += generator.feed(1);
      
    bytes += generator.qrcode('https://www.quicklyteapoya.com/');
        
    bytes += generator.cut();

    return bytes;
  }

  Future<List<int>> getTicketDePrueba() async {
    List<int> bytes = [];
    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);

    final ByteData data = await rootBundle.load('assets/images/logo.png');
    final Uint8List bytesIMG = data.buffer.asUint8List();
    final Image? image = decodeImage(bytesIMG);

    //IMPRECION DE UNA IMG
    bytes += generator.image(image!);

    bytes += generator.text(
      'QUICKLY',
      styles: PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size3,
        width: PosTextSize.size3
      ),
      linesAfter: 1
    );

    bytes += generator.text(
      'Esto es una prueba',
      styles: PosStyles(
        align: PosAlign.left
      )
    );

    bytes += generator.text(
      'Telefono: 0000000000',
      styles: PosStyles(
        align: PosAlign.center
      )
    );

    bytes += generator.hr(ch: '*', len: 29);

    bytes += generator.row([
      PosColumn(
          text: 'No',
          width: 1,
          styles: PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: 'Item',
          width: 4,
          styles: PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: 'Precio',
          width: 3,
          styles: PosStyles(align: PosAlign.center, bold: true)),
      PosColumn(
          text: 'Total',
          width: 2,
          styles: PosStyles(align: PosAlign.right, bold: true)),
      PosColumn(
          width: 2,
          styles: PosStyles(align: PosAlign.right, bold: true)),
    ]);

    bytes += generator.hr(ch: '*',len: 29);

    bytes += generator.row([
      PosColumn(
          text: '1',
          width: 1,
          styles: PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: 'Cobro',
          width: 4,
          styles: PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: '\$666',
          width: 3,
          styles: PosStyles(align: PosAlign.center, bold: true)),
      PosColumn(
          text: '13',
          width: 2,
          styles: PosStyles(align: PosAlign.right, bold: true)),
      PosColumn(
          width: 2,
          styles: PosStyles(align: PosAlign.right, bold: true)),
    ]);

    bytes += generator.hr(ch: '=', len: 29);

    bytes += generator.row([
      PosColumn(
          text: 'TOTAL',
          width: 5,
          styles:const PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size3,
            width: PosTextSize.size3,
          )),
      PosColumn(
          text: "13",
          width: 5,
          styles:const PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size3,
            width: PosTextSize.size3,
          )),
       PosColumn(
          width: 2,
          styles: PosStyles(align: PosAlign.right, bold: true)),
    ]);

    bytes += generator.hr(ch: '=', linesAfter: 1,len: 29);

    bytes += generator.text('Gracias por su atencion!',
        styles: PosStyles(align: PosAlign.center, bold: true));

    bytes += generator.text("26-11-2020 15:22:45",
        styles: PosStyles(align: PosAlign.center), linesAfter: 1);

    bytes += generator.row([
      PosColumn(
          text:'Nota:No nos hacemos',
          width:11,
          styles:const PosStyles(
            align: PosAlign.center,
            bold: false,
          )),
       PosColumn(
          width: 1,
          styles: PosStyles(align: PosAlign.right, bold: true)),
    ]);
    bytes += generator.row([
      PosColumn(
          text:'responsables',
          width:11,
          styles:const PosStyles(
            align: PosAlign.center,
            bold: false,
          )),
       PosColumn(
          width: 1,
          styles: PosStyles(align: PosAlign.right, bold: true)),
    ]);
    bytes += generator.row([
      PosColumn(
          text:'si los acesores se llevan ',
          width:11,
          styles:const PosStyles(
            align: PosAlign.center,
            bold: false,
          )),
       PosColumn(
          width: 1,
          styles: PosStyles(align: PosAlign.right, bold: true)),
    ]);
    bytes += generator.row([
      PosColumn(
          text:'su refrigerador',
          width:11,
          styles:const PosStyles(
            align: PosAlign.center,
            bold: false,
          )),
       PosColumn(
          width: 1,
          styles: PosStyles(align: PosAlign.right, bold: true)),
    ]);
    bytes += generator.feed(1);
      
    bytes += generator.qrcode('https://www.quicklyteapoya.com/');
        
    bytes += generator.cut();

    return bytes;
  }
}

