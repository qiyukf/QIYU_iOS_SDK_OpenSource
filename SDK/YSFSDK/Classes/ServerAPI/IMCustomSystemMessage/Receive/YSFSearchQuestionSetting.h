#import "YSFIMCustomSystemMessageApi.h"

@interface YSFSearchQuestionSetting : NSObject

@property (nonatomic,assign)    BOOL switchOpen;
@property (nonatomic,assign)    long long sessionId;
@property (nonatomic,assign)    double sendingRate;

+ (instancetype)sharedInstance:(NSString *)shopId;

- (void)dataByJson:(NSDictionary *)dict;
- (void)clear;

@end
