#import "YSFSessionMessageContentView.h"
#import "YSFOrderList.h"

@interface YSFShop(YSF)

- (UIView *)createCell:(CGFloat)width eventHander:(id)eventHander;

@end

@interface YSFCellView : UIButton

@property (nonatomic, strong) id itemData;

@end


@interface YSFOrderListContentView : YSFSessionMessageContentView


@end
