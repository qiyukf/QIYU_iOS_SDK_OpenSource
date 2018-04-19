#import "YSFIMCustomSystemMessageApi.h"
#import "YSFAction.h"
#import "YSFCustomAttachment.h"



@interface YSFOrderStatus : NSObject<YSFCustomAttachment>

@property (nonatomic,copy)    NSString *label;
@property (nonatomic,copy)    NSString *params;
@property (nonatomic,copy)    NSString *title;
@property (nonatomic,copy)    NSArray *logistic;
@property (nonatomic,strong)  NSArray *actionArray;

+ (instancetype)objectByDict:(NSDictionary *)dict;

@end
