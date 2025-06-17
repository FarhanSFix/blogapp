import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:blogapp/models/api_response.dart';
import 'package:blogapp/models/message.dart';
import 'package:blogapp/services/user_service.dart';

import '../constant.dart';

// Get messages between logged-in user and another user
Future<ApiResponse> getMessages(int userId) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.get(
      Uri.parse('$messagesURL/$userId'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    switch (response.statusCode) {
      case 200:
        apiResponse.data = (jsonDecode(response.body) as List)
            .map((m) => Message.fromJson(m))
            .toList();
        break;
      case 401:
        apiResponse.error = unauthorized;
        break;
      default:
        apiResponse.error = somethingWentWrong;
    }
  } catch (e) {
    apiResponse.error = serverError;
  }
  return apiResponse;
}

// Send message
Future<ApiResponse> sendMessage(int receiverId, String message) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.post(
      Uri.parse(messagesURL),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      body: {'receiver_id': receiverId.toString(), 'message': message},
    );

    switch (response.statusCode) {
      case 201:
        apiResponse.data = Message.fromJson(jsonDecode(response.body));
        break;
      case 422:
        final errors = jsonDecode(response.body)['errors'];
        apiResponse.error = errors[errors.keys.first][0];
        break;
      case 401:
        apiResponse.error = unauthorized;
        break;
      default:
        apiResponse.error = somethingWentWrong;
    }
  } catch (e) {
    apiResponse.error = serverError;
  }
  return apiResponse;
}
