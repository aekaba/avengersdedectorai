import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<File>? imageFile;
  File? _image;
  String result = "";
  ImagePicker? imagePicker;

  selectPhotoFromGallery() async {
    XFile? pickedFile =
        await imagePicker!.pickImage(source: ImageSource.gallery);
    _image = File(pickedFile!.path);
    setState(() {
      _image;
      doImageClassifaction();
    });
  }

  capturePhotoFromcamere() async {
    XFile? pickedFile =
        await imagePicker!.pickImage(source: ImageSource.camera);
    _image = File(pickedFile!.path);
    setState(() {
      _image;
      doImageClassifaction();
    });
  }

  loadDataModelFiles() async {
    String? output = await Tflite.loadModel(
        model: 'assets/model_unquant.tflite',
        labels: 'assets/labels.txt',
        numThreads: 1,
        isAsset: true,
        useGpuDelegate: false);
    print(output);
  }

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
    loadDataModelFiles();
  }

  doImageClassifaction() async {
    var recognitions = await Tflite.runModelOnImage(
      path: _image!.path,
      imageMean: 0.0,
      imageStd: 255.0,
      numResults: 2,
      threshold: 0.1,
      asynch: true,
    );
    print(recognitions!.length.toString());
    setState(() {
      result = "";
    });
    recognitions.forEach((element) {
      print(element.toString());
      result += element['label'] + '\n\n';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Colors.blueGrey),
        child: Column(
          children: [
            const SizedBox(height: 100),
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: Stack(
                children: [
                  Center(
                    child: TextButton(
                      onPressed: selectPhotoFromGallery,
                      onLongPress: capturePhotoFromcamere,
                      child: Container(
                          margin: const EdgeInsets.only(
                              top: 20, left: 20, right: 20),
                          child: _image != null
                              ? Image.file(
                                  _image!,
                                  height: 260,
                                  width: 400,
                                  fit: BoxFit.cover,
                                )
                              : const SizedBox(
                                  width: 140,
                                  height: 190,
                                  child: Icon(
                                    Icons.camera_alt_rounded,
                                    color: Colors.black,
                                  ),
                                )),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 140),
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: Text(
                result,
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }
}
