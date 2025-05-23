import 'dart:async';

import 'package:dfc_flutter/dfc_flutter_web.dart';
import 'package:dfc_flutter_firebase/src/chat/chat_message_utils.dart';
import 'package:dfc_flutter_firebase/src/chat/models/chat_message_model.dart';
import 'package:dfc_flutter_firebase/src/chat/models/chat_user_model.dart';
import 'package:dfc_flutter_firebase/src/image/image_url_utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatInput extends StatefulWidget {
  const ChatInput({
    required this.userModel,
    required this.collectionPath,
    super.key,
  });

  final ChatUserModel userModel;
  final String collectionPath;

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _textController = TextEditingController();
  bool expanded = true;
  bool _showThumb = true;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _textController.addListener(_textListener);
  }

  void _textListener() {
    adjustUIOnTextInput();
  }

  @override
  void dispose() {
    _textController.removeListener(_textListener);
    _textController.dispose();
    _focusNode.dispose();

    super.dispose();
  }

  Color _iconColor(BuildContext context) {
    if (Utils.isDarkMode(context)) {
      return Colors.white;
    }

    return Theme.of(context).primaryColor;
  }

  Widget toolbar(BuildContext context) {
    final result = <Widget>[];

    result.add(
      InkWell(
        onTap: handleExpand,
        child: Icon(Icons.keyboard_arrow_right, color: _iconColor(context)),
      ),
    );

    if (expanded) {
      result.add(const SizedBox(width: 6));

      result.add(
        InkWell(
          onTap: () => handleImagePicker(camera: true),
          child: Icon(
            Icons.photo_camera,
            color: _iconColor(context),
          ),
        ),
      );

      result.add(const SizedBox(width: 6));

      result.add(
        InkWell(
          onTap: () => handleImagePicker(camera: false),
          child: Icon(
            Icons.photo,
            color: _iconColor(context),
          ),
        ),
      );
    }

    return AnimatedSize(
      alignment: Alignment.centerLeft,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeIn,
      child: Row(
        children: result,
      ),
    );
  }

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

      final message = ChatMessageModel(
        user: widget.userModel,
        image: url,
        imageId: imageId,
      );

      await ChatMessageUtils.uploadChatMessage(
        collectionPath: widget.collectionPath,
        model: message,
      );
    }
  }

  Widget sendButton() {
    return InkWell(
      onTap: () => handleSend(fromKeyboard: false),
      child: Icon(
        _showThumb ? Icons.thumb_up : Icons.send,
        color: _iconColor(context),
      ),
    );
  }

  void adjustUIOnTextInput() {
    var needsSetState = false;

    if (_showThumb != _textController.text.isEmpty) {
      _showThumb = !_showThumb;
      needsSetState = true;
    }

    if (expanded) {
      expanded = false;
      needsSetState = true;
    }

    if (needsSetState) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.all(
        Radius.circular(500),
      ),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: <Widget>[
          toolbar(context),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextField(
                onTap: () {
                  if (expanded) {
                    setState(() => expanded = false);
                  }
                },
                focusNode: _focusNode,
                decoration: const InputDecoration(
                  hintText: 'Message...',
                  filled: true,
                  fillColor: Color.fromRGBO(0, 0, 0, 0.1),
                  border: border,
                  errorBorder: border,
                  enabledBorder: border,
                  focusedBorder: border,
                  disabledBorder: border,
                  focusedErrorBorder: border,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 7,
                  ),
                ),
                controller: _textController,
                style: const TextStyle(fontSize: 16),
                minLines: 1,
                showCursor: true,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.send,
                onSubmitted: (str) => handleSend(fromKeyboard: true),
              ),
            ),
          ),
          sendButton(),
        ],
      ),
    );
  }

  Future<void> handleSend({required bool fromKeyboard}) async {
    var text = _textController.text;

    if (!fromKeyboard) {
      if (text.isEmpty) {
        text = '_tu_'; // code for thumb up
      }
    }

    if (text.isNotEmpty) {
      final message = ChatMessageModel(
        text: text,
        user: widget.userModel,
      );

      await ChatMessageUtils.uploadChatMessage(
        collectionPath: widget.collectionPath,
        model: message,
      );

      _textController.text = '';
      _focusNode.requestFocus();
    }
  }

  void handleExpand() {
    setState(() {
      expanded = !expanded;
    });
  }
}
