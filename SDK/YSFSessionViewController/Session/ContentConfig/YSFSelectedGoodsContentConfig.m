#import "YSFSelectedGoodsContentConfig.h"
#import "YSFMessageModel.h"
#import "YSFMachineResponse.h"
#import "QYCustomUIConfig.h"
#import "YSFApiDefines.h"
#import "YSFSelectedGoods.h"


@implementation YSFSelectedGoodsContentConfig
- (CGSize)contentSize:(CGFloat)cellWidth
{
    CGFloat msgBubbleMaxWidth    = (cellWidth - 112);
    CGFloat msgContentMaxWidth = msgBubbleMaxWidth - self.contentViewInsets.left - self.contentViewInsets.right;
    CGFloat height = 80;
    YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)self.message.messageObject;
    YSFSelectedCommodityInfo *selectedGoods = (YSFSelectedCommodityInfo *)object.attachment;
    if (selectedGoods.goods.p_action.length > 0) {
        height += 36;
    }
    return CGSizeMake(msgContentMaxWidth, height);}

- (NSString *)cellContent
{
    return @"YSFSelectedGoodsContentView";
}

- (UIEdgeInsets)contentViewInsets
{
    return self.message.isOutgoingMsg ? UIEdgeInsetsMake(0,0,0,18) : UIEdgeInsetsMake(0,18,0,0);
}


@end
