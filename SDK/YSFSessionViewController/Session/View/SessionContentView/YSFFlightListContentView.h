#import "YSFSessionMessageContentView.h"
#import "YSFFlightList.h"
#import "YSFOrderListContentView.h"


@interface YSFFlightItem(YSF)

- (YSFCellView *)createCell:(CGFloat)width eventHander:(id)eventHander;

@end


@interface YSFFlightListContentView : YSFSessionMessageContentView


@end
