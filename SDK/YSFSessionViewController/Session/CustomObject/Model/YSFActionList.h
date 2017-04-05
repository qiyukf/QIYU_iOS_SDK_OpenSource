#import "YSFIMCustomSystemMessageApi.h"
#import "YSFAction.h"


@interface YSFActionList : NSObject<YSF_NIMCustomAttachment>

@property (nonatomic,copy)    NSString *label;
@property (nonatomic,strong)  NSArray<YSFAction *> *actionArray;

+ (instancetype)objectByDict:(NSDictionary *)dict;

@end
