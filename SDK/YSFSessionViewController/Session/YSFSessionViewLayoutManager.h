//
//  NIMSessionViewLayoutManager.h
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

@class YSFInputView;

@interface YSFSessionViewLayoutManager : NSObject

@property (nonatomic, assign) CGRect viewRect;

@property (nonatomic,weak) UITableView *tableView;

- (instancetype)initWithInputView:(YSFInputView*)inputView tableView:(UITableView*)tableview;

- (void)insertTableViewCellAtRows:(NSArray*)addIndexs scrollToBottom:(BOOL)scrollToBottom;

- (void)updateCellAtIndex:(NSInteger)index model:(id)model;

-(void)deleteCellAtIndexs:(NSArray*)delIndexs;

-(void)reloadDataToIndex:(NSInteger)index withAnimation:(BOOL)animated;

@end
