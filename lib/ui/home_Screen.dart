import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_wanandroid/common/common.dart';
import 'package:flutter_wanandroid/data/api/apis_service.dart';
import 'package:flutter_wanandroid/data/model/article_model.dart';
import 'package:flutter_wanandroid/data/model/banner_model.dart';
import 'package:flutter_wanandroid/ui/base_widget.dart';
import 'package:flutter_wanandroid/utils/refresh_helper.dart';
import 'package:flutter_wanandroid/utils/route_util.dart';
import 'package:flutter_wanandroid/utils/toast_util.dart';
import 'package:flutter_wanandroid/widgets/custom_cached_image.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'item_article_list.dart';

///首页页面
class HomeScreen extends BaseWidget {
  @override
  BaseWidgetState<BaseWidget> attachState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends BaseWidgetState<HomeScreen> {
  ///首页轮播图数据
  List<BannerBean> _bannerList = List();

  ///首页文章数据
  List<ArticleBean> _articleList = List();

  ///是否显示悬浮按钮
  bool isShowFAB = false;

  ///页码
  int _page = 0;

  ///ListView控制器
  ScrollController _scrollController = ScrollController();

  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bannerList.add(null);

    showLoading().then((value) {
      getBannerList();
      getTopArticleList();
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

  ///获取轮播图数据
  Future getBannerList() async {
    apiService.getBannerList((BannerModel bannerModel) {
      if (bannerModel.data.length > 0) {
        setState(() {
          _bannerList = bannerModel.data;
        });
      }
    });
  }

  ///获取置顶文章数据
  Future getTopArticleList() async {
    apiService.getTopArticleList((TopArticleModel topArticleModel) {
      if (topArticleModel.errorCode == Constants.STATUS_SUCCESS) {
        topArticleModel.data.forEach((data) {
          data.top = 1;
        });
        _articleList.clear();
        _articleList.addAll(topArticleModel.data);
      }
      getArticleList();
    }, (DioError error) {
      showError();
    });
  }

  ///获取文章数据
  Future getArticleList() async {
    _page = 0;
    apiService.getArticleList((ArticleModel articleModel) {
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
  Future getMoreArticleList() async {
    _page++;
    apiService.getArticleList((ArticleModel articleModel) {
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
  attachContentWidget(BuildContext context) {
    return Scaffold(
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: MaterialClassicHeader(),
        footer: RefreshFooter(),
        onRefresh: getTopArticleList,
        onLoading: getMoreArticleList,
        controller: _refreshController,
        child: ListView.builder(
          itemBuilder: itemView,
          physics: AlwaysScrollableScrollPhysics(),
          itemCount: _articleList.length + 1,
          controller: _scrollController,
        ),
      ),
      floatingActionButton: !isShowFAB
          ? null
          : FloatingActionButton(
              heroTag: Text("home"),
              child: Icon(Icons.vertical_align_top),
              onPressed: () {
                //回到顶部时执行的动画
                _scrollController.animateTo(0,
                    duration: Duration(milliseconds: 2000), curve: Curves.ease);
              }),
    );
  }

  Widget itemView(context, index) {
    if (index == 0) {
      return Container(
        height: 200,
        color: Colors.transparent,
        child: _bannerBuildWidget(),
      );
    }
    ArticleBean item = _articleList[index - 1];
    return ItemArticleList(item);
  }

  Widget _bannerBuildWidget() {
    return Offstage(
      offstage: _bannerList.length == 0,
      child: Swiper(
        itemBuilder: (BuildContext context, int index) {
          if (index > _bannerList.length ||
              _bannerList[index] == null ||
              _bannerList[index].imagePath == null) {
            return Container(
              height: 0,
            );
          } else {
            return InkWell(
              child: Container(
                child: CustomCachedImage(imageUrl: _bannerList[index].imagePath),
              ),
              onTap: () {
                var url = _bannerList[index].url;
                var title = _bannerList[index].title;
                RouteUtil.toWebView(context, url, title);
              },
            );
          }
        },
        itemCount: _bannerList.length,
        autoplay: true,
      ),
    );
  }

  @override
  void onClickErrorWidget() {
    showContent().then((value) {
      getBannerList();
      getTopArticleList();
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
