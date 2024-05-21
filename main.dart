import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Recognition App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ImageRecognitionPage(),
    );
  }
}

class ImageRecognitionPage extends StatefulWidget {
  @override
  _ImageRecognitionPageState createState() => _ImageRecognitionPageState();
}

class _ImageRecognitionPageState extends State<ImageRecognitionPage> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  String _result = '';

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() {
      _image = File(image.path);
    });
    _recognizeImage(_image!);
  }

  Future<void> _recognizeImage(File image) async {
    final inputImage = InputImage.fromFile(image);
    final imageLabeler = GoogleMlKit.vision.imageLabeler();
    final labels = await imageLabeler.processImage(inputImage);

    String result = 'Labels:\n';
    for (ImageLabel label in labels) {
      final String text = label.label;
      final double confidence = label.confidence;
      result += '$text (confidence: ${(confidence * 100).toStringAsFixed(2)}%)\n';
    }

    setState(() {
      _result = result;
    });

    imageLabeler.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Recognition App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image == null
                ? Text('No image selected.')
                : Image.file(_image!),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image from Gallery'),
            ),
            SizedBox(height: 16),
            Text(_result),
          ],
        ),
      ),
    );
  }
}
