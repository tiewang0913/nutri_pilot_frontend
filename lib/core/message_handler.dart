import 'package:flutter/material.dart';
import 'package:nuitri_pilot_frontend/core/common_result.dart';

abstract interface class MessageHandler {
  /*
   * 公共的错误处理器，只要是错误，就可以用这个方法来发布全局提示
   */
  void handleErr(Result e);

  /*
   * 判断一个Result是否时Err
   */
  bool isErr(Result res);

  /*
   * 显示一个信息
   */
  void showMessage(String message);
}

class GlobalMessageHandler implements MessageHandler {
  final GlobalKey<NavigatorState> navigatorKey;
  final GlobalKey<ScaffoldMessengerState> messengerKey;

  GlobalMessageHandler({
    required this.navigatorKey,
    required this.messengerKey,
  });

  @override
  bool isErr(Result res) => res is AppErr || res is BizErr || res is NetworkErr;

  @override
  void handleErr(Result e) {
    final message = getErrorMessage(e);
    showMessage(message);
  }

  @override
  void showMessage(String message) {
    //首选：不用 context，直接用全局 ScaffoldMessenger
    final m = messengerKey.currentState;
    if (m != null) {
      m.showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    //兜底：等首帧后再用 navigator 的 context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = navigatorKey.currentContext;
      if (ctx != null) {
        ScaffoldMessenger.of(
          ctx,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    });
  }

  String getErrorMessage(Result e) {
    if (e is AppErr) {
      return e.message;
    } else if (e is BizErr) {
      return e.message;
    } else if (e is NetworkErr) {
      return e.message;
    } else {
      return "Unkown Error";
    }
  }
}
