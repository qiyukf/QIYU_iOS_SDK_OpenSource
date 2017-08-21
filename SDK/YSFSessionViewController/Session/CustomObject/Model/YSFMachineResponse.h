//
//  YSFCloseService.h
//  YSFSDK
//
//  Created by amao on 9/7/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//


typedef enum : NSUInteger {
    YSFEvaluationSelectionTypeInvisible = 0,
    YSFEvaluationSelectionTypeVisible,
    YSFEvaluationSelectionTypeYes,
    YSFEvaluationSelectionTypeNo,
} YSFEvaluationSelectionType;


@interface YSFMachineResponse : NSObject<YSF_NIMCustomAttachment>

@property (nonatomic,copy)  NSString    *rawStringForCopy;

@property (nonatomic,assign)    NSInteger   command;
@property (nonatomic,copy)  NSString    *originalQuestion;
@property (nonatomic,assign)  NSInteger         answerType;
@property (nonatomic,copy)  NSString    *answerLabel;
@property (nonatomic,copy)  NSArray    *answerArray;
@property (nonatomic,assign)  BOOL        operatorHint;
@property (nonatomic,copy)  NSString    *operatorHintDesc;

@property (nonatomic,assign) BOOL isOneQuestionRelevant;
@property (nonatomic,assign) YSFEvaluationSelectionType evaluation;
@property (nonatomic, strong, readonly) NSMutableArray<NSString *> *imageUrlStringArray;
@property (nonatomic,assign)  BOOL    shouldShow;

+ (instancetype)objectByDict:(NSDictionary *)dict;

@end
