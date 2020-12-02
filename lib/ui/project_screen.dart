import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wanandroid/common/common.dart';
import 'package:flutter_wanandroid/data/api/apis_service.dart';
import 'package:flutter_wanandroid/data/model/project_article_model.dart';
import 'package:flutter_wanandroid/data/model/project_tree_model.dart';
import 'package:flutter_wanandroid/ui/base_widget.dart';
import 'package:flutter_wanandroid/ui/item_article_list.dart';
import 'package:flutter_wanandroid/ui/item_project.dart';
import 'package:flutter_wanandroid/utils/refresh_helper.dart';
import 'package:flutter_wanandroid/utils/toast_util.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

///项目页面
class ProjectScreen extends BaseWidget {
  @override
  BaseWidgetState<BaseWidget> attachState() {
    return _ProjectScreenState();
  }
}

class _ProjectScreenState extends BaseWidgetState<ProjectScreen>
    with TickerProviderStateMixin {
  List<ProjectTreeBean> _projectTreeList = List();
  TabController _tabController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    showLoading().then((value) {
      getProjectTreeList();
    });
  }

  void getProjectTreeList() {
    apiService.getProjectTreeList((ProjectTreeModel model) {
      if (model.errorCode == Constants.STATUS_SUCCESS) {
        if (model.data != null && model.data.length > 0) {
          showContent();
          setState(() {
            _projectTreeList.clear();
            _projectTreeList.addAll(model.data);
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
      print(error.response);
    });
  }

  @override
  attachContentWidget(BuildContext context) {
    _tabController =
        new TabController(length: _projectTreeList.length, vsync: this);
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            color: Theme.of(context).primaryColor,
            height: 50,
            child: TabBar(
                indicatorColor: Colors.white,
                labelStyle: TextStyle(fontSize: 16),
                unselectedLabelStyle: TextStyle(fontSize: 16),
                isScrollable: true,
                controller: _tabController,
                tabs: _projectTreeList.map((item) {
                  return Tab(
                    text: item.name,
                  );
                }).toList()),
          ),
          Expanded(
            child: TabBarView(
                controller: _tabController,
                children: _projectTreeList.map((item) {
                  return ProjectArticleScreen(item.id);
                }).toList()),
          )
        ],
      ),
    );
  }

  @override
  void onClickErrorWidget() {
    showLoading().then((value) {
      getProjectTreeList();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class ProjectArticleScreen extends StatefulWidget {
  final int id;

  ProjectArticleScreen(this.id);

  @override
  _ProjectArticleScreenState createState() {
    return _ProjectArticleScreenState();
  }
}

class _ProjectArticleScreenState extends State<ProjectArticleScreen>
    with AutomaticKeepAliveClientMixin {
  RefreshController _refreshController =
      new RefreshController(initialRefresh: true);
  ScrollController _scrollController;
  int _page = 1;

  bool isShowFAB = false;

  List<ProjectArticleBean> _projectArticleList = List();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getProjectArticleList();
    _scrollController = new ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset < 200 && isShowFAB) {
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

  getProjectArticleList() async {
    _page = 1;
    apiService.getProjectArticleList((ProjectArticleListModel model) {
      if (model.errorCode == Constants.STATUS_SUCCESS) {
        _refreshController.refreshCompleted(resetFooterState: true);
        setState(() {
          _projectArticleList.clear();
          _projectArticleList.addAll(model.data.datas);
        });
      } else {
        T.show(msg: model.errorMsg);
      }
    }, (DioError error) {
      print(error.response);
    }, widget.id, _page);
  }

  getMoreProjectArticleList() async {
    _page++;
    apiService.getProjectArticleList((ProjectArticleListModel model) {
      if (model.errorCode == Constants.STATUS_SUCCESS) {
        if (model.data.datas.length > 0) {
          _refreshController.loadComplete();
          setState(() {
            _projectArticleList.addAll(model.data.datas);
          });
        } else {
          _refreshController.loadNoData();
        }
      } else {
        _refreshController.loadFailed();
      }
    }, (DioError error) {
      _refreshController.loadFailed();
    }, widget.id, _page);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SmartRefresher(
        controller: _refreshController,
        scrollController: _scrollController,
        onRefresh: getProjectArticleList,
        onLoading: getMoreProjectArticleList,
        enablePullDown: true,
        enablePullUp: true,
        footer: RefreshFooter(),
        header: MaterialClassicHeader(),
        child: ListView.builder(
          itemBuilder: itemView,
          itemCount: _projectArticleList.length,
          physics: AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
        ),
      ),
      floatingActionButton: isShowFAB ? FloatingActionButton(
        heroTag: Text("project"),
        child: Icon(Icons.vertical_align_top),
          onPressed: (){
            _scrollController.animateTo(0, duration: Duration(milliseconds: 2000), curve: Curves.ease);
          }
      ) : null,
    );
  }

  Widget itemView(BuildContext context, int index) {
    return ItemProject(_projectArticleList[index]);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
