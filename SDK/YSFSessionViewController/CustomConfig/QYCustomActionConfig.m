#import "QYCustomActionConfig+Private.h"


@interface QYCustomActionConfig()

@property (nonatomic, copy) QYShowQuitBlock showQuitBlock;

@end


@implementation QYCustomActionConfig

+ (instancetype)sharedInstance
{
    static QYCustomActionConfig *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[QYCustomActionConfig alloc] init];
    });
    return instance;
}

- (void)setDeactivateAudioSessionAfterComplete:(BOOL)deactivate
{
    [[[YSF_NIMSDK sharedSDK] mediaManager] setDeactivateAudioSessionAfterComplete:deactivate];
}

- (void)showQuitWaiting:(QYQuitWaitingBlock)quitWaitingBlock;
{
    if (_showQuitBlock) {
        _showQuitBlock(quitWaitingBlock);
    }
}

@end
