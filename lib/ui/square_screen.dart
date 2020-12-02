import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wanandroid/common/common.dart';
import 'package:flutter_wanandroid/data/api/apis_service.dart';
import 'package:flutter_wanandroid/data/model/article_model.dart';
import 'package:flutter_wanandroid/ui/base_widget.dart';
import 'package:flutter_wanandroid/utils/refresh_helper.dart';
import 'package:flutter_wanandroid/utils/toast_util.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'item_article_list.dart';

///广场页面
class SquareScreen extends BaseWidget {


  @override
  BaseWidgetState<BaseWidget> attachState() {
    return _SquareScreenState();
  }
}

class _SquareScreenState extends BaseWidgetState<SquareScreen> {

  ///首页文章数据
  List<ArticleBean> _articleList = List();

  ///是否显示悬浮按钮
  bool isShowFAB = false;

  ///页码
  int _page = 0;

  ///ListView控制器
  ScrollController _scrollController = ScrollController();

  RefreshController _refreshController = RefreshController(initialRefresh: true);

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    showLoading().then((value) {
      getSquareList();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        ///LoadMore
      } else if (_scrollController.offset < 200 && isShowFAB) {
        setState(() {
          isShowFAB = false;
        });
      } else if (_scrollController.offset > 200 && !isShowFAB) {
        setState(() {
          isShowFAB = true;
        });
      }
    });
  }

  Future getSquareList() async {
    _page = 0;
    apiService.getSquareList((ArticleModel articleModel) {
      if (articleModel.errorCode == Constants.STATUS_SUCCESS) {
        if (articleModel.data.datas.length > 0) {
          showContent().then((value) {
            _refreshController.refreshCompleted(resetFooterState: true);
            setState(() {
              _articleList.addAll(articleModel.data.datas);
            });
          });
        } else {
          showEmpty();
        }
      } else {
        showError();
        T.show(msg: articleModel.errorMsg);
      }
    }, (DioError error) {
      showError();
    }, _page);
  }

  ///获取更多文章数据
  Future getMoreSquareList() async {
    _page++;
    apiService.getSquareList((ArticleModel articleModel) {
      if (articleModel.errorCode == Constants.STATUS_SUCCESS) {
        if (articleModel.data.datas.length > 0) {
          _refreshController.loadComplete();
          setState(() {
            _articleList.addAll(articleModel.data.datas);
          });
        } else {
          _refreshController.loadNoData();
        }
      } else {
        _refreshController.loadFailed();
        T.show(msg: articleModel.errorMsg);
      }
    }, (DioError error) {
      _refreshController.loadFailed();
      print(error.response);
    }, _page);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  attachContentWidget(BuildContext context) {
    return Scaffold(
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: MaterialClassicHeader(),
        footer: RefreshFooter(),
        onRefresh: getSquareList,
        onLoading: getMoreSquareList,
        controller: _refreshController,
        child: ListView.builder(
          itemBuilder: itemView,
          physics: AlwaysScrollableScrollPhysics(),
          itemCount: _articleList.length,
          controller: _scrollController,
        ),
      ),
      floatingActionButton: !isShowFAB
          ? null
          : FloatingActionButton(
          heroTag: Text("square"),
          child: Icon(Icons.vertical_align_top),
          onPressed: () {
            //回到顶部时执行的动画
            _scrollController.animateTo(0,
                duration: Duration(milliseconds: 2000), curve: Curves.ease);
          }),
    );
  }

  Widget itemView(context, index) {
    ArticleBean item = _articleList[index];
    return ItemArticleList(item);
  }

  @override
  void onClickErrorWidget() {
    showContent().then((value) {
      getSquareList();
    });
  }
}