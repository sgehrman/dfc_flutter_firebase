import 'package:cloud_functions/cloud_functions.dart';
import 'package:dfc_flutter/dfc_flutter_web.dart';

class FirebaseUtils {
  static Future<List<Map<dynamic, dynamic>>?> users({
    String? nextPageToken,
  }) async {
    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'users',
      );

      final params = <dynamic, dynamic>{
        'nextPageToken': nextPageToken,
      };

      final resp = await callable.call<Map<dynamic, dynamic>>(params);

      final Map<dynamic, dynamic> m = resp.data;

      if (m.listVal<Map<dynamic, dynamic>>('list') != null) {
        return m.listVal<Map<dynamic, dynamic>>('list');
      }

      return null;
    } catch (error) {
      print('error $error');
    }

    return null;
  }

  static Future<List<String>?> getSubCollections(String docPath) async {
    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'users',
      );

      final params = <dynamic, dynamic>{
        'docPath': docPath,
      };

      final resp = await callable.call<Map<dynamic, dynamic>>(params);

      final respMap = resp.data;

      return respMap['collections'] as List<String>;
    } catch (error) {
      print('error $error');
    }

    return null;
  }

  static Future<bool> modifyClaims({
    required String? email,
    required String? uid,
    required Map<String?, bool> claims,
  }) async {
    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'addUserClaims',
      );
      final HttpsCallableResult<dynamic> resp =
          await callable.call<Map<dynamic, dynamic>>(<String, dynamic>{
        'email': email,
        'uid': uid,
        'claims': claims,
      });

      if (resp.data != null) {
        final respMap = resp.data as Map;

        if (respMap['error'] != null) {
          print(resp.data);

          return false;
        }

        return true;
      }
    } catch (error) {
      print('error $error');
    }

    return false;
  }

  static Future<bool> sendEmail({
    required String to,
    required String subject,
    required String text,
    required String html,
    required String from,
  }) async {
    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'sendEmail',
      );
      final HttpsCallableResult<dynamic> resp =
          await callable.call<Map<dynamic, dynamic>>(<String, dynamic>{
        'to': to,
        'subject': subject,
        'from': from,
        'text': text,
        'html': html,
      });

      if (resp.data != null) {
        final respMap = resp.data as Map;

        if (respMap['error'] != null) {
          print(resp.data);

          return false;
        }

        return true;
      }
    } catch (error) {
      print('error $error');
    }

    return false;
  }
}
