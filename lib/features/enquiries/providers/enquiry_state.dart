import 'package:equatable/equatable.dart';
import 'package:roomly/domain/entities/enquiry_entity.dart';
import 'package:roomly/domain/entities/chat_message_entity.dart';

abstract class EnquiryState extends Equatable {
  const EnquiryState();
  @override
  List<Object?> get props => [];
}

class EnquiryInitial extends EnquiryState {
  const EnquiryInitial();
}

class EnquiryLoading extends EnquiryState {
  const EnquiryLoading();
}

class EnquiryLoaded extends EnquiryState {
  final List<EnquiryEntity> myEnquiries;
  final List<EnquiryEntity> receivedEnquiries;
  final int unreadTotal;

  const EnquiryLoaded({
    this.myEnquiries = const [],
    this.receivedEnquiries = const [],
    this.unreadTotal = 0,
  });

  @override
  List<Object?> get props => [myEnquiries, receivedEnquiries, unreadTotal];
}

class EnquiryDetailLoading extends EnquiryState {
  const EnquiryDetailLoading();
}

class EnquiryDetailLoaded extends EnquiryState {
  final EnquiryEntity enquiry;
  final List<ChatMessageEntity> messages;
  final bool isSending;

  const EnquiryDetailLoaded({
    required this.enquiry,
    this.messages = const [],
    this.isSending = false,
  });

  EnquiryDetailLoaded copyWith({
    EnquiryEntity? enquiry,
    List<ChatMessageEntity>? messages,
    bool? isSending,
  }) {
    return EnquiryDetailLoaded(
      enquiry: enquiry ?? this.enquiry,
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
    );
  }

  @override
  List<Object?> get props => [enquiry, messages, isSending];
}

class EnquiryError extends EnquiryState {
  final String message;
  const EnquiryError(this.message);
  @override
  List<Object?> get props => [message];
}

class EnquiryMessageSending extends EnquiryState {
  const EnquiryMessageSending();
}

class EnquiryActionSuccess extends EnquiryState {
  final String message;
  const EnquiryActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}
