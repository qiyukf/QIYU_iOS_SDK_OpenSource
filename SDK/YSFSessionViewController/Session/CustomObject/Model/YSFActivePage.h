#import "YSFIMCustomSystemMessageApi.h"
#import "YSFAction.h"
#import "YSFCustomAttachment.h"

@interface YSFActivePage : NSObject<YSFCustomAttachment>

@property (nonatomic,copy)    NSString *img;
@property (nonatomic,copy)    NSString *content;
@property (nonatomic,strong)    YSFAction *action;

+ (instancetype)objectByDict:(NSDictionary *)dict;

@end
