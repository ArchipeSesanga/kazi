// TODO(KZ-009): implement full Firebase exception → AppException mapping.
// Maps FirebaseException, FirebaseAuthException, FirebaseFunctionsException
// to the typed AppException hierarchy.
import 'app_exception.dart';

AppException mapException(Object e) {
  // Placeholder — full mapping in KZ-009.
  return UnknownException(e.toString());
}
