import 'package:nuitri_pilot_frontend/core/common_result.dart';

abstract interface class UserRepository {


  Future<InterfaceResult<String>> applyForResetingPasswordOtp(String email);

  Future<InterfaceResult<String>> confirmOtpAndResetPassword(
    String email,
    String otp,
    String newPwd,
  );
}

abstract class UserBaseRepository implements UserRepository {}
