import '../errors/app_exception.dart';

sealed class AsyncState<T> {
  const AsyncState();
}

final class AsyncIdle<T> extends AsyncState<T> {
  const AsyncIdle();
}

final class AsyncLoading<T> extends AsyncState<T> {
  const AsyncLoading();
}

final class AsyncData<T> extends AsyncState<T> {
  const AsyncData(this.value);

  final T value;
}

final class AsyncError<T> extends AsyncState<T> {
  const AsyncError(this.error);

  final AppException error;
}
