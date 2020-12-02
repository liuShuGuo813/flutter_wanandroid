import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wanandroid/common/common.dart';
import 'package:flutter_wanandroid/data/api/apis_service.dart';
import 'package:flutter_wanandroid/data/model/collection_model.dart';
import 'package:flutter_wanandroid/ui/base_widget.dart';
import 'package:flutter_wanandroid/utils/refresh_helper.dart';
import 'package:flutter_wanandroid/utils/toast_util.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'item_collect_list.dart';

///收藏页面
class CollectScreen extends BaseWidget {
  @override
  BaseWidgetState<BaseWidget> attachState() {
    return _CollectScreenState();
  }
}

class _CollectScreenState extends BaseWidgetState<CollectScreen> {

  ScrollController _scrollController = ScrollController();

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  int _page = 0;

  bool _isShowFAB = false;

  List<CollectionBean> _collectList = List();

  @override
  void initState() {
    super.initState();
    setAppBarVisible(true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    showLoading().then((value) {
      getCollectionList();
    });

    _scrollController.addListener(() {
      /// 滑动到底部，加载更多
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // getMoreCollectionList();
      }
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

  /// 获取收藏文章列表
  Future<Null> getCollectionList() async {
    _page = 0;
    apiService.getCollectionList((CollectionModel model) {
      if (model.errorCode == Constants.STATUS_SUCCESS) {
        if (model.data.datas.length > 0) {
          showContent();
          _refreshController.refreshCompleted(resetFooterState: true);
          setState(() {
            _collectList.clear();
            _collectList.addAll(model.data.datas);
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

  /// 获取更多文章列表
  Future<Null> getMoreCollectionList() async {
    _page++;
    apiService.getCollectionList((CollectionModel model) {
      if (model.errorCode == Constants.STATUS_SUCCESS) {
        if (model.data.datas.length > 0) {
          _refreshController.loadComplete();
          setState(() {
            _collectList.addAll(model.data.datas);
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

  @override
  AppBar attachAppBar() {
    return AppBar(
      elevation: 0.4,
      title: Text("收藏"),
    );
  }

  @override
  Widget attachContentWidget(BuildContext context) {
    return Scaffold(
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: MaterialClassicHeader(),
        footer: RefreshFooter(),
        controller: _refreshController,
        onRefresh: getCollectionList,
        onLoading: getMoreCollectionList,
        child: ListView.builder(
          itemBuilder: itemView,
          physics: new AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          itemCount: _collectList.length,
        ),
      ),
      floatingActionButton: !_isShowFAB
          ? null
          : FloatingActionButton(
        heroTag: "collect",
        child: Icon(Icons.vertical_align_top),
        onPressed: () {
          /// 回到顶部时要执行的动画
          _scrollController.animateTo(0,
              duration: Duration(milliseconds: 2000), curve: Curves.ease);
        },
      ),
    );
  }

  Widget itemView(BuildContext context, int index) {
    CollectionBean item = _collectList[index];
    return ItemCollectList(
      item: item,
      onCollectCallback: (isCollect) {
        if (isCollect) {
          setState(() {
            _collectList.removeAt(index);
          });
        }
      },
    );
  }

  @override
  void onClickErrorWidget() {
    showLoading().then((value) {
      getCollectionList();
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
