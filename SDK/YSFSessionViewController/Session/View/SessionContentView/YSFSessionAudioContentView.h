//
//  NIMSessionAudioCententView.h
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "YSFSessionMessageContentView.h"

@protocol YSFPlayAudioUIDelegate <NSObject>
-(void)startPlayingAudioUI;  //点击一开始就要显示
@optional
- (void)retryDownloadMsg; //重收消息
@end

@interface YSFSessionAudioContentView : YSFSessionMessageContentView

@property (nonatomic, strong) UILabel     *audioDurationLable; //语音时长

@property (nonatomic, weak) id<YSFPlayAudioUIDelegate> audioUIDelegate;

@end
