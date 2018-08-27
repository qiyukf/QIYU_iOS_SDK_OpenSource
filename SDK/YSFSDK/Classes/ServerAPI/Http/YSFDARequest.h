

#import "YSFHttpApi.h"

static NSString * const YSFDARequestTitleKey = @"title";
static NSString * const YSFDARequestTimeKey = @"time";
static NSString * const YSFDARequestKeyKey = @"key";
static NSString * const YSFDARequestTypeKey = @"type";
static NSString * const YSFDARequestEnterOrOutKey = @"enterOrOut";
static NSString * const YSFDARequestDescriptionKey = @"description";

@interface YSFDARequest : NSObject<YSFApiProtocol>

@property (nonatomic, copy) NSArray *array;

@end
