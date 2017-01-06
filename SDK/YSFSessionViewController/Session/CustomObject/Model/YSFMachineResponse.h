//
//  YSFCloseService.h
//  YSFSDK
//
//  Created by amao on 9/7/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//


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

+ (instancetype)objectByDict:(NSDictionary *)dict;

@end
