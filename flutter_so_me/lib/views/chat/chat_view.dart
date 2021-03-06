import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_so_me/managers/chat_manager.dart';
import 'package:flutter_so_me/views/chat/create_chat_view.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:unicons/unicons.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter_so_me/managers/encryption_manager.dart' as encrypter;

class ChatView extends StatefulWidget {
  const ChatView({key}) : super(key: key);

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final ChatManager _chatManager = ChatManager();
  var focusNode = FocusNode();
  var textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Messages'),
        actions: [
          IconButton(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CreateChatView())),
              icon: Icon(
                UniconsLine.plus_square,
                color: Theme.of(context).iconTheme.color,
              ))
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>?>>(
          stream: _chatManager.getAllChats(),
          builder: (context, snapshot) {
            return ListView.separated(
                itemBuilder: (context, index) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      snapshot.data == null) {
                    return const Center(
                        child: CircularProgressIndicator.adaptive());
                  }

                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.data == null) {
                    return const Center(child: Text('No data available'));
                  }

                  return Column(children: [
                    StreamBuilder<Map<String, dynamic>?>(
                        stream: _chatManager
                            .getUserInfo(encrypter.decryptData(
                                snapshot.data!.docs[index].data()!['user_uid']))
                            .asStream(),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState ==
                                  ConnectionState.waiting &&
                              userSnapshot.data == null) {
                            return const Center(
                                child: LinearProgressIndicator());
                          }

                          if (userSnapshot.connectionState ==
                                  ConnectionState.done &&
                              userSnapshot.data == null) {
                            return const ListTile();
                          }
                          return ListTile(
                              contentPadding: const EdgeInsets.all(0),
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(
                                    encrypter.decryptData(
                                        userSnapshot.data!['picture']!)),
                              ),
                              title: Text(
                                  encrypter
                                      .decryptData(userSnapshot.data!['name']),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1!
                                      .copyWith(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600)));
                        }),
                    snapshot.data!.docs[index].data()!['message']!.isEmpty
                        ? const SizedBox.shrink()
                        : BubbleNormal(
                            text: encrypter.decryptData(
                                snapshot.data!.docs[index].data()!['message']!),
                            isSender: encrypter.decryptData(snapshot
                                    .data!.docs[index]
                                    .data()!['user_uid']) ==
                                _chatManager.getCurrentUser(),
                            color: Color(0xFF1B97F3),
                            tail: true,
                            textStyle: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                    Text(timeago.format(
                        DateTime.fromMicrosecondsSinceEpoch(snapshot
                            .data!.docs[index]
                            .data()!['timestamp']
                            .microsecondsSinceEpoch),
                        allowFromNow: true)),
                  ]);
                },
                separatorBuilder: (context, index) => const Divider(),
                itemCount:
                    snapshot.data == null ? 0 : snapshot.data!.docs.length);
          }),
    );
  }

  Widget buildMessageInput(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
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
            await _chatManager.submitChat(message: textEditingController.text);
          },
        )),
      ]),
    );
  }
}
