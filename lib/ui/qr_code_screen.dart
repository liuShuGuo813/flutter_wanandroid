import 'package:flutter/material.dart';

///二维码页面
class QrCodeScreen extends StatefulWidget {
  QrCodeScreen({Key key}) : super(key: key);

  @override
  _QrCodeScreenState createState() {
    return _QrCodeScreenState();
  }
}

class _QrCodeScreenState extends State<QrCodeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("QrCode"),
      ),
    );
  }
}