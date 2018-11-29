//
//  NIMSessionViewLayoutManager.m
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "YSFSessionViewLayoutManager.h"
#import "YSFInputView.h"
#import "UIScrollView+YSFKit.h"
#import "YSFMessageCellProtocol.h"
#import "YSFMessageModel.h"
#import "YSFMessageCell.h"
#import "QYCustomUIConfig.h"

#import "QYCustomSDK.h"
#import "YSFCustomMessageCell.h"

YSFNotification(kKFInputViewFrameChanged);
YSFNotification(kKFInputViewInputTypeChanged);

@interface YSFSessionViewLayoutManager()<YSFInputDelegate>

@property (nonatomic,weak) YSFInputView *inputView;

@end

@implementation YSFSessionViewLayoutManager


-(instancetype)initWithInputView:(YSFInputView*)inputView tableView:(UITableView*)tableview
{
    if (self = [self init]) {
        _inputView = inputView;
        _inputView.inputDelegate = self;
        _tableView = tableview;
        _tableView.ysf_frameHeight -= _inputView.ysf_frameHeight;
        _tableView.ysf_frameHeight -= [[QYCustomUIConfig sharedInstance] bottomMargin];
    }
    return self;
}

- (void)dealloc
{
    _inputView.inputDelegate = nil;
}

-(void)insertTableViewCellAtRows:(NSArray*)addIndexs scrollToBottom:(BOOL)scrollToBottom
{
    if (!addIndexs.count) {
        return;
    }
    NSMutableArray *addIndexPathes = [NSMutableArray array];
    [addIndexs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [addIndexPathes addObject:[NSIndexPath indexPathForRow:[obj integerValue] inSection:0]];
    }];
    
    [_tableView beginUpdates];
    [_tableView insertRowsAtIndexPaths:addIndexPathes withRowAnimation:UITableViewRowAnimationNone];
    [_tableView endUpdates];
    
    __weak typeof(self) weakSelf = self;
    NSTimeInterval scrollDelay = .05f;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(scrollDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSIndexPath *indexPath = [addIndexPathes lastObject];
        NSInteger sectionNumber = [weakSelf.tableView numberOfRowsInSection:indexPath.section];
        if (indexPath.row > sectionNumber - 1) {
            indexPath = [NSIndexPath indexPathForRow:sectionNumber - 1 inSection:indexPath.section];
        }
        if ([YSF_NIMSDK sharedSDK].sdkOrKf) {
            [weakSelf.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
        else {
            if (scrollToBottom) {
                [weakSelf.tableView ysf_scrollToBottom:YES];
            }
        }
    });
}

- (void)updateCellAtIndex:(NSInteger)index model:(id)model
{
    if (index > -1) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        if ([model isKindOfClass:[YSFMessageModel class]]) {
            YSFMessageCell *cell = (YSFMessageCell *)[_tableView cellForRowAtIndexPath:indexPath];
            [cell refreshData:model];
        } else if ([model isKindOfClass:[QYCustomModel class]]) {
            YSFCustomMessageCell *cell = (YSFCustomMessageCell *)[_tableView cellForRowAtIndexPath:indexPath];
            [cell refreshData:model];
        }
    }
}

-(void)deleteCellAtIndexs:(NSArray*)delIndexs
{
    NSMutableArray *delIndexPathes = [NSMutableArray array];
    [delIndexs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [delIndexPathes addObject:[NSIndexPath indexPathForRow:[obj integerValue] inSection:0]];
    }];
    [_tableView beginUpdates];
    [_tableView deleteRowsAtIndexPaths:delIndexPathes withRowAnimation:UITableViewRowAnimationFade];
    [_tableView endUpdates];
}

-(void)reloadDataToIndex:(NSInteger)index withAnimation:(BOOL)animated
{
    [_tableView reloadData];
    if (index > 0) {
        [_tableView beginUpdates];
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:animated];
        [_tableView endUpdates];
    }
}

#pragma mark - YSFInputViewDelegate
//更改tableview布局
- (void)showInputView
{
    //[_tableView setUserInteractionEnabled:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:kKFInputViewFrameChanged object:nil];
}

- (void)hideInputView
{
    //[_tableView setUserInteractionEnabled:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kKFInputViewFrameChanged object:nil];

}

- (void)inputViewSizeToHeight:(CGFloat)toHeight showInputView:(BOOL)show
{
    //[_tableView setUserInteractionEnabled:!show];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect orginRect = [weakSelf.tableView frame];
        CGRect rect = orginRect;
        rect.origin.y = 0;
        rect.size.height = weakSelf.viewRect.size.height - toHeight;
        CGFloat bottomMargin = [[QYCustomUIConfig sharedInstance] bottomMargin];
        if (bottomMargin > 0) {
            rect.size.height -= bottomMargin;
        } else {
            if (@available(iOS 11, *)) {
                rect.size.height -= weakSelf.tableView.ysf_viewController.view.safeAreaInsets.bottom;
            }
        }
        if (!CGRectEqualToRect(orginRect, rect)) {
            [UIView animateWithDuration:0.3 animations:^{
                [weakSelf.tableView setFrame:rect];
            }];
            [weakSelf.tableView ysf_scrollToBottom:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:kKFInputViewFrameChanged object:@(YES)];
        }
    });
    
}

- (void)changeInputTypeTo:(YSFInputStatus)inputStatus {
    [[NSNotificationCenter defaultCenter] postNotificationName:kKFInputViewInputTypeChanged object:@(inputStatus)];
}


@end
