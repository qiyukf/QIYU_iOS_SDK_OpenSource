//
//  NIMSessionViewLayoutManager.h
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

@class YSFInputView;

@interface YSFSessionViewLayoutManager : NSObject

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, assign) CGRect viewRect;


- (instancetype)initWithInputView:(YSFInputView*)inputView tableView:(UITableView*)tableview;

- (void)insertTableViewCellAtRows:(NSArray*)addIndexs scrollToBottom:(BOOL)scrollToBottom;
- (void)updateCellAtIndex:(NSInteger)index
             refreshModel:(id)model
             rowAnimation:(UITableViewRowAnimation)animation;
- (void)deleteCellAtIndexs:(NSArray*)delIndexs;
- (void)reloadDataToIndex:(NSInteger)index withAnimation:(BOOL)animated;
- (void)scrollToBottomAtIndex:(NSInteger)index;

@end
