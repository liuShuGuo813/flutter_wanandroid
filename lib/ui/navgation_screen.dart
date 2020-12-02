import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wanandroid/common/common.dart';
import 'package:flutter_wanandroid/data/api/apis_service.dart';
import 'package:flutter_wanandroid/data/model/knowledge_tree_model.dart';
import 'package:flutter_wanandroid/data/model/navigation_model.dart';
import 'package:flutter_wanandroid/ui/base_widget.dart';
import 'package:flutter_wanandroid/utils/refresh_helper.dart';
import 'file:///E:/FlutterProject/flutter_wanandroid/lib/ui/item_navigation.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

///导航页
class NavigationScreen extends BaseWidget {

  @override
  BaseWidgetState<BaseWidget> attachState() {
    return _NavigationScreenState();
  }
}

class _NavigationScreenState extends BaseWidgetState<NavigationScreen> {

  ScrollController _scrollController = ScrollController();
  RefreshController _refreshController =
  RefreshController(initialRefresh: false);
  bool _isShowFAB = false;
  List<NavigationBean> _navigationList = List();
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    showLoading().then((value) {
      getKnowledgeTreeList();
    });

    _scrollController.addListener(() {
      /// 滑动到底部，加载更多
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {}
      if (_scrollController.offset < 200 && _isShowFAB) {
        setState(() {
          _isShowFAB = false;
        });
      } else if (_scrollController.offset >= 200 && !_isShowFAB) {
        setState(() {
          _isShowFAB = true;
        });
      }
    });
  }

  Future getKnowledgeTreeList() async {
    apiService.getNavigationList((NavigationModel model) {
      if (model.errorCode == Constants.STATUS_SUCCESS) {
        if (model.data.length > 0) {
          showContent().then((value) {
            _refreshController.refreshCompleted();
            setState(() {
              _navigationList.clear();
              _navigationList.addAll(model.data);
            });
          });
        } else {
          showEmpty();
        }
      }
    }, (DioError error) {
      print(error.response);
      showError();
    });
  }

  @override
  attachContentWidget(BuildContext context) {
    return Scaffold(
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        header: MaterialClassicHeader(),
        footer: RefreshFooter(),
        controller: _refreshController,
        onRefresh: getKnowledgeTreeList,
        child: ListView.builder(
          itemBuilder: itemView,
          physics: new AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          itemCount: _navigationList.length,
        ),
      ),
      floatingActionButton: !_isShowFAB
          ? null
          : FloatingActionButton(
        heroTag: "Navigation",
        child: Icon(Icons.vertical_align_top),
        onPressed: () {
          /// 回到顶部时要执行的动画
          _scrollController.animateTo(0,
              duration: Duration(milliseconds: 2000), curve: Curves.ease);
        },
      ),
    );
  }

  Widget itemView(BuildContext context,int index){
    return ItemNavigation(_navigationList[index]);
  }

  @override
  void onClickErrorWidget() {
    showLoading().then((value) {
      getKnowledgeTreeList();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

}