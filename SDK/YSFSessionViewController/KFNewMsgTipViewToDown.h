#import <UIKit/UIKit.h>

@protocol KFNewMsgTipViewToDownDelegate <NSObject>

-(void)onScrollToNewMessagesToDown;

@end

@interface KFNewMsgTipViewToDown : UIView

@property (weak,nonatomic)id<KFNewMsgTipViewToDownDelegate> delegate;

-(instancetype)initWithUnreadCount:(int)unreadCount;

-(void)setUnreadCount:(int)unreadCount;

@end
