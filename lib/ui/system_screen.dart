import 'package:flutter/material.dart';
import 'package:flutter_wanandroid/ui/base_widget.dart';
import 'package:flutter_wanandroid/ui/home_Screen.dart';
import 'package:flutter_wanandroid/ui/knowledge_screen.dart';
import 'package:flutter_wanandroid/ui/navgation_screen.dart';
import 'package:flutter_wanandroid/ui/project_screen.dart';

///体系页面
class SystemScreen extends BaseWidget {
  @override
  BaseWidgetState<BaseWidget> attachState() {
    return _SystemScreenState();
  }

}

class _SystemScreenState extends BaseWidgetState<SystemScreen>
  with TickerProviderStateMixin{
  TabController _tabController;
  var _tabList = ['体系','导航'];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    showContent();
  }

  @override
  attachContentWidget(BuildContext context) {
    _tabController = new TabController(length: _tabList.length, vsync: this);
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            color: Theme.of(context).primaryColor,
            height: 50,
            child: TabBar(
                isScrollable: false,
                unselectedLabelStyle: TextStyle(fontSize: 16),
                labelStyle: TextStyle(fontSize: 16),
                controller: _tabController,
                tabs: _tabList.map((item){
                  return Tab(
                    text: item,
                  );
                }).toList()
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
                children: [KnowLedgeScreen(),NavigationScreen()]
            ),
          )
        ],
      ),
    );
  }

  @override
  void onClickErrorWidget() {

  }

  @override
  void dispose() {
    super.dispose();
  }
}