import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_so_me/views/chat/chat_view.dart';
import 'package:unicons/unicons.dart';

import '../../managers/chat_manager.dart';

class CreateChatView extends StatefulWidget {
  const CreateChatView([Key? key]) : super(key: key);

  @override
  State<CreateChatView> createState() => _CreateChatViewState();
}

class _CreateChatViewState extends State<CreateChatView> {
  final ChatManager _chatManager = ChatManager();
  var focusNode = FocusNode();
  var textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(centerTitle: false, title: const Text('Timeline')),
        body: SizedBox(
          width: double.infinity,
          height: 200,
          child: Row(children: [
            Container(
              margin: const EdgeInsets.only(),
              decoration: BoxDecoration(
                color: Colors.brown,
                borderRadius: BorderRadius.circular(90),
              ),
            ),
            Flexible(
                child: TextField(
              focusNode: focusNode,
              textInputAction: TextInputAction.send,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.sentences,
              controller: textEditingController,
              onSubmitted: (value) async {
                await _chatManager.submitChat(
                    message: textEditingController.text);
                Navigator.pop(context);
              },
            )),
          ]),
        ));
  }
}
