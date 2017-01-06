
typedef NS_ENUM(NSInteger, YSF_TipType) {
    YSF_TipTypeCurrentModeReceiver,
    YSF_TipTypeCurrentModeSpeaker,
    YSF_TipTypeCurrentPlayingReceiver,
    YSF_TipTypeCurrentPlayingSpeaker,
};

@interface YSFRecordTipView : UIView

- (void) setReceiverOrSpeaker:(YSF_TipType) tipType;

@end
