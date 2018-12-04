//
//  NIMSessionNotificationContentView.m
//  YSFKit
//
//  Created by chris on 15/3/9.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "YSFSessionNotificationContentView.h"
#import "YSFMessageModel.h"
#import "YSFKitUtil.h"
#import "YSFDefaultValueMaker.h"
#import "QYCustomUIConfig.h"
#import "YSFStartServiceObject.h"
#import "YSFEvaluationTipObject.h"
#import "NSMutableAttributedString+YSFVendor.h"
#import "YSFNotification.h"
#import "YSFApiDefines.h"

@interface YSFSessionNotificationContentView() <YSFAttributedLabelDelegate>

@property (nonatomic, strong) UIView *leftLineView;
@property (nonatomic, strong) UIView *rightLineView;

@end

@implementation YSFSessionNotificationContentView
- (instancetype)initSessionMessageContentView {
    if (self = [super initSessionMessageContentView]) {
        _label = [[YSFAttributedLabel alloc] initWithFrame:CGRectZero];
        _label.font = [UIFont systemFontOfSize:[[QYCustomUIConfig sharedInstance] tipMessageTextFontSize]];
        _label.textColor = [[QYCustomUIConfig sharedInstance] tipMessageTextColor];
        _label.backgroundColor = [UIColor clearColor];
        _label.numberOfLines = 0;
        _label.underLineForLink = NO;
        _label.textAlignment = kCTTextAlignmentCenter;
        _label.delegate = self;
        [self addSubview:_label];
        self.bubbleType = YSFKitBubbleTypeNotify;
    }
    return self;
}

- (void)refresh:(YSFMessageModel *)model {
    [super refresh:model];
    _label.autoDetectLinks = YES;
    _label.autoDetectNumber = YES;
    
    id<YSFCellLayoutConfig> config = model.layoutConfig;
    if ([config respondsToSelector:@selector(formatedMessage:)]) {
        YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)model.message.messageObject;
        if (model.message.messageType == YSF_NIMMessageTypeTip) {
            _label.text = [model.layoutConfig formatedMessage:model];
        } else if ([object.attachment isKindOfClass:[YSFStartServiceObject class]]) {
            _label.text = [model.layoutConfig formatedMessage:model];
        } else if ([object.attachment isKindOfClass:[YSFEvaluationTipObject class]]) {
            _label.autoDetectLinks = NO;
            _label.autoDetectNumber = NO;
            
            YSFEvaluationTipObject *attachment = (YSFEvaluationTipObject *)object.attachment;
            if (attachment.specialThanksTip.length > 0) {
                _label.text = attachment.specialThanksTip;
                if (attachment.tipModify.length) {
                    NSMutableAttributedString *modifyAttrString = [[NSMutableAttributedString alloc] initWithString:attachment.tipModify];
                    [modifyAttrString ysf_setFont:[UIFont systemFontOfSize:[[QYCustomUIConfig sharedInstance] tipMessageTextFontSize]]];
                    [_label appendAttributedText:modifyAttrString];
                    [_label addCustomLink:@"YSFClickModifyAttributedString"
                                 forRange:NSMakeRange(attachment.specialThanksTip.length, modifyAttrString.length)
                                linkColor:YSFRGB(0x008fff)];
                }
            } else {
                NSInteger length = 0;
                if (!attachment.tipContent.length) {
                    //情况1：服务端返回的感谢文案为空，走原逻辑
                    _label.text = @"您对我们的服务评价为：";
                    length += 11;
                    NSMutableAttributedString *attributedstring = [[NSMutableAttributedString alloc] initWithString:YSFStrParam(attachment.tipResult)];
                    [attributedstring ysf_setFont:[UIFont boldSystemFontOfSize:[[QYCustomUIConfig sharedInstance] tipMessageTextFontSize]]];
                    [attributedstring ysf_setTextColor:[[QYCustomUIConfig sharedInstance] tipMessageTextColor]];
                    [_label appendAttributedText:attributedstring];
                    [_label appendText:@"。非常感谢！"];
                    length += (attachment.tipResult.length + 6);
                    if (attachment.tipModify.length) {
                        NSMutableAttributedString *modifyAttrString = [[NSMutableAttributedString alloc] initWithString:attachment.tipModify];
                        [modifyAttrString ysf_setFont:[UIFont systemFontOfSize:[[QYCustomUIConfig sharedInstance] tipMessageTextFontSize]]];
                        [_label appendAttributedText:modifyAttrString];
                        [_label addCustomLink:@"YSFClickModifyAttributedString" forRange:NSMakeRange(length, modifyAttrString.length) linkColor:YSFRGB(0x008fff)];
                    }
                } else {
                    NSString *replaceStr = @"#选择项#";
                    NSRange range = [attachment.tipContent rangeOfString:replaceStr];
                    if (range.location != NSNotFound) {
                        //情况2：服务端返回的感谢文案中含有"#选择项#"，将此部分内容替换为结果
                        NSString *content_head = [attachment.tipContent substringWithRange:NSMakeRange(0, range.location)];
                        NSString *content_tail = [attachment.tipContent substringWithRange:NSMakeRange(range.location + range.length, attachment.tipContent.length - content_head.length - replaceStr.length)];
                        _label.text = content_head;
                        length += content_head.length;
                        NSMutableAttributedString *attributedstring = [[NSMutableAttributedString alloc] initWithString:YSFStrParam(attachment.tipResult)];
                        [attributedstring ysf_setFont:[UIFont boldSystemFontOfSize:[[QYCustomUIConfig sharedInstance] tipMessageTextFontSize]]];
                        [attributedstring ysf_setTextColor:[[QYCustomUIConfig sharedInstance] tipMessageTextColor]];
                        [_label appendAttributedText:attributedstring];
                        length += attachment.tipResult.length;
                        if (content_tail.length) {
                            [_label appendText:content_tail];
                            length += content_tail.length;
                        }
                        if (attachment.tipModify.length) {
                            NSMutableAttributedString *modifyAttrString = [[NSMutableAttributedString alloc] initWithString:attachment.tipModify];
                            [modifyAttrString ysf_setFont:[UIFont systemFontOfSize:[[QYCustomUIConfig sharedInstance] tipMessageTextFontSize]]];
                            [_label appendAttributedText:modifyAttrString];
                            [_label addCustomLink:@"YSFClickModifyAttributedString" forRange:NSMakeRange(length, modifyAttrString.length) linkColor:YSFRGB(0x008fff)];
                        }
                    } else {
                        //情况3：服务端返回的感谢文案中不含"#xxx#"，原样展示
                        _label.text = attachment.tipContent;
                        length += attachment.tipContent.length;
                        if (attachment.tipModify.length) {
                            NSMutableAttributedString *modifyAttrString = [[NSMutableAttributedString alloc] initWithString:attachment.tipModify];
                            [modifyAttrString ysf_setFont:[UIFont systemFontOfSize:[[QYCustomUIConfig sharedInstance] tipMessageTextFontSize]]];
                            [_label appendAttributedText:modifyAttrString];
                            [_label addCustomLink:@"YSFClickModifyAttributedString" forRange:NSMakeRange(length, modifyAttrString.length) linkColor:YSFRGB(0x008fff)];
                        }
                    }
                }
            }
            
        } else if ([object.attachment isKindOfClass:[YSFNotification class]]) {
            YSFNotification *notification = (YSFNotification *)object.attachment;
            _label.text = [model.layoutConfig formatedMessage:model];
            
            if (notification.clickRange.length && notification.clickColor) {
                [_label addCustomLink:@"YSFClickAttributedString" forRange:notification.clickRange linkColor:notification.clickColor];
            }
            
            if (notification.localCommand == YSFCommandMiniAppTip) {
                [_label addCustomLink:@"YSFCommandMiniAppTip" forRange:NSMakeRange(notification.message.length-6, 6)];
            } else if (notification.localCommand == YSFCommandHistoryNotification) {
                if (!_leftLineView) {
                    _leftLineView = [[UIView alloc] initWithFrame:CGRectZero];
                    _leftLineView.backgroundColor = [[QYCustomUIConfig sharedInstance] tipMessageTextColor];
                    [self addSubview:_leftLineView];
                }
                if (!_rightLineView) {
                    _rightLineView = [[UIView alloc] initWithFrame:CGRectZero];
                    _rightLineView.backgroundColor = [[QYCustomUIConfig sharedInstance] tipMessageTextColor];
                    [self addSubview:_rightLineView];
                }
            }
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.label.ysf_frameSize = [self.label sizeThatFits:CGSizeMake(self.ysf_frameWidth - 112 - 20, CGFLOAT_MAX)];
    self.label.ysf_frameCenterX = self.ysf_frameWidth * .5f;
    self.label.ysf_frameCenterY = self.ysf_frameHeight * .5f;
    self.bubbleImageView.frame = CGRectInset(self.label.frame, -8, 0);
    self.label.ysf_frameCenterY = self.label.ysf_frameCenterY + 2;
    
    _leftLineView.hidden = YES;
    _rightLineView.hidden = YES;
    self.bubbleImageView.hidden = NO;
    YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)self.model.message.messageObject;
    if ([object.attachment isKindOfClass:[YSFNotification class]]) {
        YSFNotification *notification = (YSFNotification *)object.attachment;
        if (notification.localCommand == YSFCommandHistoryNotification) {
            _leftLineView.hidden = NO;
            _rightLineView.hidden = NO;
            self.bubbleImageView.hidden = YES;
            CGFloat lineHeight = 1. / [UIScreen mainScreen].scale;
            CGFloat space = 20;
            _leftLineView.frame = CGRectMake(space,
                                             roundf((self.ysf_frameHeight - lineHeight) / 2),
                                             CGRectGetMinX(self.bubbleImageView.frame) - space,
                                             lineHeight);
            _rightLineView.frame = CGRectMake(CGRectGetMaxX(self.bubbleImageView.frame),
                                             CGRectGetMinY(_leftLineView.frame),
                                             CGRectGetWidth(_leftLineView.frame),
                                             lineHeight);
        }
    }
}

#pragma mark - NIMAttributedLabelDelegate
- (void)ysfAttributedLabel:(YSFAttributedLabel *)label clickedOnLink:(id)data {
    if ([data isEqualToString:@"YSFCommandMiniAppTip"]) {
        YSFKitEvent *event = [[YSFKitEvent alloc] init];
        event.eventName = YSFKitEventNameOpenUrl;
        event.message = self.model.message;
        event.data = @"https://developers.weixin.qq.com/miniprogram/dev/api/custommsg/conversation.html";
        [self.delegate onCatchEvent:event];
    } else if ([data isEqualToString:@"YSFClickAttributedString"]) {
        YSFKitEvent *event = [[YSFKitEvent alloc] init];
        event.eventName = YSFKitEventNameTapSystemNotification;
        event.message = self.model.message;
        [self.delegate onCatchEvent:event];
    } else if ([data isEqualToString:@"YSFClickModifyAttributedString"]) {
        YSFKitEvent *event = [[YSFKitEvent alloc] init];
        event.eventName = YSFKitEventNameTapModifyEvaluation;
        event.message = self.model.message;
        [self.delegate onCatchEvent:event];
    }
}

@end
