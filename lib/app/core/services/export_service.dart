import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

import '../../data/models/family_member.dart';
import '../constants/app_colors.dart';

/// ສົ່ງອອກຜັງໄມ້ຄອບຄົວເປັນຮູບພາບ ແລະ PDF
class ExportService {
  ExportService._();

  /// ແປງ Widget ໃນຜັງເປັນ PNG bytes ດ້ວຍ RepaintBoundary
  static Future<Uint8List?> captureWidget(GlobalKey boundaryKey,
      {double pixelRatio = 2.0}) async {
    try {
      final boundary = boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  /// ສ້າງເອກະສານ PDF ຂອງຜັງໄມ້ຄອບຄົວ (ພ້ອມຕາຕະລາງລາຍຊື່ສະມາຊິກ)
  static Future<Uint8List> buildTreePdf({
    required String familyName,
    required String surname,
    required List<FamilyMember> members,
    Uint8List? treeImage,
  }) async {
    final doc = pw.Document();
    final sorted = [...members]..sort((a, b) {
        final g = a.generation.compareTo(b.generation);
        return g != 0 ? g : a.fullName.compareTo(b.fullName);
      });

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('ຜັງໄມ້ຄອບຄົວ $familyName',
                    style: pw.TextStyle(
                        fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text(
                    'ນາມສະກຸນ: $surname  |  ສະມາຊິກທັງໝົດ: ${members.length} ຄົນ',
                    style: const pw.TextStyle(
                        fontSize: 11, color: PdfColors.grey700)),
                pw.SizedBox(height: 10),
              ],
            ),
          ),
          if (treeImage != null)
            pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 18),
              alignment: pw.Alignment.center,
              child:
                  pw.Image(pw.MemoryImage(treeImage), fit: pw.BoxFit.contain),
            ),
          pw.Text('ລາຍຊື່ສະມາຊິກ',
              style:
                  pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: const [
              '#',
              'ຊື່ ແລະ ນາມສະກຸນ',
              'ລຸ້ນທີ',
              'ເພດ',
              'ສະຖານະ',
              'ວັນເກີດ'
            ],
            data: [
              for (var i = 0; i < sorted.length; i++)
                [
                  '${i + 1}',
                  sorted[i].fullName,
                  '${sorted[i].generation}',
                  sorted[i].genderLabel,
                  sorted[i].statusLabel,
                  _date(sorted[i].birthDate),
                ],
            ],
            headerStyle:
                pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            cellStyle: const pw.TextStyle(fontSize: 9.5),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.green100),
            cellAlignment: pw.Alignment.centerLeft,
          ),
          pw.SizedBox(height: 14),
          pw.Text('ສ້າງຈາກແອັບ Family Root',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
        ],
      ),
    );
    return doc.save();
  }

  /// ບັນທຶກຮູບ PNG ລົງໃນເຄື່ອງ (Documents/FamilyRoot)
  static Future<String?> saveImageToDevice(Uint8List bytes,
      {String name = 'family_tree'}) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final folder = Directory('${dir.path}/FamilyRoot');
      if (!folder.existsSync()) folder.createSync(recursive: true);
      final file = File(
          '${folder.path}/$name-${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (_) {
      return null;
    }
  }

  /// ສະແດງໜ້າພິມ/ແຊຣ໌ PDF
  static Future<void> printPdf(Uint8List bytes,
      {String name = 'family_root_tree'}) async {
    await Printing.layoutPdf(onLayout: (_) async => bytes, name: name);
  }

  static Future<void> sharePdf(Uint8List bytes,
      {String name = 'family_root_tree'}) async {
    await Printing.sharePdf(bytes: bytes, filename: '$name.pdf');
  }

  static String _date(DateTime? date) {
    if (date == null) return '-';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// ສີສຳລັບ PDF ຕາມສະຖານະ
  static PdfColor statusColor(String status) {
    switch (status) {
      case 'deceased':
        return PdfColor.fromInt(AppColors.deceased.toARGB32());
      default:
        return PdfColor.fromInt(AppColors.alive.toARGB32());
    }
  }
}
