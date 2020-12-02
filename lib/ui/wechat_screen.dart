import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wanandroid/common/common.dart';
import 'package:flutter_wanandroid/data/api/apis_service.dart';
import 'package:flutter_wanandroid/data/model/wx_article_model.dart';
import 'package:flutter_wanandroid/data/model/wx_chapters_model.dart';
import 'package:flutter_wanandroid/ui/base_widget.dart';
import 'package:flutter_wanandroid/ui/item_article_list.dart';
import 'package:flutter_wanandroid/ui/item_weChat_list.dart';
import 'package:flutter_wanandroid/utils/refresh_helper.dart';
import 'package:flutter_wanandroid/utils/toast_util.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

///公众号页面
class WeChatScreen extends BaseWidget {
  @override
  BaseWidgetState<BaseWidget> attachState() {
    return _WeChatScreenState();
  }
}

class _WeChatScreenState extends BaseWidgetState<WeChatScreen>
    with TickerProviderStateMixin {
  List<WXChaptersBean> _chaptersList = List();

  TabController _tabController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    showLoading().then((value) {
      getWxChapterList();
    });
  }

  Future getWxChapterList() async {
    apiService.getWXChaptersList((WXChaptersModel model) {
      if (model.errorCode == Constants.STATUS_SUCCESS) {
        if (model.data.length > 0) {
          showContent();
          setState(() {
            _chaptersList.clear();
            _chaptersList.addAll(model.data);
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
    });
  }

  @override
  attachContentWidget(BuildContext context) {
    _tabController = TabController(length: _chaptersList.length, vsync: this);
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            height: 50,
            color: Theme.of(context).primaryColor,
            child: TabBar(
                indicatorColor: Colors.white,
                controller: _tabController,
                isScrollable: true,
                unselectedLabelStyle: TextStyle(fontSize: 16),
                labelStyle: TextStyle(fontSize: 16),
                tabs: _chaptersList.map((WXChaptersBean item) {
                  return Tab(
                    text: item.name,
                  );
                }).toList()),
          ),
          Expanded(
            child: TabBarView(
                controller: _tabController,
                children: _chaptersList.map((item) {
                  return WxArticleScreen(item.id);
                }).toList()),
          )
        ],
      ),
    );
  }

  @override
  void onClickErrorWidget() {
    showLoading().then((value) {
      getWxChapterList();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class WxArticleScreen extends StatefulWidget {
  final int id;

  WxArticleScreen(this.id);

  @override
  _WxArticleScreenState createState() {
    return _WxArticleScreenState();
  }
}

class _WxArticleScreenState extends State<WxArticleScreen>
    with AutomaticKeepAliveClientMixin {
  ScrollController _scrollController = ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  bool isShowFAB = false;

  int _page = 0;
  List<WXArticleBean> _wxArticleList = List();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    getWxArticleList();

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

  Future getWxArticleList() async {
    _page = 0;
    int _id = widget.id;
    apiService.getWXArticleList((WXArticleModel model){
      if(model.errorCode == Constants.STATUS_SUCCESS){
        if(model.data.datas.length > 0){
          _refreshController.refreshCompleted(resetFooterState: true);
          setState(() {
            _wxArticleList.clear();
            _wxArticleList.addAll(model.data.datas);
          });
        }
      }else{
        T.show(msg: model.errorMsg);
      }
    }, (DioError error){
      print(error.response);
    }, _id, _page);
  }

  Future getMoreWxArticleList() async {
    _page++;
    int _id = widget.id;
    apiService.getWXArticleList((WXArticleModel model){
      if(model.errorCode == Constants.STATUS_SUCCESS){
        if(model.data.datas.length > 0){
          _refreshController.loadComplete();
          setState(() {
            _wxArticleList.addAll(model.data.datas);
          });
        }else{
          _refreshController.loadNoData();
        }
      }else{
        T.show(msg: model.errorMsg);
        _refreshController.loadFailed();
      }
    }, (DioError error){
      print(error.response);
      _refreshController.loadFailed();
    }, _id, _page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SmartRefresher(
        enablePullUp: true,
        enablePullDown: true,
        footer: RefreshFooter(),
        header: MaterialClassicHeader(),
        controller: _refreshController,
        onRefresh: getWxArticleList,
        onLoading: getMoreWxArticleList,
        child: ListView.builder(
          itemBuilder: itemView,
          itemCount: _wxArticleList.length,
          physics: AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
        ),
      ),
      floatingActionButton: !isShowFAB
          ? null
          : FloatingActionButton(
              child: Icon(Icons.vertical_align_top),
              heroTag: Text("wxChat"),
              onPressed: () {
                _scrollController.animateTo(0,
                    duration: Duration(milliseconds: 2000), curve: Curves.ease);
              }),
    );
  }

  Widget itemView(BuildContext context, int index) {
    WXArticleBean item = _wxArticleList[index];
    return ItemWeChatList(item);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }
}
