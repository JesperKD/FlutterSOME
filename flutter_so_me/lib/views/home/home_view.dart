import 'package:flutter_so_me/views/auth/login_view.dart';
import 'package:flutter_so_me/views/chat/chat_view.dart';
import 'package:flutter_so_me/views/profile/profile_view.dart';
import 'package:flutter_so_me/views/timeline/timeline_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  int _currentIndex = 0;
  final List<Widget> _views = [TimelineView(), ChatView(), const ProfileView()];

  @override
  void initState() {
    isUserAuth();
    super.initState();
  }

  isUserAuth() {
    _firebaseAuth.authStateChanges().listen((user) {
      if (user == null) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginView()),
            (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _firebaseAuth.currentUser == null
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            body: IndexedStack(
              index: _currentIndex,
              children: _views,
            ),
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Theme.of(context).iconTheme.color,
              unselectedItemColor: Colors.grey,
              showSelectedLabels: false,
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(UniconsLine.history), label: 'Timeline'),
                BottomNavigationBarItem(
                    icon: Icon(UniconsLine.comment_dots), label: 'Chat'),
                BottomNavigationBarItem(
                    icon: Icon(UniconsLine.user), label: 'Profile')
              ],
            ),
          );
  }
}
