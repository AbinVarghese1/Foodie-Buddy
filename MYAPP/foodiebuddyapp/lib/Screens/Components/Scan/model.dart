import 'dart:io';
import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class MLService {
  static Interpreter? _interpreter;
  static final List<String> labels = ['Noodles', 'Briyani'];

  static Future<void> loadModel() async {
    final model = await FirebaseModelDownloader.instance.getModel(
      'Recipe-Detector', // Replace with your actual model name
      FirebaseModelDownloadType.latestModel,
      FirebaseModelDownloadConditions(
        iosAllowsCellularAccess: true,
        iosAllowsBackgroundDownloading: false,
        androidChargingRequired: false,
        androidWifiRequired: false,
        androidDeviceIdleRequired: false,
      ),
    );

    _interpreter = await Interpreter.fromFile(model.file);
  }

  static Future<List<double>> runInference(File imageFile) async {
    if (_interpreter == null) {
      throw Exception("Model not loaded");
    }

    // Preprocess the image
    var input = await _preProcessImage(imageFile);

    // Run inference
    var output = List.filled(1 * labels.length, 0.0).reshape([1, labels.length]);
    _interpreter!.run(input, output);

    return output[0];
  }

  static Future<List<List<List<List<double>>>>> _preProcessImage(File imageFile) async {
    // Read the image file and resize it to match the model's input shape
    img.Image? image = img.decodeImage(await imageFile.readAsBytes());
    img.Image resizedImage = img.copyResize(image!, width: 224, height: 224);

    // Convert the image to a list of normalized pixel values
    var inputImage = List.generate(
      1,
      (_) => List.generate(
        224,
        (y) => List.generate(
          224,
          (x) {
            var pixel = resizedImage.getPixel(x, y);
            return [
              (pixel.r / 255.0 - 0.485) / 0.229,
              (pixel.g / 255.0 - 0.456) / 0.224,
              (pixel.b / 255.0 - 0.406) / 0.225,
            ];
          },
        ),
      ),
    );

    return inputImage;
  }

  static String interpretOutput(List<double> output) {
    // Find the index with the highest probability
    int maxIndex = 0;
    double maxProb = output[0];
    for (int i = 1; i < output.length; i++) {
      if (output[i] > maxProb) {
        maxProb = output[i];
        maxIndex = i;
      }
    }

    // Return the corresponding label
    return labels[maxIndex];
  }
}
