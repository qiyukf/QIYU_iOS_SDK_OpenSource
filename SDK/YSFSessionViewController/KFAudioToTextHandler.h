
@interface KFAudioToTextHandler : NSObject

+ (instancetype)sharedInstance;

- (BOOL)audioInTransfering:(NSString *)messageId;
- (void)addMessage:(NSString *)from messageId:(NSString *)messageId;
- (void)removeMessage:(NSString *)messageId;

@end
