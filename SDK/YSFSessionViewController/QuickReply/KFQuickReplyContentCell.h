//
//  KFQuickReplyContentCell.h
//  QYKF
//
//  Created by Jacky Yu on 2018/3/7.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YSFQuickReplyContentInfo;

@interface YSFQuickReplyContentCell : UITableViewCell

@property (nonatomic, copy) NSString *searchText;
@property (nonatomic, assign) BOOL onlyMatchFirst;

- (void)refresh:(NSString *)keyword showContent:(NSString *)showContent;

@end
