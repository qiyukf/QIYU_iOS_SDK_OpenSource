//
//  YSFMixReplyContentView.m
//  YSFSessionViewController
//
//  Created by liaosipei on 2018/8/24.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import "YSFMixReplyContentView.h"
#import "YSFMessageModel.h"
#import "YSFMixReply.h"
#import "UIControl+BlocksKit.h"

@interface YSFMixReplyContentView()

@property (nonatomic, strong) UIView *contentView;

@end

@implementation YSFMixReplyContentView

- (instancetype)initSessionMessageContentView {
    self = [super initSessionMessageContentView];
    if (self) {
        _contentView = [[UIView alloc] init];
        [self addSubview:_contentView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (![YSF_NIMSDK sharedSDK].sdkOrKf) {
        _contentView.ysf_frameLeft = -5;
    }
    _contentView.ysf_frameWidth = self.ysf_frameWidth;
    _contentView.ysf_frameHeight = self.ysf_frameHeight;
}

- (void)refresh:(YSFMessageModel *)data {
    [super refresh:data];
    YSF_NIMCustomObject *object = data.message.messageObject;
    YSFMixReply *mixReply = (YSFMixReply *)object.attachment;
    
    [_contentView ysf_removeAllSubviews];
    
    __block CGFloat offsetY = self.model.contentViewInsets.top;
    offsetY += 13;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:16.0f];
    label.text = mixReply.label;
    label.frame = CGRectMake(18, offsetY, self.ysf_frameWidth - 28, 0);
    [label sizeToFit];
    [_contentView addSubview:label];
    
    offsetY += label.ysf_frameHeight;
    offsetY += 13;
    
    CGFloat lineDegree = 1. / [UIScreen mainScreen].scale;
    UIView *splitLine = [[UIView alloc] init];
    splitLine.backgroundColor = YSFRGB(0xdbdbdb);
    splitLine.frame = CGRectMake(5, offsetY, self.ysf_frameWidth - 5, lineDegree);
    [_contentView addSubview:splitLine];
    
    __weak typeof(self) weakSelf = self;
    [mixReply.actionList enumerateObjectsUsingBlock:^(YSFAction *action, NSUInteger idx, BOOL * _Nonnull stop) {
        offsetY += 15;
        if (idx > 0) {
            offsetY += 34;
        }
        UIButton *button = [[UIButton alloc] init];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        button.layer.borderWidth = lineDegree;
        button.layer.borderColor = YSFRGB(0x5092E1).CGColor;
        button.layer.cornerRadius = 2.;
        button.frame = CGRectMake(25, offsetY, self.ysf_frameWidth - 45, 34);
        [button setTitle:action.validOperation forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button ysf_addEventHandler:^(id  _Nonnull sender) {
            [weakSelf clickButtonAction:action];
        } forControlEvents:UIControlEventTouchUpInside];
        [weakSelf.contentView addSubview:button];
    }];
}

- (void)clickButtonAction:(YSFAction *)action {
    YSFKitEvent *event = [[YSFKitEvent alloc] init];
    event.eventName = YSFKitEventNameTapMixReply;
    event.message = self.model.message;
    event.data = action;
    [self.delegate onCatchEvent:event];
}

@end
