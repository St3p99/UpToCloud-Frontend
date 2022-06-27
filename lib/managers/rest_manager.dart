import 'dart:convert';
import 'dart:io';
import 'package:universal_io/io.dart';
import 'package:http_parser/http_parser.dart';
import 'package:admin/models/file_data_model.dart';
import 'package:http/http.dart';

import '../support/constants.dart';
import '../support/error_listener.dart';

enum TypeHeader { json, urlencoded, multipart }

class RestManager {
  // ErrorListener delegate;
  String? token;

  Future<Response> _makeRequest(
      String serverAddress, String servicePath, String method,
      {TypeHeader? type,
      Map<String, dynamic>? value,
      dynamic body,
      bool httpsEnabled = false}) async {
    Uri uri;
    if (httpsEnabled)
      uri = Uri.https(serverAddress, servicePath, value);
    else
      uri = Uri.http(serverAddress, servicePath, value);

    print(uri.toString());
    try {
      late Response response;
      String? contentType;
      dynamic formattedBody;

      // setting content-type
      if (type == TypeHeader.json) {
        contentType = "application/json;charset=utf-8";
        formattedBody = json.encode(body);
      } else if (type == TypeHeader.urlencoded) {
        contentType = "application/x-www-form-urlencoded";
        formattedBody = body.keys.map((key) => "$key=${body[key]}").join("&");
      }

      // setting headers
      Map<String, String> headers = Map();

      if(contentType != null)headers[HttpHeaders.contentTypeHeader] = contentType;
      if (token != null) {
        headers[HttpHeaders.authorizationHeader] = 'bearer $token';
      }

      // making request
      switch (method) {
        case "post":
          {
            response = await post(
              uri,
              headers: headers,
              body: formattedBody,
            );
          }
          break;
        case "get":
          {
            response = await get(
              uri,
              headers: headers,
            );
          }
          break;
        case "put":
          {
            response = await put(
              uri,
              headers: headers,
            );
          }
          break;
        case "delete":
          {
            response = await delete(
              uri,
              headers: headers,
            );
          }
          break;
        default:
      }
      print(response.statusCode);
      return response;
    } catch (err) {
      print('RestManager: makeRequest exception: ' + err.toString());
      await Future.delayed(
          const Duration(seconds: 60), () => null); // not the best solution
      throw err;
    }
  }

  Future<StreamedResponse> makePostMultiPartRequest(
      String serverAddress, String servicePath, dynamic files,
      {bool httpsEnabled = false}) async {
    Uri uri;
    if (httpsEnabled)
      uri = Uri.https(serverAddress, servicePath);
    else
      uri = Uri.http(serverAddress, servicePath);

    MultipartRequest request = MultipartRequest('POST', uri);
    Map<String, String> headers = new Map();
    headers[HttpHeaders.authorizationHeader] = 'bearer $token';
    request.headers.addAll(headers);

    if (files is List<FileDataModel>){
      for (FileDataModel file in files)
        request.files.add(
            await MultipartFile(
                'file', file.stream, file.bytes, filename: file.name,
                contentType: MediaType.parse(file.mime)
            )
        );
    } else if( files is FileDataModel)
      request.files.add(
          await MultipartFile('file', files.stream, files.bytes, filename: files.name, contentType: MediaType.parse(files.mime))
      );
    else throw Exception();
    print(uri.toString());
    StreamedResponse res = await request.send();
    return res;
  }

  Future<StreamedResponse> makeGetMultiPartRequest(
      String serverAddress, String servicePath,
      {bool httpsEnabled = false}) async {
    Uri uri;
    if (httpsEnabled)
      uri = Uri.https(serverAddress, servicePath);
    else
      uri = Uri.http(serverAddress, servicePath);

    MultipartRequest request = MultipartRequest('GET', uri);
    Map<String, String> headers = new Map();
    headers[HttpHeaders.authorizationHeader] = 'bearer $token';
    request.headers.addAll(headers);

    print(uri.toString());
    StreamedResponse res = await request.send();
    return res;
  }

  Future<Response> makeGetRequestStream(
      String serverAddress, String servicePath,
      {bool httpsEnabled = false}) async {
    Uri uri;
    if (httpsEnabled)
      uri = Uri.https(serverAddress, servicePath);
    else
      uri = Uri.http(serverAddress, servicePath);

    Map<String, String> headers = new Map();
    headers[HttpHeaders.contentTypeHeader] = "application/octet-stream";
    headers[HttpHeaders.authorizationHeader] = 'bearer $token';


    print(uri.toString());
    Response res = await get(uri, headers: headers);
    return res;
  }


  Future<Response> makePostRequest(
      String serverAddress, String servicePath, dynamic body,
      {Map<String, dynamic>? value,
      TypeHeader type = TypeHeader.json,
      bool httpsEnabled = false}) async {
    return _makeRequest(serverAddress, servicePath, "post",
        type: type, body: body, value: value, httpsEnabled: httpsEnabled);
  }

  Future<Response> makeGetRequest(String serverAddress, String servicePath,
      [Map<String, dynamic>? value, TypeHeader? type]) async {
    return _makeRequest(serverAddress, servicePath, "get",
        type: type, value: value);
  }

  Future<Response> makePutRequest(String serverAddress, String servicePath,
      [Map<String, dynamic>? value, TypeHeader? type]) async {
    return _makeRequest(serverAddress, servicePath, "put",
        type: type, value: value);
  }

  Future<Response> makeDeleteRequest(String serverAddress, String servicePath,
      [Map<String, dynamic>? value, TypeHeader? type]) async {
    return _makeRequest(serverAddress, servicePath, "delete",
        type: type, value: value);
  }


}
