#import "QYCustomActionConfig.h"

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

- (void)showQuitWaiting:(QYShowQuitWaitingBlock)showQuitWaitingBlock;
{
    if (_showQuitBlock) {
        _showQuitBlock(showQuitWaitingBlock);
    }
}

@end
