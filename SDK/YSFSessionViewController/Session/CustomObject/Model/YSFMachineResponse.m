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
#import "YSFMachineContentConfig.h"


@interface YSFMachineResponse() <YSFAttributedTextContentViewDelegate>

@property (nonatomic, strong) NSMutableArray<NSString *> *imageUrlStringArray;

@end


@implementation YSFMachineResponse
- (NSString *)thumbText {
    NSString *text = @"";
    if (_operatorHint) {
        text = [NSString stringWithFormat:@"%@", _operatorHintDesc];
    } else {
        text = [NSString stringWithFormat:@"%@", _answerLabel];
        for (NSDictionary *item in _answerArray) {
            NSString *answerText = item[@"answer"] ? : @"";
            text = [text stringByAppendingString:answerText];
        }
    }
    return text;
}

- (YSFMachineContentConfig *)contentConfig {
    return [[YSFMachineContentConfig alloc] init];
}

- (NSDictionary *)encodeAttachment {
    NSMutableDictionary *dict   = [NSMutableDictionary dictionary];
    
    dict[YSFApiKeyCmd] = @(_command);
    dict[YSFApiKeyQuestion] = YSFStrParam(_originalQuestion);
    dict[YSFApiKeyEvaluation] = @(_evaluation);
    dict[YSFApiKeyEvaluationContent] = YSFStrParam(_evaluationContent);
    dict[YSFApiKeyEvaluationReason] = @(_evaluationReason);
    dict[YSFApiKeyEvaluationGuide] = YSFStrParam(_evaluationGuide);
    dict[YSFApiKeyAnswerType] = @(_answerType);
    dict[YSFApiKeyOperatorHint] = @(_operatorHint);
    dict[YSFApiKeyOperatorHintDesc] = YSFStrParam(_operatorHintDesc);
    if (_answerArray) {
        NSData *arrayData = [NSJSONSerialization dataWithJSONObject:_answerArray options:0 error:nil];
        if (arrayData) {
            dict[YSFApiKeyAnswerList]  = [[NSString alloc] initWithData:arrayData encoding:NSUTF8StringEncoding];
        }
    }
    dict[YSFApiKeyAnswerLabel] = YSFStrParam(_answerLabel);
    
    return dict;
}

+ (instancetype)objectByDict:(NSDictionary *)dict {
    YSFMachineResponse *instance = [[YSFMachineResponse alloc] init];
    instance.command = [dict ysf_jsonInteger:YSFApiKeyCmd];
    instance.originalQuestion = YSFStrParam([dict ysf_jsonString:YSFApiKeyQuestion]);
    instance.evaluation = [dict ysf_jsonInteger:YSFApiKeyEvaluation];
    instance.evaluationContent = YSFStrParam([dict ysf_jsonString:YSFApiKeyEvaluationContent]);
    instance.evaluationReason = [dict ysf_jsonBool:YSFApiKeyEvaluationReason];
    instance.evaluationGuide = YSFStrParam([dict ysf_jsonString:YSFApiKeyEvaluationGuide]);
    instance.answerType = [dict ysf_jsonInteger:YSFApiKeyAnswerType];
    instance.operatorHint = [dict ysf_jsonBool:YSFApiKeyOperatorHint];
    instance.operatorHintDesc = YSFStrParam([dict ysf_jsonString:YSFApiKeyOperatorHintDesc]);
    NSString *answerList = [dict ysf_jsonString:YSFApiKeyAnswerList];
    if (answerList) {
        instance.answerArray = [answerList ysf_toArray];
    }
    instance.answerLabel = YSFStrParam([dict ysf_jsonString:YSFApiKeyAnswerLabel]);
    if (instance.answerArray && instance.answerArray.count == 1 && !instance.answerLabel.length) {
        instance.isOneQuestionRelevant = NO;
    } else {
        instance.isOneQuestionRelevant = YES;
    }
    return instance;
}

- (NSMutableArray<NSString *> *)imageUrlStringArray {
    if (_imageUrlStringArray == nil) {
        self.imageUrlStringArray = [NSMutableArray array];
        
        YSFAttributedTextView *textView = [[YSFAttributedTextView alloc] initWithFrame:CGRectInfinite];
        textView.textDelegate = self;
        textView.shouldDrawImages = NO;
        NSData *data = [self.answerLabel dataUsingEncoding:NSUTF8StringEncoding];
        NSAttributedString *string = [[NSAttributedString alloc] ysf_initWithHTMLData:data options:0 documentAttributes:NULL];
        textView.attributedString = string;
        [textView layoutSubviews];
        
        if (self.answerArray.count == 1 && !self.isOneQuestionRelevant) {
            NSDictionary *dict = [self.answerArray objectAtIndex:0];
            NSString *oneAnswer = [dict objectForKey:YSFApiKeyAnswer];
            data = [oneAnswer dataUsingEncoding:NSUTF8StringEncoding];
            string = [[NSAttributedString alloc] ysf_initWithHTMLData:data options:0 documentAttributes:NULL];
            textView.attributedString = string;
            [textView layoutSubviews];
        }
        
        data = [self.operatorHintDesc dataUsingEncoding:NSUTF8StringEncoding];
        string = [[NSAttributedString alloc] ysf_initWithHTMLData:data options:0 documentAttributes:NULL];
        textView.attributedString = string;
        [textView layoutSubviews];
    }
    return _imageUrlStringArray;
}

- (UIView *)attributedTextContentView:(YSFAttributedTextContentView *)attributedTextContentView
                    viewForAttachment:(YSFTextAttachment *)attachment
                                frame:(CGRect)frame {
    if ([attachment isKindOfClass:[YSFImageTextAttachment class]]) {
        NSString *urlString = attachment.contentURL.relativeString;
        if (urlString.length) {
            [_imageUrlStringArray addObject:urlString];
        }
    }
    return nil;
}

@end
