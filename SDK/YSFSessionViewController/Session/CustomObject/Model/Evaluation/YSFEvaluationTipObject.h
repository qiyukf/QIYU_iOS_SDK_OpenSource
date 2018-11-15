//
//  YSFEvaluationTipObject.h
//  YSFSDK
//
//  Created by towik on 1/24/16.
//  Copyright (c) 2016 Netease. All rights reserved.
//


@interface YSFEvaluationTipObject : NSObject <YSF_NIMCustomAttachment>

@property (nonatomic, assign) NSInteger command;
@property (nonatomic, assign) long long sessionId;
@property (nonatomic, copy) NSString *tipContent;
@property (nonatomic, copy) NSString *tipResult;
@property (nonatomic, copy) NSString *tipModify;
@property (nonatomic, copy) NSString *specialThanksTip;

+ (instancetype)objectByDict:(NSDictionary *)dict;

@end
