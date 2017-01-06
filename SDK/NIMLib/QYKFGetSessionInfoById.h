#import <Foundation/Foundation.h>


typedef int64_t (^QYKFGetSessionIdByYxIdCallback)(NSString *fromYxId);


@interface QYKFGetSessionInfoById : NSObject

+ (instancetype) sharedInstance;

- (void)registerByYxIdCallback:(QYKFGetSessionIdByYxIdCallback)cb;

- (int64_t)GetSessionIdByYxId:(NSString *)yxId;

@end
