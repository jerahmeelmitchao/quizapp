import 'dart:io';

class ErrorMapper {
  static String map(Object error) {
    final raw = error.toString().toLowerCase();

    if (error is SocketException ||
        raw.contains('socketexception') ||
        raw.contains('failed host lookup') ||
        raw.contains('no route to host') ||
        raw.contains('connection refused') ||
        raw.contains('network is unreachable')) {
      return 'Not connected to the internet. Please check your connection and try again.';
    }

    if (error is HttpException || raw.contains('timed out')) {
      return 'The server took too long to respond. Please try again in a moment.';
    }

    if (raw.contains('formatexception') || raw.contains('unexpected character')) {
      return 'The app received an invalid response. Please try again later.';
    }

    if (raw.contains('400')) {
      return 'The request could not be processed. Please check your file and try again.';
    }

    if (raw.contains('401') || raw.contains('403')) {
      return 'You are not allowed to do this action right now.';
    }

    if (raw.contains('404')) {
      return 'The requested service could not be found.';
    }

    if (raw.contains('413')) {
      return 'The selected file is too large to process.';
    }

    if (raw.contains('500') || raw.contains('502') || raw.contains('503')) {
      return 'The service is currently unavailable. Please try again later.';
    }

    return 'Something went wrong. Please try again.';
  }
}
