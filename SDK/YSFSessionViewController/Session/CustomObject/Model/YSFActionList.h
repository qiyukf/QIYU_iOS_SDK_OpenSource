#import "YSFIMCustomSystemMessageApi.h"
#import "YSFAction.h"
#import "YSFCustomAttachment.h"


@interface YSFActionList : NSObject<YSFCustomAttachment>

@property (nonatomic,copy)    NSString *label;
@property (nonatomic,strong)  NSArray<YSFAction *> *actionArray;

+ (instancetype)objectByDict:(NSDictionary *)dict;

@end
