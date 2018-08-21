
#import "QYCommodityInfo.h"



@interface QYCommodityInfo() <YSF_NIMCustomAttachment>

//支付金额
@property (nonatomic, copy) NSString *payMoney;
//价格
@property (nonatomic, copy) NSString *price;
//订单数量
@property (nonatomic, copy) NSString *orderCount;
//订单sku
@property (nonatomic, copy) NSString *orderSku;
//订单状态
@property (nonatomic, copy) NSString *orderStatus;
//订单编号
@property (nonatomic, copy) NSString *orderId;
//下单时间
@property (nonatomic, copy) NSString *orderTime;
//活动描述
@property (nonatomic, copy) NSString *activity;
//活动链接
@property (nonatomic, copy) NSString *activityHref;
@property (nonatomic, assign) BOOL bAuto;

//对title,desc,note有字数限制要求
- (void)checkCommodityInfoValid;
- (NSDictionary *)encodeAttachment;
+ (QYCommodityInfo *)objectByDict:(NSDictionary *)dict;

@end
