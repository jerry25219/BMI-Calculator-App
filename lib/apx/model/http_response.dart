class HttpResponse {
  final int code;
  final String? msg;
  final String? detail;
  final String? rq;
  final dynamic data;

  HttpResponse({required this.code, this.msg, this.detail, this.rq, this.data});

  factory HttpResponse.fromJson(Map<String, dynamic> json) {
    return HttpResponse(
        code: json['code'],
        msg: json['msg'],
        detail: json['detail'],
        rq: json['rq'],
        data: json['data']);
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'msg': msg,
      'detail': detail,
      'rq': rq,
      'data': data,
    };
  }
}
