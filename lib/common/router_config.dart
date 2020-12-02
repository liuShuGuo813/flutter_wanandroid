import 'package:flutter/material.dart';
import 'package:flutter_wanandroid/ui/main_screen.dart';
import 'package:flutter_wanandroid/ui/splash_screen.dart';

//存放路由配置
class RouterName{
  static const String splash = 'splash';
  static const String main = 'main';
  static const String login = 'login';
}

class Router{
  static Map<String,WidgetBuilder> generateRoute(){
      Map<String,WidgetBuilder> route = {
          RouterName.splash: (context) => SplashScreen(),
          RouterName.main: (context) => MainScreen(),

      };
      return route;
  }
}