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
#import "NSString+FileTransfer.h"
#import "NSAttributedString+YSF.h"
#import "YSFCoreText.h"
#import "QYCustomUIConfig.h"

@interface YSFMixReplyContentView() <YSFAttributedLabelDelegate>

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
    
    YSFAttributedTextView *attrLabel = [[YSFAttributedTextView alloc] initWithFrame:CGRectInfinite];
    attrLabel.shouldDrawImages = NO;
    attrLabel.backgroundColor = [UIColor clearColor];
    
    NSString *labelStr = mixReply.label;
    attrLabel.attributedString = [labelStr ysf_attributedString:self.model.message.isOutgoingMsg];
    if (attrLabel.attributedString.length) {
        offsetY += 15.5;
        attrLabel.ysf_frameWidth = self.model.contentSize.width;
        CGSize size = [attrLabel.attributedTextContentView sizeThatFits:CGSizeZero];
        attrLabel.frame = CGRectMake(self.model.contentViewInsets.left, offsetY, self.model.contentSize.width, size.height);
        [attrLabel layoutSubviews];
        [_contentView addSubview:attrLabel];
        offsetY += size.height;
        offsetY += 13;
    }
    
    CGFloat lineDegree = 1. / [UIScreen mainScreen].scale;
    UIView *splitLine = [[UIView alloc] init];
    splitLine.backgroundColor = YSFRGB(0xdbdbdb);
    splitLine.frame = CGRectMake(5, offsetY, self.ysf_frameWidth - 5, lineDegree);
    [_contentView addSubview:splitLine];
    
    __weak typeof(self) weakSelf = self;
    [mixReply.actionList enumerateObjectsUsingBlock:^(YSFAction *action, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *title = action.validOperation;
        if (title.length) {
            UIView *point = [[UIView alloc] init];
            point.backgroundColor = YSFRGB(0xd6d6d6);
            point.layer.cornerRadius = 4;
            point.frame = CGRectMake(18, offsetY + 23, 7.5, 7.5);
            [weakSelf.contentView addSubview:point];
            
            YSFAttributedLabel *actionLabel = [self getAttrubutedLabel];
            [actionLabel setText:title];
            [actionLabel addCustomLink:action forRange:NSMakeRange(0, title.length)];
            CGSize size = [actionLabel sizeThatFits:CGSizeMake(self.model.contentSize.width - 15, CGFLOAT_MAX)];
            offsetY += 15.5;
            actionLabel.frame = CGRectMake(self.model.contentViewInsets.left + 15, offsetY, self.model.contentSize.width - 15, size.height);
            [weakSelf.contentView addSubview:actionLabel];
            offsetY += size.height;
            offsetY += -9;
        }
    }];
    offsetY += 22;
}

- (YSFAttributedLabel *)getAttrubutedLabel {
    YSFAttributedLabel *label = [[YSFAttributedLabel alloc] initWithFrame:CGRectZero];
    label.delegate = self;
    label.numberOfLines = 0;
    label.underLineForLink = NO;
    label.autoDetectNumber = NO;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.font = [UIFont systemFontOfSize:16.f];
    label.highlightColor = YSFRGBA2(0x1a000000);
    label.backgroundColor = [UIColor clearColor];
    QYCustomUIConfig *config = [QYCustomUIConfig sharedInstance];
    if (self.model.message.isOutgoingMsg) {
        label.textColor = config.customMessageTextColor;
        label.linkColor = config.customMessageHyperLinkColor;
    } else {
        label.textColor = config.serviceMessageTextColor;
        label.linkColor = config.serviceMessageHyperLinkColor;
    }
    CGFloat fontSize = self.model.message.isOutgoingMsg ? config.customMessageTextFontSize : config.serviceMessageTextFontSize;
    label.font = [UIFont systemFontOfSize:fontSize];
    return label;
}

- (void)ysfAttributedLabel:(YSFAttributedLabel *)label clickedOnLink:(id)linkData {
    if ([linkData isKindOfClass:[YSFAction class]]) {
        YSFKitEvent *event = [[YSFKitEvent alloc] init];
        event.eventName = YSFKitEventNameTapMixReply;
        event.message = self.model.message;
        event.data = linkData;
        [self.delegate onCatchEvent:event];
    }
}

@end
