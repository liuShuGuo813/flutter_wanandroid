import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_wanandroid/utils/route_util.dart';
import 'package:flutter_wanandroid/utils/utils.dart';
import 'package:flutter_wanandroid/widgets/MarqeeWidget.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:share/share.dart';

class WebViewScreen extends StatefulWidget {
  String title;
  String url;

  WebViewScreen({@required this.title, @required this.url});

  @override
  _WebViewScreenState createState() {
    return _WebViewScreenState();
  }
}

class _WebViewScreenState extends State<WebViewScreen> {
  bool isLoad = false;

  final flutterWebViewPlugin = FlutterWebviewPlugin();

  @override
  void initState() {
    super.initState();
    flutterWebViewPlugin.onStateChanged.listen((event) {
      if (event.type == WebViewState.finishLoad) {
        setState(() {
          isLoad = false;
        });
      } else if (event.type == WebViewState.startLoad) {
        setState(() {
          isLoad = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      url: widget.url,
      appBar: AppBar(
        title: MarqueeWidget(child: Text(widget.title)),
        elevation: 0.4,
        bottom: PreferredSize(
            child: SizedBox(
              height: 2,
              child: isLoad ? LinearProgressIndicator() : Container(),
            ),
            preferredSize: Size.fromHeight(2)),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.language),
              onPressed: () {
                RouteUtil.launchInBrowser(widget.url, title: widget.title);
              }),
          IconButton(
              icon: Icon(Icons.share),
              onPressed: () {
                Share.share('${widget.title} : ${widget.url}');
              })
        ],
      ),
      withJavascript: true,
      withLocalStorage: true,
      withZoom: false,
      hidden: true,
    );
  }

  @override
  void dispose() {
    super.dispose();
    flutterWebViewPlugin.dispose();
  }
}
