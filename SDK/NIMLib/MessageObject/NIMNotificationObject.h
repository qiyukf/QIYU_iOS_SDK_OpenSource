//
//  YSF_NIMNotificationObject.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMMessageObjectProtocol.h"
#import "NIMNotificationContent.h"

//#import "NIMNetCallManagerProtocol.h"
//#import "NIMTeamNotificationContent.h"
//#import "NIMNetCallNotificationContent.h"


/**
 *  通知对象
 */
@interface YSF_NIMNotificationObject : NSObject<YSF_NIMMessageObject>
/**
 *  通知内容
 */
@property (nonatomic,strong,readonly)    YSF_NIMNotificationContent  *content;

/**
 *  通知类型
 */
@property (nonatomic,assign,readonly) YSF_NIMNotificationType notificationType;

@end

