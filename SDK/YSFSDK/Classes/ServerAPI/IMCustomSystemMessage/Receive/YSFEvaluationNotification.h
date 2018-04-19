#import "YSFIMCustomSystemMessageApi.h"
#import "YSFOrderList.h"

@interface YSFEvaluationNotification : NSObject

@property (nonatomic,assign)    long long sessionId;
@property (nonatomic,assign)    BOOL evaluationAutoPopup;

+ (instancetype)dataByJson:(NSDictionary *)dict;

@end
