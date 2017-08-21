//
//  NIMMessageCell.h
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "YSFMessageCellProtocol.h"
#import "YSFTimestampModel.h"

@class YSFSessionMessageContentView;
@class YSFAvatarImageView;
@class YSFBadgeView;

@interface YSFMessageCell : UITableViewCell

@property (nonatomic, strong) YSFAvatarImageView *headImageView;
@property (nonatomic, strong) UIImageView *vipLevel;
@property (nonatomic, strong) UILabel *nameLabel;                                 //姓名（群显示 个人不显示）
@property (nonatomic, strong) YSFSessionMessageContentView *bubbleView;           //内容区域
@property (nonatomic, strong) UIActivityIndicatorView *traningActivityIndicator;  //发送loading
@property (nonatomic, strong) UIButton *retryButton;                              //重试
@property (nonatomic, strong) YSFBadgeView *audioPlayedIcon;                      //语音未读红点
@property (nonatomic,strong) YSFMessageModel *model;
@property (nonatomic, weak)   id<YSFMessageCellDelegate> messageDelegate;
@property (nonatomic, strong) UILabel *trashWordsTip;
@property (nonatomic, strong) UIButton *submitForm;

- (void)refreshData:(YSFMessageModel *)data;

@end
