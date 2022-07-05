import 'package:call_log/call_log.dart';
import 'package:contact_reminder/models/log_type.dart';

class ContactLogModel {
  final String number;
  final String name;
  final String sender;
  final String message;
  final int duration;
  final Type type; // call or sms
  final DateTime dateTime;
  final CallType callType; // receive send missed

  ContactLogModel({
    required this.number,
    required this.message,
    required this.sender,
    required this.duration,
    required this.callType,
    required this.type,
    required this.dateTime,
    required this.name,
  });

  ContactLogModel copyWith({
    String? number,
    String? name,
    String? sender,
    String? message,
    int? duration,
    Type? type, // call or sms
    DateTime? dateTime,
    CallType? callType,
  }) {
    return ContactLogModel(
      sender: sender ?? this.sender,
      callType: callType ?? this.callType,
      dateTime: dateTime ?? this.dateTime,
      duration: duration ?? this.duration,
      message: message ?? this.message,
      name: name ?? this.name,
      number: number ?? this.number,
      type: type ?? this.type,
    );
  }
}
