MutableUploadDemo
=================

模拟需求：图文混编，要求用户选择图片后就上传，可选择多图，并行上传，用户确定提交后后台执行，必须全部图片上传完才能提交文字
hans友情提示
-------
###   1.上传图片
      - (void)postImage:(UIImage *)image imageName:(NSString *)name;
###   2.发送文本
      - (void)postTexts:(NSArray *)texts success:(Success)success fail:(Error)fail;
