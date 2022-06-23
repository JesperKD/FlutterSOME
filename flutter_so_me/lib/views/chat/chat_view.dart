import 'package:flutter/material.dart';
import 'package:flutter_so_me/views/home/home_view.dart';
import 'package:unicons/unicons.dart';

class ChatView extends StatelessWidget {
  const ChatView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Timeline'),
        actions: [
          IconButton(
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const HomeView())),
              icon: Icon(
                UniconsLine.plus_square,
                color: Theme.of(context).iconTheme.color,
              ))
        ],
      ),
    );
  }
}
