import 'package:flutter/material.dart';
import 'package:flutter_wanandroid/common/application.dart';
import 'package:flutter_wanandroid/common/common.dart';
import 'package:flutter_wanandroid/event/theme_change_event.dart';
import 'package:flutter_wanandroid/res/colors.dart';
import 'package:flutter_wanandroid/ui/about_screen.dart';
import 'package:flutter_wanandroid/ui/qr_code_screen.dart';
import 'package:flutter_wanandroid/utils/route_util.dart';
import 'package:flutter_wanandroid/utils/sp_util.dart';
import 'package:flutter_wanandroid/utils/theme_util.dart';
import 'package:flutter_wanandroid/utils/toast_util.dart';

///设置页面
class SettingScreen extends StatefulWidget {
  SettingScreen({Key key}) : super(key: key);

  @override
  _SettingScreenState createState() {
    return _SettingScreenState();
  }
}

class _SettingScreenState extends State<SettingScreen> {
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
    return Scaffold(
      appBar: AppBar(
        title: Text("设置"),
        elevation: 0.4,
      ),
      body: ListView(
        children: <Widget>[
          ExpansionTile(  //可收缩组件
              title: Row(
                children: <Widget>[
                  Icon(Icons.color_lens,color: Theme.of(context).primaryColor,),
                  Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Text("主题"),
                  )
                ],
              ),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 0,
                ),

                ///所有颜色按钮垂直排列Ω
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          color: Theme.of(context).cardColor,
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          child: Wrap(
                            runSpacing: 8,
                            children: themeColorMap.keys.map((String key) {
                              Color value = themeColorMap[key];
                              return Material(
                                borderRadius: BorderRadius.circular(4),
                                color: value,
                                child: InkWell(
                                  onTap: () {
                                    SPUtil.putString(Constants.THEME_COLOR_KEY, key);
                                    ThemeUtils.currentThemeColor = value;
                                    Application.eventBus.fire(ThemeChangeEvent());
                                  },
                                  splashColor: Colors.black.withAlpha(50),
                                  child: Stack(
                                    alignment: AlignmentDirectional.center,
                                    children: <Widget>[
                                      Container(
                                        width: double.infinity,
                                        height: 40,
                                        child: Center(
                                          child: Text(
                                            key,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 124),
                                        child: Offstage(
                                          offstage: ThemeUtils.currentThemeColor != value,
                                          child: Icon(
                                            Icons.check,
                                            size: 22,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ))
                  ],
                ),
              )
            ],
          ),
          ListTile(
            trailing: Icon(Icons.chevron_right),
            title: Row(
              children: <Widget>[
                Icon(Icons.feedback,color: Theme.of(context).primaryColor,),
                Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Text("意见反馈"),
                )
              ],
            ),
            onTap: (){
//              var url = "https://github.com/iceCola7/flutter_wanandroid/issues";
//              RouteUtil.launchInBrowser(url);
            },
          ),
          ListTile(
            trailing: Icon(Icons.chevron_right),
            title: Row(
              children: <Widget>[
                Icon(Icons.info,color: Theme.of(context).primaryColor,),
                Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Text("扫码下载"),
                )
              ],
            ),
            onTap: (){
              RouteUtil.push(context,QrCodeScreen());
            },
          ),
          ListTile(
            trailing: Icon(Icons.chevron_right),
            title: Row(
              children: <Widget>[
                Icon(Icons.info,color: Theme.of(context).primaryColor,),
                Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Text("关于"),)
              ],
            ),
            onTap: (){
              RouteUtil.push(context,AboutScreen());
            },
          )
        ],
      ),
    );
  }
}