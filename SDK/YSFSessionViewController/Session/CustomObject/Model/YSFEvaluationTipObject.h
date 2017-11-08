//
//  YSFEvaluationTipObject.h
//  YSFSDK
//
//  Created by towik on 1/24/16.
//  Copyright (c) 2016 Netease. All rights reserved.
//


@interface YSFEvaluationTipObject : NSObject<YSF_NIMCustomAttachment>
@property (nonatomic,assign)    NSInteger   command;
@property (nonatomic,copy)      NSString    *tipContent;
@property (nonatomic,copy)      NSString    *tipResult;
@property (nonatomic,copy)      NSString    *kaolaTipContent;

+ (YSFEvaluationTipObject *)objectByDict:(NSDictionary *)dict;
@end
