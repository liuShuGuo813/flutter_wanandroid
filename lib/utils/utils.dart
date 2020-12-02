class Utils{
  //获取Assets目录下的资源图片
  static String getImgPath(String name,{String format = 'png'}){
      return 'assets/images/$name.$format';
  }
}