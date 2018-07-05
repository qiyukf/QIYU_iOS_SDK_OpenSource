#import "YSFBotFormViewController.h"
#import "YSFCustomSystemNotificationParser.h"
#import "YSFOrderListContentView.h"
#import "UIImageView+YSFWebCache.h"
#import "YSFBotForm.h"
#import "YSFKeyboardManager.h"
#import "YSFAlertController.h"
#import "NIMNOSResizer.h"
#import "UIImage+YSF.h"
#import "NIMPathManager.h"
#import "NIMUtil.h"
#import "NSString+FileTransfer.h"
#import <AssetsLibrary/AssetsLibrary.h>
@import MobileCoreServices;
@import AVFoundation;

#define cellHeight 70.0;
#define onlineSessionCellReuseIdentify @"OnlineSessionCell"
#define callCenterCellReuseIdentify @"CallCenterCell"
#define kYSFOrderCell @"YSFOrderCell"

typedef enum : NSUInteger {
    NTESImagePickerModeImage,
    NTESImagePickerModeShootImage,
} NTESImagePickerMode;


@interface YSFBotFormImage : UIView

@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *imageFilePath;
@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, assign) long long imageFileSize;

@end

@implementation YSFBotFormImage

@end

@interface YSFBotFormViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, YSFKeyboardObserver, YSF_NIMSystemNotificationManagerDelegate>

@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) YSFAction *action;
@property (nonatomic, assign) CGRect scrollViewFrame;
@property (nonatomic, assign)    NTESImagePickerMode      mode;
@property (nonatomic, weak)    UIButton      *uploadImageButton;

@end

@implementation YSFBotFormViewController

-(instancetype)init
{
    self = [super init];
    if (self)
    {
    }
    
    return self;
}

- (void)dealloc
{
    [[[YSF_NIMSDK sharedSDK] systemNotificationManager] removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = YSFRGBA(0x000000, 0.18);
    [self makeMainView];
    [[[YSF_NIMSDK sharedSDK] systemNotificationManager] addDelegate:self];
    
    [[YSFKeyboardManager defaultManager] addObserver:self];

    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap:)];
    [self.view addGestureRecognizer:singleTapRecognizer];
}

-(void)makeMainView
{
    UIView *title = [UIView new];
    title.backgroundColor = [UIColor whiteColor];
    title.ysf_frameWidth = YSFUIScreenWidth;
    [self.view addSubview:title];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.numberOfLines = 0;
    titleLabel.text = _botForm.label;
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.ysf_frameTop = 10;
    titleLabel.ysf_frameWidth = title.ysf_frameWidth - 65;
    titleLabel.ysf_frameLeft = 25;
    [titleLabel sizeToFit];
    [title addSubview:titleLabel];
    
    title.ysf_frameHeight = titleLabel.ysf_frameHeight + 20;

    UIView *splitLine = [UIView new];
    splitLine.backgroundColor = YSFRGB(0xdbdbdb);
    splitLine.ysf_frameTop = title.ysf_frameHeight - 0.5;
    splitLine.ysf_frameHeight = 0.5;
    splitLine.ysf_frameLeft = 0;
    splitLine.ysf_frameWidth = YSFUIScreenWidth;
    [title addSubview:splitLine];
    
    UIButton *close = [UIButton new];
    [close setImage:[UIImage ysf_imageInKit:@"icon_evaluation_close"] forState:UIControlStateNormal];
    close.ysf_frameHeight = title.ysf_frameHeight;
    close.ysf_frameWidth = 32;
    close.ysf_frameRight = YSFUIScreenWidth;
    [close addTarget:self action:@selector(onClose) forControlEvents:UIControlEventTouchUpInside];
    [title addSubview:close];
    
    _scrollView = [UIScrollView new];
    _scrollView.frame = CGRectMake(0, 0, YSFUIScreenWidth, 0);
    _scrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_scrollView];
    
    int offsetY = 20;
    for (YSFBotFormCell *cell in _botForm.forms) {
        UILabel *label = [UILabel new];
        label.numberOfLines = 0;
        label.text = cell.label;
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = YSFRGB(0x666666);
        label.ysf_frameLeft = 25;
        label.ysf_frameTop = offsetY;
        label.ysf_frameWidth = _scrollView.ysf_frameWidth - 170;
        [_scrollView addSubview:label];

        if (cell.required) {
            label.text = [label.text stringByAppendingString:@" *"];
            NSMutableAttributedString *attributeString = [label.attributedText mutableCopy];
            [attributeString addAttribute:NSForegroundColorAttributeName value:YSFRGB(0x5092E1)
                                    range:NSMakeRange(label.text.length - 1, 1)];
            label.attributedText = attributeString;
        }
        [label sizeToFit];
        
        UILabel *requiredTip = [UILabel new];
        requiredTip.tag = YES;
        requiredTip.hidden = YES;
        requiredTip.text = @"此信息不得为空";
        requiredTip.font = [UIFont systemFontOfSize:14];
        requiredTip.textColor = YSFRGB(0xe64340);
        requiredTip.ysf_frameLeft = 23;
        requiredTip.ysf_frameTop = offsetY;
        [requiredTip sizeToFit];
        requiredTip.ysf_frameRight = _scrollView.ysf_frameWidth - 25;
        [_scrollView addSubview:requiredTip];
        
        offsetY += label.ysf_frameHeight + 8;
        
        if ([cell.type isEqualToString:@"image"]) {
            YSFBotFormImage *imagePanel = [YSFBotFormImage new];
            if (cell.required) {
                imagePanel.tag = YES;
            }
            imagePanel.ysf_frameLeft = 25;
            imagePanel.ysf_frameTop = offsetY - 6;
            imagePanel.ysf_frameWidth = 180;
            imagePanel.ysf_frameHeight = 50;
            [_scrollView addSubview:imagePanel];

            UIButton *uploadImage = [UIButton new];
            [uploadImage addTarget:self action:@selector(uploadImage:) forControlEvents:UIControlEventTouchUpInside];
            uploadImage.titleLabel.font = [UIFont systemFontOfSize:14];
            [uploadImage setTitleColor:YSFRGB(0x5092E1) forState:UIControlStateNormal];
            [uploadImage setTitle:@"上传图片" forState:UIControlStateNormal];
            uploadImage.ysf_frameLeft = 0;
            uploadImage.ysf_frameTop = 6;
            uploadImage.ysf_frameWidth = 110;
            uploadImage.ysf_frameHeight = 43;
            uploadImage.layer.borderWidth = 0.5;
            uploadImage.layer.borderColor = YSFRGB(0x5092E1).CGColor;
            [imagePanel addSubview:uploadImage];
            
            UIView *removeImagePanel = [UIView new];
            if (cell.imageUrl.length > 0) {
                removeImagePanel.hidden = NO;
                uploadImage.hidden = YES;
                imagePanel.imageUrl = cell.imageUrl;
                imagePanel.imageName = cell.imageName;
                imagePanel.imageFileSize = cell.imageFileSize;
            }
            else {
                removeImagePanel.hidden = YES;
                uploadImage.hidden = NO;
            }
            removeImagePanel.ysf_frameLeft = 0;
            removeImagePanel.ysf_frameTop = 0;
            removeImagePanel.ysf_frameWidth = imagePanel.ysf_frameWidth;
            removeImagePanel.ysf_frameHeight = imagePanel.ysf_frameHeight;
            [imagePanel addSubview:removeImagePanel];

            UIView *removeImageView = [UIView new];
            removeImageView.ysf_frameLeft = 0;
            removeImageView.ysf_frameTop = 6;
            removeImageView.ysf_frameWidth = 170;
            removeImageView.ysf_frameHeight = 43;
            removeImageView.backgroundColor = YSFRGB(0xfafafa);
            removeImageView.layer.borderWidth = 0.5;
            removeImageView.layer.borderColor = YSFRGB(0xcccccc).CGColor;
            [removeImagePanel addSubview:removeImageView];
            
            UIImageView *imageView = [UIImageView new];
            imageView.image = [UIImage ysf_imageInKit:@"icon_botform_image"];
            imageView.frame = CGRectMake(5, 5, 29, 33);
            [removeImageView addSubview:imageView];
            
            UILabel *imageName = [UILabel new];
            imageName.text = cell.imageName;
            imageName.frame = CGRectMake(43, 3, 110, 20);
            imageName.font = [UIFont systemFontOfSize:14];
            [removeImageView addSubview:imageName];
            
            UILabel *imageSize = [UILabel new];
            imageSize.text = [NSString getFileSizeTextWithFileLength:cell.imageFileSize];
            imageSize.frame = CGRectMake(43, 21, 110, 20);
            imageSize.font = [UIFont systemFontOfSize:14];
            [removeImageView addSubview:imageSize];
            
            UIButton *removeImage = [UIButton new];
            [removeImage addTarget:self action:@selector(onRemoveImage:) forControlEvents:UIControlEventTouchUpInside];
            [removeImage setImage:[UIImage ysf_imageInKit:@"icon_file_transfer_cancel"] forState:UIControlStateNormal] ;
            removeImage.frame = CGRectMake(160, 0, 20, 20);
            [removeImagePanel addSubview:removeImage];
        }
        else {
            UITextField *textField = [UITextField new];
            textField.text = cell.value;
            if (cell.required) {
                textField.tag = YES;
            }
            [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
            textField.font = [UIFont systemFontOfSize:16];
            textField.ysf_frameLeft = 25;
            textField.ysf_frameTop = offsetY;
            textField.ysf_frameWidth = _scrollView.ysf_frameWidth - 50;
            textField.ysf_frameHeight = 43;
            textField.layer.borderWidth = 0.5;
            textField.layer.borderColor = YSFRGB(0xcccccc).CGColor;
            textField.leftViewMode = UITextFieldViewModeAlways;
            textField.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 0)];
            [_scrollView addSubview:textField];
        }

        offsetY += 60;
    }
    
    UIView *bottom = [UIView new];
    bottom.backgroundColor = [UIColor whiteColor];
    bottom.ysf_frameWidth = YSFUIScreenWidth;
    bottom.ysf_frameHeight = 63;
    bottom.ysf_frameTop = offsetY;
    [_scrollView addSubview:bottom];
    
    UIView *splitLine2 = [UIView new];
    splitLine2.backgroundColor = YSFRGB(0xdbdbdb);
    splitLine2.ysf_frameTop = 0;
    splitLine2.ysf_frameHeight = 0.5;
    splitLine2.ysf_frameLeft = 0;
    splitLine2.ysf_frameWidth = YSFUIScreenWidth;
    [bottom addSubview:splitLine2];
    
    UIButton *submit = [UIButton new];
    [submit addTarget:self action:@selector(onSubmit:) forControlEvents:UIControlEventTouchUpInside];
    [submit setTitle:@"提交" forState:UIControlStateNormal];
    submit.backgroundColor = YSFRGB(0x529DF9);
    submit.layer.cornerRadius = 5;
    submit.titleLabel.font = [UIFont systemFontOfSize:16];
    submit.ysf_frameWidth = title.ysf_frameWidth - 50;
    submit.ysf_frameHeight = 43;
    submit.ysf_frameLeft = 25;
    submit.ysf_frameBottom = bottom.ysf_frameHeight - 10;
    [bottom addSubview:submit];
    
    offsetY += 63;
    _scrollView.contentSize = CGSizeMake(CGRectGetWidth(_scrollView.frame), offsetY);
    CGFloat scrollViewHeight = self.view.bounds.size.height - 30 - title.ysf_frameHeight;
    if (offsetY < self.view.bounds.size.height - 30 - title.ysf_frameHeight) {
        scrollViewHeight = offsetY;
    }
    _scrollView.frame = CGRectMake(0, self.view.bounds.size.height - scrollViewHeight, YSFUIScreenWidth, scrollViewHeight);
    _scrollViewFrame = _scrollView.frame;
    title.ysf_frameBottom = _scrollView.ysf_frameTop;
}

- (void)onClose
{
    [self closeViewController:NO];
}

- (void)onSubmit:(id)sender
{
    UILabel *tipLabel = nil;
    BOOL stopSubmit = NO;
    for (UIView *view in _scrollView.subviews) {
        if ([view isKindOfClass:[UILabel class]] && view.tag == YES) {
            tipLabel = (UILabel *)view;
        }
        
        if ([view isKindOfClass:[UITextField class]]) {
            UITextField *textFiled = (UITextField *)view;
            if (textFiled.text.length == 0 && textFiled.tag == YES) {
                tipLabel.hidden = NO;
                stopSubmit = YES;
            }
            else {
                tipLabel.hidden = YES;
            }
        }
        else if ([view isKindOfClass:[YSFBotFormImage class]]) {
            YSFBotFormImage *imageImage = (YSFBotFormImage *)view;
            if (imageImage.imageUrl.length == 0 && imageImage.tag == YES) {
                tipLabel.hidden = NO;
                stopSubmit = YES;
            }
            else {
                tipLabel.hidden = YES;
            }
        }
    }
    
    if (stopSubmit) {
        return;
    }
    
    [self closeViewController:YES];
}

- (void)closeViewController:(BOOL)submitted
{
    int index = 0;
    NSString *idStr = @"";
    YSFSubmittedBotForm *submittedBotForm = [YSFSubmittedBotForm new];
    NSMutableArray *cells =  [NSMutableArray new];
    for (UIView *view in _scrollView.subviews) {
        if ([view isKindOfClass:[UITextField class]]) {
            UITextField *textFiled = (UITextField *)view;
            YSFBotFormCell *botFormCell = _botForm.forms[index];
            YSFSubmittedBotFormCell *submittedBotFormCell = [YSFSubmittedBotFormCell new];
            submittedBotFormCell.label = botFormCell.label;
            submittedBotFormCell.type = botFormCell.type;
            submittedBotFormCell.value = textFiled.text;
            [cells addObject:submittedBotFormCell];
            
            NSString *tmpIdStr = [NSString stringWithFormat:@"&%@=%@", botFormCell.id, submittedBotFormCell.value];
            idStr = [idStr stringByAppendingString:tmpIdStr];
            
            index++;
        }
        else if ([view isKindOfClass:[YSFBotFormImage class]]) {
            YSFBotFormImage *imageView = (YSFBotFormImage *)view;
            YSFBotFormCell *botFormCell = _botForm.forms[index];
            YSFSubmittedBotFormCell *submittedBotFormCell = [YSFSubmittedBotFormCell new];
            submittedBotFormCell.label = botFormCell.label;
            submittedBotFormCell.type = botFormCell.type;
            if (imageView.imageUrl.length > 0) {
                NSMutableDictionary *dict = [NSMutableDictionary new];
                dict[@"name"] = YSFStrParam(imageView.imageName);
                dict[@"size"] = @(imageView.imageFileSize);
                dict[@"url"] = YSFStrParam(imageView.imageUrl);
                submittedBotFormCell.imageValue = dict;
            }
            [cells addObject:submittedBotFormCell];
            
            NSString *tmpIdStr = [NSString stringWithFormat:@"&%@=%@", botFormCell.id, [submittedBotFormCell.imageValue ysf_toUTF8String]];
            idStr = [idStr stringByAppendingString:tmpIdStr];
            
            index++;
        }
    }
    submittedBotForm.params = idStr;
    submittedBotForm.forms = cells;
    [submittedBotForm setImageUrlString:cells];
    if (_submitCallback) {
        _submitCallback(submitted, submittedBotForm);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)keyboardChangedWithTransition:(YSFKeyboardTransition)transition {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:transition.animationDuration delay:0 options:transition.animationOption animations:^{
        if (transition.toVisible) {
            for (UIView * view in weakSelf.scrollView.subviews) {
                if (view.isFirstResponder && [view isKindOfClass:[UITextField class]]) {
                    CGRect kbFrame = [[YSFKeyboardManager defaultManager] convertRect:transition.toFrame toView:weakSelf.scrollView];
                    CGRect scrollViewFrame = weakSelf.scrollViewFrame;
                    scrollViewFrame.size.height -= kbFrame.size.height;
                    weakSelf.scrollView.frame = scrollViewFrame;
                    [weakSelf.scrollView scrollRectToVisible:view.frame animated:YES];
                }
            }
        }
        else {
            weakSelf.scrollView.frame = weakSelf.scrollViewFrame;
        }
    } completion:^(BOOL finished) {
        
    }];
}

-(void)onSingleTap:(UITapGestureRecognizer *)recognizer
{
    [self.view setNeedsLayout];
    [self.view endEditing:YES];
}

- (void)uploadImage:(UIButton *)button
{
    self.uploadImageButton = button;
    __weak typeof(self) weakSelf = self;
    YSFAlertController * alertController = [YSFAlertController actionSheetWithTitle:nil];
    [alertController addAction:[YSFAlertAction actionWithTitle:@"选择本地图片" handler:^(YSFAlertAction * _Nonnull action) {
        //相册
        [weakSelf mediaPicturePressed];
    }]];
    
    [alertController addAction:[YSFAlertAction actionWithTitle:@"拍照" handler:^(YSFAlertAction * _Nonnull action) {
        //拍照
        [weakSelf mediaShootPressed];
    }]];
    
    [alertController addCancelActionWithHandler:nil];
    
    [alertController showWithSender:button
                     arrowDirection:UIPopoverArrowDirectionAny controller:self animated:YES completion:nil];
}

- (void)onRemoveImage:(UIButton *)button
{
    button.superview.hidden = YES;
    button.superview.superview.subviews[0].hidden = NO;
    [button.superview setNeedsDisplay];
}

- (void)textFieldDidChange:(UITextField *)textField
{
    NSString *str = textField.text;
    if (str.length > 100) {
        textField.text = [str substringToIndex:100];
    }
}

- (void)mediaPicturePressed
{
    self.mode = NTESImagePickerModeImage;
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    _mode = NTESImagePickerModeImage;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (UIImagePickerController *)cameraInit
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:@"检测不到相机设备"
                                   delegate:nil
                          cancelButtonTitle:@"确定"
                          otherButtonTitles:nil] show];
        return nil;
    }
    NSString *mediaType = AVMediaTypeVideo;
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        [[[UIAlertView alloc] initWithTitle:@"没有相机权限"
                                    message:@"请在iPhone的“设置-隐私-相机”选项中，允许访问你的相机。"
                                   delegate:nil
                          cancelButtonTitle:@"确定"
                          otherButtonTitles:nil] show];
        return nil;
        
    }
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    
    return imagePicker;
}

- (void)mediaShootPressed
{
    UIImagePickerController *imagePicker = [self cameraInit];
    if (imagePicker) {
        self.mode = NTESImagePickerModeShootImage;
        imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

#pragma mark - ImagePicker初始化
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        
    }
    else{
        UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
        if (_mode == NTESImagePickerModeShootImage) {
            UIImageWriteToSavedPhotosAlbum(orgImage, nil, nil, nil);
        }
        
        __block NSString* imageSourceName;
        NSURL *imageURL = info[UIImagePickerControllerReferenceURL];
         ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
        __weak typeof(self) weakSelf = self;
        [assetslibrary assetForURL:imageURL resultBlock:^(ALAsset *myasset) {
                    ALAssetRepresentation *representation = [myasset defaultRepresentation];
                    imageSourceName = [representation filename];
                    if (imageSourceName.length == 0) {
                        imageSourceName = @"IMG.JPG";
                    }
                    [picker dismissViewControllerAnimated:YES completion:^{
                        
                        switch (weakSelf.mode) {
                            case NTESImagePickerModeImage:
                            {
                                [weakSelf uploadImageResource:orgImage imageSourceName:imageSourceName];
                                break;
                            }
                            case NTESImagePickerModeShootImage:
                            {
                                [weakSelf uploadImageResource:orgImage imageSourceName:imageSourceName];
                                break;
                            }
                            default:
                                break;
                        }
                        
                    }];
            
                } failureBlock:nil];
    }
}

- (void)uploadImageResource:(UIImage *)orgImage imageSourceName:(NSString *)imageSourceName
{
    UIImage *destImage = [UIImage imageWithData:UIImageJPEGRepresentation(orgImage, 0.8)];
    NSString *imagePath = [[YSF_NIMPathManager sharedManager] sdkNIMResourcePath];
    NSString *imageName = [YSF_NIMUtil uuid];
    imagePath = [imagePath stringByAppendingPathComponent:imageName];
    [destImage ysf_saveToFilepathWithJpeg:imagePath];
    long long fileSize = [[NSFileManager defaultManager] attributesOfItemAtPath:imagePath error:nil].fileSize;
    __weak typeof(self) weakSelf = self;
    [[[YSF_NIMSDK sharedSDK] resourceManager] upload:imagePath progress:nil
                                          completion:^(NSString *urlString, NSError *error) {
                                              if (error) {
                                                  UIWindow *topmostWindow = [[[UIApplication sharedApplication] windows] lastObject];
                                                  [topmostWindow ysf_makeToast:@"图片上传失败，请稍后重试" duration:2 position:YSFToastPositionCenter];
                                                  
                                                  return;
                                              }
                                              weakSelf.uploadImageButton.hidden = YES;
                                              weakSelf.uploadImageButton.superview.subviews[1].hidden = NO;
                                              UILabel *imageNameLabel = weakSelf.uploadImageButton.superview.subviews[1].subviews[0].subviews[1];
                                              imageNameLabel.text = imageSourceName;
                                              UILabel *imageSizeLabel = weakSelf.uploadImageButton.superview.subviews[1].subviews[0].subviews[2];
                                              NSString *fileSizeStr = [NSString getFileSizeTextWithFileLength:fileSize];
                                              imageSizeLabel.text = fileSizeStr;
                                              ((YSFBotFormImage *)weakSelf.uploadImageButton.superview).imageUrl = urlString;
                                              ((YSFBotFormImage *)weakSelf.uploadImageButton.superview).imageFilePath = imageName;
                                              ((YSFBotFormImage *)weakSelf.uploadImageButton.superview).imageName = imageSourceName;
                                              ((YSFBotFormImage *)weakSelf.uploadImageButton.superview).imageFileSize = fileSize;
                                          }];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


@end
