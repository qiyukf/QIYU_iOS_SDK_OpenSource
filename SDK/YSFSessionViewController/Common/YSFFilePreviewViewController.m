//
//  YSFFilePreviewViewController.m
//  YSFSessionViewController
//
//  Created by JackyYu on 17/2/14.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "YSFFilePreviewViewController.h"
#import "YSFReachability.h"
#import "YSFAlertController.h"
#import "YSFLoadProgressView.h"
#import "UIImage+FileTransfer.h"
#import "NSString+FileTransfer.h"
#import "UIView+YSFToast.h"


@interface YSFFilePreviewViewController ()

@property (nonatomic, strong) YSF_NIMMessage *message;
@property (nonatomic, strong) UILabel *fileLengthLabel;                 //文件大小Label
@property (nonatomic, strong) UILabel *downloadingLabel;                //正在下载。。。Label
@property (nonatomic, strong) UIProgressView *loadProgressView;         //下载进度条
@property (nonatomic, strong) UIButton *cancelDownloadButton;           //取消下载
@property (nonatomic, strong) UIButton *downloadButton;                 //开始下载&继续下载
@property (nonatomic, strong) UIButton *openByOtherAppsButton;          //用其他应用打开
@property (nonatomic, strong) UILabel *tipLabel;                        //用其他应用打开提示
@property (nonatomic, strong) UIDocumentInteractionController *documentController;  //iOS用其他应用打开交互
@property (nonatomic, strong) YSFReachability *reachability;
@property (nonatomic, assign) BOOL isDownloading;                       //是否正在下载中
@property (nonatomic, assign) BOOL hasShowNoWifiTip;                    //是否已经弹出过当前非WIFI连接

@end

@implementation YSFFilePreviewViewController

- (instancetype)initWithFileMessage:(YSF_NIMMessage *)message
{
    self = [super init];
    if (self) {
        self.message = message;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"文件预览";
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.translucent = NO;
    YSF_NIMFileObject *fileObject = (YSF_NIMFileObject *)_message.messageObject;
    if ([self isExistFile] && [self canOpenWithFileName:fileObject.displayName]) {
        [self loadFile];
    } else {
        [self initData];
        [self initUI];
    }
}

- (void)dealloc
{
    [_reachability stopNotifier];
}

- (void)initData
{
    self.isDownloading = NO;
    self.hasShowNoWifiTip = NO;
    self.reachability = [YSFReachability reachabilityForInternetConnection];
    [_reachability startNotifier];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNetworkChanged:) name:YSFReachabilityChangedNotification object:nil];
}

- (void)initUI
{
    YSF_NIMFileObject *fileObject = (YSF_NIMFileObject *)_message.messageObject;
    
    UIImageView *fileIconView = [[UIImageView alloc] initWithFrame:CGRectMake((YSFUIScreenWidth - 75)/2, 30, 75, 75)];
    fileIconView.contentMode = UIViewContentModeScaleAspectFill;
    fileIconView.clipsToBounds = YES;
    fileIconView.image = [UIImage getFileIconWithDefaultIcon:[UIImage ysf_imageInKit:@"icon_file_type_other_preview"] fileName:fileObject.displayName];
    [self.view addSubview:fileIconView];
    
    UILabel *fileNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 136, YSFUIScreenWidth, 25)];
    fileNameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    fileNameLabel.font = [UIFont systemFontOfSize:14.0f];
    fileNameLabel.textAlignment = NSTextAlignmentCenter;
    fileNameLabel.textColor = [UIColor blackColor];
    fileNameLabel.text = fileObject.displayName;
    [self.view addSubview:fileNameLabel];
    
    UILabel *fileLengthLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 161, YSFUIScreenWidth, 21)];
    self.fileLengthLabel = fileLengthLabel;
    fileLengthLabel.font = [UIFont systemFontOfSize:12.0f];
    fileLengthLabel.textAlignment = NSTextAlignmentCenter;
    fileLengthLabel.textColor = [UIColor grayColor];
    fileLengthLabel.text = [NSString stringWithFormat:@"文件大小: %@", [NSString getFileSizeTextWithFileLength:fileObject.fileLength]];
    [self.view addSubview:fileLengthLabel];
    
    UILabel *downloadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 174, YSFUIScreenWidth, 25)];
    self.downloadingLabel = downloadingLabel;
    downloadingLabel.numberOfLines = 1;
    downloadingLabel.font = [UIFont systemFontOfSize:18.f];
    downloadingLabel.textAlignment = NSTextAlignmentCenter;
    downloadingLabel.textColor = YSFRGB(0x999999);
    downloadingLabel.hidden = YES;
    [self.view addSubview:downloadingLabel];
    
    UIProgressView *loadProgressView = [[UIProgressView alloc] initWithFrame:CGRectMake(16, 219, (YSFUIScreenWidth - 2*16), 16)];
    self.loadProgressView = loadProgressView;
    loadProgressView.progressViewStyle = UIProgressViewStyleDefault;
    loadProgressView.progressTintColor = YSFRGB(0x529DF9);
    loadProgressView.trackTintColor = YSFRGB(0xefefef);
    loadProgressView.transform = CGAffineTransformMakeScale(1.f, 3.f);
    loadProgressView.contentMode = UIViewContentModeScaleAspectFill;
    for (UIImageView *imageView in loadProgressView.subviews) {
        imageView.layer.cornerRadius = 3.f;
        imageView.layer.masksToBounds = YES;
    }
    loadProgressView.hidden = YES;
    [self.view addSubview:loadProgressView];
    
    UIButton *cancelDownloadButton = [[UIButton alloc] initWithFrame:CGRectMake(YSFUIScreenWidth-25-10, 208, 25, 25)];
    self.cancelDownloadButton = cancelDownloadButton;
    [cancelDownloadButton setImage:[UIImage ysf_imageInKit:@"icon_file_transfer_cancel"] forState:UIControlStateNormal];
    [cancelDownloadButton addTarget:self action:@selector(onTapCancelDownloadButton) forControlEvents:UIControlEventTouchUpInside];
    cancelDownloadButton.hidden = YES;
    [self.view addSubview:cancelDownloadButton];
    
    UIButton *downloadButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 204, (YSFUIScreenWidth - 2*20), 47)];
    self.downloadButton = downloadButton;
    downloadButton.backgroundColor = YSFRGB(0xFF529DF9);
    downloadButton.layer.cornerRadius = 4.f;
    downloadButton.titleLabel.font = [UIFont systemFontOfSize:18.f];
    [downloadButton setTitle:@"开始下载" forState:UIControlStateNormal];
    [downloadButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [downloadButton addTarget:self action:@selector(onTapDownloadButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:downloadButton];
    
    UIButton *openByOtherAppsButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 204, (YSFUIScreenWidth - 2*20), 47)];
    self.openByOtherAppsButton = openByOtherAppsButton;
    openByOtherAppsButton.backgroundColor = YSFRGB(0x529DF9);
    openByOtherAppsButton.layer.cornerRadius = 4.f;
    openByOtherAppsButton.titleLabel.font = [UIFont systemFontOfSize:18.f];
    [openByOtherAppsButton setTitle:@"用其他应用打开" forState:UIControlStateNormal];
    [openByOtherAppsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [openByOtherAppsButton addTarget:self action:@selector(onTapOpenByOtherAppsButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:openByOtherAppsButton];
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake((YSFUIScreenWidth - 300)/2, 263, 300, 17)];
    self.tipLabel = tipLabel;
    tipLabel.numberOfLines = 1;
    tipLabel.font = [UIFont systemFontOfSize:12.f];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.textColor = YSFRGB(0x999999);
    tipLabel.text = @"七鱼暂时无法打开此类文件,可使用其他应用打开并预览";
    [self.view addSubview:tipLabel];
    
    if (![self isExistFile]) {
        downloadButton.hidden = NO;
        openByOtherAppsButton.hidden = YES;
        tipLabel.hidden = YES;
    } else {
        downloadButton.hidden = YES;
        openByOtherAppsButton.hidden = NO;
        tipLabel.hidden = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_isDownloading) {
        YSF_NIMFileObject *fileObject = (YSF_NIMFileObject *)_message.messageObject;
        [[[YSF_NIMSDK sharedSDK] resourceManager] cancelTask:fileObject.path];
    }
}

- (void)onTapDownloadButton
{
    YSFNetworkStatus status = [_reachability currentReachabilityStatus];
    if (status == YSFNotReachable) {
        [self.view ysf_makeToast:@"当前网络不可用，请检查你的网络！" duration:1.f position:YSFToastPositionCenter];
        return;
    } else if (status != YSFReachableViaWiFi && !_hasShowNoWifiTip) {
        YSFAlertController* alert = [YSFAlertController alertWithTitle:@"下载文件将产生手机流量" message:@"检测到您处于非WIFI环境下，下载文件将产生手机流量，是否确认继续下载？"];
        [alert addAction:[YSFAlertAction actionWithTitle:@"取消" style:YSFAlertActionStyleCancel handler:nil]];
        __weak typeof(self) weakSelf = self;
        [alert addAction:[YSFAlertAction actionWithTitle:@"确认下载" handler:^(YSFAlertAction * _Nonnull action) {
            weakSelf.hasShowNoWifiTip = YES;
            weakSelf.fileLengthLabel.hidden = YES;
            weakSelf.downloadButton.hidden = YES;
            weakSelf.downloadingLabel.hidden = NO;
            weakSelf.loadProgressView.hidden = NO;
            weakSelf.cancelDownloadButton.hidden = NO;
            [weakSelf downloadFile];
        }]];
        [alert showWithSender:nil controller:self animated:YES completion:nil];
    } else {
        _fileLengthLabel.hidden = YES;
        _downloadButton.hidden = YES;
        _downloadingLabel.hidden = NO;
        _loadProgressView.hidden = NO;
        _cancelDownloadButton.hidden = NO;
        [self downloadFile];
    }
}

- (void)onTapCancelDownloadButton
{
    [_downloadButton setTitle:@"继续下载" forState:UIControlStateNormal];
    YSF_NIMFileObject *fileObject = (YSF_NIMFileObject *)_message.messageObject;
    [[[YSF_NIMSDK sharedSDK] resourceManager] cancelTask:fileObject.path];
    _downloadingLabel.hidden = YES;
    _loadProgressView.hidden = YES;
    _cancelDownloadButton.hidden = YES;
    _fileLengthLabel.hidden = NO;
    _downloadButton.hidden = NO;
}

- (void)onTapOpenByOtherAppsButton
{
    YSF_NIMFileObject *fileObject = (YSF_NIMFileObject *)_message.messageObject;
    NSURL *fileUrl = [NSURL fileURLWithPath:fileObject.path];
    UIDocumentInteractionController *documentController = [UIDocumentInteractionController interactionControllerWithURL:fileUrl];
    self.documentController = documentController;
    [documentController presentOptionsMenuFromRect:CGRectZero inView:self.view animated:YES];
}

- (void)onNetworkChanged:(id)sender
{
    //网络切换的时候云信resourceManager不会做到继续下载，这里曲线实现继续下载。
    if (_isDownloading) {
        YSF_NIMFileObject *fileObject = (YSF_NIMFileObject *)_message.messageObject;
        [[[YSF_NIMSDK sharedSDK] resourceManager] cancelTask:fileObject.path];
        [self downloadFile];
    }
}

#pragma mark - Private Method

- (BOOL)isExistFile
{
    YSF_NIMFileObject *fileObject = (YSF_NIMFileObject *)_message.messageObject;
    return [[NSFileManager defaultManager] fileExistsAtPath:fileObject.path];
}

- (BOOL)canOpenWithFileName:(NSString *)fileName
{
    NSDictionary *fileExtDict = @{
                                  @"txt" : @(YES),
                                  @"htm" : @(YES),
                                  @"html" : @(YES),
                                  @"xml" : @(YES),
                                  @"jpg" : @(YES),
                                  @"jpeg" : @(YES),
                                  @"png" : @(YES),
                                  @"gif" : @(YES),
                                  @"bmp" : @(YES),
                                  @"doc" : @(YES),
                                  @"docx" : @(YES),
                                  @"xls" : @(YES),
                                  @"xlsx" : @(YES),
                                  @"csv" : @(YES),
                                  @"ppt" : @(YES),
                                  @"pptx" : @(YES),
                                  @"pdf" : @(YES),
                                  @"key" : @(YES),
                                  };
    BOOL result = NO;
    NSString *fileExt = [[fileName pathExtension] lowercaseString];
    
    if ([fileExtDict objectForKey:fileExt]) {
        result = YES;
    }
    
    return result;
}

- (void)loadFile
{
    YSF_NIMFileObject *fileObject = (YSF_NIMFileObject *)_message.messageObject;
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    webView.backgroundColor = [UIColor whiteColor];
    webView.scalesPageToFit = YES;
    NSString *filePath = fileObject.path;
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:fileUrl];
    //txt会有编码格式不同有乱码的问题
    if ([[fileObject.displayName pathExtension] isEqualToString:@"txt"]) {
        NSString *text = [NSString stringWithContentsOfFile:filePath usedEncoding:nil error:nil];
        if (!text) {
            //不能识别就按GBK编码再解码一次
            NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGBK_95);
            text = [NSString stringWithContentsOfFile:filePath encoding:enc error:nil];
        }
        if (!text) {
            //不能识别就按GB18030编码再解码一次
            NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            text = [NSString stringWithContentsOfFile:filePath encoding:enc error:nil];
        }
        if (text) {
            [webView loadHTMLString:text baseURL:nil];
        } else {
            [webView loadRequest:request];
        }
    } else {
        [webView loadRequest:request];
    }
    [self.view addSubview:webView];
}

- (void)downloadFile
{
    _isDownloading = YES;
    YSF_NIMFileObject *fileObject = (YSF_NIMFileObject *)_message.messageObject;
    __weak typeof(self) weakSelf = self;
    [[[YSF_NIMSDK sharedSDK] resourceManager] download:fileObject.url filepath:fileObject.path progress:^(CGFloat progress) {
        [weakSelf.loadProgressView setProgress:progress animated:YES];
        weakSelf.downloadingLabel.text = [NSString stringWithFormat:@"正在下载...（%@/%@）", [NSString getFileSizeTextWithFileLength:fileObject.fileLength*progress], [NSString getFileSizeTextWithFileLength:fileObject.fileLength]];
    } completion:^(NSError *error) {
        if (!error) {
            if ([weakSelf canOpenWithFileName:fileObject.displayName]) {
                [weakSelf loadFile];
            } else {
                weakSelf.downloadingLabel.hidden = YES;
                weakSelf.loadProgressView.hidden = YES;
                weakSelf.cancelDownloadButton.hidden = YES;
                weakSelf.fileLengthLabel.hidden = NO;
                weakSelf.openByOtherAppsButton.hidden = NO;
                weakSelf.tipLabel.hidden = NO;
            }
        }
        if ([weakSelf.reachability isReachable]) {
            weakSelf.isDownloading = NO;
        }
    }];
}





@end
