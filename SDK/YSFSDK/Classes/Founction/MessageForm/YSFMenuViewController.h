//
//  YSFMenuViewController.h
//  YSFSDK
//
//  Created by liaosipei on 2019/3/27.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YSFMessageFormField.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^YSFMenuCompletion)(void);

@interface YSFMenuViewController : UIViewController

- (instancetype)initWithFieldType:(YSFMessageFormFieldType)type
                            title:(NSString *)title
                      optionArray:(NSArray *)optionArray
                       completion:(YSFMenuCompletion)completion;

@end

NS_ASSUME_NONNULL_END
