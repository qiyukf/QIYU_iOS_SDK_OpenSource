//
//  YSFCustomMessageAttachment.m
//  YSFSessionViewController
//
//  Created by liaosipei on 2018/11/23.
//  Copyright © 2018 Netease. All rights reserved.
//

#import "YSFCustomMessageAttachment.h"
#import "YSFApiDefines.h"
#import "YSFCustomAttachment.h"
#import "QYCustomMessage.h"
#import "QYCustomMessage_Private.h"
#import "YSFCustomMessageManager.h"

@implementation YSFCustomMessageAttachment

- (NSString *)thumbText {
    if (self.message && [self.message respondsToSelector:@selector(thumbText)]) {
        return YSFStrParam([self.message thumbText]);
    }
    return @"[自定义消息]";
}

- (id<YSFSessionContentConfig>)contentConfig {
    return nil;
}

- (NSDictionary *)encodeAttachment {
    if (self.message) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:YSFStrParam(NSStringFromClass([self.message class])) forKey:YSFApiKeyCustomMessageClass];
        [dict setValue:@(YSFCommandCustomMessage) forKey:YSFApiKeyCmd];
        if (self.message.messageId) {
            [dict setValue:self.message.messageId forKey:YSFApiKeyCustomMessageID];
        }
        [dict setValue:@(self.message.sourceType) forKey:YSFApiKeyCustomMessageSourceType];
        if ([self.message respondsToSelector:@selector(encodeMessage)]) {
            NSDictionary *data = [self.message encodeMessage];
            if (data) {
                [dict setValue:data forKey:YSFApiKeyCustomMessageData];
            }
        }
        return dict;
    }
    return nil;
}

+ (instancetype)objectByDict:(NSDictionary *)dict {
    QYCustomMessage *message = nil;
    NSString *clsName = [dict ysf_jsonString:YSFApiKeyCustomMessageClass];
    if (clsName.length) {
        Class cls = NSClassFromString(clsName);
        if (cls) {
            message = [[cls alloc] init];
            if ([message respondsToSelector:@selector(decodeMessage:)]) {
                [message decodeMessage:[dict ysf_jsonDict:YSFApiKeyCustomMessageData]];
            }
            message.messageId = YSFStrParam([dict ysf_jsonString:YSFApiKeyCustomMessageID]);
            message.sourceType = [dict ysf_jsonInteger:YSFApiKeyCustomMessageSourceType];
        }
    }
    
    YSFCustomMessageAttachment *attachment = [[YSFCustomMessageAttachment alloc] init];
    attachment.message = message;
    return attachment;
}

@end
