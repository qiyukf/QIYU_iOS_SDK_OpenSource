//
//  YSFMachineResponse.m
//  YSFSDK
//
//  Created by amao on 9/7/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "YSFMachineResponse.h"
#import "NSDictionary+YSFJson.h"
#import "YSFApiDefines.h"
#import "YSFCoreText.h"

@interface YSFMachineResponse() <YSFAttributedTextContentViewDelegate>

@property (nonatomic, strong) NSMutableArray<NSString *> *imageUrlStringArray;

@end

@implementation YSFMachineResponse

- (NSDictionary *)encodeAttachment
{
    NSMutableDictionary *dict   = [NSMutableDictionary dictionary];
    
    dict[YSFApiKeyCmd]               = @(_command);
    dict[YSFApiKeyQuestion]          = YSFStrParam(_originalQuestion);
    dict[YSFApiKeyEvaluation] = @(_evaluation);
    dict[YSFApiKeyAnswerType]        = @(_answerType);
    dict[YSFApiKeyOperatorHint]      = @(_operatorHint);
    dict[YSFApiKeyOperatorHintDesc]  = YSFStrParam(_operatorHintDesc);

    if (_answerArray) {
        NSData *arrayData = [NSJSONSerialization dataWithJSONObject:_answerArray
                                                            options:0
                                                              error:nil];
        if (arrayData)
        {
            dict[YSFApiKeyAnswerList]  = [[NSString alloc] initWithData:arrayData
                                                               encoding:NSUTF8StringEncoding];
        }
    }
    
    dict[YSFApiKeyAnswerLabel]  = YSFStrParam(_answerLabel);
    
    return dict;
}

+ (instancetype)objectByDict:(NSDictionary *)dict
{
    YSFMachineResponse *instance = [[YSFMachineResponse alloc] init];
    instance.command             = [dict ysf_jsonInteger:YSFApiKeyCmd];
    instance.originalQuestion = [dict ysf_jsonString:YSFApiKeyQuestion];
    instance.evaluation = [dict ysf_jsonInteger:YSFApiKeyEvaluation];

    if (!instance.originalQuestion) {
        instance.originalQuestion = @"";
    }
    instance.answerType = [dict ysf_jsonInteger:YSFApiKeyAnswerType];
    instance.operatorHint = [dict ysf_jsonBool:YSFApiKeyOperatorHint];
    instance.operatorHintDesc = [dict ysf_jsonString:YSFApiKeyOperatorHintDesc];
    if (!instance.operatorHintDesc) {
        instance.operatorHintDesc = @"";
    }
    NSString *answerList = [dict ysf_jsonString:YSFApiKeyAnswerList];
    if (answerList) {
        instance.answerArray = [answerList ysf_toArray];
    }
    
    instance.answerLabel = [dict ysf_jsonString:YSFApiKeyAnswerLabel];
    if (!instance.answerLabel) {
        instance.answerLabel = @"";
    }
    if (instance.answerArray && instance.answerArray.count == 1 && [instance.answerLabel isEqualToString:@""]) {
        instance.isOneQuestionRelevant = NO;
    }
    else {
        instance.isOneQuestionRelevant = YES;
    }
    
    instance.imageUrlStringArray = [NSMutableArray new];
    
    YSFAttributedTextView *textView = [[YSFAttributedTextView alloc] initWithFrame:CGRectInfinite];
    textView.textDelegate = instance;
    textView.shouldDrawImages = NO;
    NSData *data = [instance.answerLabel dataUsingEncoding:NSUTF8StringEncoding];
    NSAttributedString *string = [[NSAttributedString alloc] ysf_initWithHTMLData:data options:0 documentAttributes:NULL];
    textView.attributedString = string;
    [textView layoutSubviews];
    
    
    if (instance.answerArray.count == 1 && !instance.isOneQuestionRelevant) {
        NSDictionary *dict = [instance.answerArray objectAtIndex:0];
        NSString *oneAnswer = [dict objectForKey:YSFApiKeyAnswer];
        data = [oneAnswer dataUsingEncoding:NSUTF8StringEncoding];
        string = [[NSAttributedString alloc] ysf_initWithHTMLData:data options:0 documentAttributes:NULL];
        textView.attributedString = string;
        [textView layoutSubviews];
    }
    
    data = [instance.operatorHintDesc dataUsingEncoding:NSUTF8StringEncoding];
    string = [[NSAttributedString alloc] ysf_initWithHTMLData:data options:0 documentAttributes:NULL];
    textView.attributedString = string;
    [textView layoutSubviews];
    
    return instance;
}

- (UIView *)attributedTextContentView:(YSFAttributedTextContentView *)attributedTextContentView viewForAttachment:(YSFTextAttachment *)attachment frame:(CGRect)frame
{
    if ([attachment isKindOfClass:[YSFImageTextAttachment class]])
    {
        NSString *urlString = attachment.contentURL.relativeString;
        [_imageUrlStringArray addObject:urlString];
    }
    return nil;
}

@end
