#import "YSFIMCustomSystemMessageApi.h"

@interface YSFSessionStatusResponse : NSObject

@property (nonatomic,copy)    NSDictionary *shopSessionStatus;
+ (instancetype)dataByJson:(NSDictionary *)dict;


@end
