#import "YSFIMCustomSystemMessageApi.h"

@interface YSFSystemConfig : NSObject

@property (nonatomic, assign) BOOL switchOpen;
@property (nonatomic, assign) CGFloat sendingRate;

+ (instancetype)sharedInstance;
+ (instancetype)sharedInstance:(NSString *)shopId;
- (instancetype)setNewConfig:(NSDictionary *)dict;

@end
