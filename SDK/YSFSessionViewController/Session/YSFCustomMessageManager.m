//
//  YSFCustomMessageManager.m
//  YSFSessionViewController
//
//  Created by liaosipei on 2018/11/27.
//  Copyright © 2018 Netease. All rights reserved.
//

#import "YSFCustomMessageManager.h"
#import "QYCustomMessage.h"
#import "QYCustomModel.h"
#import "QYCustomModel_Private.h"
#import "YSFCustomMessageAttachment.h"

#define YSFCustomMessageKeyMessageClass     @"ysf_custom_message_class"
#define YSFCustomMessageKeyModelClass       @"ysf_custom_model_class"
#define YSFCustomMessageKeyContentClass     @"ysf_custom_content_class"


@interface YSFCustomMessageManager ()

@property (nonatomic, strong) NSMutableDictionary *dictionary;

@end


@implementation YSFCustomMessageManager
+ (instancetype)sharedManager {
    static YSFCustomMessageManager *messageManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        messageManager = [[YSFCustomMessageManager alloc] init];
    });
    return messageManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _dictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)cleanCache {
    if (_dictionary.count) {
        [_dictionary removeAllObjects];
    }
}

- (void)registerCustomMessageClass:(Class)messageClass
                        modelClass:(Class)modelClass
                  contentViewClass:(Class)contentViewClass {
    if (!messageClass || !modelClass || !contentViewClass) {
        return;
    }
    NSString *messageClassStr = YSFStrParam(NSStringFromClass(messageClass));
    NSString *modelClassStr = YSFStrParam(NSStringFromClass(modelClass));
    NSString *contentClassStr = YSFStrParam(NSStringFromClass(contentViewClass));
    NSDictionary *dict = @{
                           YSFCustomMessageKeyModelClass : modelClassStr,
                           YSFCustomMessageKeyContentClass : contentClassStr,
                           };
    if (_dictionary) {
        [_dictionary setValue:dict forKey:messageClassStr];
    } else {
        _dictionary = [NSMutableDictionary dictionaryWithObject:dict forKey:messageClassStr];
    }
}

- (NSString *)modelClassNameForMessageClass:(Class)messageClass {
    if (!_dictionary || _dictionary.count == 0 || !messageClass) {
        return nil;
    }
    NSString *messageClassStr = NSStringFromClass(messageClass);
    id object = [_dictionary objectForKey:messageClassStr];
    if ([object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary *)object;
        return [dict objectForKey:YSFCustomMessageKeyModelClass];
    }
    return nil;
}

- (NSString *)contentClassNameForMessageClass:(Class)messageClass {
    if (!_dictionary || _dictionary.count == 0 || !messageClass) {
        return nil;
    }
    NSString *messageClassStr = NSStringFromClass(messageClass);
    id object = [_dictionary objectForKey:messageClassStr];
    if ([object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary *)object;
        return [dict objectForKey:YSFCustomMessageKeyContentClass];
    }
    return nil;
}

- (BOOL)isCustomMessage:(YSF_NIMMessage *)message {
    if (message.messageType == YSF_NIMMessageTypeCustom
        && [message.messageObject isKindOfClass:[YSF_NIMCustomObject class]]) {
        YSF_NIMCustomObject *customObj = (YSF_NIMCustomObject *)message.messageObject;
        if ([customObj.attachment isKindOfClass:[YSFCustomMessageAttachment class]]) {
            YSFCustomMessageAttachment *attachment = (YSFCustomMessageAttachment *)customObj.attachment;
            if ([attachment.message isKindOfClass:[QYCustomMessage class]]) {
                return YES;
            }
        }
    }
    return NO;
}

- (NSString *)modelClassNameForYSFMessage:(YSF_NIMMessage *)message {
    if (message.messageType == YSF_NIMMessageTypeCustom
        && [message.messageObject isKindOfClass:[YSF_NIMCustomObject class]]) {
        YSF_NIMCustomObject *customObj = (YSF_NIMCustomObject *)message.messageObject;
        if ([customObj.attachment isKindOfClass:[YSFCustomMessageAttachment class]]) {
            YSFCustomMessageAttachment *attachment = (YSFCustomMessageAttachment *)customObj.attachment;
            if ([attachment.message isKindOfClass:[QYCustomMessage class]]) {
                return [self modelClassNameForMessageClass:[attachment.message class]];
            }
        }
    }
    return nil;
}

- (QYCustomModel *)makeModelForYSFMessage:(YSF_NIMMessage *)message {
    if ([self isCustomMessage:message]) {
        NSString *cls = [self modelClassNameForYSFMessage:message];
        if (cls.length) {
            Class modelCls = NSClassFromString(cls);
            if (modelCls) {
                QYCustomModel *model = [[modelCls alloc] init];
                if ([model isKindOfClass:[QYCustomModel class]]) {
                    model.ysfMessage = message;
                    return model;
                }
            }
        }
    }
    return nil;
}

@end
