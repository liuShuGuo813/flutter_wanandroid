import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wanandroid/common/common.dart';
import 'package:flutter_wanandroid/common/user.dart';
import 'package:flutter_wanandroid/data/api/apis_service.dart';
import 'package:flutter_wanandroid/data/model/article_model.dart';
import 'package:flutter_wanandroid/data/model/base_model.dart';
import 'package:flutter_wanandroid/data/model/wx_article_model.dart';
import 'package:flutter_wanandroid/utils/route_util.dart';
import 'package:flutter_wanandroid/utils/toast_util.dart';
import 'package:flutter_wanandroid/widgets/custom_cached_image.dart';
import 'package:flutter_wanandroid/widgets/like_button_widget.dart';

///公众号文章Item
class ItemWeChatList extends StatefulWidget {
  WXArticleBean item;

  ItemWeChatList(this.item);

  @override
  _ItemWeChatListState createState() {
    return _ItemWeChatListState(item);
  }
}

class _ItemWeChatListState extends State<ItemWeChatList> {
  WXArticleBean item;

  _ItemWeChatListState(this.item);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        var url = item.link;
        var title = item.title;
        RouteUtil.toWebView(context, url, title);
      },
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Row(
              children: <Widget>[
                Text(
                  item.author.isNotEmpty ? item.author : item.shareUser,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  textAlign: TextAlign.left,
                ),
                Expanded(
                  //充满父容器剩余空间
                  child: Text(
                    item.niceDate,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    textAlign: TextAlign.right,
                  ),
                )
              ],
            ),
          ),
          Container(
            alignment: Alignment.topLeft,
            padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Text(
              item.title,
              style: TextStyle(fontSize: 16),
              maxLines: 2,
              textAlign: TextAlign.left,
            ),
          ),
          Container(
            alignment: Alignment.topLeft,
            padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    item.superChapterName + "/" + item.chapterName,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey[600]),
                    textAlign: TextAlign.left,
                  ),
                ),
                LikeButtonWidget(
                  isLike: item.collect,
                  onClick: () {
                    addOrCancelCollect(item);
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void addOrCancelCollect(WXArticleBean item) {
    List<String> cookies = User.singleton.cookie;
    if (cookies == null || cookies.length == 0) {
      T.show(msg: "请先登录~");
    } else {
      if (item.collect) {
        apiService.cancelCollection((BaseModel model) {
          if (null != model) {
            if (model.errorCode == Constants.STATUS_SUCCESS) {
              T.show(msg: "已取消收藏~");
              setState(() {
                item.collect = false;
              });
            } else {
              T.show(msg: "取消收藏失败");
            }
          }
        }, (DioError error) {
          print(error.response);
        }, item.id);
      }else{
        apiService.addCollection((BaseModel model) {
          if (null != model) {
            if (model.errorCode == Constants.STATUS_SUCCESS) {
              T.show(msg: "收藏成功~");
              setState(() {
                item.collect = true;
              });
            } else {
              T.show(msg: "收藏失败");
            }
          }
        }, (DioError error) {
          print(error.response);
        }, item.id);
      }
    }
  }
}
