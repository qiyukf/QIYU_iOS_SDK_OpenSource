#import <UIKit/UIKit.h>
#import "YSFOrderList.h"
#import "YSFFlightList.h"

typedef BOOL (^TapItemCallback)(id itemData);

@interface YSFMoreOrderListViewController : UIViewController

@property (nonatomic, assign) BOOL showTop;
@property (nonatomic, strong) YSFAction *action;
@property (nonatomic, copy) NSString *titleString;
@property (nonatomic, copy) NSArray *originalData;
@property (nonatomic, copy) TapItemCallback tapItemCallback;


@end
