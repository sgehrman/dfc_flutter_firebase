import 'package:dfc_flutter/dfc_flutter_web.dart';
import 'package:dfc_flutter_firebase/src/firebase/firebase_user_provider.dart';
import 'package:dfc_flutter_firebase/src/image/image_url_utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditProfileDialog extends StatefulWidget {
  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final ProfileData _data = ProfileData();
  final _formKey = GlobalKey<FormState>();
  bool _autovalidate = false;

  Future<void> handleImagePicker({required bool camera}) async {
    final file = await ImagePicker()
        .pickImage(source: camera ? ImageSource.camera : ImageSource.gallery);

    if (file != null) {
      final imageData = await file.readAsBytes();
      final imageId = Utils.uniqueFirestoreId();

      final url = await ImageUrlUtils.uploadImageDataReturnUrl(
        imageId,
        imageData,
        folder: ImageUrlUtils.chatImageFolder,
      );

      _data.photoUrl = url;

      if (mounted) {
        setState(() {});
      }
    } else {
      print('file null for ImagePicker');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<FirebaseUserProvider>();

    Widget image = const Icon(Icons.image, size: 32);

    final imageUrl = _data.photoUrl ?? userProvider.photoUrl;
    if (imageUrl.isNotEmpty) {
      image = Image.network(
        imageUrl,
        fit: BoxFit.contain,
      );
    }

    return SimpleDialog(
      title: Text(
        'Edit your Profile',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      contentPadding:
          const EdgeInsets.only(top: 12, bottom: 16, left: 16, right: 16),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      children: [
        Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                autovalidateMode: _autovalidate
                    ? AutovalidateMode.always
                    : AutovalidateMode.disabled,
                initialValue: userProvider.displayName,
                // The validator receives the text that the user has entered.
                decoration: const InputDecoration(
                  icon: Icon(Icons.person),
                  hintText: 'Name',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your name';
                  }

                  return null;
                },
                onSaved: (value) {
                  _data.name = value!.trim();
                },
              ),
              TextFormField(
                autovalidateMode: _autovalidate
                    ? AutovalidateMode.always
                    : AutovalidateMode.disabled,
                initialValue: userProvider.email,
                keyboardType: TextInputType
                    .emailAddress, // Use email input type for emails.

                decoration: const InputDecoration(
                  icon: Icon(Icons.email),
                  hintText: 'Email Address',
                ),
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (StrUtils.isEmailValid(value)) {
                    return null;
                  }

                  return 'Please enter your email address';
                },
                onSaved: (value) {
                  _data.email = value!.trim();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Edit your Avatar image',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Spacer(),
            if (Utils.isMobile)
              IconButton(
                onPressed: () => handleImagePicker(camera: true),
                icon: const Icon(
                  Icons.photo_camera,
                ),
              ),
            IconButton(
              onPressed: () => handleImagePicker(camera: false),
              icon: const Icon(
                Icons.photo,
              ),
            ),
          ],
        ),
        Container(
          height: 200,
          width: 200,
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(color: Colors.white),
          child: image,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();

              Navigator.of(context).pop(_data);
            } else {
              setState(() {
                _autovalidate = true;
              });
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// ==================================================

Future<ProfileData?> showEmailEditProfileDialog(BuildContext context) {
  return showDialog<ProfileData>(
    context: context,
    builder: (context) {
      return EditProfileDialog();
    },
  );
}

// ==================================================

class ProfileData {
  String email = '';
  String name = '';
  String? photoUrl;

  @override
  String toString() {
    return 'ProfileData: $email $name ${photoUrl ?? 'photoUrl null'}';
  }
}
