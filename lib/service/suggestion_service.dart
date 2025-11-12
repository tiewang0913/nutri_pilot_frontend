import 'dart:io';

import 'package:nuitri_pilot_frontend/core/common_result.dart';
import 'package:nuitri_pilot_frontend/core/di.dart';
import 'package:nuitri_pilot_frontend/repo/suggestion_repo.dart';

class SuggestionService {
  SuggestionRepo repo;
  SuggestionService(this.repo);

  Future<dynamic> seekingSuggestion(File file) async {
    InterfaceResult<dynamic> res = await repo.seekingSuggestion(file);
    if (DI.I.messageHandler.isErr(res)) {
      DI.I.messageHandler.handleErr(res);
      return "";
    } else {
      return res.value;
    }
  }
}
