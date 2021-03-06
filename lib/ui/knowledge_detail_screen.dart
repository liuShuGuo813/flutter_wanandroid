import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wanandroid/common/common.dart';
import 'package:flutter_wanandroid/data/api/apis_service.dart';
import 'package:flutter_wanandroid/data/model/knowledge_detail_model.dart';
import 'package:flutter_wanandroid/data/model/knowledge_tree_model.dart';
import 'package:flutter_wanandroid/utils/refresh_helper.dart';
import 'package:flutter_wanandroid/utils/toast_util.dart';
import 'file:///E:/FlutterProject/flutter_wanandroid/lib/ui/item_knowledge_detail_list.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'base_widget.dart';

class KnowledgeDetailScreen extends StatefulWidget {
  KnowledgeTreeBean _knowledgeTreeBean;
  int index;

  KnowledgeDetailScreen(this._knowledgeTreeBean,{this.index = -1});

  @override
  _KnowledgeDetailScreenState createState() {
    return _KnowledgeDetailScreenState();
  }
}

class _KnowledgeDetailScreenState extends State<KnowledgeDetailScreen> with
    TickerProviderStateMixin{

  KnowledgeTreeBean knowledgeTreeBean;
  int index;
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    knowledgeTreeBean = widget._knowledgeTreeBean;
    index = widget.index;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(index == -1){
      _tabController =
      new TabController(length: knowledgeTreeBean.children.length, vsync: this);
    }else{
      //默认选择某个Item
      _tabController =
      new TabController(length: knowledgeTreeBean.children.length, vsync: this,initialIndex: index);
    }
    return new Scaffold(
      appBar: new AppBar(
        elevation: 0.4,
        title: Text(knowledgeTreeBean.name),
        bottom: new TabBar(
            indicatorColor: Colors.white,
            labelStyle: TextStyle(fontSize: 16),
            unselectedLabelStyle: TextStyle(fontSize: 16),
            controller: _tabController,
            isScrollable: true,
            tabs: knowledgeTreeBean.children.map((KnowledgeTreeChildBean item) {
              return Tab(text: item.name);
            }).toList()),
      ),
      body: TabBarView(
          controller: _tabController,
          children: knowledgeTreeBean.children.map((item) {
            return KnowledgeArticleScreen(item.id);
          }).toList()),
    );
  }
}

class KnowledgeArticleScreen extends BaseWidget {
  final int id;

  KnowledgeArticleScreen(this.id);

  @override
  BaseWidgetState<BaseWidget> attachState() {
    return KnowledgeArticleScreenState();
  }
}

class KnowledgeArticleScreenState
    extends BaseWidgetState<KnowledgeArticleScreen> {
  List<KnowledgeDetailChild> _list = new List();

  ScrollController _scrollController = ScrollController(); //listview的控制器
  int _page = 0;

  /// 是否显示悬浮按钮
  bool _isShowFAB = false;

  RefreshController _refreshController =
  new RefreshController(initialRefresh: false);

  Future getKnowledgeDetailList() async {
    _page = 0;
    int _id = widget.id;
    apiService.getKnowledgeDetailList((KnowledgeDetailModel model) {
      if (model.errorCode == Constants.STATUS_SUCCESS) {
        if (model.data.datas.length > 0) {
          showContent();
          _refreshController.refreshCompleted(resetFooterState: true);
          setState(() {
            _list.clear();
            _list.addAll(model.data.datas);
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
    }, _page, _id);
  }

  Future getMoreKnowledgeDetailList() async {
    _page++;
    int _id = widget.id;
    apiService.getKnowledgeDetailList((KnowledgeDetailModel model) {
      if (model.errorCode == Constants.STATUS_SUCCESS) {
        if (model.data.datas.length > 0) {
          _refreshController.loadComplete();
          setState(() {
            _list.addAll(model.data.datas);
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
    }, _page, _id);
  }

  @override
  void initState() {
    super.initState();
    setAppBarVisible(false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    showLoading().then((value) {
      getKnowledgeDetailList();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // getMoreKnowledgeDetailList();
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


  @override
  Widget attachContentWidget(BuildContext context) {
    return Scaffold(
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: MaterialClassicHeader(),
        footer: RefreshFooter(),
        controller: _refreshController,
        onRefresh: getKnowledgeDetailList,
        onLoading: getMoreKnowledgeDetailList,
        child: ListView.builder(
          itemBuilder: itemView,
          physics: new AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          itemCount: _list.length,
        ),
      ),
      floatingActionButton: !_isShowFAB
          ? null
          : FloatingActionButton(
        heroTag: "knowledge_detail",
        child: Icon(Icons.vertical_align_top),
        onPressed: () {
          /// 回到顶部时要执行的动画
          _scrollController.animateTo(0,
              duration: Duration(milliseconds: 2000), curve: Curves.ease);
        },
      ),
    );
  }

  @override
  void onClickErrorWidget() {
    showLoading().then((value) {
      getKnowledgeDetailList();
    });
  }

  Widget itemView(BuildContext context, int index) {
    KnowledgeDetailChild item = _list[index];
    return ItemKnowledgeDetailList(item: item);
  }
}
