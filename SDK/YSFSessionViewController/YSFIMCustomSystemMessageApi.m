//
//  YSFIMApi.m
//  YSFSDK
//
//  Created by amao on 8/26/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "YSFIMCustomSystemMessageApi.h"


@implementation YSFIMCustomSystemMessageApi

+ (void)sendMessage:(id<YSFIMCustomSystemMessageApiProtocol>)api completion:(YSFIMApiBlock)block
{
    [self sendMessage:api shopId:@"-1" completion:block];
}

+ (void)sendMessage:(id<YSFIMCustomSystemMessageApiProtocol>)api shopId:(NSString *)shopId
     completion:(YSFIMApiBlock)block
{
    NSDictionary *dict = [api toDict];
    YSF_NIMSession *session = [YSF_NIMSession session:shopId type:YSF_NIMSessionTypeYSF];

    NIMLogApp(@"YSFIMApi request %@ for %@",dict,session);
    
    
    NSString *content = nil;
    if (dict)
    {
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict
                                               options:0
                                                 error:nil];
        if (data)
        {
            content = [[NSString alloc] initWithData:data
                                            encoding:NSUTF8StringEncoding];
        }
    }
    
    if (content) {

        YSF_NIMCustomSystemNotification *notification = [[YSF_NIMCustomSystemNotification alloc] initWithContent:content];
        notification.sendToOnlineUsersOnly = YES;
        
        if ([api respondsToSelector:@selector(apnContent)]) {
            NSString *apnsContent = [notification apnsContent];
            notification.apnsContent = apnsContent;
        }
        
        
        [[[YSF_NIMSDK sharedSDK] systemNotificationManager] sendCustomNotification:notification
                                                                     toSession:session
                                                                    completion:^(NSError *error) {
                                                                        if (error) {
                                                                            NIMLogApp(@"YSFIMApi request failed: %@",error);
                                                                        }
                                                                        if (block) {
                                                                            block(error);
                                                                        }
                                                                    }];
        
    }
    else
    {
        if (block) {
            block([NSError errorWithDomain:YSFErrorDomain
                                      code:YSFCodeInvalidData
                                  userInfo:nil]);
        }
    }
}
@end
