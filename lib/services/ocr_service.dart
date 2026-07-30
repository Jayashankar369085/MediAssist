import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class OCRService {
  // Replace after Render deployment
static const String baseUrl =
    "https://mediassistbackend-production.up.railway.app";
  Future<List<dynamic>> extractPrescription(File image) async {
    var request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/prescription/extract"),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        "file",
        image.path,
      ),
    );

    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception("OCR Failed");
    }

    final body =
        await response.stream.bytesToString();
    print("OCR RESPONSE:");
    print(body);
    final json = jsonDecode(body);

    return json["medicines"]["medicines"];
  }
}