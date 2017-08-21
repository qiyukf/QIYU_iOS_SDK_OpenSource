#import "YSFIMCustomSystemMessageApi.h"
#import "YSFOrderList.h"

@interface YSFEvaluationNotification : NSObject

@property (nonatomic,assign)    long long sessionId;

+ (instancetype)dataByJson:(NSDictionary *)dict;

@end
