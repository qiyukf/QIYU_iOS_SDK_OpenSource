//
//  YSFMenuViewController.m
//  YSFSDK
//
//  Created by liaosipei on 2019/3/27.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "YSFMenuViewController.h"
#import "YSFMenuModel.h"

static NSString * const YSFMenuCellIdentifier = @"YSFMenuCellIdentifier";
static CGFloat YSFMenuHorizontalSpace = 16.0f;
static CGFloat YSFMenuSubmitButtonHeight = 48.0f;
static CGFloat YSFMenuSubmitButtonVerticalSpace = 15.0f;

typedef NS_ENUM(NSInteger, YSFMenuSubmitType) {
    YSFMenuSubmitTypeEnable = 0,    //确定，可点击
    YSFMenuSubmitTypeUnable,        //确定，不可点击
    YSFMenuSubmitTypeHighlighted,   //确定，高亮状态
    YSFMenuSubmitTypeSubmitting,    //确定中，不可点击
};


@interface YSFMenuViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) YSFMessageFormFieldType type;
@property (nonatomic, strong) NSArray *optionArray;
@property (nonatomic, assign) NSUInteger selectIndex;
@property (nonatomic, copy) YSFMenuCompletion completion;
@property (nonatomic, copy) NSString *oldOptions;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *sendView;
@property (nonatomic, strong) UIView *seperatorLine;
@property (nonatomic, strong) UIButton *sendButton;

@end


@implementation YSFMenuViewController
- (void)dealloc {
    _tableView.dataSource = nil;
    _tableView.delegate = nil;
}

- (instancetype)initWithFieldType:(YSFMessageFormFieldType)type
                            title:(NSString *)title
                      optionArray:(NSArray *)optionArray
                       completion:(YSFMenuCompletion)completion {
    self = [super init];
    if (self) {
        self.type = type;
        self.title = title;
        self.optionArray = optionArray;
        self.oldOptions = [self getSelectedOptionsString];
        
        if (type == YSFMessageFormFieldTypeSingleMenu) {
            for (NSUInteger i = 0; i < [self.optionArray count]; i++) {
                YSFMenuModel *model = [self.optionArray objectAtIndex:i];
                if (model.selected) {
                    self.selectIndex = i;
                    break;
                }
            }
        }
        _completion = completion;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = YSFColorFromRGB(0xeeeeee);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 48;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:YSFMenuCellIdentifier];
    [self.view addSubview:self.tableView];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    //sendView
    self.sendView = [[UIView alloc] initWithFrame:CGRectZero];
    self.sendView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.sendView];
    //seperatorLine
    self.seperatorLine = [[UIView alloc] init];
    self.seperatorLine.backgroundColor = YSFColorFromRGB(0xcccccc);
    [self.sendView addSubview:self.seperatorLine];
    //sendButton
    self.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sendButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    self.sendButton.layer.cornerRadius = 3.0;
    [self.sendButton addTarget:self action:@selector(onSendTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.sendButton addTarget:self action:@selector(onSendTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.sendButton addTarget:self action:@selector(onSendTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    [self.sendView addSubview:self.sendButton];
    [self updateSendButtonEnable:YSFMenuSubmitTypeUnable];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    CGFloat lineHeight = 1.0 / [UIScreen mainScreen].scale;
    CGFloat bottom = 0;
    if (@available(iOS 11, *)) {
        bottom = self.view.safeAreaInsets.bottom;
    }
    self.tableView.frame = CGRectMake(0, 0, width, height - bottom - 2 * YSFMenuSubmitButtonVerticalSpace - YSFMenuSubmitButtonHeight);
    self.sendView.frame = CGRectMake(0, CGRectGetMaxY(self.tableView.frame), width, 2 * YSFMenuSubmitButtonVerticalSpace + YSFMenuSubmitButtonHeight);
    self.sendButton.frame = CGRectMake(YSFMenuHorizontalSpace,
                                       YSFMenuSubmitButtonVerticalSpace,
                                       width - 2 * YSFMenuHorizontalSpace,
                                       YSFMenuSubmitButtonHeight);
    self.seperatorLine.frame = CGRectMake(0, 0, width, lineHeight);
}

- (void)updateSendButtonEnable:(YSFMenuSubmitType)type {
    if (type == YSFMenuSubmitTypeEnable) {
        self.view.userInteractionEnabled = YES;
        _sendButton.enabled = YES;
        [_sendButton setTitle:@"确 认" forState:UIControlStateNormal];
        _sendButton.backgroundColor = YSFColorFromRGBA(0x5e94e2, 1);
    } else if (type == YSFMenuSubmitTypeUnable) {
        self.view.userInteractionEnabled = YES;
        _sendButton.enabled = NO;
        [_sendButton setTitle:@"确 认" forState:UIControlStateNormal];
        _sendButton.backgroundColor = YSFColorFromRGBA(0x5e94e2, 0.6);
    } else if (type == YSFMenuSubmitTypeHighlighted) {
        self.view.userInteractionEnabled = YES;
        _sendButton.enabled = YES;
        [_sendButton setTitle:@"确 认" forState:UIControlStateNormal];
        _sendButton.backgroundColor = YSFColorFromRGBA(0x5e94e2, 0.6);
    } else if (type == YSFMenuSubmitTypeSubmitting) {
        self.view.userInteractionEnabled = NO;
        _sendButton.enabled = NO;
        [_sendButton setTitle:@"确认中..." forState:UIControlStateNormal];
        _sendButton.backgroundColor = YSFColorFromRGBA(0x5e94e2, 0.6);
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.optionArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:YSFMenuCellIdentifier forIndexPath:indexPath];
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.separatorInset = UIEdgeInsetsZero;
    cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
    
    YSFMenuModel *model = [self.optionArray objectAtIndex:indexPath.row];
    cell.textLabel.text = model.text;
    if (model.selected) {
        cell.textLabel.textColor = YSFColorFromRGB(0x337eff);
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.textLabel.textColor = YSFColorFromRGB(0x333333);
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    YSFMenuModel *selectModel = [self.optionArray objectAtIndex:indexPath.row];
    if (self.type == YSFMessageFormFieldTypeSingleMenu) {
        if (indexPath.row == self.selectIndex) {
            return;
        }
        YSFMenuModel *oldModel = [self.optionArray objectAtIndex:self.selectIndex];
        oldModel.selected = NO;
        NSIndexPath *oldIndex = [NSIndexPath indexPathForRow:self.selectIndex inSection:0];
        
        self.selectIndex = indexPath.row;
        selectModel.selected = YES;
        [self reloadRows:@[oldIndex, indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self updateSendButtonEnable:YSFMenuSubmitTypeEnable];
    } else if (self.type == YSFMessageFormFieldTypeMultipleMenu) {
        if (indexPath.row == 0) {
            YSFMenuModel *first = [self.optionArray firstObject];
            if (first && first.selected) {
                return;
            }
            if (!selectModel.selected) {
                for (YSFMenuModel *model in self.optionArray) {
                    model.selected = NO;
                }
                selectModel.selected = YES;
            }
            [self updateSendButtonEnable:YSFMenuSubmitTypeEnable];
        } else {
            selectModel.selected = !selectModel.selected;
            YSFMenuModel *firstModel = [self.optionArray objectAtIndex:0];
            firstModel.selected = NO;
            if (!selectModel.selected) {
                BOOL isAllUnselected = YES;
                if ([self.optionArray count] > 1) {
                    for (NSUInteger i = 1; i < [self.optionArray count]; i++) {
                        YSFMenuModel *model = [self.optionArray objectAtIndex:i];
                        if (model.selected) {
                            isAllUnselected = NO;
                            break;
                        }
                    }
                }
                if (isAllUnselected) {
                    firstModel.selected = YES;
                }
            }
            [self updateSendButtonEnable:YSFMenuSubmitTypeEnable];
        }
        [tableView reloadData];
    }
}

- (void)reloadRows:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    if (@available(iOS 11, *)) {
        __weak typeof(self) weakSelf = self;
        [self.tableView performBatchUpdates:^{
            [weakSelf.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
        } completion:^(BOOL finished) {
            
        }];
    } else {
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
        [self.tableView endUpdates];
    }
}

#pragma mark - Action
- (void)onSendTouchDown:(id)sender {
    [self updateSendButtonEnable:YSFMenuSubmitTypeHighlighted];
}

- (void)onSendTouchUpInside:(id)sender {
    [self updateSendButtonEnable:YSFMenuSubmitTypeSubmitting];
    if (self.completion) {
        self.completion();
        self.completion = nil;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onSendTouchUpOutside:(id)sender {
    [self updateSendButtonEnable:YSFMenuSubmitTypeEnable];
}

#pragma mark - Others
- (NSString *)getSelectedOptionsString {
    NSString *string = @"";
    for (YSFMenuModel *model in self.optionArray) {
        if (model.selected && model.text.length) {
            string = [string stringByAppendingString:model.text];
        }
    }
    return string;
}

@end
