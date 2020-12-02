import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wanandroid/widgets/webview_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class RouteUtil{
  ///跳转页面
  static void push(BuildContext context,Widget page) async{
    if(context == null || page == null) return;
    await Navigator.push(context,new CupertinoPageRoute(builder: (context) => page));
  }

  ///打开外部浏览器
  static Future<Null> launchInBrowser(String url,{String title}) async{
    if(await canLaunch(url)){
      await launch(url,forceSafariVC: false,forceWebView: false);
    }else{
      throw 'Could not launch url $url';
    }
  }

  ///跳转webView
  static toWebView(BuildContext context,String url,String title) async{
    if(context == null || url.isEmpty) return;
    if(url.endsWith(".apk")){
      launchInBrowser(url,title: title);
    }else{
      Navigator.of(context).push(new CupertinoPageRoute(builder: (context){
        return WebViewScreen(title: title, url: url);
      }));
    }
  }

}