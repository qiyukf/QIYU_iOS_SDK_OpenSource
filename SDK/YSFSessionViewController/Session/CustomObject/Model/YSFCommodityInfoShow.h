#import "YSFCustomAttachment.h"
#import "QYCommodityInfo.h"


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
//备注
@property (nonatomic, copy) NSString *note;
@property (nonatomic, copy) NSString *ext;
//发送时是否显示
@property (nonatomic, assign) BOOL show;
//是否作为自动发送消息，NO为否，YES为是，默认为自动发送消息
@property (nonatomic, assign) BOOL bAuto;
@property (nonatomic, copy) NSArray<QYCommodityTag *> *tagsArray;
@property (nonatomic, copy) NSString *tagsString;

+ (YSFCommodityInfoShow *)objectByDict:(NSDictionary *)dict;


@end
