class Message {
  int? id;
  int? senderId;
  int? receiverId;
  String? message;
  String? createdAt;

  Message({
    this.id,
    this.senderId,
    this.receiverId,
    this.message,
    this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      message: json['message'],
      createdAt: json['created_at'],
    );
  }
}
