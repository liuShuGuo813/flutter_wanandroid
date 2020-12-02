import 'package:flutter/material.dart';
import 'package:flutter_wanandroid/common/user.dart';
import 'package:flutter_wanandroid/ui/drawer_screen.dart';
import 'package:flutter_wanandroid/ui/home_Screen.dart';
import 'package:flutter_wanandroid/ui/project_screen.dart';
import 'package:flutter_wanandroid/ui/search_screen.dart';
import 'package:flutter_wanandroid/ui/share_article.dart';
import 'package:flutter_wanandroid/ui/square_screen.dart';
import 'package:flutter_wanandroid/ui/system_screen.dart';
import 'package:flutter_wanandroid/ui/wechat_screen.dart';
import 'package:flutter_wanandroid/utils/route_util.dart';
import 'package:flutter_wanandroid/utils/toast_util.dart';
import 'package:flutter_wanandroid/utils/utils.dart';

import 'login_screen.dart';

///项目首页
class MainScreen extends StatefulWidget {
  MainScreen({Key key}) : super(key: key);

  @override
  _MainScreenState createState() {
    return _MainScreenState();
  }
}

/// AutomaticKeepAliveClientMixin 切换tab后保留tab的状态，避免initState方法重复调用
/// https://blog.csdn.net/xcf111/article/details/95318987
class _MainScreenState extends State<MainScreen>
    with AutomaticKeepAliveClientMixin {
  PageController _pageController = PageController();
  int _selectIndex = 0; //当前选中的索引

  //Tab的名字
  final bottomTitles = ['首页', '广场', '公众号', '体系', '项目'];

  //Tab的内容
  var pages = <Widget>[
    HomeScreen(),
    SquareScreen(),
    WeChatScreen(),
    SystemScreen(),
    ProjectScreen()
  ];

  ///控制抽屉
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

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
    // TODO: implement build
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: DrawerScreen(), //侧滑页面
        appBar: getAppBar(),
        body: Container(
          color: Theme.of(context).primaryColor,
          child: SafeArea(
            child: PageView.builder(
              scrollDirection: Axis.vertical,
              controller: _pageController,
              itemBuilder: (context, index) => pages[index],
              itemCount: pages.length,
              physics: NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _selectIndex = index;
                });
              },
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: buildImage(0, 'ic_home'), title: Text(bottomTitles[0])),
            BottomNavigationBarItem(icon: buildImage(1, 'ic_square'), title: Text(bottomTitles[1])),
            BottomNavigationBarItem(icon: buildImage(2, 'ic_wechat'), title: Text(bottomTitles[2])),
            BottomNavigationBarItem(icon: buildImage(3, 'ic_system'), title: Text(bottomTitles[3])),
            BottomNavigationBarItem(icon: buildImage(4, 'ic_project'), title: Text(bottomTitles[4])),
          ],
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectIndex,
          onTap: (index) => _onItemTapped(index),
        ),
      ),
    );
  }

  Widget getAppBar(){
    if(_selectIndex == 1 || _selectIndex == 0){
      return AppBar(
        title: Text(bottomTitles[_selectIndex]), //标题
        bottom: null,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(3),
            child: CircleAvatar(
              radius: 30.0,
              backgroundImage: AssetImage(Utils.getImgPath('ic_avatar')),
            ),
          ),
          onPressed: (){
            _scaffoldKey.currentState.openDrawer();
          },
        ),
        elevation: 0,
        actions: <Widget>[
          //右上角搜索/添加按钮
          IconButton(
              icon: Icon(_selectIndex == 1 ? Icons.add : Icons.search),
              onPressed: () {
                if (_selectIndex == 1) {
                  if (null != User.singleton.userName && User.singleton.userName.isNotEmpty) {
                    RouteUtil.push(context, ShareArticle()); //跳到分享
                  }else{
                    T.show(msg: "请先登录");
                    RouteUtil.push(context, LoginScreen());
                  }
                } else {
                  RouteUtil.push(context, SearchScreen()); //跳到搜索
                }
              })
        ],
      );
    }else{
      return null;
    }
  }

  Widget buildImage(index, imagePath) {
    return Image.asset(
      Utils.getImgPath(imagePath),
      width: 22,
      height: 22,
      color: _selectIndex == index
          ? Theme.of(context).primaryColor
          : Colors.grey[600],
    );
  }

  void _onItemTapped(index) {
    _pageController.jumpToPage(index);
  }

  //返回按键处理
  Future<bool> _onWillPop() {
    return showDialog(
            context: context,
            builder: (context) => new AlertDialog(
                  title: Text("提示"),
                  content: Text("确定退出应用吗？"),
                  actions: <Widget>[
                    FlatButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(
                          "再看一会儿",
                          style: TextStyle(color: Colors.grey),
                        )),
                    FlatButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(
                          "退出",
                          style: TextStyle(color: Colors.grey),
                        ))
                  ],
                )) ??
        false;
  }

  @override
  bool get wantKeepAlive => true;
}
