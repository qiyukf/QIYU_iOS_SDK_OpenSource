#import "QYCustomActionConfig.h"

/**
 *  是否退出排队回调
 */
typedef void (^QYShowQuitBlock)(QYQuitWaitingBlock block);

@interface QYCustomActionConfig(Private)

@property (nonatomic, copy) QYShowQuitBlock showQuitBlock;

@end
