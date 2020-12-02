import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wanandroid/common/application.dart';
import 'package:flutter_wanandroid/common/common.dart';
import 'package:flutter_wanandroid/data/api/apis_service.dart';
import 'package:flutter_wanandroid/data/model/base_model.dart';
import 'package:flutter_wanandroid/event/refresh_article_event.dart';
import 'package:flutter_wanandroid/utils/route_util.dart';
import 'package:flutter_wanandroid/utils/toast_util.dart';
import 'package:flutter_wanandroid/widgets/loading_dialog.dart';

///分享文章页面
class ShareArticle extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ShareArticleState();
  }
  
}

class _ShareArticleState extends State<ShareArticle> {

  TextEditingController _titleController = TextEditingController();
  TextEditingController _linkController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }
  
  String title = '';
  String link = '';
  
  void shareArticle() async{
    title = _titleController.text;
    link = _linkController.text;
    
    if(title.isEmpty) {
      T.show(msg: "标题不可为空");
      return;
    }
    
    if(link.isEmpty){
      T.show(msg: "链接不可为空");
      return;
    }

    var params = {
      "title" : title,
      "link" : link
    };

    _showLoading(context);
    
    apiService.shareArticle((BaseModel model){
      _hideLoading(context);
      if(model.errorCode == Constants.STATUS_SUCCESS){
        T.show(msg: "分享成功");
        Application.eventBus.fire(RefreshArticleEvent());
        Navigator.of(context).pop();
      }else{
        T.show(msg: model.errorMsg);
      }
    }, (DioError error){
      _hideLoading(context);
      T.show(msg: "分享失败");
    }, params);
    
  }
  
  _showLoading(BuildContext context){
    showDialog(
        context: context,
      builder: (context) => LoadingDialog(
        loadingText: "正在提交中...",
        outSizeDismiss: false,
      )
    );
  }
  
  _hideLoading(BuildContext context){
    Navigator.of(context).pop();
  }
  
  
  @override
  void dispose() {
    _linkController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (){
        //触摸收起键盘
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text("分享文章"),
          elevation: 0.4,
        ),
        body: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                child: Row(
                  children: <Widget>[
                    Expanded(child: Text("文章标题"),),
                    InkWell(
                      child: Text("刷新标题",style: TextStyle(color: Colors.cyan)),
                      onTap: (){
                        _titleController.clear();
                      },
                    )
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                child: TextField(
                  controller: _titleController,
                  maxLength: 100,
                  autofocus: false, //不自动对焦
                  maxLines: 3,
                  decoration: InputDecoration.collapsed(
                    hintText: "100字以内",
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                child: Row(
                  children: <Widget>[
                    Expanded(child: Text("文章链接"),),
                    InkWell(
                      child: Text("打开链接",style: TextStyle(color: Colors.cyan)),
                      onTap: (){
                        var link = _linkController.text;
                        var title = _titleController.text;
                        if(link.isEmpty){
                          T.show(msg: "请输入地址");
                        }else{
                          RouteUtil.toWebView(context, link, title.isEmpty ? "文章链接" : title);
                        }
                      },
                    )
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                child: TextField(
                  controller: _linkController,
                  autofocus: false, //不自动对焦
                  decoration: InputDecoration.collapsed(
                      hintText: "如:https://www.wanandroid.com/user_article/add",
                      hintStyle: TextStyle(color: Colors.grey[600])
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                width: double.infinity,
                height: 60,
                child: RaisedButton(
                  child: Text(
                    "分享",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: (){
                    shareArticle();
                  },
                  color: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0)
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(),
              ),
              Text(
                "1. 只要是任何好文都可以分享哈，并不一定要是原创！投递的文章会进入广场 tab;"
                    "\n2. CSDN，掘金，简书等官方博客站点会直接通过，不需要审核;"
                    "\n3. 其他个人站点会进入审核阶段，不要投递任何无效链接，测试的请尽快删除，否则可能会对你的账号产生一定影响;"
                    "\n4. 目前处于测试阶段，如果你发现500等错误，可以向我提交日志，让我们一起使网站变得更好。"
                    "\n5. 由于本站只有我一个人开发与维护，会尽力保证24小时内审核，当然有可能哪天太累，会延期，请保持佛系...",
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
  

}