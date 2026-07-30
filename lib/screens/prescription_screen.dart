import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'prescription_result_screen.dart';
import '../services/ocr_service.dart';
class PrescriptionScreen extends StatefulWidget {
  const PrescriptionScreen({super.key});

  @override
  State<PrescriptionScreen> createState() =>
      _PrescriptionScreenState();
}

class _PrescriptionScreenState
    extends State<PrescriptionScreen> {
      final OCRService _ocrService = OCRService();

bool isLoading = false;
  File? selectedImage;
  
  Future<void> pickImage() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }
Future<void> analyzePrescription() async {

  if (selectedImage == null) return;

  setState(() {
    isLoading = true;
  });

  try {

    final medicines =
        await _ocrService.extractPrescription(
      selectedImage!,
    );

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PrescriptionResultScreen(
          extractedMedicines: medicines,
        ),
      ),
    );

  } catch (e) {

    ScaffoldMessenger.of(context)
        .showSnackBar(

      SnackBar(
        content: Text(e.toString()),
      ),

    );

  } finally {

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }

  }

}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Prescription Analysis",
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            if (selectedImage != null)
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(20),
                child: Image.file(
                  selectedImage!,
                  height: 300,
                ),
              )
            else
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Icon(
                    Icons.receipt_long,
                    size: 100,
                  ),
                ),
              ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: pickImage,
                icon: const Icon(
                  Icons.upload,
                ),
                label: const Text(
                  "Upload Prescription",
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: selectedImage == null || isLoading
    ? null
    : analyzePrescription,
                icon: const Icon(
                  Icons.analytics,
                ),
                label: Text(
  isLoading
      ? "Analyzing..."
      : "Analyze Prescription",
),
              ),
            ),
          ],
        ),
      ),
    );
  }
}