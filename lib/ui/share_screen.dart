import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wanandroid/common/application.dart';
import 'package:flutter_wanandroid/common/common.dart';
import 'package:flutter_wanandroid/common/user.dart';
import 'package:flutter_wanandroid/data/api/apis_service.dart';
import 'package:flutter_wanandroid/data/model/base_model.dart';
import 'package:flutter_wanandroid/data/model/share_model.dart';
import 'package:flutter_wanandroid/event/refresh_article_event.dart';
import 'package:flutter_wanandroid/ui/base_widget.dart';
import 'package:flutter_wanandroid/ui/share_article.dart';
import 'package:flutter_wanandroid/utils/refresh_helper.dart';
import 'package:flutter_wanandroid/utils/route_util.dart';
import 'package:flutter_wanandroid/utils/toast_util.dart';
import 'package:flutter_wanandroid/widgets/loading_dialog.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'item_share_article.dart';
import 'login_screen.dart';

///我的分享页面
class ShareScreen extends BaseWidget {
  @override
  BaseWidgetState<BaseWidget> attachState() {
    return _ShareScreenState();
  }
}

class _ShareScreenState extends BaseWidgetState<ShareScreen> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  ScrollController _scrollController = ScrollController();

  int _page = 1;
  bool isShowFAB = false;
  List<ShareBean> _shareList = List();

  @override
  void initState() {
    super.initState();
    setAppBarVisible(true);
    registerArticleAdd();
    _scrollController.addListener(() {
      if (_scrollController.offset > 200 && !isShowFAB) {
        setState(() {
          isShowFAB = true;
        });
      } else if (_scrollController.offset < 200 && isShowFAB) {
        setState(() {
          isShowFAB = false;
        });
      }
    });
  }

  ///监听文章分享,成功后刷新列表
  registerArticleAdd() {
    Application.eventBus
        .on<RefreshArticleEvent>()
        .listen((RefreshArticleEvent event) {
      getShareArticleList();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    showLoading().then((value) {
      getShareArticleList();
    });
  }

  Future getShareArticleList() async {
    _page = 1;
    apiService.getShareList((ShareModel model) {
      if (model.errorCode == Constants.STATUS_SUCCESS) {
        if (model.data.shareArticles.datas.length > 0) {
          showContent();
          _refreshController.refreshCompleted(resetFooterState: false);
          setState(() {
            _shareList.clear();
            _shareList.addAll(model.data.shareArticles.datas);
          });
        } else {
          showEmpty();
        }
      } else {
        showError();
        T.show(msg: model.errorMsg);
      }
    }, (DioError error) {
      showError();
    }, _page);
  }

  ///删除已分享的文章
  Future deleteShareArticle(int id, int index) async {
    _showLoadingDialog(context);
    apiService.deleteShareArticle((BaseModel model) {
      if (model.errorCode == Constants.STATUS_SUCCESS) {
        _hideDialog(context);
        setState(() {
          _shareList.removeAt(index);
          T.show(msg: "删除成功");
          getShareArticleList();
        });
      } else {
        _hideDialog(context);
      }
    }, (DioError error) {
      _hideDialog(context);
    }, id);
  }

  Future getMoreShareArticleList() async {
    _page++;
    apiService.getShareList((ShareModel model) {
      if (model.errorCode == Constants.STATUS_SUCCESS) {
        if (model.data.shareArticles.datas.length > 0) {
          _refreshController.loadComplete();
          setState(() {
            _shareList.addAll(model.data.shareArticles.datas);
          });
        } else {
          _refreshController.loadNoData();
        }
      } else {
        _refreshController.loadFailed();
        T.show(msg: model.errorMsg);
      }
    }, (DioError error) {
      _refreshController.loadFailed();
    }, _page);
  }

  _showLoadingDialog(BuildContext context) {
    showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return LoadingDialog(
            outSizeDismiss: false,
          );
        });
  }

  _hideDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  AppBar attachAppBar() {
    return AppBar(
      elevation: 0.4,
      title: Text("我的分享"),
      actions: <Widget>[
        IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              if (null != User.singleton.userName &&
                  User.singleton.userName.isNotEmpty) {
                RouteUtil.push(context, ShareArticle()); //跳到分享
              } else {
                T.show(msg: "请先登录");
                RouteUtil.push(context, LoginScreen());
              }
            })
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  attachContentWidget(BuildContext context) {
    return Scaffold(
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: getShareArticleList,
        onLoading: getMoreShareArticleList,
        enablePullDown: true,
        enablePullUp: true,
        header: MaterialClassicHeader(),
        footer: RefreshFooter(),
        child: ListView.builder(
          itemBuilder: itemView,
          itemCount: _shareList.length,
          physics: AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: Text("share"),
        child: Icon(Icons.vertical_align_top),
        onPressed: () {
          _scrollController.animateTo(0,
              duration: Duration(milliseconds: 2000), curve: Curves.ease);
        },
      ),
    );
  }

  Widget itemView(BuildContext context, int index) {
    return ItemShareArticle(
      item: _shareList[index],
      deleteItemCallBack: (id) {
        deleteShareArticle(id, index);
      },
    );
  }

  @override
  void onClickErrorWidget() {
    showLoading().then((value) {
      getShareArticleList();
    });
  }
}
