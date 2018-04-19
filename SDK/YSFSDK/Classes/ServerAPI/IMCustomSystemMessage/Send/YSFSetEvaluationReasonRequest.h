//
//  YSFSetEvaluationReasonRequest.h
//  YSFSDK
//
//  Created by Jacky Yu on 2018/3/2.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import "YSFIMCustomSystemMessageApi.h"

@interface YSFSetEvaluationReasonRequest : YSFIMCustomSystemMessageApi<YSFIMCustomSystemMessageApiProtocol>

@property (nonatomic, copy) NSString *msgId;
@property (nonatomic, copy) NSString *evaluationContent;

@end
