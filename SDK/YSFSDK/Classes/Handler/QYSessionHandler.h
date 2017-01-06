//
//  QYSessionHandler.h
//  YSFSDK
//
//  Created by 金华 on 16/3/15.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol QYSessionHandlerDelegate <NSObject>

- (void)pickImageCompeletedWithImages:(NSArray*)images;
- (void)pickImageCanceled;

@end

@interface QYSessionHandler : NSObject

@property (weak,nonatomic)id<QYSessionHandlerDelegate> delegate;

@end
