#import "YSFSelectedGoodsContentConfig.h"
#import "YSFMessageModel.h"
#import "YSFMachineResponse.h"
#import "QYCustomUIConfig.h"
#import "YSFAttributedLabel.h"
#import "YSFApiDefines.h"


@implementation YSFSelectedGoodsContentConfig
- (CGSize)contentSize:(CGFloat)cellWidth
{
    CGFloat msgBubbleMaxWidth    = (cellWidth - 112);
    CGFloat msgContentMaxWidth = msgBubbleMaxWidth - self.contentViewInsets.left - self.contentViewInsets.right;
    return CGSizeMake(msgContentMaxWidth, 80);}

- (NSString *)cellContent
{
    return @"YSFSelectedGoodsContentView";
}

- (UIEdgeInsets)contentViewInsets
{
    return self.message.isOutgoingMsg ? UIEdgeInsetsMake(0,0,0,18) : UIEdgeInsetsMake(0,18,0,0);
}


@end
