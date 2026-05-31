import 'package:json_annotation/json_annotation.dart';

part 'ip_tv_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class IpTvModel {
  final String? channel;
  final String? feed;
  final String? title;
  final String? url;
  final String? quality;
  final String? label;
  final String? userAgent;
  final String? referrer;

  IpTvModel({
    required this.channel,
    required this.feed,
    required this.title,
    required this.url,
    this.quality,
    this.label,
    this.userAgent,
    this.referrer,
  });

  factory IpTvModel.fromJson(Map<String, dynamic> json) =>
      _$IpTvModelFromJson(json);
  Map<String, dynamic> toJson() => _$IpTvModelToJson(this);
}
