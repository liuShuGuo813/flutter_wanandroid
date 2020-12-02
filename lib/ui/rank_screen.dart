import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wanandroid/common/common.dart';
import 'package:flutter_wanandroid/data/api/apis_service.dart';
import 'package:flutter_wanandroid/data/model/rank_model.dart';
import 'package:flutter_wanandroid/data/model/user_score_model.dart';
import 'package:flutter_wanandroid/res/styles.dart';
import 'package:flutter_wanandroid/ui/base_widget.dart';
import 'package:flutter_wanandroid/utils/refresh_helper.dart';
import 'package:flutter_wanandroid/utils/toast_util.dart';
import 'package:flutter_wanandroid/utils/utils.dart';
import 'package:flutter_wanandroid/widgets/rank_progress.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

///积分排行榜页面
class RankScreen extends BaseWidget {
  @override
  BaseWidgetState<BaseWidget> attachState() {
    return _RankScreenState();
  }
}

class _RankScreenState extends BaseWidgetState<RankScreen>
    with SingleTickerProviderStateMixin {
  ScrollController _scrollController = ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  int _page = 1;
  bool isShowFAB = false;
  List<RankBean> _rankList = List();

  getRankList() async {
    _page = 1;
    apiService.getRankList((RankModel model) {
      if (model.errorCode == Constants.STATUS_SUCCESS) {
        if (model.data.datas != null && model.data.datas.length > 0) {
          showContent();
          _refreshController.refreshCompleted(resetFooterState: true);
          setState(() {
            _rankList.clear();
            _rankList.addAll(model.data.datas);
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

  getMoreRankList() async {
    _page++;
    apiService.getRankList((RankModel model) {
      if (model.errorCode == Constants.STATUS_SUCCESS) {
        if (model.data.datas != null && model.data.datas.length > 0) {
          _refreshController.loadComplete();
          setState(() {
            _rankList.addAll(model.data.datas);
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
  void initState() {
    super.initState();
    setAppBarVisible(true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initScrollController();
    showLoading().then((value) {
      getRankList();
    });
  }

  void initScrollController() {
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

  @override
  attachContentWidget(BuildContext context) {
    return Scaffold(
      body: SmartRefresher(
        controller: _refreshController,
        enablePullUp: true,
        enablePullDown: true,
        onRefresh: () {
          getRankList();
        },
        onLoading: getMoreRankList,
        header: MaterialClassicHeader(),
        footer: RefreshFooter(),
        child: ListView.builder(
          itemBuilder: itemView,
          itemCount: _rankList.length,
          physics: AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
        ),
      ),
      floatingActionButton: isShowFAB
          ? FloatingActionButton(
              child: Icon(Icons.vertical_align_top),
              heroTag: Text("score"),
              onPressed: () {
                _scrollController.animateTo(0,
                    duration: Duration(milliseconds: 2000), curve: Curves.ease);
              })
          : null,
    );
  }

  Widget itemView(BuildContext context, int index) {
    var item = _rankList[index];
    int scale = 1000;
    int max = _rankList[0].coinCount;
    return Stack(
      children: <Widget>[
        Column(

          children: <Widget>[
            RankProgress(end: item.coinCount / max,),
//            Divider(
//              height: 1,
//            ),
          ],
        ),
        Container(
          padding: EdgeInsets.all(16),
          height: 50,
          child: Row(
            children: <Widget>[
              Offstage(
                offstage: index != 0,
                child: Container(
                  width: 30,
                  height: double.infinity,
                  child: Image.asset(
                    Utils.getImgPath("ic_rank_1"),
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
              Offstage(
                offstage: index != 1,
                child: Container(
                  width: 30,
                  height: double.infinity,
                  child: Image.asset(
                    Utils.getImgPath("ic_rank_2"),
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
              Offstage(
                offstage: index != 2,
                child: Container(
                  width: 30,
                  height: double.infinity,
                  child: Image.asset(
                    Utils.getImgPath("ic_rank_3"),
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
              Offstage(
                offstage: index < 3,
                child: Container(
                  width: 30,
                  height: double.infinity,
                  child: Text(
                    (index + 1).toString(),
                    style: TextStyle(fontSize: 14.0),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Expanded(
                  child: Container(
                    padding: EdgeInsets.only(left: 10,right: 10),
                    child: Text(
                      item.username,
                      style: TextStyle(fontSize: 14.0),
                    ),
                  )
              ),
              Container(
                alignment: Alignment.centerRight,
                  child: Text(
                    item.coinCount.toString(),
                    style: TextStyle(fontSize: 14.0,color: Color.fromARGB(255, 66, 130, 244)),
                  )
              )
            ],
          ),
        )
      ],
    );
  }

  @override
  AppBar attachAppBar() {
    return AppBar(
      title: Text("积分排行榜"),
    );
  }

  @override
  void onClickErrorWidget() {
    showLoading().then((value) {
      getRankList();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
