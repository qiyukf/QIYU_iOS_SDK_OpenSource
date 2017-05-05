//
//  NIMSessionTextContentView.m
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "YSFSessionTextContentView.h"
#import "YSFMessageModel.h"
#import "../../YSFSDK/ExportHeaders/QYCustomUIConfig.h"
#import "YSFAttributedLabel.h"
#import "YSFAttributedLabel+YSF.h"

@interface YSFSessionTextContentView()<YSFAttributedLabelDelegate>

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
    if (self.model.message.isPushMessageType) {
        [_textLabel ysf_setText:@""];
        [_textLabel appendHTMLText:text];
    }
    else {
        [_textLabel ysf_setText:text];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    UIEdgeInsets contentInsets = self.model.contentViewInsets;
    CGSize contentsize         = self.model.contentSize;
    CGRect labelFrame = CGRectMake(contentInsets.left, contentInsets.top, contentsize.width, contentsize.height);
    self.textLabel.frame = labelFrame;
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

@end
