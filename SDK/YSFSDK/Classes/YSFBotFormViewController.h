#import <UIKit/UIKit.h>
#import "YSFBotForm.h"
#import "YSFSubmittedBotForm.h"

typedef void (^SubmitCallback)(BOOL submitted, YSFSubmittedBotForm *botForm);

@interface YSFBotFormViewController : UIViewController

@property (nonatomic, strong) YSFBotForm *botForm;
@property (nonatomic, copy) SubmitCallback submitCallback;


@end
