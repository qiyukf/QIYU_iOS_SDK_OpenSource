//
//  QYCustomMessage.m
//  YSFSDK
//
//  Created by liaosipei on 2018/11/22.
//  Copyright © 2018 Netease. All rights reserved.
//

#import "QYCustomMessage.h"
#import "QYCustomMessage_Private.h"

@implementation QYCustomMessage

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[QYCustomMessage class]]) {
        return NO;
    }
    QYCustomMessage *message = object;
    return [message.messageId isEqualToString:self.messageId];
}

#pragma mark - QYCustomMessageCoding
- (NSString *)thumbText {
    return @"[自定义消息]";
}

- (NSDictionary *)encodeMessage {
    return nil;
}

- (void)decodeMessage:(NSDictionary *)content {
    
}

- (QYCustomMessageSourceType)messageSourceType {
    return QYCustomMessageSourceTypeNone;
}

@end
