import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:mrz/extensions/string.extension.dart';

class ProcessTextImage {
  static final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  Future<MRZData?> firstDetectingProcess(
    RecognizedText recognizedText,
  ) async {
    try {
      return MRZData.extractMRZfromString(recognizedText.text);
    } catch (error) {
      debugPrint("Isolate process:  has error $error");
      return null;
    }
  }

  void dispose() {
    textRecognizer.close();
  }
}
