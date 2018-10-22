#import "YSFIMCustomSystemMessageApi.h"
#import "YSFAction.h"

@interface YSFBotText : NSObject <YSF_NIMCustomAttachment>

@property (nonatomic,copy)NSString *text;

+ (instancetype)objectByDict:(NSDictionary *)dict;

@end
