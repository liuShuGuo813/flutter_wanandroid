import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_wanandroid/common/application.dart';
import 'package:flutter_wanandroid/common/common.dart';
import 'package:flutter_wanandroid/common/router_config.dart' as R;
import 'package:flutter_wanandroid/res/colors.dart';
import 'package:flutter_wanandroid/ui/splash_screen.dart';
import 'package:flutter_wanandroid/ui/splash_screen.dart';
import 'package:flutter_wanandroid/utils/sp_util.dart';
import 'common/user.dart';
import 'net/dio_manager.dart';
import 'utils/theme_util.dart';
import 'event/theme_change_event.dart';
import 'package:event_bus/event_bus.dart';

/// 在拿不到context的地方通过navigatorKey进行路由跳转：
/// https://stackoverflow.com/questions/52962112/how-to-navigate-without-context-in-flutter-app
final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

void main() async{

  /// 修改问题: Unhandled Exception: ServicesBinding.defaultBinaryMessenger was accessed before the binding was initialized
  /// https://stackoverflow.com/questions/57689492/flutter-unhandled-exception-servicesbinding-defaultbinarymessenger-was-accesse
  WidgetsFlutterBinding.ensureInitialized();

  await SPUtil.getInstance();

  await getTheme();

  runApp(MyApp());

  if (Platform.isAndroid) {
    // 以下两行 设置android状态栏为透明的沉浸。写在组件渲染之后，
    // 是为了在渲染后进行set赋值，覆盖状态栏，写在渲染之前MaterialApp组件会覆盖掉这个值。
    SystemUiOverlayStyle systemUiOverlayStyle =
    SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

//获取主题
Future<Null> getTheme(){
  //是否是夜间模式
  bool dark = SPUtil.getBool(Constants.DARK_KEY,defValue: false);
  ThemeUtils.dark = dark;

  //如果不是夜间模式,用户设置的主题才生效
  if(!dark){
    String themeColorKey = SPUtil.getString(Constants.THEME_COLOR_KEY,defValue: 'blue');
    if(themeColorMap.containsKey(themeColorKey)){
      ThemeUtils.currentThemeColor = themeColorMap[themeColorKey];
    }
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  //主题模式
  ThemeData _themeData;

  @override
  void initState() {
    super.initState();
    _initAsync();
    Application.eventBus = EventBus();  //实例化EventBus
    _themeData = ThemeUtils.getThemeData();
    registerThemeEvent();
  }

  //初始化一些基础配置
  void _initAsync() async{
    await User().getUserInfo();
    await DioManager.init();
  }

  //注册主题监听事件
  void registerThemeEvent() {
    Application.eventBus
        .on<ThemeChangeEvent>()
        .listen((ThemeChangeEvent event) => changeTheme(event));
  }

  //监听用户切换主题
  void changeTheme(ThemeChangeEvent event) async {
    setState(() {
      _themeData = ThemeUtils.getThemeData();
    });
  }

  @override
  void dispose() {
    super.dispose();
    Application.eventBus.destroy();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName, //标题
      debugShowCheckedModeBanner: false, //去掉debug图标
      theme: _themeData,
      routes: R.Router.generateRoute(),
      navigatorKey: navigatorKey, //设置全局导航(为没有context的地方提供跳转)
      home: SplashScreen(),
    );
  }

}

