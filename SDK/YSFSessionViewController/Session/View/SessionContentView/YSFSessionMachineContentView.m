//
//  NIMSessionTextContentView.m
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "YSFSessionMachineContentView.h"
#import "YSFMessageModel.h"
#import "../../YSFSDK/ExportHeaders/QYCustomUIConfig.h"
#import "YSFMachineResponse.h"
#import "YSFAttributedLabel.h"
#import "YSFApiDefines.h"


@interface QuestionLink : NSObject
@property (nonatomic, copy) NSDictionary *questionDict;
@end

@implementation QuestionLink

@end


@interface YSFSessionMachineContentView()<YSFAttributedLabelDelegate>
@property (nonatomic, strong) UIView *content;

@end

@implementation YSFSessionMachineContentView

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
    __block CGFloat offsetY = self.model.contentViewInsets.top;

    [_content ysf_removeAllSubviews];
    YSFAttributedLabel *answerLabel = [self newAttrubutedLabel];
    YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)data.message.messageObject;
    YSFMachineResponse *attachment = (YSFMachineResponse *)object.attachment;
    NSString *tmpAnswerLabel = [attachment.answerLabel unescapeHtml];
    [answerLabel appendHTMLText:tmpAnswerLabel];
    if (answerLabel.attributedString.length > 0) {
        offsetY += 15.5;
        CGSize size = [answerLabel sizeThatFits:CGSizeMake(self.model.contentSize.width, CGFLOAT_MAX)];
        answerLabel.frame = CGRectMake(self.model.contentViewInsets.left, offsetY,
                                       self.model.contentSize.width, size.height);
        [_content addSubview:answerLabel];
        offsetY += size.height;
        offsetY += 13;
    }
    
    if (attachment.answerArray.count == 1 && !attachment.isOneQuestionRelevant) {
        YSFAttributedLabel *questionLabel = [self newAttrubutedLabel];
        NSString *answer = @"";
        NSDictionary *dict = [attachment.answerArray objectAtIndex:0];
//        if (attachment.isOneQuestionRelevant) {
//            NSUInteger start = questionLabel.attributedString.length + answer.length;
//            NSString *question = [dict objectForKey:YSFApiKeyQuestion];
//            if (question) {
//                answer = [answer stringByAppendingString:question];
//                QuestionLink *questionLink = [[QuestionLink alloc] init];
//                questionLink.questionDict = dict;
//                [questionLabel addCustomLink:questionLink forRange:NSMakeRange(start, question.length)];
//            }
//        }
//        else {
            NSString *oneAnswer = [dict objectForKey:YSFApiKeyAnswer];
            if (oneAnswer) {
                answer = [answer stringByAppendingString:oneAnswer];
            }
//        }
        answer = [answer unescapeHtml];
        [questionLabel appendHTMLText:answer];
        CGSize size = [questionLabel sizeThatFits:CGSizeMake(self.model.contentSize.width - 15, CGFLOAT_MAX)];
        offsetY += 15.5;
        questionLabel.frame = CGRectMake(self.model.contentViewInsets.left, offsetY,
                                         self.model.contentSize.width, size.height);
        [_content addSubview:questionLabel];
        offsetY += size.height;
        offsetY += 13;
    }
    else if ((attachment.answerArray.count == 1 && attachment.isOneQuestionRelevant)
             || attachment.answerArray.count > 1)
    {
        [attachment.answerArray enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *question = [dict objectForKey:YSFApiKeyQuestion];
            if (question) {
                UIView *splitLine = [UIView new];
                splitLine.backgroundColor = YSFRGB(0xdbdbdb);
                splitLine.ysf_frameHeight = 0.5;
                splitLine.ysf_frameLeft = 5;
                splitLine.ysf_frameWidth = self.ysf_frameWidth - 5;
                splitLine.ysf_frameTop = offsetY;
                [_content addSubview:splitLine];
                
                UIView *point = [UIView new];
                point.backgroundColor = YSFRGB(0xd6d6d6);
                point.ysf_frameHeight = 7.5;
                point.ysf_frameLeft = 18;
                point.ysf_frameWidth = 7.5;
                point.layer.cornerRadius = 4;
                point.ysf_frameTop = offsetY + 23;
                [_content addSubview:point];

                
                QuestionLink *questionLink = [[QuestionLink alloc] init];
                questionLink.questionDict = dict;
                
                YSFAttributedLabel *questionLabel = [self newAttrubutedLabel];
                [questionLabel setText:question];
                [questionLabel addCustomLink:questionLink forRange:NSMakeRange(0, question.length)];
                CGSize size = [questionLabel sizeThatFits:CGSizeMake(self.model.contentSize.width - 15, CGFLOAT_MAX)];
                offsetY += 15.5;
                questionLabel.frame = CGRectMake(self.model.contentViewInsets.left + 15, offsetY,
                                                 self.model.contentSize.width - 15, size.height);
                [_content addSubview:questionLabel];
                offsetY += size.height;
                offsetY += 13;
            }
        }];
        
    }
    
    if (attachment.operatorHint && attachment.operatorHintDesc.length > 0) {
        if (_content.subviews.count > 0) {
            UIView *splitLine = [UIView new];
            splitLine.backgroundColor = YSFRGB(0xdbdbdb);
            splitLine.ysf_frameHeight = 0.5;
            splitLine.ysf_frameLeft = 5;
            splitLine.ysf_frameWidth = self.ysf_frameWidth - 5;
            splitLine.ysf_frameTop = offsetY;
            [_content addSubview:splitLine];
        }

        YSFAttributedLabel *questionLabel = [self newAttrubutedLabel];
        [questionLabel appendHTMLText:attachment.operatorHintDesc];
        CGSize size = [questionLabel sizeThatFits:CGSizeMake(self.model.contentSize.width, CGFLOAT_MAX)];
        offsetY += 15.5;
        questionLabel.frame = CGRectMake(self.model.contentViewInsets.left, offsetY,
                                         self.model.contentSize.width, size.height);
        [_content addSubview:questionLabel];
        offsetY += size.height;
        offsetY += 13;
    }
}


#pragma mark - NIMAttributedLabelDelegate
- (void)ysfAttributedLabel:(YSFAttributedLabel *)label
             clickedOnLink:(id)strQuestion
{
    if ([strQuestion isKindOfClass:[QuestionLink class]]) {
        QuestionLink *questionLink = strQuestion;
        YSFKitEvent *event = [[YSFKitEvent alloc] init];
        event.eventName = YSFKitEventNameTapMachineQuestion;
        event.message = self.model.message;
        event.data = questionLink.questionDict;
        [self.delegate onCatchEvent:event];
    }
    else {
        YSFKitEvent *event = [[YSFKitEvent alloc] init];
        event.eventName = YSFKitEventNameTapMachineManual;
        event.message = self.model.message;
        event.data = strQuestion;
        [self.delegate onCatchEvent:event];
    }

}

- (YSFAttributedLabel *)newAttrubutedLabel
{
    YSFAttributedLabel *answerLabel = [[YSFAttributedLabel alloc] initWithFrame:CGRectZero];
    answerLabel.delegate = self;
    answerLabel.numberOfLines = 0;
    answerLabel.underLineForLink = NO;
    answerLabel.autoDetectNumber = NO;
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

- (void)layoutSubviews{
    [super layoutSubviews];
    _content.ysf_frameWidth = self.ysf_frameWidth;
    _content.ysf_frameHeight = self.ysf_frameHeight;
}

@end
