// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ip_tv_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IpTvModel _$IpTvModelFromJson(Map<String, dynamic> json) => IpTvModel(
  channel: json['channel'] as String?,
  feed: json['feed'] as String?,
  title: json['title'] as String?,
  url: json['url'] as String?,
  quality: json['quality'] as String?,
  label: json['label'] as String?,
  userAgent: json['user_agent'] as String?,
  referrer: json['referrer'] as String?,
);

Map<String, dynamic> _$IpTvModelToJson(IpTvModel instance) => <String, dynamic>{
  'channel': instance.channel,
  'feed': instance.feed,
  'title': instance.title,
  'url': instance.url,
  'quality': instance.quality,
  'label': instance.label,
  'user_agent': instance.userAgent,
  'referrer': instance.referrer,
};
