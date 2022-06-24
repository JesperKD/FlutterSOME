import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_so_me/managers/chat_manager.dart';
import 'package:flutter_so_me/views/home/home_view.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:unicons/unicons.dart';

import 'create_chat_view.dart';

class ChatView extends StatelessWidget {
  ChatView({Key? key}) : super(key: key);

  final ChatManager _chatManager = ChatManager();

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

                    return Card(
                      elevation: 0,
                      color: Theme.of(context).cardColor,
                      margin: const EdgeInsets.all(16),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              StreamBuilder<Map<String, dynamic>?>(
                                  stream: _chatManager
                                      .getUserInfo(snapshot.data!.docs[index]
                                          .data()!['user_uid2'])
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
                                            userSnapshot.data!['picture']!),
                                      ),
                                      title: Text(userSnapshot.data!['name'],
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1!
                                              .copyWith(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600)),
                                      subtitle: Text(
                                          timeago.format(
                                              snapshot.data!.docs[index]
                                                  .data()!['timestamp']
                                                  .toDate(),
                                              allowFromNow: true),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2!
                                              .copyWith(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.grey)),
                                      trailing: IconButton(
                                          onPressed: null,
                                          icon: Icon(
                                            Icons.more_horiz,
                                            color: Theme.of(context)
                                                .iconTheme
                                                .color,
                                          )),
                                    );
                                  }),
                              snapshot.data!.docs[index]
                                      .data()!['message']!
                                      .isEmpty
                                  ? const SizedBox.shrink()
                                  : Text(
                                      snapshot.data!.docs[index]
                                          .data()!['message']!,
                                      textAlign: TextAlign.left,
                                    ),
                            ]),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(),
                  itemCount:
                      snapshot.data == null ? 0 : snapshot.data!.docs.length);
            }));
  }
}
