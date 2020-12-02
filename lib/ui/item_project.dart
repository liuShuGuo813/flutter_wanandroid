import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wanandroid/common/common.dart';
import 'package:flutter_wanandroid/common/user.dart';
import 'package:flutter_wanandroid/data/api/apis_service.dart';
import 'package:flutter_wanandroid/data/model/base_model.dart';
import 'package:flutter_wanandroid/data/model/project_article_model.dart';
import 'package:flutter_wanandroid/utils/route_util.dart';
import 'package:flutter_wanandroid/utils/toast_util.dart';
import 'package:flutter_wanandroid/widgets/custom_cached_image.dart';
import 'package:flutter_wanandroid/widgets/like_button_widget.dart';

///项目文章Item
class ItemProject extends StatefulWidget {
  ProjectArticleBean item;


  ItemProject(this.item);

  @override
  _ItemProjectState createState() {
    return _ItemProjectState();
  }
}

class _ItemProjectState extends State<ItemProject> {
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
    ProjectArticleBean item = widget.item;
    return InkWell(
      onTap: (){
        RouteUtil.toWebView(context, item.link, item.title);
      },
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(16, 8, 8, 8),
                width: 80,
                height: 130,
                color: Colors.transparent,
                child: CustomCachedImage(
                  imageUrl: item.envelopePic,
                  fit: BoxFit.fill,
                ),
              ),
              Expanded(
                  child: Column(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.fromLTRB(0, 8, 8, 8),
                        child: Text(
                          item.title,
                          style: TextStyle(fontSize: 16),
                          maxLines: 2,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.fromLTRB(0, 0, 8, 8),
                        child: Text(
                          item.desc,
                          style: TextStyle(fontSize: 14,color: Colors.grey[600]),
                          maxLines: 2,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.fromLTRB(0, 0, 8, 8),
                        child: Row(
                          children: <Widget>[
                            Text(
                              item.author.isNotEmpty ? item.author : item.shareUser,
                              style: TextStyle(fontSize: 12,color: Colors.grey[600]),
                              textAlign: TextAlign.left,
                            ),
                            Expanded(
                                child: Text(
                                  item.niceDate,
                                  style: TextStyle(fontSize: 12,color: Colors.grey[600]),
                                  maxLines: 1,
                                  textAlign: TextAlign.right,
                                )
                            )
                          ],
                        ),
                      ),
                      Container(
                        alignment: Alignment.topRight,
                        padding: EdgeInsets.fromLTRB(0, 0, 8, 8),
                        child: LikeButtonWidget(
                          isLike: item.collect,
                          onClick: (){
                            addOrCancelCollect(item);
                          },
                        ),
                      )
                    ],
                  )
              ),
            ],
          ),
        ],
      ),
    );
  }

  void addOrCancelCollect(ProjectArticleBean item) {
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