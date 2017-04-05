#import "YSFIMCustomSystemMessageApi.h"
#import "YSFAction.h"

@interface YSFActivePage : NSObject<YSF_NIMCustomAttachment>

@property (nonatomic,copy)    NSString *img;
@property (nonatomic,copy)    NSString *content;
@property (nonatomic,strong)    YSFAction *action;

+ (instancetype)objectByDict:(NSDictionary *)dict;

@end
