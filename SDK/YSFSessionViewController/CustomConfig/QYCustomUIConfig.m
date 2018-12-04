#import "QYCustomUIConfig+Private.h"


@implementation QYCustomInputItem

@end


@interface QYCustomUIConfig()

@property (nonatomic, assign) CGFloat compressQuality;

@property (nonatomic, assign) BOOL showEvaluationEntry;

@property (nonatomic, assign) BOOL showTransWords;

@end



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
    self.sessionTipTextColor = YSFRGBA2(0xffc08722);
    self.sessionTipTextFontSize = 14;
    self.customMessageTextColor = [UIColor whiteColor];
    self.customMessageHyperLinkColor = [UIColor whiteColor];
    self.customMessageTextFontSize = 16;
    self.serviceMessageTextColor = [UIColor blackColor];
    self.serviceMessageHyperLinkColor = YSFRGBA2(0xff4e97d9);
    self.serviceMessageTextFontSize = 16;
    self.tipMessageTextColor = YSFRGBA2(0xffa3afb7);
    self.tipMessageTextFontSize = 12;
    self.inputTextColor = [UIColor blackColor];
    self.inputTextFontSize = 14;

    self.sessionBackground = nil;
    self.sessionTipBackgroundColor = YSFRGBA2(0xfffff9e2);
    self.customerHeadImage = [UIImage ysf_imageInKit:@"icon_customer_avatar"];
    self.customerHeadImageUrl = nil;
    self.serviceHeadImage = [UIImage ysf_imageInKit:@"icon_service_avatar"];
    self.serviceHeadImageUrl = nil;
    self.humanButtonText = nil;
    self.sessionMessageSpacing = 0;
    self.headMessageSpacing = 5.0;
    self.showHeadImage = YES;
    
    self.customerMessageBubbleNormalImage = [[UIImage ysf_imageInKit:@"icon_sender_node_normal"]
                                         resizableImageWithCapInsets:UIEdgeInsetsMake(25,10,10,10)
                                         resizingMode:UIImageResizingModeStretch];
    self.customerMessageBubblePressedImage = [[UIImage ysf_imageInKit:@"icon_sender_node_pressed"]
                                            resizableImageWithCapInsets:UIEdgeInsetsMake(25,10,10,10)
                                            resizingMode:UIImageResizingModeStretch];
    self.serviceMessageBubbleNormalImage = [[UIImage ysf_imageInKit:@"icon_receiver_node_normal"]
                                            resizableImageWithCapInsets:UIEdgeInsetsMake(25,10,10,10)
                                            resizingMode:UIImageResizingModeStretch];
    self.serviceMessageBubblePressedImage = [[UIImage ysf_imageInKit:@"icon_receiver_node_pressed"]
                                            resizableImageWithCapInsets:UIEdgeInsetsMake(25,10,10,10)
                                            resizingMode:UIImageResizingModeStretch];
    
    self.actionButtonTextColor = YSFRGB(0x4f82ae);
    self.actionButtonBorderColor = YSFRGB(0x4f82ae);
    self.rightBarButtonItemColorBlackOrWhite = YES;
    self.showAudioEntry = YES;
    self.showAudioEntryInRobotMode = YES;
    self.showEmoticonEntry = YES;
    self.showImageEntry = YES;
    self.autoShowKeyboard = YES;
    
    self.showShopEntrance = NO;
    self.shopEntranceImage = nil;
    self.shopEntranceText = @"商铺";
    
    self.showSessionListEntrance = NO;
    self.sessionListEntrancePosition = YES;
    self.sessionListEntranceImage = nil;
    
    self.compressQuality = 0.5;
    self.showTransWords = NO;
    self.showEvaluationEntry = YES;
    self.bypassDisplayMode = QYBypassDisplayModeBottom;
    
    self.customInputItems = nil;
}

- (void)setToKf
{
    _customMessageTextColor = [UIColor blackColor];
    _customMessageHyperLinkColor = YSFRGBA2(0xff4e97d9);
    _serviceMessageTextColor = [UIColor whiteColor];
    _serviceMessageHyperLinkColor = [UIColor whiteColor];
}

@end
