//
//  NIMSessionTextContentView.m
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "YSFSessionTextContentView.h"
#import "YSFMessageModel.h"
#import "QYCustomUIConfig+Private.h"
#import "YSFAttributedLabel.h"
#import "YSFAttributedLabel+YSF.h"
#import "YSFApiDefines.h"
#import "YSF_NIMMessage+YSF.h"
#import "UIControl+BlocksKit.h"

@interface YSFSessionTextContentView()<YSFAttributedLabelDelegate>
@property (nonatomic, strong) UIView *splitLine;
@property (nonatomic, strong) UIButton *action;
@end

@implementation YSFSessionTextContentView

-(instancetype)initSessionMessageContentView
{
    if (self = [super initSessionMessageContentView]) {
        _textLabel = [[YSFAttributedLabel alloc] initWithFrame:CGRectZero];
        _textLabel.delegate = self;
        _textLabel.numberOfLines = 0;
        _textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _textLabel.font = [UIFont systemFontOfSize:16.f];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.highlightColor = YSFRGBA2(0x1a000000);
        [self addSubview:_textLabel];
        
        _splitLine = [UIView new];
        _splitLine.backgroundColor = YSFRGB(0xdbdbdb);
        [self addSubview:_splitLine];
        
        _action = [UIButton new];
        [_action setTitleColor:YSFRGB(0x5092E1) forState:UIControlStateNormal];
        __weak typeof(self) weakSelf = self;
        [_action ysf_addEventHandler:^(id  _Nonnull sender) {
            [weakSelf actionClick:weakSelf.model.message.actionUrl];
        } forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_action];
    }
    return self;
}

- (void)refresh:(YSFMessageModel *)data{
    [super refresh:data];

    QYCustomUIConfig *uiConfig = [QYCustomUIConfig sharedInstance];
    if (self.model.message.isOutgoingMsg) {
        _textLabel.textColor = uiConfig.customMessageTextColor;
        _textLabel.linkColor = uiConfig.customMessageHyperLinkColor;
    }
    else {
        _textLabel.textColor = uiConfig.serviceMessageTextColor;
        _textLabel.linkColor = uiConfig.serviceMessageHyperLinkColor;
    }
    
    _textLabel.underLineForLink = YES;
    CGFloat fontSize = self.model.message.isOutgoingMsg ? uiConfig.customMessageTextFontSize : uiConfig.serviceMessageTextFontSize;
    _textLabel.font = [UIFont systemFontOfSize:fontSize];
    
    NSString *text = self.model.message.text;
    if (![YSF_NIMSDK sharedSDK].sdkOrKf && !self.model.message.isOutgoingMsg && !uiConfig.showTransWords) {
        text = [self.model.message getTextWithoutTrashWords];
    }

    if (self.model.message.isPushMessageType) {
        [_textLabel ysf_setText:@""];
        [_textLabel appendHTMLText:text];
    }
    else {
        [_textLabel ysf_setText:text];
    }
    
    if (self.model.message.isPushMessageType) {
        _splitLine.hidden = NO;
        _action.hidden = NO;
        [_action setTitle:self.model.message.actionText forState:UIControlStateNormal];
        _action.titleLabel.font = [UIFont systemFontOfSize:15];
    }
    else {
        _splitLine.hidden = YES;
        _action.hidden = YES;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    UIEdgeInsets contentInsets = self.model.contentViewInsets;
    CGSize contentsize         = self.model.contentSize;
    CGRect labelFrame = CGRectMake(contentInsets.left, contentInsets.top, contentsize.width, contentsize.height);
    self.textLabel.frame = labelFrame;
    
    if (self.model.message.isPushMessageType) {
        _textLabel.ysf_frameHeight -= 44;
        _splitLine.ysf_frameTop = _textLabel.ysf_frameBottom;
        _splitLine.ysf_frameHeight = 0.5;
        _splitLine.ysf_frameLeft = 5;
        _splitLine.ysf_frameWidth = self.ysf_frameWidth - 5;
        _action.ysf_frameLeft = 5;
        _action.ysf_frameWidth = self.ysf_frameWidth - 5;
        _action.ysf_frameTop = _splitLine.ysf_frameBottom;
        _action.ysf_frameHeight = 44;
        if (![YSF_NIMSDK sharedSDK].sdkOrKf) {
            _splitLine.ysf_frameLeft = -5;
            _action.ysf_frameLeft = -5;
        }
    }
}


#pragma mark - NIMAttributedLabelDelegate
- (void)ysfAttributedLabel:(YSFAttributedLabel *)label
             clickedOnLink:(id)linkData{
    
    YSFKitEvent *event = [[YSFKitEvent alloc] init];
    if ([linkData isKindOfClass:[NSString class]]) {

        NSDataDetector	*linkDetector	= [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink | NSTextCheckingTypePhoneNumber error:nil];
        NSArray			*matches		= [linkDetector matchesInString:linkData options:0 range:NSMakeRange(0, [linkData length])];
        
        for (NSTextCheckingResult *match in matches) {
            if (match.resultType == NSTextCheckingTypePhoneNumber) {
                event.eventName = YSFKitEventNameTapLabelPhoneNumber;
            }
            else {
                event.eventName = YSFKitEventNameTapLabelLink;
            }
            break;
        }
        
        event.message = self.model.message;
        event.data = linkData;
        [self.delegate onCatchEvent:event];
    }

}

- (void)actionClick:(NSString *)actionUrl
{
    YSFKitEvent *event = [[YSFKitEvent alloc] init];
    event.eventName = YSFKitEventNameTapPushMessageActionUrl;
    event.message = self.model.message;
    event.data = actionUrl;
    [self.delegate onCatchEvent:event];
}

@end
