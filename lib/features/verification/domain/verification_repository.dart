import 'package:image_picker/image_picker.dart';

import '../../../core/models/verification_request.dart';

export '../../../core/models/verification_request.dart';

enum VerificationDocKind { idDocument, selfie }

abstract interface class VerificationRepository {
  Stream<VerificationRequest?> watch(String uid);
  Future<String> uploadDocument(XFile file, VerificationDocKind kind);
  Future<void> submit({
    required String idDocumentPath,
    required String selfiePath,
  });
}
