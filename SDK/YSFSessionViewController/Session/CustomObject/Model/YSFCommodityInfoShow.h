#import "YSFCustomAttachment.h"

/**
 *  自定义商品信息按钮信息
 */
@class QYCommodityTag;

@interface YSFCommodityInfoShow : NSObject<YSFCustomAttachment>

//命令
@property (nonatomic, assign) NSInteger command;
//标题
@property (nonatomic, copy) NSString *title;
//摘要
@property (nonatomic, copy) NSString *desc;
//图片文件链接
@property (nonatomic, copy) NSString *pictureUrlString;
//跳转链接
@property (nonatomic, copy) NSString *urlString;
//支付金额
@property (nonatomic, copy) NSString *payMoney;
//价格
@property (nonatomic, copy) NSString *price;
//订单数量
@property (nonatomic, copy) NSString *orderCount;
//备注
@property (nonatomic, copy) NSString *note;
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
@property (nonatomic, copy) NSString *ext;
//发送时是否显示
@property (nonatomic, assign) BOOL show;
//是否作为自动发送消息，NO为否，YES为是，默认为自动发送消息
@property (nonatomic, assign) BOOL bAuto;
@property (nonatomic, copy) NSArray<QYCommodityTag *> *tagsArray;
@property (nonatomic, copy) NSString *tagsString;

+ (YSFCommodityInfoShow *)objectByDict:(NSDictionary *)dict;


@end
