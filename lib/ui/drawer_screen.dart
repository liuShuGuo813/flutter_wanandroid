import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wanandroid/common/application.dart';
import 'package:flutter_wanandroid/common/common.dart';
import 'package:flutter_wanandroid/common/user.dart';
import 'package:flutter_wanandroid/data/api/apis_service.dart';
import 'package:flutter_wanandroid/data/model/base_model.dart';
import 'package:flutter_wanandroid/data/model/user_info_model.dart';
import 'package:flutter_wanandroid/event/login_event.dart';
import 'package:flutter_wanandroid/event/theme_change_event.dart';
import 'package:flutter_wanandroid/res/styles.dart';
import 'package:flutter_wanandroid/ui/collect_screen.dart';
import 'package:flutter_wanandroid/ui/rank_screen.dart';
import 'package:flutter_wanandroid/ui/score_screen.dart';
import 'package:flutter_wanandroid/ui/setting_screen.dart';
import 'package:flutter_wanandroid/ui/share_screen.dart';
import 'package:flutter_wanandroid/utils/route_util.dart';
import 'package:flutter_wanandroid/utils/sp_util.dart';
import 'package:flutter_wanandroid/utils/theme_util.dart';
import 'package:flutter_wanandroid/utils/toast_util.dart';
import 'package:flutter_wanandroid/utils/utils.dart';

import 'login_screen.dart';

///菜单页面
class DrawerScreen extends StatefulWidget {
  @override
  _DrawerScreenState createState() {
    return _DrawerScreenState();
  }
}

class _DrawerScreenState extends State<DrawerScreen>
    with AutomaticKeepAliveClientMixin {
  bool _isLogin = false;
  String _userName = '请先登录';
  String _level = '--'; //等级
  String _rank = '--'; //排名
  String _myScore = ''; //我的积分
  bool isDark = ThemeUtils.dark;

  @override
  void initState() {
    super.initState();
    print("draw initState");
    registerLoginEvent();
    if (null != User.singleton.userName && User.singleton.userName.isNotEmpty) {
      _isLogin = true;
      _userName = User.singleton.userName;
      getUserInfo();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

  }

  ///登录事件监听
  void registerLoginEvent() {
    Application.eventBus.on<LoginEvent>().listen((event) {
      setState(() {
        _isLogin = true;
        _userName = User.singleton.userName;
        getUserInfo();
      });
    });
  }

  ///获取个人信息
  Future getUserInfo() async {
    apiService.getUserInfo((UserInfoModel model) {
      if (model.errorCode == Constants.STATUS_SUCCESS) {
        setState(() {
          _level = (model.data.coinCount ~/ 100 - 1).toString();
          _rank = model.data.rank;
          _myScore = model.data.coinCount.toString();
        });
      }else{
        T.show(msg: model.errorMsg);
      }
    }, (DioError error) {
      print(error.response);
    });
  }

  @override
  void dispose() {
    super.dispose();
    print("draw dispose");
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(16, 40, 16, 10),
            color: Theme.of(context).primaryColor,
            child: Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    child: Image.asset(
                      Utils.getImgPath('ic_rank'),
                      width: 20,
                      height: 20,
                      color: Colors.white,
                    ),
                    onTap: () => RouteUtil.push(context, RankScreen()),
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Colors.transparent,
                  backgroundImage:
                  AssetImage(Utils.getImgPath("ic_avatar")),
                  radius: 40.0,
                ),
                Gaps.vGap10,
                InkWell(
                  child: Column(
                    children: <Widget>[
                      Text(
                        _userName,
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      Gaps.vGap5,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "等级",
                            style:
                            TextStyle(fontSize: 11, color: Colors.grey[100],height: 1.1),
                          ),
                          Text(
                            _level,
                            style:
                            TextStyle(fontSize: 11, color: Colors.grey[100],height: 1.5),
                          ),
                          Gaps.hGap5,
                          Text(
                            "排名",
                            style:
                            TextStyle(fontSize: 11, color: Colors.grey[100],height: 1.1),
                          ),
                          Text(
                            _rank,
                            style:
                            TextStyle(fontSize: 11, color: Colors.grey[100],height: 1.5),
                          ),
                        ],
                      )
                    ],
                  ),
                  onTap: () {
                    if (!_isLogin) {
                      RouteUtil.push(context, LoginScreen());
                    }
                  },
                ),
              ],
            ),
          ),
          ListTile(
            title: Text(
              "我的积分",
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 16),
            ),
            leading: Image.asset(
              Utils.getImgPath('ic_score'),
              width: 24,
              height: 24,
              color: Theme.of(context).primaryColor,
            ),
            onTap: () {
              if (!_isLogin) {
                T.show(msg: '请先登录');
                RouteUtil.push(context, LoginScreen());
              } else {
                RouteUtil.push(context, ScoreScreen(_myScore));
              }
            },
          ),
          ListTile(
            title: Text(
              "我的收藏",
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 16),
            ),
            leading: Icon(
              Icons.favorite_border,
              size: 24,
              color: Theme.of(context).primaryColor,
            ),
            onTap: () {
              if (!_isLogin) {
                T.show(msg: '请先登录');
                RouteUtil.push(context, LoginScreen());
              } else {
                RouteUtil.push(context, CollectScreen());
              }
            },
          ),
          ListTile(
            title: Text(
              "我的分享",
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 16),
            ),
            leading: Image.asset(
              Utils.getImgPath('ic_share'),
              width: 24,
              height: 24,
              color: Theme.of(context).primaryColor,
            ),
            onTap: () {
              if (!_isLogin) {
                T.show(msg: '请先登录');
                RouteUtil.push(context, LoginScreen());
              } else {
                RouteUtil.push(context, ShareScreen());
              }
            },
          ),
          ListTile(
            title: Text(
              isDark ? "夜间模式" : "日间模式",
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 16),
            ),
            leading: Icon(
              isDark ? Icons.brightness_2 : Icons.brightness_7,
              size: 24,
              color: Theme.of(context).primaryColor,
            ),
            onTap: () {
              setState(() {
                changeTheme();
              });
            },
          ),
          ListTile(
            title: Text(
              "系统设置",
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 16),
            ),
            leading: Icon(
              Icons.settings,
              size: 24,
              color: Theme.of(context).primaryColor,
            ),
            onTap: () {
              RouteUtil.push(context, SettingScreen());
            },
          ),
          Offstage(
            offstage: !_isLogin,
            child: ListTile(
              title: Text(
                "退出登录",
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 16),
              ),
              leading: Icon(
                Icons.power_settings_new,
                size: 24,
                color: Theme.of(context).primaryColor,
              ),
              onTap: () {
                _logout(context);
              },
            ),
          )
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("确认要退出登录吗？"),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(
                    "取消",
                    style: TextStyle(color: Colors.cyan),
                  )
              ),
              FlatButton(
                  onPressed: () {
                    apiService.logout((BaseModel model){
                      if(null != model){
                        if(model.errorCode == Constants.STATUS_SUCCESS){
                            User().clearUserInfo();
                            setState(() {
                              _isLogin = false;
                              _userName = "去登录";
                              _level = "--";
                              _rank = "--";
                              _myScore = '';
                            });
                            T.show(msg: "已退出登录");
                            Navigator.of(context).pop(true);
                        }else{
                          T.show(msg: model.errorMsg);
                        }
                      }
                    }, (DioError error){
                      print(error.response);
                    });
                  },
                  child: Text(
                    "确定",
                    style: TextStyle(color: Colors.cyan),
                  )
              ),
            ],
          );
        });
  }

  @override
  bool get wantKeepAlive => true;

  //切换夜间模式
  void changeTheme() async {
    ThemeUtils.dark = !ThemeUtils.dark;
    isDark = ThemeUtils.dark;
    SPUtil.putBool(Constants.DARK_KEY, ThemeUtils.dark);
    Application.eventBus.fire(ThemeChangeEvent());
  }
}
