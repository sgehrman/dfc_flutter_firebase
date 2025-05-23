import 'package:dfc_flutter/dfc_flutter_web.dart';
import 'package:dfc_flutter_firebase/src/chat/models/image_url_model.dart';
import 'package:dfc_flutter_firebase/src/image/image_url_utils.dart';
import 'package:flutter/material.dart';

class ImageDeleteDialog extends StatefulWidget {
  const ImageDeleteDialog(this.imageUrl);

  final ImageUrlModel imageUrl;

  @override
  State<ImageDeleteDialog> createState() => _ImageDeleteDialogState();
}

class _ImageDeleteDialogState extends State<ImageDeleteDialog> {
  Widget imageWell(BuildContext context) {
    return Image.network(
      widget.imageUrl.url,
      fit: BoxFit.contain,
    );
  }

  Future<bool> _deleteImage(BuildContext context) async {
    try {
      await ImageUrlUtils.deleteImage(widget.imageUrl);
    } catch (error) {
      print(error);

      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(
        'Delete Image',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      contentPadding:
          const EdgeInsets.only(top: 6, bottom: 16, left: 20, right: 20),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      children: [
        imageWell(context),
        const SizedBox(
          height: 20,
        ),
        ColoredButton(
          color: Colors.red,
          title: 'Delete',
          icon: const Icon(Icons.remove_circle, size: 16),
          onPressed: () async {
            final success = await _deleteImage(context);
            if (success) {
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            } else {
              print('error on delete image');
            }
          },
        ),
      ],
    );
  }
}

Future<void> showImageDeleteDialog(
  BuildContext context,
  ImageUrlModel imageUrl,
) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return ImageDeleteDialog(imageUrl);
    },
  );
}
