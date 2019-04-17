//
//  NIMInputView.m
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "YSFInputView.h"
#import <AVFoundation/AVFoundation.h>
#import "YSFInputMoreContainerView.h"
#import "YSFEmoticonView.h"
#import "YSFInputAudioRecordIndicatorView.h"
#import "YSFInputToolBar.h"
#import "YSFInputTextView.h"
#import "YSFKeyboardManager.h"
#import "QYCustomUIConfig.h"
#import "YSFEmoticonDataManager.h"


@interface YSFInputView () <UITextViewDelegate, YSFKeyboardObserver, YSFEmoticonViewDelegate> {
    CGFloat _inputTextViewOlderHeight;
}
@property (nonatomic, weak) id<YSFInputDelegate> inputDelegate;
@property (nonatomic, weak) id<YSFInputActionDelegate> actionDelegate;

@property (nonatomic, assign) YSFInputStatus inputStatus;
@property (nonatomic, assign) NIMAudioRecordPhase recordPhase;

@property (nonatomic, strong) YSFInputAudioRecordIndicatorView *audioRecordIndicator;
@property (strong, nonatomic)  YSFInputMoreContainerView *moreContainer;

@end


@implementation YSFInputView
+ (Class)actionBarClass {
    return YSFActionBar.class;
}

+ (Class)toolBarClass {
    return YSFInputToolBar.class;
}

- (instancetype)initWithFrame:(CGRect)frame inputType:(YSFInputStatus)inputStatus {
    self = [super initWithFrame:frame];
    if (self) {
        //设置最大输入字数
        _maxTextLength = 4500;
        //最大输入行数
        _maxInputLines = 4;
        
        _inputStatus = inputStatus;
        _recording = NO;
        _recordPhase = AudioRecordPhaseEnd;
        _inputTextViewOlderHeight = YSFTopInputViewHeight;

        if (_inputStatus == YSFInputStatusAudio) {
            [self changeInputTypeToAudio];
        } else {
            [self changeInputTypeToText];
        }
        
        [self addKeyboardObserver];
        
        _actionBar = [[[self.class actionBarClass] alloc] init];
        _actionBar.hidden = YES;
        _actionBarHeight = [[self.class actionBarClass] heightForActionBar];
        _actionBar.ysf_frameHeight = _actionBarHeight;
        [self addSubview:_actionBar];

        _toolBar = [[[self.class toolBarClass] alloc] initWithFrame:CGRectZero];
        _toolBar.ysf_frameSize = [_toolBar sizeThatFits:CGSizeMake(self.ysf_frameWidth, CGFLOAT_MAX)];
        _toolBar.recordLabel.text = @"按住 说话";
        _toolBar.inputTextView.delegate = self;
        [self addSubview:_toolBar];
        
        [_toolBar.inputTextView setCustomUI];
        _inputBottomViewHeight = 0;
        [_toolBar.recordButton setHidden:YES];
        [_toolBar.recordLabel setHidden:YES];
        
        [_toolBar.emoticonBtn addTarget:self action:@selector(onTouchEmoticonBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_toolBar.moreMediaBtn addTarget:self action:@selector(onTouchMoreBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_toolBar.voiceBtn addTarget:self action:@selector(onTouchVoiceBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_toolBar.recordButton addTarget:self action:@selector(onTouchRecordBtnDown:) forControlEvents:UIControlEventTouchDown];
        [_toolBar.recordButton addTarget:self action:@selector(onTouchRecordBtnDragInside:) forControlEvents:UIControlEventTouchDragInside];
        [_toolBar.recordButton addTarget:self action:@selector(onTouchRecordBtnDragOutside:) forControlEvents:UIControlEventTouchDragOutside];
        [_toolBar.recordButton addTarget:self action:@selector(onTouchRecordBtnUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [_toolBar.recordButton addTarget:self action:@selector(onTouchRecordBtnUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
        [_toolBar.imageButton addTarget:self action:@selector(onTouchImageBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        __weak typeof(self) weakSelf = self;
        _toolBar.inputTextView.pasteImageCallback = ^(UIImage *image) {
            [weakSelf.actionDelegate onPasteImage:image];
        };
    }
    return self;
}

- (void)dealloc {
    [self removeKeyboardObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _toolBar.inputTextView.delegate = nil;
}

- (void)layoutSubviews {
    if (_actionBar && !_actionBar.hidden) {
        _emoticonView.ysf_frameTop = _inputTextViewOlderHeight + _actionBarHeight;
        _moreContainer.ysf_frameTop = _inputTextViewOlderHeight + _actionBarHeight;
    } else {
        _emoticonView.ysf_frameTop = _inputTextViewOlderHeight;
        _moreContainer.ysf_frameTop = _inputTextViewOlderHeight;
    }
    _actionBar.ysf_frameTop = 0;
    _actionBar.ysf_frameWidth = self.ysf_frameWidth;
    if (@available(iOS 11, *)) {
        _toolBar.ysf_frameLeft = self.safeAreaInsets.left;
    }
    _toolBar.ysf_frameWidth = self.ysf_frameWidth;
    if (@available(iOS 11, *)) {
        _toolBar.ysf_frameWidth -= self.safeAreaInsets.left + self.safeAreaInsets.right;
    }
    if (_actionBar.hidden == NO) {
        _toolBar.ysf_frameTop = _actionBar.ysf_frameHeight;
    } else {
        _toolBar.ysf_frameTop = 0;
    }
}

#pragma mark - Setter & Getter
- (void)setInputDelegate:(id<YSFInputDelegate>)delegate {
    _inputDelegate = delegate;
}

- (void)setInputActionDelegate:(id<YSFInputActionDelegate>)actionDelegate {
    _actionDelegate = actionDelegate;
}

- (void)setInputStatus:(YSFInputStatus)inputStatus {
    _inputStatus = inputStatus;
    if (self.inputDelegate && [self.inputDelegate respondsToSelector:@selector(changeInputTypeTo:)]) {
        [self.inputDelegate changeInputTypeTo:inputStatus];
    }
    if (inputStatus != YSFInputStatusEmoticon) {
        [self removeEmoticonView];
    }
    if (inputStatus != YSFInputStatusMore) {
        [self removeMoreContainerView];
    }
}

- (void)setActionInfoArray:(NSArray<YSFActionInfo *> *)actionInfoArray {
    if (_actionBar.actionInfoArray.count == 0 && actionInfoArray.count > 0) {
        self.ysf_frameHeight += self.actionBarHeight;
    } else if (_actionBar.actionInfoArray.count > 0 && actionInfoArray.count == 0) {
        self.ysf_frameHeight -= self.actionBarHeight;
    }
    _actionBar.actionInfoArray = actionInfoArray;
    _actionBar.hidden = (actionInfoArray.count == 0);
    [self willShowBottomHeight:_bottomHeight animation:NO];
}

- (void)setActionCallback:(SelectActionCallback)callback {
    _actionBar.selectActionCallback = callback;
}

- (NSString *)inputText {
    return [_toolBar.inputTextView text];
}

- (void)setInputText:(NSString *)inputText {
    [_toolBar layoutIfNeeded];
    [_toolBar.inputTextView setText:inputText];
    [self inputTextViewToHeight:[self getTextViewContentH:_toolBar.inputTextView]];;
}

- (void)setInputTextPlaceHolder:(NSString*)placeHolder {
    [_toolBar.inputTextView setPlaceHolder:placeHolder];
}

- (YSFInputAudioRecordIndicatorView *)audioRecordIndicator {
    if(!_audioRecordIndicator) {
        _audioRecordIndicator = [[YSFInputAudioRecordIndicatorView alloc] init];
    }
    return _audioRecordIndicator;
}

- (void)setRecordPhase:(NIMAudioRecordPhase)recordPhase {
    if (recordPhase == AudioRecordPhaseStart || recordPhase == AudioRecordPhaseRecording)  {
        _toolBar.recordLabel.text = @"松开 结束";
    } else if (recordPhase == AudioRecordPhaseCancelling) {
        _toolBar.recordLabel.text = @"按住 说话";
        _toolBar.recordButton.highlighted = YES;
    } else {
        _toolBar.recordLabel.text = @"按住 说话";
        _toolBar.recordButton.highlighted = NO;
    }
    NIMAudioRecordPhase prevPhase = _recordPhase;
    _recordPhase = recordPhase;
    self.audioRecordIndicator.phase = _recordPhase;
    if(prevPhase == AudioRecordPhaseEnd) {
        if(AudioRecordPhaseStart == _recordPhase) {
            if ([_actionDelegate respondsToSelector:@selector(onStartRecording)]) {
                [_actionDelegate onStartRecording];
            }
        }
    } else if (prevPhase == AudioRecordPhaseStart || prevPhase == AudioRecordPhaseRecording) {
        if (AudioRecordPhaseEnd == _recordPhase) {
            if ([_actionDelegate respondsToSelector:@selector(onStopRecording)]) {
                [_actionDelegate onStopRecording];
            }
        }
    } else if (prevPhase == AudioRecordPhaseCancelling) {
        if(AudioRecordPhaseEnd == _recordPhase) {
            if ([_actionDelegate respondsToSelector:@selector(onCancelRecording)]) {
                [_actionDelegate onCancelRecording];
            }
        }
    }
}

- (void)setRecording:(BOOL)recording {
    if(recording) {
        [[[UIApplication sharedApplication] keyWindow] addSubview:self.audioRecordIndicator];
        self.recordPhase = AudioRecordPhaseRecording;
    } else {
        [self.audioRecordIndicator removeFromSuperview];
        self.audioRecordIndicator = nil;
    }
    _recording = recording;
}

- (void)setHumanOrMachine:(BOOL)humanOrMachine {
    //若从人工变为机器人，且表情面板展开，则修改输入状态为文字
    if (_toolBar.humanOrMachine && !humanOrMachine && _inputStatus == YSFInputStatusEmoticon) {
        [self.toolBar.inputTextView becomeFirstResponder];
    }
    _toolBar.humanOrMachine = humanOrMachine;
    if (!humanOrMachine) {
        [self changeInputTypeToText];
    }
}

#pragma mark - Public
- (void)updateAudioRecordTime:(NSTimeInterval)time {
    
}

- (void)updateVoicePower:(float)power {
    
}

#pragma mark - Layout
- (CGFloat)getTextViewContentH:(UITextView *)textView {
    return YSFIOS8 ? textView.contentSize.height : ceilf([textView sizeThatFits:textView.frame.size].height);
}

- (void)updateAllButtonImages {
    if (_inputStatus == YSFInputStatusText) {
        [self updateVoiceBtnImages:YES];
        [self updateEmotAndTextBtnImages:YES];
        [_toolBar.recordButton setHidden:YES];
        [_toolBar.recordLabel setHidden:YES];
        [_toolBar.inputTextView setHidden:NO];
        [_toolBar.inputTextBkgImage setHidden:NO];
    } else if(_inputStatus == YSFInputStatusAudio) {
        [self updateVoiceBtnImages:NO];
        [self updateEmotAndTextBtnImages:YES];
        [_toolBar.recordButton setHidden:NO];
        [_toolBar.recordLabel setHidden:NO];
        [_toolBar.inputTextView setHidden:YES];
        [_toolBar.inputTextBkgImage setHidden:YES];
    } else if (_inputStatus == YSFInputStatusEmoticon) {
        [self updateVoiceBtnImages:YES];
        [self updateEmotAndTextBtnImages:NO];
        [_toolBar.recordButton setHidden:YES];
        [_toolBar.recordLabel setHidden:YES];
        [_toolBar.inputTextView setHidden:NO];
        [_toolBar.inputTextBkgImage setHidden:NO];
    } else {
        [self updateVoiceBtnImages:YES];
        [self updateEmotAndTextBtnImages:YES];
        [_toolBar.recordButton setHidden:YES];
        [_toolBar.recordLabel setHidden:YES];
        [_toolBar.inputTextView setHidden:NO];
        [_toolBar.inputTextBkgImage setHidden:NO];
    }
}

- (void)updateVoiceBtnImages:(BOOL)selected {
    [_toolBar.voiceBtn setImage:(selected ? [UIImage ysf_imageInKit:@"icon_toolview_voice_normal"] : [UIImage ysf_imageInKit:@"icon_toolview_keyboard_normal"])
                       forState:UIControlStateNormal];
    [_toolBar.voiceBtn setImage:(selected ? [UIImage ysf_imageInKit:@"icon_toolview_voice_pressed"] : [UIImage ysf_imageInKit:@"icon_toolview_keyboard_pressed"])
                       forState:UIControlStateHighlighted];
}

- (void)updateEmotAndTextBtnImages:(BOOL)selected {
    [_toolBar.emoticonBtn setImage:(selected ? [UIImage ysf_imageInKit:@"icon_toolview_emotion_normal"] : [UIImage ysf_imageInKit:@"icon_toolview_keyboard_normal"])
                          forState:UIControlStateNormal];
    [_toolBar.emoticonBtn setImage:(selected ? [UIImage ysf_imageInKit:@"icon_toolview_emotion_pressed"] : [UIImage ysf_imageInKit:@"icon_toolview_keyboard_pressed"])
                          forState:UIControlStateHighlighted];
}

#pragma mark - Keyboard
- (void)addKeyboardObserver {
    [[YSFKeyboardManager defaultManager] addObserver:self];
}

- (void)removeKeyboardObserver {
    [[YSFKeyboardManager defaultManager] removeObserver:self];
}

- (void)keyboardChangedWithTransition:(YSFKeyboardTransition)transition {
    [UIView animateWithDuration:transition.animationDuration delay:0 options:transition.animationOption animations:^{
        [self willShowKeyboardFromFrame:transition.toFrame];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)willShowKeyboardFromFrame:(CGRect)toFrame {
    if (toFrame.origin.y == [[UIScreen mainScreen] bounds].size.height) {
        if (_inputStatus != YSFInputStatusEmoticon && _inputStatus != YSFInputStatusMore) {
            [self willShowBottomHeight:0 animation:NO];
        }
    } else {
        CGFloat bottomHeight = toFrame.size.height;
        CGFloat bottomMargin = [[QYCustomUIConfig sharedInstance] bottomMargin];
        if (bottomMargin > 0) {
            bottomHeight -= bottomMargin;
        } else {
            if (@available(iOS 11, *)) {
                bottomHeight -= self.ysf_viewController.view.safeAreaInsets.bottom;
            }
        }
        [self willShowBottomHeight:bottomHeight animation:NO];
    }
}

- (void)willShowBottomHeight:(CGFloat)bottomHeight animation:(BOOL)animation {
    self.bottomHeight = bottomHeight;
    CGRect fromFrame = self.frame;
    CGFloat toHeight = self.toolBar.frame.size.height + bottomHeight;
    if (!_actionBar.hidden) {
        toHeight += _actionBar.ysf_frameHeight;
    }
    CGRect toFrame = CGRectMake(fromFrame.origin.x, fromFrame.origin.y + (fromFrame.size.height - toHeight), fromFrame.size.width, toHeight);
    if (animation) {
        [UIView animateWithDuration:0.25 animations:^{
            self.frame = toFrame;
        }];
    } else {
        self.frame = toFrame;
    }
    
    if (bottomHeight == 0) {
        if (self.inputDelegate && [self.inputDelegate respondsToSelector:@selector(hideInputView)]) {
            [self.inputDelegate hideInputView];
        }
    } else {
        if (self.inputDelegate && [self.inputDelegate respondsToSelector:@selector(showInputView)]) {
            [self.inputDelegate showInputView];
        }
    }
    if (self.inputDelegate && [self.inputDelegate respondsToSelector:@selector(inputViewSizeToHeight:showInputView:)]) {
        [self.inputDelegate inputViewSizeToHeight:toHeight showInputView:!(bottomHeight==0)];
    }
}

- (void)inputTextViewToHeight:(CGFloat)toHeight {
    toHeight = MAX(YSFTopInputViewHeight, toHeight);
    toHeight = MIN(YSFTopInputViewMaxHeight, toHeight);

    [self inputTextViewChangeHeight:toHeight];
}

- (void)inputTextViewChangeHeight:(CGFloat)toHeight {
    if (toHeight != _inputTextViewOlderHeight) {
        CGFloat changeHeight = toHeight - _inputTextViewOlderHeight;
        CGRect rect = self.frame;
        rect.size.height += changeHeight;
        rect.origin.y -= changeHeight;
        self.frame = rect;
        
        rect = self.toolBar.frame;
        rect.size.height += changeHeight;
        [self updateInputTopViewFrame:rect];
        
        _inputTextViewOlderHeight = toHeight;
        
        if (_inputDelegate && [_inputDelegate respondsToSelector:@selector(inputViewSizeToHeight:showInputView:)]) {
            [_inputDelegate inputViewSizeToHeight:self.frame.size.height showInputView:YES];
        }
    }
}

- (void)updateInputTopViewFrame:(CGRect)rect {
    self.toolBar.frame = rect;
    [self.toolBar layoutIfNeeded];
    self.emoticonView.ysf_frameTop = self.toolBar.ysf_frameBottom;
}

//键盘弹出后视图兼容iPad
- (CGRect)resetEndFrameForIPad:(CGRect)endFrame {
    if (_containerController && endFrame.size.height > 0) {
        BOOL flag = NO;
        if (_containerController.presentingViewController && _containerController.modalPresentationStyle == UIModalPresentationFormSheet) {
            flag = YES;
        } else {
            if (_containerController.navigationController
                && _containerController.navigationController.presentingViewController
                && _containerController.navigationController.modalPresentationStyle == UIModalPresentationFormSheet) {
                flag = YES;
            }
        }
        if (flag) {
            CGFloat sheetHeight = _containerController.view.frame.size.height;
            CGFloat fullHeight = [UIScreen mainScreen].bounds.size.height;
            CGFloat height = (fullHeight - sheetHeight)*0.5;
            
            if (height <= endFrame.size.height) {
                endFrame = CGRectMake(endFrame.origin.x, endFrame.origin.y, endFrame.size.width, endFrame.size.height - height);
            }
        }
    }
    return endFrame;
}

#pragma mark - Actions
- (void)onTouchVoiceBtn:(id)sender {
    // image change
    if (_inputStatus != YSFInputStatusAudio) {
        [self changeInputTypeToAudio];
    } else {
        [self changeInputTypeToText];
        [self.toolBar.inputTextView becomeFirstResponder];
    }
}

- (IBAction)onTouchRecordBtnDown:(id)sender {
    // start Recording
    self.recordPhase = AudioRecordPhaseStart;
}

- (IBAction)onTouchRecordBtnUpInside:(id)sender {
    // finish Recording
    self.recordPhase = AudioRecordPhaseEnd;
}

- (IBAction)onTouchRecordBtnUpOutside:(id)sender {
    //TODO cancel Recording
    self.recordPhase = AudioRecordPhaseEnd;
}

- (IBAction)onTouchRecordBtnDragInside:(id)sender {
    //TODO @"手指上滑，取消发送"
    self.recordPhase = AudioRecordPhaseRecording;
}

- (IBAction)onTouchRecordBtnDragOutside:(id)sender {
    //TODO @"松开手指，取消发送"
    self.recordPhase = AudioRecordPhaseCancelling;
}

- (void)onTouchEmoticonBtn:(id)sender {
    if (_inputStatus != YSFInputStatusEmoticon) {
        if (!_emoticonView) {
            _emoticonView = [[YSFEmoticonView alloc] initWithFrame:CGRectMake(0, _inputTextViewOlderHeight, self.ysf_frameWidth, YSFBottomInputViewHeight_Max)];
            _emoticonView.delegate = self;
            [self addSubview:_emoticonView];
        }
        [self bringSubviewToFront:_emoticonView];
        _emoticonView.hidden = NO;
        _moreContainer.hidden = YES;
        
        self.inputStatus = YSFInputStatusEmoticon;
        _inputBottomViewHeight = YSFBottomInputViewHeight_Max;
        [self endTextEditWithInputBottomViewHeight:_inputBottomViewHeight];
    } else {
        self.inputStatus = YSFInputStatusText;
        _inputBottomViewHeight = 0;
        [self.toolBar.inputTextView becomeFirstResponder];
    }
    [self inputTextViewToHeight:[self getTextViewContentH:self.toolBar.inputTextView]];;
    [self updateAllButtonImages];
}

- (void)removeEmoticonView {
    if (_emoticonView) {
        _emoticonView.hidden = YES;
        [_emoticonView removeFromSuperview];
        _emoticonView = nil;
    }
}

- (void)onTouchMoreBtn:(id)sender {
    if (_inputStatus != YSFInputStatusMore) {
        NSUInteger count = [[QYCustomUIConfig sharedInstance].customInputItems count];
        CGFloat height = (count <= YSFMore_kItemColumns) ? YSFBottomInputViewHeight_Min : YSFBottomInputViewHeight_Max;
        if (!_moreContainer) {
            _moreContainer = [[YSFInputMoreContainerView alloc] initWithFrame:CGRectMake(0, _inputTextViewOlderHeight, self.ysf_frameWidth, height)];
            [self addSubview:_moreContainer];
        }
        [self bringSubviewToFront:_moreContainer];
        _moreContainer.hidden = NO;
        _emoticonView.hidden = YES;
        
        self.inputStatus = YSFInputStatusMore;
        _inputBottomViewHeight = height;
        [self endTextEditWithInputBottomViewHeight:_inputBottomViewHeight];
    } else {
        self.inputStatus = YSFInputStatusText;
        _inputBottomViewHeight = 0;
        [self.toolBar.inputTextView becomeFirstResponder];
    }
    [self inputTextViewToHeight:[self getTextViewContentH:self.toolBar.inputTextView]];;
    [self updateAllButtonImages];
}

- (void)removeMoreContainerView {
    if (_moreContainer) {
        _moreContainer.hidden = YES;
        [_moreContainer removeFromSuperview];
        _moreContainer = nil;
    }
}

- (void)onTouchImageBtn:(id)sender {
    if ([self.actionDelegate respondsToSelector:@selector(onMediaPicturePressed)]) {
        [self.actionDelegate onMediaPicturePressed];
        self.inputStatus = YSFInputStatusText;
        _inputBottomViewHeight = 0;
        [self endTextEditWithInputBottomViewHeight:0];
        [self updateAllButtonImages];
    }
}

- (void)changeInputTypeToText {
    self.inputStatus = YSFInputStatusText;
    [self inputTextViewToHeight:[self getTextViewContentH:self.toolBar.inputTextView]];;
    [self updateAllButtonImages];
}

- (void)changeInputTypeToAudio {
    __weak typeof(self) weakSelf = self;
    if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]) {
        [[AVAudioSession sharedInstance] performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.inputStatus = YSFInputStatusAudio;
                    if ([weakSelf.toolBar.inputTextView isFirstResponder]) {
                        weakSelf.inputBottomViewHeight = 0;
                        [weakSelf.toolBar.inputTextView resignFirstResponder];
                    } else if (weakSelf.inputBottomViewHeight > 0) {
                        weakSelf.inputBottomViewHeight = 0;
                        [weakSelf willShowBottomHeight:weakSelf.inputBottomViewHeight animation:NO];
                    }
                    [weakSelf inputTextViewChangeHeight:YSFTopInputViewHeight];;
                    [weakSelf updateAllButtonImages];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:@"没有麦克风权限"
                                                message:@"请在iPhone的“设置-隐私-麦克风”选项中，允许访问你的麦克风。"
                                               delegate:nil
                                      cancelButtonTitle:@"确定"
                                      otherButtonTitles:nil] show];
                });
            }
        }];
    }
}

- (void)endTextEditWithInputBottomViewHeight:(CGFloat)inputBottomViewHeight {
    if ([self.toolBar.inputTextView isFirstResponder]) {
        [self.toolBar.inputTextView resignFirstResponder];
    }
    [self willShowBottomHeight:inputBottomViewHeight animation:YES];
}

- (void)inputBottomViewHeightToZero {
    if (_inputStatus != YSFInputStatusAudio) {
        _inputBottomViewHeight = 0.0;
        self.inputStatus = YSFInputStatusText;
        [self endTextEditWithInputBottomViewHeight:0];
        [self updateAllButtonImages];
    }
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.inputStatus = YSFInputStatusText;
    [self updateAllButtonImages];
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        NSString *sendText = textView.text;
        if ([sendText length]) {
            if ([self.actionDelegate respondsToSelector:@selector(onSendText:)]) {
                BOOL sended = [self.actionDelegate onSendText:sendText];
                if (sended) {
                    textView.text = @"";
                    [textView layoutIfNeeded];
                    [self inputTextViewToHeight:[self getTextViewContentH:textView]];;
                }
            }
        }
        return NO;
    }
    if ([text isEqualToString:@""]) {
        //ios cut and delete command use the same @"", has conflict.
        //当有选择一部分的时候直接删除或剪切
        if (range.length > 1) {
            return YES;
        }
        //delete Emoji
        //一般表情至少包括[*]有3个字符
        //只有当找到表情的时候才手动删除返回NO,其他情况交给系统删除
        NSRange range = [self rangeForEmoticon];
        if (range.length != 1) {
            [self deleteTextRange:range];
            return NO;
        }
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    if ([self textViewHasChanged:textView]) {
        NSString *str = textView.text;
        if (str.length > self.maxTextLength) {
            textView.text = [str substringToIndex:self.maxTextLength];
        }
        if (self.actionDelegate && [self.actionDelegate respondsToSelector:@selector(onTextChanged:)]) {
            [self.actionDelegate onTextChanged:self];
        }
        [self inputTextViewToHeight:[self getTextViewContentH:textView]];
    }
}

- (BOOL)textViewHasChanged:(UITextView *)textView {
    NSString *lang = [(UITextInputMode*)[[UITextInputMode activeInputModes] firstObject] primaryLanguage]; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) {
        UITextRange *selectedRange = [textView markedTextRange];
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        if (!position) {
            return YES;
        }
    } else {
        return YES;
    }
    return NO;
}

#pragma mark - Emoticon
- (void)onTouchEmoticonSendButton:(id)sender {
    if ([self.toolBar.inputTextView.text length] > 0) {
        if ([self.actionDelegate respondsToSelector:@selector(onSendText:)]) {
            if ([self.actionDelegate onSendText:self.toolBar.inputTextView.text]) {
                self.toolBar.inputTextView.text = @"";
                [self textViewDidChange:self.toolBar.inputTextView];
            }
        }
    }
}

- (void)selectEmoticonItem:(YSFEmoticonItem *)selectItem {
    if (selectItem.type == YSFEmoticonTypeDefaultEmoji || selectItem.type == YSFEmoticonTypeCustomEmoji) {
        NSString *tag = selectItem.emoticonTag;
        if (!tag.length) {
            tag = [[YSFEmoticonDataManager sharedManager] emoticonTagForID:selectItem.emoticonID];
        }
        if (tag.length) {
            [self.toolBar.inputTextView insertText:selectItem.emoticonTag];
            [self.toolBar.inputTextView scrollRangeToVisible:NSMakeRange(self.toolBar.inputTextView.text.length, 1)];
        }
    } else if (selectItem.type == YSFEmoticonTypeCustomGraph) {
        if ([self.actionDelegate respondsToSelector:@selector(onSelectEmoticonGraphicItem:)]) {
            [self.actionDelegate onSelectEmoticonGraphicItem:selectItem];
        }
    } else if (selectItem.type == YSFEmoticonTypeDelete) {
        NSRange range = [self rangeForEmoticon];
        [self deleteTextRange:range];
    }
}

- (void)deleteTextRange:(NSRange)range {
    NSString *text = [self.toolBar.inputTextView text];
    if (range.location + range.length <= [text length]
        && range.location != NSNotFound
        && range.length != 0) {
        NSString *newText = [text stringByReplacingCharactersInRange:range withString:@""];
        NSRange newSelectRange = NSMakeRange(range.location, 0);
        [self.toolBar.inputTextView setText:newText];
        [self textViewDidChange:self.toolBar.inputTextView];
        [self.toolBar.inputTextView setSelectedRange:newSelectRange];
    }
}

- (NSRange)rangeForEmoticon {
    NSString *text = [self.toolBar.inputTextView text];
    NSRange range = [self.toolBar.inputTextView selectedRange];
    NSString *selectedText = range.length ? [text substringWithRange:range] : text;
    NSInteger endLocation = range.location + range.length;
    if (range.length) {
        return range;
    }
    if (endLocation <= 0) {
        return NSMakeRange(NSNotFound, 0);
    }
    NSInteger index = -1;
    if ([selectedText hasSuffix:@"]"]) {
        for (NSInteger i = endLocation; i-1 >= 0 ; i--) {
            NSRange subRange = NSMakeRange(i - 1, 1);
            NSString *subString = [text substringWithRange:subRange];
            if ([subString compare:@"["] == NSOrderedSame) {
                index = i - 1;
                break;
            }
        }
    }
    if (index == -1) {
        return NSMakeRange(endLocation - 1, 1);
    } else {
        NSRange emoticonRange = NSMakeRange(index, endLocation - index);
        NSString *name = [text substringWithRange:emoticonRange];
        YSFEmoticonItem *item = [[YSFEmoticonDataManager sharedManager] emoticonItemForTag:name];
        return item ? emoticonRange : NSMakeRange(endLocation - 1, 1);
    }
}

@end
