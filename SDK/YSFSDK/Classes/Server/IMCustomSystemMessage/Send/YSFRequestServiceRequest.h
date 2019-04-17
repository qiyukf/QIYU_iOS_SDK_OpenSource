//
//  YSFCustomServiceRequest.h
//  YSFSDK
//
//  Created by amao on 8/26/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "YSFIMCustomSystemMessageApi.h"

@class QYSource;

@interface YSFRequestServiceRequest : NSObject<YSFIMCustomSystemMessageApiProtocol>

@property (nonatomic,assign)        BOOL        onlyManual;
@property (nonatomic,strong)        QYSource    *source;
@property (nonatomic,assign)        long long   staffId;
@property (nonatomic,assign)        long long   groupId;
@property (nonatomic,assign)        long long   robotId;
@property (nonatomic,assign)        long long   entryId;
@property (nonatomic,assign)        long long commonQuestionTemplateId;
@property (nonatomic,assign)        BOOL   openRobotInShuntMode;
@property (nonatomic,assign)        NSInteger   vipLevel;

@end
