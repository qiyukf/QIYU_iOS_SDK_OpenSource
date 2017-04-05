#import <UIKit/UIKit.h>
#import "YSFOrderList.h"

typedef void (^TapGoodsCallback)(YSFGoods *good);

@interface YSFMoreOrderListViewController : UIViewController

@property (nonatomic, strong) YSFOrderList *orderList;
@property (nonatomic, copy) TapGoodsCallback tapGoodsCallback;


@end
