enum ErrorKind {
  network,
  unauthorized,
  forbidden,
  notFound,
  rateLimited,
  server,
  validation,
  business,
  unknown,
}

/*
 * Parent Class of all the Results 
 */
sealed class Result<T> {
  const Result();
}

/*
 * Application inner result
 */
class AppResult<T> extends Result<T> {
  final T? value;
  const AppResult(this.value);
}

class AppOk<T> extends AppResult<T> {
  const AppOk(super.value);
}

class AppErr<T> extends AppResult<T> {
  final String message;
  const AppErr({required this.message}) : super(null);
}

/*
 * Parent Class of all the InterfaceResult
 * Which means this is the abstract result coming from backend http interfaces.
 */
class InterfaceResult<T> extends Result<T> {
  final T? value;
  const InterfaceResult(this.value);
}

class BizOk<T> extends InterfaceResult<T> {
  const BizOk(super.value);
}

class BizErr<T> extends InterfaceResult<T> {
  final int code;
  final String message;
  const BizErr(this.code, this.message) : super(null);
}

class NetworkErr<T> extends InterfaceResult<T> {
  final ErrorKind kind;
  final int? httpStatus;
  final String message;
  const NetworkErr(this.kind, this.httpStatus, this.message):super(null);
}
