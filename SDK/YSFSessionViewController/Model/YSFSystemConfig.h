#import "YSFIMCustomSystemMessageApi.h"

@interface YSFSystemConfig : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic,assign)      BOOL switchOpen;
@property (nonatomic,assign)      CGFloat sendingRate;

- (instancetype)setNewConfig:(NSDictionary *)dict;

@end
