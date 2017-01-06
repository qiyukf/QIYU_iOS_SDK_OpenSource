//
//  YSFGalleryViewController.h
//  NIMDemo
//
//  Created by panqinke on 15-10-25.
//  Copyright (c) 2015年 Netease. All rights reserved.
//


typedef void (^SendingImageConfirmedCallback)(BOOL shouldSend);

@interface YSFImageConfirmedViewController : UIViewController

@property (nonatomic, copy) SendingImageConfirmedCallback sendingImageConfirmedCallback;

- (instancetype)initWithImage:(UIImage *)image;

@end




