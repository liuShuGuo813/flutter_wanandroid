import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_wanandroid/common/common.dart';
import 'package:flutter_wanandroid/data/api/apis_service.dart';
import 'package:flutter_wanandroid/data/model/user_score_model.dart';
import 'package:flutter_wanandroid/ui/base_widget.dart';
import 'package:flutter_wanandroid/ui/item_user_score.dart';
import 'package:flutter_wanandroid/utils/refresh_helper.dart';
import 'package:flutter_wanandroid/utils/route_util.dart';
import 'package:flutter_wanandroid/utils/toast_util.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

///积分页面
class ScoreScreen extends BaseWidget {
  String _myScore = '--';

  ScoreScreen(this._myScore);

  @override
  BaseWidgetState<BaseWidget> attachState() {
    return _ScoreScreenState();
  }
}

class _ScoreScreenState extends BaseWidgetState<ScoreScreen>
    with SingleTickerProviderStateMixin {
  ///积分
  Animation animation;
  AnimationController animationController;
  int mScore;

  ScrollController _scrollController = ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  int _page = 1;
  bool isShowFAB = false;
  List<UserScoreBean> _userScoreList = List();

  getUserScoreList() async{
    _page = 1;
    apiService.getUserScoreList((UserScoreModel model){
      if(model.errorCode == Constants.STATUS_SUCCESS){
        if(model.data.datas != null && model.data.datas.length > 0){
          showContent();
          _refreshController.refreshCompleted(resetFooterState: true);
          setState(() {
            _userScoreList.clear();
            _userScoreList.addAll(model.data.datas);
          });
        }else{
          showEmpty();
        }
      }else{
        showError();
        T.show(msg: model.errorMsg);
      }
    }, (DioError error){
      showError();
    }, _page);
  }

  getMoreUserScoreList() async{
    _page++;
    apiService.getUserScoreList((UserScoreModel model){
      if(model.errorCode == Constants.STATUS_SUCCESS){
        if(model.data.datas != null && model.data.datas.length > 0){
          _refreshController.loadComplete();
          setState(() {
            _userScoreList.addAll(model.data.datas);
          });
        }else{
          _refreshController.loadNoData();
        }
      }else{
        _refreshController.loadFailed();
        T.show(msg: model.errorMsg);
      }
    }, (DioError error){
      _refreshController.loadFailed();
    }, _page);
  }

  @override
  void initState() {
    super.initState();
    mScore = widget._myScore.isEmpty ? 0 : int.parse(widget._myScore);
    animationController = new AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    final Animation curve =
        CurvedAnimation(parent: animationController, curve: Curves.linear);
    animation = IntTween(begin: 0, end: mScore).animate(curve);
    setAppBarVisible(true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initScrollController();
    showLoading().then((value){
      getUserScoreList();
    });
  }

  void initScrollController(){
    _scrollController.addListener(() {
      if(_scrollController.offset > 200 && !isShowFAB){
        setState(() {
          isShowFAB = true;
        });
      }else if(_scrollController.offset < 200 && isShowFAB){
        setState(() {
          isShowFAB = false;
        });
      }
    });
  }



  @override
  attachContentWidget(BuildContext context) {
    animationController.forward();
    return Scaffold(
      body: SmartRefresher(
        controller: _refreshController,
        enablePullUp: true,
        enablePullDown: true,
        onRefresh: (){
          getUserScoreList();
          animationController.reverse();
        },
        onLoading: getMoreUserScoreList,
        header: MaterialClassicHeader(),
        footer: RefreshFooter(),
        child: ListView.builder(
          itemBuilder: itemView,
          itemCount: _userScoreList.length + 1,
          physics: AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
        ),
      ),
      floatingActionButton: isShowFAB ? FloatingActionButton(
        child: Icon(Icons.vertical_align_top),
          heroTag: Text("score"),
          onPressed: (){
            _scrollController.animateTo(0, duration: Duration(milliseconds: 2000), curve: Curves.ease);
          }
      ) : null,
    );
  }

  Widget itemView(BuildContext context,int index){
    if(index == 0){
      return AnimatedBuilder(
          animation: animationController,
          builder: (context, child) {
            return Container(
              height: 150,
              alignment: Alignment.center,
              color: Theme.of(context).primaryColor,
              child: Text(
                animation.value.toString(),
                style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            );
          });
    }
    return ItemUserScore(_userScoreList[index - 1]);
  }

  @override
  AppBar attachAppBar() {
    return AppBar(
      title: Text("我的积分"),
      actions: <Widget>[
        IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              var title = "本站积分规则";
              var url = "https://www.wanandroid.com/blog/show/2653";
              RouteUtil.toWebView(context, url, title);
            })
      ],
    );
  }

  @override
  void onClickErrorWidget() {
    showLoading().then((value){
      getUserScoreList();
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
