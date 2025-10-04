

import 'package:nuitri_pilot_frontend/core/network.dart';

abstract interface class UserRepository{

  // ignore: non_constant_identifier_names
  Future<Result<String>> applyForResetingPasswordOtp(String email);

}

abstract class UserBaseRepository implements UserRepository{
}