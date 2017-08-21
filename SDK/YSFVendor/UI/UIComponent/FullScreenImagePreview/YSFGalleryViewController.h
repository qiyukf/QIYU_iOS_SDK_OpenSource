//
//  YSFGalleryViewController.h
//  NIMDemo
//
//  Created by ght on 15-2-3.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YSFPresentViewController.h"

@class YSFGalleryItem;
typedef UIView * (^QueryMessageContentViewCallback)(YSFGalleryItem *item);


@interface YSFGalleryItem : NSObject

@property (nonatomic,copy)  NSString    *thumbPath;
@property (nonatomic,copy)  NSString    *imageURL;
@property (nonatomic,copy)  NSString    *name;
@property (nonatomic,weak)  id  message;
@property (nonatomic,assign)  NSUInteger  indexAtMesaage;

@end


@interface YSFGalleryViewController : YSFPresentViewController

- (instancetype)initWithCurrentIndex:(NSUInteger)currentIndex allItems:(NSMutableArray *) allItems callback:(QueryMessageContentViewCallback) cb;

@end




