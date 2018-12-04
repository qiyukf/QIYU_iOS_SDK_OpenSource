//
//  NIMMessageCell.h
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "YSFMessageCellProtocol.h"
#import "YSFTimestampModel.h"

static CGFloat kHeadImageSize = 40.0f;
static CGFloat kHeadHorizontalMargin = 8.0f;
static CGFloat kHeadVerticalMargin = 3.0f;


@class YSFAvatarImageView;
@class YSFBadgeView;
@class YSFSessionMessageContentView;
@protocol YSFExtraViewParamConfig;

@interface YSFMessageCell : UITableViewCell

@property (nonatomic, strong) YSFAvatarImageView *headImageView;    //头像
@property (nonatomic, strong) UIImageView *vipLevel;                //VIP等级
@property (nonatomic, strong) YSFSessionMessageContentView *bubbleView;     //内容区域
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;    //发送loading
@property (nonatomic, strong) YSFBadgeView *audioPlayedIcon;    //语音未读红点
@property (nonatomic, strong) UILabel *nameLabel;       //姓名（仅群聊显示，个人不显示）
@property (nonatomic, strong) UILabel *trashWordsTip;   //违禁词提示
@property (nonatomic, strong) UIButton *retryButton;    //重试按钮
@property (nonatomic, strong) UIButton *submitForm;     //表单提交按钮

@property (nonatomic, strong) UIView<YSFExtraViewParamConfig> *extraView;   //扩展视图

@property (nonatomic,strong) YSFMessageModel *model;
@property (nonatomic, weak) id<YSFMessageCellDelegate> messageDelegate;

- (void)refreshData:(YSFMessageModel *)data;

@end
