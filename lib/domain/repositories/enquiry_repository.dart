import 'package:dartz/dartz.dart';
import 'package:roomly/core/errors/failures.dart';
import 'package:roomly/domain/entities/enquiry_entity.dart';
import 'package:roomly/domain/entities/chat_message_entity.dart';

abstract class EnquiryRepository {
  // Enquiries
  Future<Either<Failure, List<EnquiryEntity>>> getMyEnquiries({int page = 1, int limit = 20});
  Future<Either<Failure, List<EnquiryEntity>>> getReceivedEnquiries({int page = 1, int limit = 20});
  Future<Either<Failure, EnquiryEntity>> getEnquiryById(int id);
  Future<Either<Failure, EnquiryEntity>> sendEnquiry({
    required int propertyId,
    required String message,
    EnquiryContactMethod contactMethod = EnquiryContactMethod.chat,
  });
  Future<Either<Failure, EnquiryEntity>> replyToEnquiry({
    required int enquiryId,
    required String message,
  });
  Future<Either<Failure, bool>> markAsRead(int enquiryId);
  Future<Either<Failure, bool>> closeEnquiry(int enquiryId);
  Future<Either<Failure, bool>> acceptEnquiry(int enquiryId);
  Future<Either<Failure, bool>> deleteEnquiry(int enquiryId);

  // Chat
  Future<Either<Failure, List<ChatMessageEntity>>> getMessages(int enquiryId, {int page = 1, int limit = 50});
  Future<Either<Failure, ChatMessageEntity>> sendMessage({
    required int enquiryId,
    required String message,
    MessageType type = MessageType.text,
    Map<String, dynamic>? metadata,
  });
}
