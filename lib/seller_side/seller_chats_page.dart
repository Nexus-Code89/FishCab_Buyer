import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fish_cab/chat/chat_service.dart';
import 'package:fish_cab/components/chat_bubble.dart';
import 'package:fish_cab/components/my_textfield.dart';
import 'package:flutter/material.dart';
import 'package:fish_cab/home pages/bottom_navigation_bar.dart';

class SellerChatsPage extends StatefulWidget {
  final String receiverName;
  final String receiverUserID;
  const SellerChatsPage({
    super.key,
    required this.receiverName,
    required this.receiverUserID,
  });

  @override
  _SellerChatsPageState createState() => _SellerChatsPageState();
}

class _SellerChatsPageState extends State<SellerChatsPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage() async {
    // only send message if there is something to send
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(widget.receiverUserID, _messageController.text);
      // clear the text controller after sending the message
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
        toolbarHeight: 80,
        titleSpacing: 20,
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
        titleTextStyle: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 20, fontFamily: 'Montserrat'),
      ),
      body: Column(
        children: [
          // messages
          Expanded(
            child: _buildMessageList(),
          ),

          // user input
          _buildMessageInput(),

          const SizedBox(height: 25),
        ],
      ),
    );
  }

  // build message list
  Widget _buildMessageList() {
    return StreamBuilder(
        stream: _chatService.getMessages(widget.receiverUserID, _firebaseAuth.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('Loading...');
          }

          return ListView(
            children: snapshot.data!.docs.map((document) => _buildMessageItem(document)).toList(),
          );
        });
  }

  // build message item
  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    // align the messages left and right
    var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid) ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
        // TO DO: change email to name

        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
              crossAxisAlignment:
                  (data['senderId'] == _firebaseAuth.currentUser!.uid) ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              mainAxisAlignment:
                  (data['senderId'] == _firebaseAuth.currentUser!.uid) ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                Text(data['senderEmail']),
                const SizedBox(height: 5),
                (data['senderId'] == _firebaseAuth.currentUser!.uid)
                    ? ChatBubble(message: data['message'], type: 'sender')
                    : ChatBubble(message: data['message'], type: 'receiver')
              ]),
        ));
  }

  // build message input
  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50.0),
      child: Row(
        children: [
          Expanded(
              child: MyTextField(
            controller: _messageController,
            hintText: 'Enter message',
            obscureText: false,
          )),

          // send button
          IconButton(
              padding: EdgeInsets.zero,
              onPressed: sendMessage,
              icon: Icon(
                Icons.send,
                size: 30,
                color: Colors.blue,
              ))
        ],
      ),
    );
  }
}
