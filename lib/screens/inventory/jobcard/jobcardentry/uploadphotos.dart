import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sheraccerp/util/jobcard_lists.dart';

class UploadPhotos extends StatefulWidget {
  const UploadPhotos({super.key});

  @override
  State<UploadPhotos> createState() => _UploadPhotosState();
}

class _UploadPhotosState extends State<UploadPhotos> {
  bool _isImagePickerActive = false;

 
  Future<void> _pickImage1(ImageSource source) async {
    if (!_isImagePickerActive) {
      _isImagePickerActive = true;
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          imageFile1 = File(pickedFile.path);
        });
      }
      _isImagePickerActive = false;
    }
  }

 
  Future<void> _pickImage2(ImageSource source) async {
    if (!_isImagePickerActive) {
      _isImagePickerActive = true;
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          imageFile2 = File(pickedFile.path);
        });
      }
      _isImagePickerActive = false;
    }
  }

  
  Future<void> _pickImage3(ImageSource source) async {
    if (!_isImagePickerActive) {
      _isImagePickerActive = true;
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          imageFile3 = File(pickedFile.path);
        });
      }
      _isImagePickerActive = false;
    }
  }

  
  Future<void> _pickImage4(ImageSource source) async {
    if (!_isImagePickerActive) {
      _isImagePickerActive = true;
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          imageFile4 = File(pickedFile.path);
        });
      }
      _isImagePickerActive = false;
    }
  }

 
  Future<void> _pickImage5(ImageSource source) async {
    if (!_isImagePickerActive) {
      _isImagePickerActive = true;
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          imageFile5 = File(pickedFile.path);
        });
      }
      _isImagePickerActive = false;
    }
  }

 
  Future<void> _pickImage6(ImageSource source) async {
    if (!_isImagePickerActive) {
      _isImagePickerActive = true;
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          imageFile6 = File(pickedFile.path);
        });
      }
      _isImagePickerActive = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title:  const Text(
          "Upload Photos",
          style: TextStyle(fontSize: 15),
                ),),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          
            children: [
               
                SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [const SizedBox(height: 50,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      _pickImage1(ImageSource
                          .gallery); // Change to ImageSource.camera for camera access
                    },
                    child: imageFile1 != null
                        ? Container(padding: const EdgeInsets.all(10),
                            width: 120,
                            child: Image.file(
                              imageFile1!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(padding: const EdgeInsets.all(10),
                            width: 120,
                            decoration: BoxDecoration(border: Border.all()),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt_outlined,
                                  size: 50,
                                ),
                                Center(
                                    child: Text(
                                  "NO IMAGE \nAVAILABLE",
                                  style: TextStyle(fontSize: 8),
                                ))
                              ],
                            ),
                          ),
                  ),
                  InkWell(
                    onTap: () {
                      _pickImage2(ImageSource
                          .gallery); // Change to ImageSource.camera for camera access
                    },
                    child: imageFile2 != null
                        ? Container(padding: const EdgeInsets.all(10),
                            width: 120,
                            child: Image.file(
                              imageFile2!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(padding: const EdgeInsets.all(10),
                            width: 120,
                            decoration: BoxDecoration(border: Border.all()),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt_outlined,
                                  size: 50,
                                ),
                                Center(
                                    child: Text(
                                  "NO IMAGE \nAVAILABLE",
                                  style: TextStyle(fontSize: 8),
                                ))
                              ],
                            ),
                          ),
                  ),
                  InkWell(
                    onTap: () {
                      _pickImage3(ImageSource.gallery);
                    }, // Change to ImageSource.camera for camera access
                    child: imageFile3 != null
                        ? Container(padding: const EdgeInsets.all(10),
                            width: 120,
                            child: Image.file(
                              imageFile3!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(padding: const EdgeInsets.all(10),
                            width: 120,
                            decoration: BoxDecoration(border: Border.all()),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt_outlined,
                                  size: 50,
                                ),
                                Center(
                                    child: Text(
                                  "NO IMAGE \nAVAILABLE",
                                  style: TextStyle(fontSize: 8),
                                ))
                              ],
                            ),
                          ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      _pickImage4(ImageSource.gallery);
                    }, // Change to ImageSource.camera for camera access
                    child: imageFile4 != null
                        ? Container(padding: const EdgeInsets.all(10),
                            width: 120,
                            child: Image.file(
                              imageFile4!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(padding: const EdgeInsets.all(10),
                            width: 120,
                            decoration: BoxDecoration(border: Border.all()),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt_outlined,
                                  size: 50,
                                ),
                                Center(
                                    child: Text(
                                  "NO IMAGE \nAVAILABLE",
                                  style: TextStyle(fontSize: 8),
                                ))
                              ],
                            ),
                          ),
                  ),
                  InkWell(
                    onTap: () {
                      _pickImage5(ImageSource.gallery);
                    }, // Change to ImageSource.camera for camera access
                    child: imageFile5 != null
                        ? Container(padding: const EdgeInsets.all(10),
                            width: 120,
                            child: Image.file(
                              imageFile5!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(padding: const EdgeInsets.all(10),
                            width: 120,
                            decoration: BoxDecoration(border: Border.all()),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt_outlined,
                                  size: 50,
                                ),
                                Center(
                                    child: Text(
                                  "NO IMAGE \nAVAILABLE",
                                  style: TextStyle(fontSize: 8),
                                ))
                              ],
                            ),
                          ),
                  ),
                  InkWell(
                    onTap: () {
                      _pickImage6(ImageSource.gallery);
                    }, // Change to ImageSource.camera for camera access
                    child: imageFile6 != null
                        ? Container(padding: const EdgeInsets.all(10),
                            width: 120,
                            child: Image.file(
                              imageFile6!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(padding: const EdgeInsets.all(10),
                            width: 120,
                            decoration: BoxDecoration(border: Border.all()),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt_outlined,
                                  size: 50,
                                ),
                                Center(
                                    child: Text(
                                  "NO IMAGE \nAVAILABLE",
                                  style: TextStyle(fontSize: 8),
                                ))
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
                ),Row(mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(onPressed: (){
                      Navigator.of(context).pop();
                    },style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: const Text("Exit"),),
                 const SizedBox(width: 30,),
                ElevatedButton(onPressed: (){
                   Navigator.of(context).pop();
                },style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: const Text("Save"),),
         const SizedBox(height: 100,),    ],
                ),     ]),
        ));
  }
}
