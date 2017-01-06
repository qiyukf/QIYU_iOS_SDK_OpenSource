#import "YSFTransAudioToTextLoadingViewController.h"
#import "YSFApiDefines.h"

@interface YSFTransAudioToTextLoadingViewController ()
@property (nonatomic, strong) YSF_NIMMessage *message;
@property (nonatomic, strong) UIButton *displayResult;
@property (nonatomic, strong) UIButton *cancel;
@end


@implementation YSFTransAudioToTextLoadingViewController

- (instancetype)initWithAudioToTextOption:(YSF_NIMMessage *)message
{
    if (self = [super init])
    {
        _message = message;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ULKScrollView *scrollView = [ULKScrollView new];
    scrollView.backgroundColor = [UIColor whiteColor];
    self.view = scrollView;
    ULKFrameLayout *mainLayout = [ULKFrameLayout new];
    mainLayout.ulk_padding = UIEdgeInsetsMake(20, 20, 20, 20);
    [scrollView addSubview:mainLayout];
    _displayResult = [UIButton new];
    [_displayResult setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_displayResult setTitle:@"正在转换..." forState:UIControlStateNormal];
    _displayResult.ulk_layoutGravity = ULKGravityCenter;
    
    [mainLayout addSubview:_displayResult];
    
    _cancel = [UIButton new];
    _cancel.ulk_layoutWidth = 120;
    _cancel.ulk_layoutHeight = 50;
    [_cancel ysf_cornerRadius:25 borderWidth:1 borderColor:[UIColor blackColor]];
    [_cancel setTitle:@"取消" forState:UIControlStateNormal];
    [_cancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _cancel.ulk_layoutGravity = ULKGravityCenterHorizontal|ULKGravityBottom;
    _cancel.ulk_layoutMargin = UIEdgeInsetsMake(0, 0, 50, 0);
    [_cancel addTarget:self action:@selector(onCancelClick:) forControlEvents:UIControlEventTouchUpInside];
    [mainLayout addSubview:_cancel];
    
    __weak typeof(self) weakSelf = self;
    YSF_NIMAudioObject *audioObject =  (YSF_NIMAudioObject *)_message.messageObject;
    NSDictionary *dict = [_message.ext ysf_toDict];
    NSString *text = [dict objectForKey:YSFApiKeyContent];
    if (text) {
        weakSelf.cancel.hidden = YES;
        UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap:)];
        singleTapRecognizer.numberOfTapsRequired = 1;
        singleTapRecognizer.numberOfTouchesRequired = 1;
        singleTapRecognizer.cancelsTouchesInView = NO;
        singleTapRecognizer.delaysTouchesEnded = NO;
        [weakSelf.view addGestureRecognizer:singleTapRecognizer];
        

        self.displayResult.titleLabel.numberOfLines = 0;
        [self.displayResult setTitle:text forState:UIControlStateNormal];
        [self.displayResult.superview ulk_clearMeasuredDimensionSize];
        [self.displayResult.superview setNeedsLayout];
    }
    else {
        if (audioObject.url.length == 0) {
            [[[YSF_NIMSDK sharedSDK] resourceManager] upload:audioObject.path progress:nil
                                                  completion:^(NSString *urlString, NSError *error) {
                                                      YSF_NIMAudioToTextOption *audioToTextOption = [YSF_NIMAudioToTextOption new];
                                                      audioToTextOption.url = urlString;
                                                      audioToTextOption.filepath = audioObject.path;
                                                      [self transfer:audioToTextOption];
                                                       }];

        }
        else {
            YSF_NIMAudioToTextOption *audioToTextOption = [YSF_NIMAudioToTextOption new];
            audioToTextOption.url = audioObject.url;
            audioToTextOption.filepath = audioObject.path;
            [self transfer:audioToTextOption];
        }
    }
}

- (void)onCancelClick:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

 - (void)cancelSendImage:(id)sender
{
    _sendingImageConfirmedCallback(NO);
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendImage:(id)sender
{
    _sendingImageConfirmedCallback(YES);
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)onSingleTap:(UITapGestureRecognizer *)recognizer
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)transfer:(YSF_NIMAudioToTextOption *)audioToTextOption
{
    __weak typeof(self) weakSelf = self;
    [[[YSF_NIMSDK sharedSDK] mediaManager] transAudioToText:audioToTextOption result:^(NSError *error,NSString *text){
          weakSelf.cancel.hidden = YES;
          UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap:)];
          singleTapRecognizer.numberOfTapsRequired = 1;
          singleTapRecognizer.numberOfTouchesRequired = 1;
          singleTapRecognizer.cancelsTouchesInView = NO;
          singleTapRecognizer.delaysTouchesEnded = NO;
          [weakSelf.view addGestureRecognizer:singleTapRecognizer];
          
          if (error) {
              [weakSelf.displayResult setImage:[UIImage ysf_imageInKit:@"icon_message_cell_error"] forState:UIControlStateNormal];
              weakSelf.displayResult.ulk_layoutWidth = 200;
              weakSelf.displayResult.imageEdgeInsets = UIEdgeInsetsMake(0, -7, 0, 0);
              weakSelf.displayResult.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
              [weakSelf.displayResult setTitle:@"转换失败" forState:UIControlStateNormal];
          }
          else {
              _message.ext = [NSString stringWithFormat:@"{\"%@\":\"%@\"}", YSFApiKeyContent, text];
              [[[YSF_NIMSDK sharedSDK] conversationManager] updateMessage:NO message:_message forSession:_message.session completion:nil];
              
              weakSelf.displayResult.titleLabel.numberOfLines = 0;
              [weakSelf.displayResult setTitle:text forState:UIControlStateNormal];
          }
        
        
        [weakSelf.displayResult ulk_clearMeasuredDimensionSize];
        [weakSelf.displayResult setNeedsLayout];
        [weakSelf.displayResult.superview ulk_clearMeasuredDimensionSize];
        [weakSelf.displayResult.superview setNeedsLayout];
    }];
}

@end



