import 'dart:convert';
import 'dart:typed_data';

import 'package:nuitri_pilot_frontend/core/common_result.dart';
import 'package:nuitri_pilot_frontend/core/network.dart';
import 'package:nuitri_pilot_frontend/core/storage/keys.dart';
import 'package:nuitri_pilot_frontend/core/storage/local_storage.dart';

class WellnessRepo {
  Map<String, Map<String, String>> routeMap = {
    "chronics": {
      "list": "user_chronics",
      "addCatalogItem": "add_new_chronics",
    },
    "allergies": {
      "list": "user_allergies",
      "addCatalogItem": "add_new_allergy",
    },
  };

  Future<InterfaceResult<dynamic>> getWellnessCatagory(
    String tag,
  ) async {
    Uint8List? value = LocalStorage().get(LOCAL_TOKEN_KEY);
    String token = utf8.decode(Uint8List.fromList(value!));
    Map<String, String> map = routeMap[tag]!;
    String path = map["list"]!;
    return await post('/wellness/$path', {},  token: token);
  }

  Future<InterfaceResult<dynamic>> addCatalogItem(
    String tag,
    String name,
  ) async {
    Uint8List? value = LocalStorage().get(LOCAL_TOKEN_KEY);
    String token = utf8.decode(Uint8List.fromList(value!));
    return await post('/wellness/add_wellness_catalog_item?catalogName=$tag', {"name": name}, token: token);
  }
}
