import 'package:flutter/foundation.dart';
import 'package:roomly/domain/entities/enquiry_entity.dart';
import 'package:roomly/domain/entities/chat_message_entity.dart';
import 'package:roomly/domain/repositories/enquiry_repository.dart';
import 'package:roomly/features/enquiries/providers/enquiry_state.dart';

class EnquiryNotifier extends ChangeNotifier {
  final EnquiryRepository _repository;

  EnquiryState _state = const EnquiryInitial();
  List<EnquiryEntity> _myEnquiries = [];
  List<EnquiryEntity> _receivedEnquiries = [];
  EnquiryEntity? _selectedEnquiry;
  List<ChatMessageEntity> _messages = [];
  bool _isSending = false;

  EnquiryNotifier({required EnquiryRepository enquiryRepository}) : _repository = enquiryRepository;

  EnquiryState get state => _state;
  List<EnquiryEntity> get myEnquiries => _myEnquiries;
  List<EnquiryEntity> get receivedEnquiries => _receivedEnquiries;
  EnquiryEntity? get selectedEnquiry => _selectedEnquiry;
  List<ChatMessageEntity> get messages => _messages;
  bool get isSending => _isSending;
  int get unreadTotal => [..._myEnquiries, ..._receivedEnquiries].fold(0, (sum, e) => sum + e.unreadCount);
  bool get isLoading => _state is EnquiryLoading || _state is EnquiryDetailLoading || _state is EnquiryMessageSending;

  String? get errorMessage => _state is EnquiryError ? (_state as EnquiryError).message : null;

  Future<void> loadAllEnquiries() async {
    _state = const EnquiryLoading();
    notifyListeners();

    final results = await Future.wait([
      _repository.getMyEnquiries(),
      _repository.getReceivedEnquiries(),
    ]);

    final myResult = results[0] as dynamic;
    final receivedResult = results[1] as dynamic;

    myResult.fold(
      (failure) {
        _state = EnquiryError(failure.message);
        notifyListeners();
      },
      (myList) {
        _myEnquiries = myList as List<EnquiryEntity>;
        receivedResult.fold(
          (failure) {
            _state = EnquiryLoaded(myEnquiries: _myEnquiries, receivedEnquiries: _receivedEnquiries, unreadTotal: unreadTotal);
            notifyListeners();
          },
          (receivedList) {
            _receivedEnquiries = receivedList as List<EnquiryEntity>;
            _state = EnquiryLoaded(
              myEnquiries: _myEnquiries,
              receivedEnquiries: _receivedEnquiries,
              unreadTotal: unreadTotal,
            );
            notifyListeners();
          },
        );
      },
    );
  }

  Future<void> loadMyEnquiries() async {
    _state = const EnquiryLoading();
    notifyListeners();
    final result = await _repository.getMyEnquiries();
    result.fold(
      (failure) {
        _state = EnquiryError(failure.message);
        notifyListeners();
      },
      (list) {
        _myEnquiries = list;
        _state = EnquiryLoaded(myEnquiries: _myEnquiries, receivedEnquiries: _receivedEnquiries, unreadTotal: unreadTotal);
        notifyListeners();
      },
    );
  }

  Future<void> loadReceivedEnquiries() async {
    _state = const EnquiryLoading();
    notifyListeners();
    final result = await _repository.getReceivedEnquiries();
    result.fold(
      (failure) {
        _state = EnquiryError(failure.message);
        notifyListeners();
      },
      (list) {
        _receivedEnquiries = list;
        _state = EnquiryLoaded(myEnquiries: _myEnquiries, receivedEnquiries: _receivedEnquiries, unreadTotal: unreadTotal);
        notifyListeners();
      },
    );
  }

  Future<EnquiryEntity?> createEnquiry({required int propertyId, required String message, EnquiryContactMethod method = EnquiryContactMethod.chat}) async {
    _state = const EnquiryLoading();
    notifyListeners();

    final result = await _repository.sendEnquiry(propertyId: propertyId, message: message, contactMethod: method);
    return result.fold(
      (failure) {
        _state = EnquiryError(failure.message);
        notifyListeners();
        return null;
      },
      (enquiry) {
        _myEnquiries = [enquiry, ..._myEnquiries];
        _selectedEnquiry = enquiry;
        _state = EnquiryLoaded(myEnquiries: _myEnquiries, receivedEnquiries: _receivedEnquiries, unreadTotal: unreadTotal);
        notifyListeners();
        return enquiry;
      },
    );
  }

  Future<void> openEnquiryDetail(int enquiryId) async {
    _state = const EnquiryDetailLoading();
    notifyListeners();

    final enquiryResult = await _repository.getEnquiryById(enquiryId);
    await enquiryResult.fold(
      (failure) async {
        _state = EnquiryError(failure.message);
        notifyListeners();
      },
      (enquiry) async {
        _selectedEnquiry = enquiry;
        // Load messages
        final msgResult = await _repository.getMessages(enquiryId);
        msgResult.fold(
          (failure) {
            _messages = [];
            _state = EnquiryDetailLoaded(enquiry: enquiry, messages: _messages);
            notifyListeners();
          },
          (msgs) {
            _messages = msgs;
            _state = EnquiryDetailLoaded(enquiry: enquiry, messages: _messages);
            notifyListeners();
          },
        );
        // Mark as read
        await _repository.markAsRead(enquiryId);
      },
    );
  }

  Future<bool> sendMessage({required int enquiryId, required String message, MessageType type = MessageType.text}) async {
    if (message.trim().isEmpty) return false;

    // Optimistic UI
    final tempMessage = ChatMessageEntity(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      enquiryId: enquiryId,
      senderId: 0,
      senderName: 'You',
      senderRole: 'tenant',
      message: message.trim(),
      type: type,
      timestamp: DateTime.now(),
      isRead: false,
    );

    _messages = [..._messages, tempMessage];
    if (_selectedEnquiry != null) {
      _state = EnquiryDetailLoaded(enquiry: _selectedEnquiry!, messages: _messages, isSending: true);
    }
    _isSending = true;
    notifyListeners();

    final result = await _repository.sendMessage(enquiryId: enquiryId, message: message.trim(), type: type);

    return result.fold(
      (failure) {
        // Remove temp and show error
        _messages = _messages.where((m) => m.id != tempMessage.id).toList();
        if (_selectedEnquiry != null) {
          _state = EnquiryDetailLoaded(enquiry: _selectedEnquiry!, messages: _messages, isSending: false);
        }
        _isSending = false;
        notifyListeners();
        _state = EnquiryError(failure.message);
        notifyListeners();
        return false;
      },
      (realMessage) {
        // Replace temp with real
        _messages = _messages.map((m) => m.id == tempMessage.id ? realMessage : m).toList();
        if (_selectedEnquiry != null) {
          final updatedEnquiry = _selectedEnquiry!.copyWith(
            lastMessage: realMessage.message,
            lastMessageAt: realMessage.timestamp,
            updatedAt: DateTime.now(),
          );
          _selectedEnquiry = updatedEnquiry;
          _state = EnquiryDetailLoaded(enquiry: updatedEnquiry, messages: _messages, isSending: false);
        }
        _isSending = false;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> sendBookingRequest({required int enquiryId, required String checkInNote}) async {
    return await sendMessage(
      enquiryId: enquiryId,
      message: checkInNote.isEmpty ? 'I would like to book this property' : checkInNote,
      type: MessageType.bookingRequest,
    );
  }

  Future<bool> acceptBooking(int enquiryId) async {
    final result = await _repository.acceptEnquiry(enquiryId);
    return result.fold(
      (failure) {
        _state = EnquiryError(failure.message);
        notifyListeners();
        return false;
      },
      (_) {
        if (_selectedEnquiry != null) {
          _selectedEnquiry = _selectedEnquiry!.copyWith(status: EnquiryStatus.accepted);
          _state = EnquiryDetailLoaded(enquiry: _selectedEnquiry!, messages: _messages);
          notifyListeners();
        }
        // Send system message
        sendMessage(enquiryId: enquiryId, message: 'Booking accepted! Owner has confirmed your request.', type: MessageType.bookingConfirmed);
        return true;
      },
    );
  }

  Future<bool> closeEnquiry(int enquiryId) async {
    final result = await _repository.closeEnquiry(enquiryId);
    return result.fold(
      (failure) {
        _state = EnquiryError(failure.message);
        notifyListeners();
        return false;
      },
      (_) {
        if (_selectedEnquiry != null) {
          _selectedEnquiry = _selectedEnquiry!.copyWith(status: EnquiryStatus.closed);
          _state = EnquiryDetailLoaded(enquiry: _selectedEnquiry!, messages: _messages);
          notifyListeners();
        }
        return true;
      },
    );
  }

  void clearError() {
    if (_state is EnquiryError) {
      if (_selectedEnquiry != null) {
        _state = EnquiryDetailLoaded(enquiry: _selectedEnquiry!, messages: _messages);
      } else {
        _state = EnquiryLoaded(myEnquiries: _myEnquiries, receivedEnquiries: _receivedEnquiries, unreadTotal: unreadTotal);
      }
      notifyListeners();
    }
  }

  void clearSelection() {
    _selectedEnquiry = null;
    _messages = [];
    _state = EnquiryLoaded(myEnquiries: _myEnquiries, receivedEnquiries: _receivedEnquiries, unreadTotal: unreadTotal);
    notifyListeners();
  }
}
