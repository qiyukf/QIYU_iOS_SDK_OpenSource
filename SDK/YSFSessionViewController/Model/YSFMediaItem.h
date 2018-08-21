//
//  NIMMediaItem.h
//  YSFKit
//
//  Created by amao on 8/11/15.
//  Copyright (c) 2015 NetEase. All rights reserved.
//


@interface YSFMediaItem : NSObject
@property (nonatomic,assign)    NSInteger tag;

@property (nonatomic,strong)    UIImage *normalImage;

@property (nonatomic,strong)    UIImage *selectedImage;

@property (nonatomic,copy)      NSString *title;

+ (YSFMediaItem *)item:(NSInteger)tag
           normalImage:(UIImage *)normal
         selectedImage:(UIImage *)selectedImage
                 title:(NSString *)title;
@end
