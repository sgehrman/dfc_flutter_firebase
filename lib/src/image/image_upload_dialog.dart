import 'dart:io';
import 'dart:typed_data';

import 'package:dfc_flutter/dfc_flutter_web.dart';
import 'package:dfc_flutter_firebase/src/image/image_url_utils.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadData {
  String? url = '';
  String name = '';

  @override
  String toString() {
    return '$url $name';
  }
}

class UploadDialog extends StatefulWidget {
  @override
  _UploadDialogState createState() => _UploadDialogState();
}

class _UploadDialogState extends State<UploadDialog> {
  final UploadData _data = UploadData();
  final _formKey = GlobalKey<FormState>();
  String? _imageUrl;
  File? _imageFile;
  bool? _saveAsJpg = true;

  Widget imageWell(BuildContext context) {
    Widget? child;

    if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      child = Image.network(
        _imageUrl ?? '',
        fit: BoxFit.contain,
      );
    } else if (_imageFile != null) {
      child = ExtendedImage.file(_imageFile!, fit: BoxFit.contain);
    }

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 4),
          height: 120,
          width: 180,
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(30),
            border: const Border.fromBorderSide(
              BorderSide(color: Colors.black12),
            ),
          ),
          child: child,
        ),
        Positioned(
          right: 0,
          top: 0,
          child: IconButton(
            icon: const Icon(Icons.photo_camera),
            onPressed: () async {
              await _getImage(ImageSource.camera);
            },
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: IconButton(
            icon: const Icon(Icons.photo),
            onPressed: () async {
              await _getImage(ImageSource.gallery);
            },
          ),
        ),
      ],
    );
  }

  Future<void> _getImage(ImageSource imageSource) async {
    final image = await ImagePicker().pickImage(source: imageSource);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<String?> _uploadImage(BuildContext context, String filename) async {
    if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      return _uploadImageUrl(context, filename);
    } else if (_imageFile != null) {
      return _uploadFileContents(context, filename);
    }

    return null;
  }

  Future<String?> _uploadImageUrl(BuildContext context, String filename) async {
    final Uint8List? imageData = await getNetworkImageData(_imageUrl!);

    if (imageData != null) {
      return ImageUrlUtils.uploadImageData(
        filename,
        imageData,
        saveAsJpg: _saveAsJpg!,
      );
    }

    return null;
  }

  Future<String?> _uploadFileContents(
    BuildContext context,
    String filename,
  ) async {
    final Uint8List? imageData = await _imageFile?.readAsBytes();
    if (imageData != null) {
      return ImageUrlUtils.uploadImageData(
        filename,
        imageData,
        saveAsJpg: _saveAsJpg!,
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(
        'Upload Image',
        style: Theme.of(context).textTheme.headline5,
      ),
      contentPadding:
          const EdgeInsets.only(top: 6, bottom: 16, left: 20, right: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      children: [
        Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              imageWell(context),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'To upload a file from a URL, put in the URL below and hit the download button.',
                ),
              ),
              TextFormField(
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: 'Image URL',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.cloud_download),
                    onPressed: () {
                      _formKey.currentState!.save();

                      setState(() {
                        _imageUrl = _data.url;
                      });
                    },
                  ),
                ),
                onChanged: (String value) {
                  setState(() {
                    _data.url = value;
                  });
                },
              ),
              TextFormField(
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Image name',
                  helperText: 'Name the image',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Name cannot be blank';
                  }

                  return null;
                },
                onSaved: (String? value) {
                  _data.name = value!.trim();
                },
              ),
              CheckboxListTile(
                title: const Text('Save in JPG format'),
                value: _saveAsJpg,
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (bool? value) {
                  setState(() {
                    _saveAsJpg = value;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.cloud_upload, size: 16),
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();

              _data.url = await _uploadImage(context, _data.name);
              if (Utils.isNotEmpty(_data.url)) {
                Navigator.of(context).pop(_data);
              } else {
                print('error on upload image');
              }
            }
          },
          label: const Text('Upload'),
        ),
      ],
    );
  }
}

Future<UploadData?> showImageUploadDialog(BuildContext context) async {
  return showDialog<UploadData>(
    context: context,
    builder: (BuildContext context) {
      return UploadDialog();
    },
  );
}
