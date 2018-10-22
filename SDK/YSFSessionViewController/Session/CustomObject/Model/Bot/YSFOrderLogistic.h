#import "YSFIMCustomSystemMessageApi.h"
#import "YSFAction.h"
#import "YSFCustomAttachment.h"


@interface YSFOrderLogisticNode : NSObject

@property (nonatomic,copy)    NSString *logistic;
@property (nonatomic,copy)    NSString *timestamp;

@end



@interface YSFOrderLogistic : NSObject <YSFCustomAttachment>

@property (nonatomic,copy)    NSString *label;
@property (nonatomic,copy)    NSString *title;
@property (nonatomic,copy)    NSArray *logistic;
@property (nonatomic,strong)  YSFAction *action;
@property (nonatomic,assign)  BOOL fullLogistic;

+ (instancetype)objectByDict:(NSDictionary *)dict;

@end
