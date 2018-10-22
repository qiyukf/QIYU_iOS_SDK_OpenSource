//
//  YSFCameraViewController.h
//  YSFSessionViewController
//
//  Created by liaosipei on 2018/9/12.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YSFCameraViewControllerDelegate <NSObject>

- (void)sendVideoMessage:(NSURL *)url;

@end

@interface YSFCameraViewController : UIViewController

@property (nonatomic, weak) id<YSFCameraViewControllerDelegate> delegate;
@property (nonatomic, copy) NSString *videoDataPath;

@end
