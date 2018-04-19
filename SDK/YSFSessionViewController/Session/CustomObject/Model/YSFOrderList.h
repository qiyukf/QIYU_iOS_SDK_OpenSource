#import "YSFIMCustomSystemMessageApi.h"
#import "YSFAction.h"
#import "YSFCustomAttachment.h"

@interface YSFGoods : NSObject

@property (nonatomic,copy)    NSString *p_status;
@property (nonatomic,copy)    NSString *p_img;
@property (nonatomic,copy)    NSString *p_name;
@property (nonatomic,copy)    NSString *params;
@property (nonatomic,copy)    NSString *p_price;
@property (nonatomic,copy)    NSString *p_count;
@property (nonatomic,copy)    NSString *p_stock;
@property (nonatomic,copy)    NSString *target;

- (NSDictionary *)encodeAttachment;
+ (instancetype)objectByDict:(NSDictionary *)dict;

@end


@interface YSFShop : NSObject

@property (nonatomic,copy)    NSString *s_status;
@property (nonatomic,copy)    NSString *s_name;
@property (nonatomic,copy)    NSArray *goods;

+ (instancetype)objectByDict:(NSDictionary *)dict;

@end


@interface YSFOrderList : NSObject<YSFCustomAttachment>

@property (nonatomic,copy)    NSString *label;
@property (nonatomic,strong)  YSFAction* action;
@property (nonatomic,copy)    NSArray *shops;

+ (instancetype)objectByDict:(NSDictionary *)dict;

@end
