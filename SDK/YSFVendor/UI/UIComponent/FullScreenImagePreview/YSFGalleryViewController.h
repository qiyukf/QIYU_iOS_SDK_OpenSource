//
//  YSFGalleryViewController.h
//  NIMDemo
//
//  Created by ght on 15-2-3.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YSFPresentViewController.h"


/**
 *  YSFGalleryItem: 图片对象
 */
@interface YSFGalleryItem : NSObject

@property (nonatomic, weak) id message;
@property (nonatomic, assign) NSUInteger indexAtMesaage;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *path;         //图片path
@property (nonatomic, copy) NSString *thumbPath;    //缩略图path
@property (nonatomic, copy) NSString *imageURL;     //远程下载url
@property (nonatomic, assign) BOOL isOriginal;      //是否已加载原图

@end


/**
 *  回调：取消息流中消息contentView
 */
typedef UIView * (^messageContentViewCallback)(YSFGalleryItem *item);


/**
 *  YSFGalleryViewController: 图片浏览VC
 */
@interface YSFGalleryViewController : YSFPresentViewController

- (instancetype)initWithGalleryItems:(NSArray *)galleryItems
                        currentIndex:(NSUInteger)currentIndex
                            callback:(messageContentViewCallback)msgViewCallback;

@end




