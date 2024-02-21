class AppExceptions implements Exception {

  final _message ;
  final _prefix ;

  AppExceptions([this._message , this._prefix]) ;

  String toString(){
    return '$_prefix$_message';
  }
}

class InternetException extends AppExceptions {
  InternetException([String? message]) : super(message, 'No internet');
}


class RequestTimeOut extends AppExceptions {
  RequestTimeOut([String? message]) : super(message, 'Request Time out');
}

class ServerException extends AppExceptions {
  ServerException([String? message]) : super(message, 'Internal server error');
}

class InvalidUrlException extends AppExceptions {
  InvalidUrlException([String? message]) : super(message, 'Invalid Url');
}

class FetchDataException extends AppExceptions {
  FetchDataException([String? message]) : super(message, 'Error During Communication: ');
}

class BadRequestException extends AppExceptions {
  BadRequestException([message]) : super(message, "Invalid Request: ");
}

class ValidationException extends AppExceptions {
  ValidationException([message]) : super(message, "Validation error: ");
}

class UnauthorisedException extends AppExceptions {
  UnauthorisedException([message]) : super(message, "Unauthorised: ");
}

class InvalidInputException extends AppExceptions {
  InvalidInputException([String? message]) : super(message, "Invalid Input: ");
}

class ForbiddenException extends AppExceptions {
  ForbiddenException([String? message]) : super(message, "Forbidden: ");
}

class NotFoundException extends AppExceptions {
  NotFoundException([String? message]) : super(message, "Not Found: ");
}

class ServerErrorException extends AppExceptions {
  ServerErrorException([String? message]) : super(message, "Server Error: ");
}

class UnProcessableException extends AppExceptions {
  UnProcessableException([String? message]) : super(message, "UnProcessable Exception: ");
}




