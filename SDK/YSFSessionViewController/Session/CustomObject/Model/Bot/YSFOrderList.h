#import "YSFIMCustomSystemMessageApi.h"
#import "YSFAction.h"
#import "YSFCustomAttachment.h"
#import "QYSessionViewController.h"

@interface QYSelectedCommodityInfo()

- (NSDictionary *)encodeAttachment;
+ (instancetype)objectByDict:(NSDictionary *)dict;

@end


@interface YSFShop : NSObject

@property (nonatomic,copy)    NSString *s_status;
@property (nonatomic,copy)    NSString *s_name;
@property (nonatomic,copy)    NSArray *goods;

+ (instancetype)objectByDict:(NSDictionary *)dict;

@end


@interface YSFOrderList : NSObject <YSFCustomAttachment>

@property (nonatomic,copy)    NSString *label;
@property (nonatomic,strong)  YSFAction* action;
@property (nonatomic,copy)    NSArray *shops;

+ (instancetype)objectByDict:(NSDictionary *)dict;

@end
