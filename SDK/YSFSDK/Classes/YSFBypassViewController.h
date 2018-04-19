#import "YSFKFBypassNotification.h"

typedef void (^ByPassCallback)(BOOL done, NSDictionary *byPassDict);



@interface YSFBypassViewController : UIViewController

- (instancetype)initWithByPassNotificatioin:(YSFKFBypassNotification *)bypassNotification
                         callback:(ByPassCallback)callback;

@end
