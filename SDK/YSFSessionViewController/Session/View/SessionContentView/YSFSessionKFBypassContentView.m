//
//  NIMSessionTextContentView.m
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "YSFSessionKFBypassContentView.h"
#import "YSFMessageModel.h"
#import "QYCustomUIConfig.h"
#import "YSFKFBypassNotification.h"
#import "YSFAttributedLabel.h"
#import "YSFApiDefines.h"


@interface KFBypassLink : NSObject
@property (nonatomic, copy) NSDictionary *entryDict;
@end

@implementation KFBypassLink

@end


@interface YSFSessionKFBypassContentView()<YSFAttributedLabelDelegate>
@property (nonatomic, strong) UIView *content;

@end

@implementation YSFSessionKFBypassContentView

-(instancetype)initSessionMessageContentView
{
    if (self = [super initSessionMessageContentView]) {
        _content = [UIView new];
        [self addSubview:_content];
    }
    return self;
}

- (void)refresh:(YSFMessageModel *)data{
    [super refresh:data];
    
//    [_textLabel setText:@""];
//    _textLabel.backgroundColor = [UIColor clearColor];
//    QYCustomUIConfig *uiConfig = [QYCustomUIConfig sharedInstance];
//    if (self.model.message.isOutgoingMsg) {
//        _textLabel.textColor = uiConfig.customMessageTextColor;
//        _textLabel.linkColor = uiConfig.customMessageHyperLinkColor;
//    }
//    else {
//        _textLabel.textColor = uiConfig.serviceMessageTextColor;
//        _textLabel.linkColor = uiConfig.serviceMessageHyperLinkColor;
//    }
//    _textLabel.underLineForLink = NO;
//    CGFloat fontSize = self.model.message.isOutgoingMsg ? uiConfig.customMessageTextFontSize : uiConfig.serviceMessageTextFontSize;
//    _textLabel.font = [UIFont systemFontOfSize:fontSize];
//    
//    YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)data.message.messageObject;
//    YSFKFBypassNotification *attachment = (YSFKFBypassNotification *)object.attachment;
//    __block NSString *answer = @"";
//    answer = [answer stringByAppendingString:attachment.message];
//    [_textLabel appendText:answer];
//    
//    [attachment.entries enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if (answer.length > 0) {
//            [_textLabel appendText:@"\n"];
//        }
//        
//        NSUInteger start = _textLabel.attributedString.length;
//        NSString *label = [obj objectForKey:YSFApiKeyLabel];
//        if (label) {
//            if (!attachment.disable) {
//                [_textLabel appendText:label];
//                KFBypassLink *kfBypassLink = [[KFBypassLink alloc] init];
//                kfBypassLink.entryDict = obj;
//                [_textLabel addCustomLink:kfBypassLink forRange:NSMakeRange(start, label.length)];
//            }
//            else {
//                NSMutableAttributedString *attributedstring = [[NSMutableAttributedString alloc]initWithString:label];
//                [attributedstring ysf_setFont:_textLabel.font];
//                [attributedstring ysf_setTextColor:YSFRGBA2(0xff999999)];
//                [_textLabel appendAttributedText:attributedstring];
//            }
//        }
//    }];
//    
    
    
    
    __block CGFloat offsetY = self.model.contentViewInsets.top;
    
    [_content ysf_removeAllSubviews];
    YSFAttributedLabel *answerLabel = [self newAttrubutedLabel];
    YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)data.message.messageObject;
    YSFKFBypassNotification *attachment = (YSFKFBypassNotification *)object.attachment;
    NSString *tmpAnswerLabel = [attachment.message unescapeHtml];
    [answerLabel appendHTMLText:tmpAnswerLabel];
    if (answerLabel.attributedString.length > 0) {
        offsetY += 12;
        CGSize size = [answerLabel sizeThatFits:CGSizeMake(self.model.contentSize.width, CGFLOAT_MAX)];
        answerLabel.frame = CGRectMake(self.model.contentViewInsets.left, offsetY,
                                       self.model.contentSize.width, size.height);
        [_content addSubview:answerLabel];
        offsetY += size.height;
        offsetY += 12;
    }
    
    [attachment.entries enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *question = [dict objectForKey:YSFApiKeyLabel];
        if (question) {
            UIView *splitLine = [UIView new];
            splitLine.backgroundColor = YSFRGB(0xdbdbdb);
            splitLine.ysf_frameHeight = 0.5;
            splitLine.ysf_frameLeft = 5;
            splitLine.ysf_frameWidth = self.ysf_frameWidth - 5;
            splitLine.ysf_frameTop = offsetY;
            [self.content addSubview:splitLine];
            
            UIView *point = [UIView new];
            point.backgroundColor = YSFRGB(0xd6d6d6);
            point.ysf_frameHeight = 7.5;
            point.ysf_frameLeft = 18;
            point.ysf_frameWidth = 7.5;
            point.layer.cornerRadius = 4;
            point.ysf_frameTop = offsetY + 19;
            [self.content addSubview:point];
            
            YSFAttributedLabel *questionLabel = [self newAttrubutedLabel];
            if (!attachment.disable) {
                [questionLabel setText:question];
                KFBypassLink *kfBypassLink = [[KFBypassLink alloc] init];
                kfBypassLink.entryDict = dict;
                [questionLabel addCustomLink:kfBypassLink forRange:NSMakeRange(0, question.length)];
            }
            else {
                NSMutableAttributedString *attributedstring = [[NSMutableAttributedString alloc]initWithString:question];
                [attributedstring ysf_setFont:questionLabel.font];
                [attributedstring ysf_setTextColor:YSFRGBA2(0xff999999)];
                [questionLabel setAttributedText:attributedstring];
            }
            
            CGSize size = [questionLabel sizeThatFits:CGSizeMake(self.model.contentSize.width - 15, CGFLOAT_MAX)];
            offsetY += 12;
            questionLabel.frame = CGRectMake(self.model.contentViewInsets.left + 15, offsetY,
                                             self.model.contentSize.width - 15, size.height);
            

            
            [self.content addSubview:questionLabel];
            offsetY += size.height;
            offsetY += 12;
            }
    }];


    

}

- (void)layoutSubviews{
    [super layoutSubviews];
    _content.ysf_frameWidth = self.ysf_frameWidth;
    _content.ysf_frameHeight = self.ysf_frameHeight;
}


#pragma mark - NIMAttributedLabelDelegate
- (void)ysfAttributedLabel:(YSFAttributedLabel *)label
             clickedOnLink:(id)strQuestion
{
    if ([strQuestion isKindOfClass:[KFBypassLink class]]) {
        KFBypassLink *kfBypassLink = strQuestion;
        YSFKitEvent *event = [[YSFKitEvent alloc] init];
        event.eventName = YSFKitEventNameTapKFBypass;
        event.message = self.model.message;
        event.data = kfBypassLink.entryDict;
        [self.delegate onCatchEvent:event];
    }

}


- (YSFAttributedLabel *)newAttrubutedLabel
{
    YSFAttributedLabel *answerLabel = [[YSFAttributedLabel alloc] initWithFrame:CGRectZero];
    answerLabel.delegate = self;
    answerLabel.numberOfLines = 0;
    answerLabel.underLineForLink = NO;
    answerLabel.lineBreakMode = NSLineBreakByWordWrapping;
    answerLabel.font = [UIFont systemFontOfSize:16.f];
    answerLabel.highlightColor = YSFRGBA2(0x1a000000);
    answerLabel.backgroundColor = [UIColor clearColor];
    QYCustomUIConfig *uiConfig = [QYCustomUIConfig sharedInstance];
    if (self.model.message.isOutgoingMsg) {
        answerLabel.textColor = uiConfig.customMessageTextColor;
        answerLabel.linkColor = uiConfig.customMessageHyperLinkColor;
    }
    else {
        answerLabel.textColor = uiConfig.serviceMessageTextColor;
        answerLabel.linkColor = uiConfig.serviceMessageHyperLinkColor;
    }
    CGFloat fontSize = self.model.message.isOutgoingMsg ? uiConfig.customMessageTextFontSize : uiConfig.serviceMessageTextFontSize;
    answerLabel.font = [UIFont systemFontOfSize:fontSize];
    return answerLabel;
}


@end
