#import "NIMSDK.h"

typedef void (^SendingImageConfirmedCallback)(BOOL shouldSend);

@interface YSFTransAudioToTextLoadingViewController : UIViewController

- (instancetype)initWithAudioToTextOption:(YSF_NIMMessage *)message;
@property (nonatomic, copy) SendingImageConfirmedCallback sendingImageConfirmedCallback;


@end




