import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_v2ex/models/web/item_tab_topic.dart';
import 'package:flutter_v2ex/models/web/model_topic_detail.dart';
import 'package:flutter_v2ex/models/web/item_tab_topic.dart';

class Read {
  final Box box = Hive.box('recentTopicsBox');
  // 获取当前时间
  static DateTime now = DateTime.now();
  // 获取年、月、日
  int year = now.year;
  int month = now.month;
  int day = now.day;

  // var data = {
  //   '3/13': [
  //     {'topicId': 1, 'replyCount': '1', 'content': {}},
  //     {'topicId': 2, 'replyCount': '1', 'content': {}},
  //   ],
  //   '3/14': [
  //     {'topicId': 1, 'replyCount': '1', 'content': {}},
  //     {'topicId': 2, 'replyCount': '1', 'content': {}},
  //   ],
  //   '3/15': [
  //     {'topicId': 1, 'replyCount': '1', 'content': {}},
  //     {'topicId': 2, 'replyCount': '1', 'content': {}},
  //   ],
  // };

  // 新增
  void add(TopicDetailModel topicDetail) {
    // 获取当前年月日时间戳

    String topicId = topicDetail.topicId;
    String replyCount = topicDetail.replyCount;
    String nowDay  = '$year-$month-$day';
    TabTopicItem content = TabTopicItem();
    content.replyCount = int.parse(topicDetail.replyCount);
    content.memberId = topicDetail.createdId;
    content.topicId = topicDetail.topicId;
    content.avatar = topicDetail.avatar;
    content.topicTitle = topicDetail.topicTitle;
    content.clickCount = '';
    content.nodeId = topicDetail.nodeId;
    content.nodeName = topicDetail.nodeId;
    content.lastReplyMId = '';
    content.lastReplyTime = topicDetail.createdTime;



    Map<String, dynamic> record = {'topicId': topicId, 'replyCount': replyCount, 'content': content};
    var keys = box.keys;

    if (keys.contains(nowDay)) {
      // 已存在当前天
      var nowDayData = box.get(nowDay);
      print('line 43: $nowDayData');
      // 是否已存在当前主题数据
      // result true 已存在，删除重新存
      bool result = nowDayData.where((item) => item["topicId"] == topicId).isNotEmpty;
      print('line 46: $result');
      if(result){
        nowDayData.removeWhere((item) => item["topicId"] == topicId);
      }
      nowDayData.add(record);
    } else {
      // 否则新建
      box.put(nowDay, [record]);
    }
  }

  // 清除所有已读
  void clear() {
    box.clear();
  }

  void keep() {
    // 缓存的keys List
    var keys = box.keys;
    int len = keys.length;
    if(len >= 7){
      // 删除最旧的那条
      box.delete(0);
    }
  }

  // 查询
   query() {
    List historyTopicList = [];
    Map dateItem = {};
     var keys = box.keys;
     if(keys.isNotEmpty){
       for(var i in keys){
         var data = i.split('-');
         dateItem['date'] = data[1]+'月'+data[2]+'日';
         dateItem['topicList'] = [];
         for(var j in box.get(i)){
           Map map = {};
           map['topicId'] = j['topicId'];
           map['replyCount'] = j['replyCount'];
           map['content'] = TabTopicItem();
           map['content'] = j['content'];
           dateItem['topicList'].add(map);
         }
         dateItem['topicList'] = dateItem['topicList'].reversed.toList();
         historyTopicList.add(dateItem);
       }
       return historyTopicList;
     }else{
       return [];
     }
  }
}