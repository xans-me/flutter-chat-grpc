import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_chat_grpc/protobuff/service.pb.dart';
import 'package:flutter_chat_grpc/protobuff/service.pbgrpc.dart';
import 'package:grpc/grpc.dart';

class ChatService {
  User user = User();

  // init broadcast client which actual use to communicate with the server
  // static to always to same instance
  static BroadcastClient client;

  // constructor for ChatService class
  ChatService(String username) {
    // setup user
    user
      ..clearName()
      ..name = username
      ..clearId()
      ..id = sha256.convert(utf8.encode(user.name)).toString();

    // setup a client
    client = BroadcastClient(
      ClientChannel(
        "10.0.2.2",
        port: 8080,
        options: ChannelOptions(
          credentials: ChannelCredentials.insecure(),
        ),
      ),
    );
  }

  // method async to send message
  Future<Close> sendMessage(String body) async {
    return client.broadcastMessage(
      Message()
        ..id = user.id
        ..content = body
        ..timestamp = DateTime.now().toIso8601String(),
    );
  }

  // method async to receive message
  Stream<Message> receiveMessage() async* {
    Connect connect = Connect()
      ..user = user
      ..active = true;

    // await for loop to get all various messages from calling client
    await for (var msg in client.createStream(connect)) {
      yield msg;
    }
  }
}
