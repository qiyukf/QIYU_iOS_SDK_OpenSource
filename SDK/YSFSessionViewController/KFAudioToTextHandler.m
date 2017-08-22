
#import "KFAudioToTextHandler.h"
#import "NSDictionary+YSFJson.h"
#import "YSFApiDefines.h"


@interface KFAudioToTextHandler() <YSF_NIMSystemNotificationManagerDelegate, YSF_NIMChatManagerDelegate>

@property (nonatomic,strong) NSMutableDictionary *cacheAudioText;
@property (nonatomic,strong) NSMutableDictionary *cacheTransferingAudio;

@end

@implementation KFAudioToTextHandler

+ (instancetype)sharedInstance
{
    static KFAudioToTextHandler *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[KFAudioToTextHandler alloc] init];
    });
    return instance;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        _cacheAudioText = [NSMutableDictionary new];
        _cacheTransferingAudio = [NSMutableDictionary new];
        [[[YSF_NIMSDK sharedSDK] systemNotificationManager] addDelegate:self];
        [[[YSF_NIMSDK sharedSDK] chatManager] addDelegate:self];

    }
    return self;
}


-(void)dealloc{
    [[[YSF_NIMSDK sharedSDK] systemNotificationManager] removeDelegate:self];
    [[[YSF_NIMSDK sharedSDK] chatManager] removeDelegate:self];
}

- (BOOL)audioInTransfering:(NSString *)messageId
{
    return [_cacheTransferingAudio objectForKey:messageId] != nil;
}

- (void)addMessage:(NSString *)from messageId:(NSString *)messageId
{
    [_cacheTransferingAudio setObject:from forKey:messageId];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(120 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *from = [_cacheTransferingAudio objectForKey:messageId];
        //如果超时，则更新为失败
        if (messageId) {
            [self removeMessage:messageId];
            YSF_NIMSession *session = [YSF_NIMSession session:from type:YSF_NIMSessionTypeYSF];
            YSF_QYKFMessage * message = (YSF_QYKFMessage *)[[[YSF_NIMSDK sharedSDK] conversationManager] queryMessage:messageId forSession:session];
            [[[YSF_NIMSDK sharedSDK] conversationManager] updateMessage:YES message:message forSession:session completion:nil];
        }
    });
}

- (void)removeMessage:(NSString *)messageId
{
    [_cacheTransferingAudio removeObjectForKey:messageId];
}

//接收消息
- (void)onRecvMessages:(NSArray *)messages
{
    if ([[YSF_NIMSDK sharedSDK] sdkOrKf]) {
        return;
    }
    
    for (YSF_QYKFMessage *message in messages) {
        if (message.messageType == YSF_NIMMessageTypeAudio) {
            [_cacheTransferingAudio setObject:message.from forKey:message.messageId];
            
            NSDictionary *dic = [_cacheAudioText objectForKey:message.messageId];
            if (dic) {
                NSString *text = [dic ysf_jsonString:YSFApiKeyText];
                NSString *yxId = [dic ysf_jsonString:YSFApiKeyFromImId];
                NSInteger type = [dic ysf_jsonInteger:YSFApiKeyType];
                if (type == 0) {
                    message.isPlayed = YES;
                    message.ext = [NSString stringWithFormat:@"{\"%@\":\"%@\"}", YSFApiKeyContent, text];
                }
                else {
                    message.ext = @"";
                }
                YSF_NIMSession *session = [YSF_NIMSession session:yxId type:YSF_NIMSessionTypeYSF];
                message.ext = [NSString stringWithFormat:@"{\"%@\":\"%@\"}", YSFApiKeyContent, text];
                [[[YSF_NIMSDK sharedSDK] conversationManager] updateMessage:YES message:message forSession:session completion:nil];
                
                [_cacheAudioText removeObjectForKey:message.messageId];
            }
            else {
                [[KFAudioToTextHandler sharedInstance] addMessage:message.from messageId:message.messageId];
            }
        }
    }
}

- (void)onReceiveCustomSystemNotification:(YSF_NIMCustomSystemNotification *)notification
{
    if ([[YSF_NIMSDK sharedSDK] sdkOrKf]) {
        return;
    }
    
    NSString* jsonStr = notification.content;
    NSDictionary* dic = [jsonStr ysf_toDict];
    if (jsonStr) {
        NSInteger cmd = [dic ysf_jsonInteger:YSFApiKeyCmd];
        switch (cmd) {
                
            case YSFCommandAudioToText:
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.9 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    NSString *msgId = [dic ysf_jsonString:YSFApiKeyMsgId];
                    NSString *text = [dic ysf_jsonString:YSFApiKeyText];
                    NSString *yxId = [dic ysf_jsonString:YSFApiKeyFromImId];
                    NSInteger type = [dic ysf_jsonInteger:YSFApiKeyType];
                    [_cacheTransferingAudio removeObjectForKey:msgId];
                    
                    if (msgId) {
                        YSF_NIMSession *session = [YSF_NIMSession session:yxId type:YSF_NIMSessionTypeYSF];
                        YSF_QYKFMessage * message = (YSF_QYKFMessage *)[[[YSF_NIMSDK sharedSDK] conversationManager] queryMessage:msgId forSession:session];
                        if (message && message.messageType == YSF_NIMMessageTypeAudio) {
                            if (type == 0) {
                                message.isPlayed = YES;
                                message.ext = [NSString stringWithFormat:@"{\"%@\":\"%@\"}", YSFApiKeyContent, text];
                            }
                            else {
                                message.ext = @"";
                            }
                            [[[YSF_NIMSDK sharedSDK] conversationManager] updateMessage:NO message:message forSession:session completion:nil];
                        }
                        else {
                            [_cacheAudioText setObject:dic forKey:msgId];
                        }
                    }
                    else {
                        //assert(false);
                    }

                });
            }
                break;
        }
    }
}

@end
