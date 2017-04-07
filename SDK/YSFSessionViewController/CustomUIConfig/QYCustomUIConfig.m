#import "QYCustomUIConfig.h"

@implementation QYCustomUIConfig

+ (instancetype)sharedInstance
{
    static QYCustomUIConfig *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[QYCustomUIConfig alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self restoreToDefault];
    }
    return self;
}

- (void)restoreToDefault
{
    _sdkOrKf = YES;
    _sessionTipTextColor = YSFRGBA2(0xffc08722);
    _sessionTipTextFontSize = 14;
    _customMessageTextColor = [UIColor whiteColor];
    _customMessageHyperLinkColor = [UIColor whiteColor];
    _customMessageTextFontSize = 16;
    _serviceMessageTextColor = [UIColor blackColor];
    _serviceMessageHyperLinkColor = YSFRGBA2(0xff4e97d9);
    _serviceMessageTextFontSize = 16;
    _tipMessageTextColor = YSFRGBA2(0xffa3afb7);
    _tipMessageTextFontSize = 12;
    _inputTextColor = [UIColor blackColor];
    _inputTextFontSize = 14;

    _sessionBackground = nil;
    _sessionTipBackgroundColor = YSFRGBA2(0xfffff9e2);
    _customerHeadImage = [UIImage ysf_imageInKit:@"icon_customer_avatar"];
    _customerHeadImageUrl = nil;
    _serviceHeadImage = [UIImage ysf_imageInKit:@"icon_service_avatar"];
    _serviceHeadImageUrl = nil;
    _sessionMessageSpacing = 0;
    _showHeadImage = YES;
    
    _customerMessageBubbleNormalImage = [[UIImage ysf_imageInKit:@"icon_sender_node_normal"]
                                         resizableImageWithCapInsets:UIEdgeInsetsMake(25,10,10,10)
                                         resizingMode:UIImageResizingModeStretch];
    _customerMessageBubblePressedImage = [[UIImage ysf_imageInKit:@"icon_sender_node_pressed"]
                                            resizableImageWithCapInsets:UIEdgeInsetsMake(25,10,10,10)
                                            resizingMode:UIImageResizingModeStretch];
    _serviceMessageBubbleNormalImage = [[UIImage ysf_imageInKit:@"icon_receiver_node_normal"]
                                            resizableImageWithCapInsets:UIEdgeInsetsMake(25,10,10,10)
                                            resizingMode:UIImageResizingModeStretch];
    _serviceMessageBubblePressedImage = [[UIImage ysf_imageInKit:@"icon_receiver_node_pressed"]
                                            resizableImageWithCapInsets:UIEdgeInsetsMake(25,10,10,10)
                                            resizingMode:UIImageResizingModeStretch];
    
    _rightBarButtonItemColorBlackOrWhite = YES;
    _showAudioEntry = YES;
    _showAudioEntryInRobotMode = YES;
    _showEmoticonEntry = YES;
    _autoShowKeyboard = YES;
    
    _showShopEntrance = YES;
    _shopEntranceImage = nil;
    _shopEntranceText = @"商铺";
    
    _showSessionListEntrance = NO;
    _sessionListEntrancePosition = YES;
    _sessionListEntranceImage = nil;
    
}

- (void)setSdkOrKf:(BOOL)sdkOrKf
{
    _sdkOrKf = sdkOrKf;
    if (sdkOrKf) {
        _customMessageTextColor = [UIColor whiteColor];
        _customMessageHyperLinkColor = [UIColor whiteColor];
        _serviceMessageTextColor = [UIColor blackColor];
        _serviceMessageHyperLinkColor = YSFRGBA2(0xff4e97d9);
    }
    else {
        _customMessageTextColor = [UIColor blackColor];
        _customMessageHyperLinkColor = YSFRGBA2(0xff4e97d9);
        _serviceMessageTextColor = [UIColor whiteColor];
        _serviceMessageHyperLinkColor = [UIColor whiteColor];
    }
}

@end
