import 'dart:convert';

import 'package:flutter_qjs/flutter_qjs.dart';
import 'package:http_interceptor/http_interceptor.dart';

import '../../http/m_client.dart';

class JsHttpClient {
  late JavascriptRuntime runtime;

  JsHttpClient(this.runtime);

  void init() {
    InterceptedClient client(dynamic reqcopyWith) {
      return MClient.init(
          reqcopyWith: (reqcopyWith as Map?)?.toMapStringDynamic);
    }

    runtime.onMessage('http_get', (dynamic args) async {
      return jsonEncode((await client(args[1]).get(Uri.parse(args[2]),
              headers: (args[3] as Map?)?.toMapStringString))
          .toJson());
    });
    runtime.onMessage('http_post', (dynamic args) async {
      return jsonEncode((await client(args[1]).post(Uri.parse(args[2]),
              headers: (args[3] as Map?)?.toMapStringString,
              body: (args[4] as Map?)?.toMapStringString))
          .toJson());
    });
    runtime.onMessage('http_put', (dynamic args) async {
      return (await client(args[1]).put(Uri.parse(args[2]),
              headers: (args[3] as Map?)?.toMapStringString, body: args[4]))
          .toJson();
    });
    runtime.onMessage('http_delete', (dynamic args) async {
      return jsonEncode((await client(args[1]).delete(Uri.parse(args[2]),
              headers: (args[3] as Map?)?.map(
                  (key, value) => MapEntry(key.toString(), value.toString())),
              body: (args[4] as Map?)?.toMapStringString))
          .toJson());
    });
    runtime.onMessage('http_patch', (dynamic args) async {
      return jsonEncode((await client(args[1]).patch(Uri.parse(args[2]),
              headers: (args[3] as Map?)?.toMapStringString,
              body: (args[4] as Map?)?.toMapStringString))
          .toJson());
    });
    runtime.evaluate('''
class Client {
    constructor(reqcopyWith) {
        this.reqcopyWith = reqcopyWith;
    }
    async get(url, headers) {
        headers = headers;
        const result = await sendMessage(
            "http_get",
            JSON.stringify([null, this.reqcopyWith, url, headers])
        );
        return JSON.parse(result);
    }
    async post(url, headers, body) {
        headers = headers;
        const result = await sendMessage(
            "http_post",
            JSON.stringify([null, this.reqcopyWith, url, headers, body])
        );
        return JSON.parse(result);
    }
    async put(url, headers, body) {
        headers = headers;
        const result = await sendMessage(
            "http_post",
            JSON.stringify([null, this.reqcopyWith, url, headers, body])
        );
        return JSON.parse(result);
    }
    async delete(url, headers, body) {
        headers = headers;
        const result = await sendMessage(
            "http_post",
            JSON.stringify([null, this.reqcopyWith, url, headers, body])
        );
        return JSON.parse(result);
    }
    async patch(url, headers, body) {
        headers = headers;
        const result = await sendMessage(
            "http_post",
            JSON.stringify([null, this.reqcopyWith, url, headers, body])
        );
        return JSON.parse(result);
    }
}
''');
  }
}

extension ResponseExtexsion on Response {
  Map<String, dynamic> toJson() => {
        'body': body,
        'headers': headers,
        'isRedirect': isRedirect,
        'persistentConnection': persistentConnection,
        'reasonPhrase': reasonPhrase,
        'statusCode': statusCode,
        'request': {
          'contentLength': request?.contentLength,
          'finalized': request?.finalized,
          'followRedirects': request?.followRedirects,
          'headers': request?.headers,
          'maxRedirects': request?.maxRedirects,
          'method': request?.method,
          'persistentConnection': request?.persistentConnection,
          'url': request?.url.toString()
        }
      };
}

extension ToMapExtension on Map? {
  Map<String, dynamic>? get toMapStringDynamic {
    return this?.map((key, value) => MapEntry(key.toString(), value));
  }

  Map<String, String>? get toMapStringString {
    return this
        ?.map((key, value) => MapEntry(key.toString(), value.toString()));
  }
}
