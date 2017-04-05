//
//  YXNOSResizer.h
//  NIM
//
//  Created by amao on 11/19/14.
//  Copyright (c) 2014 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
图片缩略参数的格式为：Widthx|y|zHeight，其中Width和Height分别表示图片的宽和高，而x,y,z表示缩略类型，分别为：

x：内缩略 : 原图等比例缩略，缩略后的图片“一边等于请求长度，另一边小于等于请求长度”
y：裁剪缩略: 原图等比例缩略， 缩略后的图片“一边等于请求长度， 另一边大于等于请求长度”
z：外缩略:当图等比例缩略，缩略后的图片“一边等于请求长度，另一边大于等于请求长度”

 详细参考: http://gitlab.hz.netease.com/nos/user-manual/raw/master/_build/html/imageOperations.html

 
*/

//传入宽高后,自动会乘以retina scale并返回
//如传入 NIMNOSX(100,100) 在3gs上返回 100x100  6p上返回300x300 而其他机器返回 200x200

#define NIMNOSX(w,h) [[YSF_NIMNOSResizer sharedResizer] resize:@"x" width:(w) height:(h)]
#define NIMNOSY(w,h) [[YSF_NIMNOSResizer sharedResizer] resize:@"y" width:(w) height:(h)]
#define NIMNOSZ(w,h) [[YSF_NIMNOSResizer sharedResizer] resize:@"z" width:(w) height:(h)]

@interface YSF_NIMNOSResizer : NSObject
+ (instancetype)sharedResizer;

- (CGSize)resizeWidth:(CGFloat)width
               height:(CGFloat)height;

- (NSString *)resize:(NSString *)mode
               width:(CGFloat)width
              height:(CGFloat)height;

- (NSString *)imageThumbParam;
- (NSString *)videoThumbParam;



@end
