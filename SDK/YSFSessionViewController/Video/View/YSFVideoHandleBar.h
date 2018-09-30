//
//  YSFVideoHandleBar.h
//  YSFSessionViewController
//
//  Created by liaosipei on 2018/9/19.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol YSFVideoHandleBarDelegate <NSObject>

- (void)playOrPause:(BOOL)play;

@end

@interface YSFVideoHandleBar : UIView

@property (nonatomic, weak) id<YSFVideoHandleBarDelegate> delegate;

- (void)updateCurTime:(NSTimeInterval)curTime totalTime:(NSTimeInterval)totalTime;
- (void)updatePlayButton:(BOOL)selected;

@end

NS_ASSUME_NONNULL_END
