import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wanandroid/common/application.dart';
import 'package:flutter_wanandroid/common/common.dart';
import 'package:flutter_wanandroid/common/user.dart';
import 'package:flutter_wanandroid/data/api/apis_service.dart';
import 'package:flutter_wanandroid/data/model/user_model.dart';
import 'package:flutter_wanandroid/event/login_event.dart';
import 'package:flutter_wanandroid/ui/register_screen.dart';
import 'package:flutter_wanandroid/utils/toast_util.dart';
import 'package:flutter_wanandroid/widgets/loading_dialog.dart';

///登录页面
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _userNameController = TextEditingController();
  TextEditingController _psdController = TextEditingController();

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
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        //触摸收起键盘
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: Text("登录"), elevation: 0.4),
        body: Container(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 10),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "用户登录",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 20),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "请使用WanAndroid账号登录",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(2),
                  child: TextField(
                    autofocus: true, //自动对焦
                    controller: _userNameController,
                    maxLines: 1,
                    decoration: InputDecoration(
                        labelText: "用户名",
                        hintText: "请输入用户名",
                        labelStyle: TextStyle(color: Colors.cyan)),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(2),
                  child: TextField(
                    autofocus: false,
                    //不自动对焦
                    controller: _psdController,
                    obscureText: true,
                    maxLines: 1,
                    decoration: InputDecoration(
                        labelText: "密码",
                        hintText: "请输入密码",
                        labelStyle: TextStyle(color: Colors.cyan)),
                  ),
                ),
                // 登录按钮
                Padding(
                  padding: const EdgeInsets.only(top: 28.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                          padding: EdgeInsets.all(16.0),
                          elevation: 0.5,
                          child: Text("登录"),
                          color: Theme.of(context).primaryColor,
                          textColor: Colors.white,
                          onPressed: () {
                            String username = _userNameController.text;
                            String password = _psdController.text;
                            _login(username, password);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 10.0),
                  alignment: Alignment.centerRight,
                  child: FlatButton(
                      onPressed: () {
                        registerClick();
                      },
                      child: Text(
                        "还没有账号，注册一个？",
                        style: TextStyle(fontSize: 14),
                      )),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _showLoading(BuildContext context){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_){
        return LoadingDialog(
          loadingText: "正在登录...",
          outSizeDismiss: false,
        );
      }
    );
  }

  _hideLoading(BuildContext context){
    Navigator.of(context).pop();
  }

  void registerClick() async {
    await Navigator.of(context).push(new MaterialPageRoute(builder: (context){
      return RegisterScreen();
    })).then((value){
        var map = jsonDecode(value);
        var userName = map['username'];
        var passWord = map['password'];
        _userNameController.text = userName;
        _psdController.text = passWord;
        _login(userName, passWord);
    });
  }

  Future _login(String userName, String passWord) async {
    if((null != userName && userName.length > 0) &&
        null != passWord && passWord.length > 0){
      _showLoading(context);
      apiService.login((UserModel model,Response response){
        _hideLoading(context);
        if(null != model){
          if(model.errorCode == Constants.STATUS_SUCCESS){
            User().saveUserInfo(model, response);
            Application.eventBus.fire(LoginEvent());
            T.show(msg: "登录成功");
            Navigator.of(context).pop();
          }else{
            T.show(msg: model.errorMsg);
          }
        }
      }, (DioError error){
        _hideLoading(context);
        print(error.response);
      }, userName, passWord);
    }else{
      T.show(msg: "用户名或密码不能为空");
    }
  }
}
