import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wanandroid/common/common.dart';
import 'package:flutter_wanandroid/data/api/apis_service.dart';
import 'package:flutter_wanandroid/data/model/knowledge_detail_model.dart';
import 'package:flutter_wanandroid/data/model/knowledge_tree_model.dart';
import 'package:flutter_wanandroid/ui/base_widget.dart';
import 'package:flutter_wanandroid/utils/refresh_helper.dart';
import 'file:///E:/FlutterProject/flutter_wanandroid/lib/ui/item_knowledge_tree.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

///子体系页面
class KnowLedgeScreen extends BaseWidget {

  @override
  BaseWidgetState<BaseWidget> attachState() {
    return _KnowLedgeScreenState();
  }
}

class _KnowLedgeScreenState extends BaseWidgetState<KnowLedgeScreen> {

  ScrollController _scrollController = ScrollController();
  RefreshController _refreshController =
  RefreshController(initialRefresh: false);
  bool _isShowFAB = false;
  List<KnowledgeTreeBean> _knowledgeTreeList = List();

  @override
  void initState() {
    super.initState();
  }

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
    apiService.getKnowledgeTreeList((KnowledgeTreeModel knowledgeTreeModel) {
      if (knowledgeTreeModel.errorCode == Constants.STATUS_SUCCESS) {
        if (knowledgeTreeModel.data.length > 0) {
          showContent().then((value) {
            _refreshController.refreshCompleted();
            setState(() {
              _knowledgeTreeList.clear();
              _knowledgeTreeList.addAll(knowledgeTreeModel.data);
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
          itemCount: _knowledgeTreeList.length,
        ),
      ),
      floatingActionButton: !_isShowFAB
          ? null
          : FloatingActionButton(
        heroTag: "knowledge",
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
    return ItemKnowledgeTree(_knowledgeTreeList[index]);
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
    super.dispose();
  }
}