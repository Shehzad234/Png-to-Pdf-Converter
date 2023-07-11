import 'dart:developer';
import 'dart:io';
import '/utils/loading_popup.dart';
import '/utils/show_message.dart';

import '/pages/converted/view/converted_view.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:pdf/widgets.dart' as pw;

class HomeViewModel extends ChangeNotifier {
  String? pngFilePath;
  String? pngFileName;
  String? pdfFileName;
  String? pdfFilepath;
  bool filePickedFlag = false;

  pickpngFile() async {
    final file = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ["png"],
        dialogTitle: "Pick png File");
    if (file != null) {
      if (file.files.first.path!.endsWith(".png") == false) {
        showMessage("Only png format supported");
        return;
      }
      pngFilePath = file.files.first.path;
      pngFileName = file.files.first.name;

      filePickedFlagPositive();
      log("$pngFileName $pngFilePath");
    }
  }

  convertpngToPdf(context) async {
    loadingPopup(context);
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final pdf = pw.Document();
      final image = pw.MemoryImage(
        File(pngFilePath!).readAsBytesSync(),
      );

      pdf.addPage(pw.Page(build: (pw.Context context) {
        return pw.Center(
          child: pw.Image(image),
        ); // Center
      }));
      var temp = pngFilePath!.split("");
      temp.removeRange(temp.length - 3, temp.length);
      pdfFilepath = "${temp.join()}pdf";
      log(pdfFilepath!);
      pdfFileName = pdfFilepath!.split("/").last;

      final file = File(pdfFilepath!);
      await file.writeAsBytes(await pdf.save()).then((value) async {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed(ConvertedView.path);
        showMessage("Sucessfully Converted");
        filePickedFlagNagative();
      });
    } catch (e) {
      showMessage(e.toString());
      Navigator.of(context).pop();
    }
  }

  filePickedFlagPositive() {
    filePickedFlag = true;
    notifyListeners();
  }

  filePickedFlagNagative() {
    filePickedFlag = false;
    notifyListeners();
  }

  //---------------------FOR DRAWER-------------------------------

}
