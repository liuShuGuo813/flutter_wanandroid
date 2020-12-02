import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wanandroid/common/common.dart';
import 'package:flutter_wanandroid/data/api/apis_service.dart';
import 'package:flutter_wanandroid/data/model/user_model.dart';
import 'package:flutter_wanandroid/utils/toast_util.dart';
import 'package:flutter_wanandroid/widgets/loading_dialog.dart';

///注册页面
class RegisterScreen extends StatefulWidget {

  @override
  _RegisterScreenState createState() {
    return _RegisterScreenState();
  }
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController _userNameController = TextEditingController();
  TextEditingController _psdController = TextEditingController();
  TextEditingController _psdAgainController = TextEditingController();
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
        appBar: AppBar(title: Text("注册"), elevation: 0.4),
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
                    "用户注册",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 20),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "用户注册后才可以登录！",
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
                Container(
                  padding: EdgeInsets.all(2),
                  child: TextField(
                    autofocus: false,
                    //不自动对焦
                    controller: _psdAgainController,
                    obscureText: true,
                    maxLines: 1,
                    decoration: InputDecoration(
                        labelText: "再次输入密码",
                        hintText: "请再次输入密码",
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
                          child: Text("注册"),
                          color: Theme.of(context).primaryColor,
                          textColor: Colors.white,
                          onPressed: () {
                            String username = _userNameController.text;
                            String password = _psdController.text;
                            String passwordAgain = _psdAgainController.text;
                            _register(username, password,passwordAgain);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
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
            loadingText: "正在注册...",
            outSizeDismiss: false,
          );
        }
    );
  }

  _hideLoading(BuildContext context){
    Navigator.of(context).pop();
  }

  Future _register(String userName, String passWord,String passWordAgain) async {
    if(passWord != passWordAgain){
      T.show(msg: "两次输入密码不一致");
    }else{
      _showLoading(context);
      apiService.register((UserModel model){
        _hideLoading(context);
        if (model != null) {
          if (model.errorCode == 0) {
            T.show(msg: "注册成功！");
            var map = {'username': userName, 'password': passWord};
            Navigator.of(context).pop(jsonEncode(map));
          } else {
            T.show(msg: model.errorMsg);
          }
        }
      }, (DioError error){
        _hideLoading(context);
        print(error.response);
      }, userName, passWord);
    }
  }
}