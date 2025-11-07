import 'package:nuitri_pilot_frontend/core/common_result.dart';
import 'package:nuitri_pilot_frontend/core/di.dart';
import 'package:nuitri_pilot_frontend/data/data.dart';
import 'package:nuitri_pilot_frontend/repo/wellness_repo.dart';

class WellnessService {
  WellnessRepo repo;
  WellnessService(this.repo);

  Future<WellnessCatagory?> getWellnessCatagory(String tag) async {
    InterfaceResult<WellnessCatagory> res = await repo.getWellnessCatagory(tag);
    if (DI.I.messageHandler.isErr(res)) {
      DI.I.messageHandler.handleErr(res);
      return null;
    } else {
      return res.value!;
    }
  }
}
