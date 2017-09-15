//
//  V_SlideCardCell.h
//  TanTanDemo
//
//  Created by zhujiamin on 2016/11/16.
//  Copyright © 2016年 zhujiamin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "M_SlideCard.h"

typedef NS_ENUM(NSInteger, CardState) {
    FirstCard = 0,
    SecondCard,
    ThirdCard,
    OtherCard,
};

@protocol V_SlideCardCellDelegate;

@interface V_SlideCardCell : UIView

@property (nonatomic, weak)   id<V_SlideCardCellDelegate> delegate;
@property (nonatomic, strong) M_SlideCard   *dataItem;

/** cell当前所处的状态 */
@property (nonatomic)         CardState     currentState;
/** cell之间的Y偏移，显示层叠效果*/
@property (nonatomic)         CGFloat       cellMarginY;

@end

@protocol V_SlideCardCellDelegate <NSObject>

- (void)loadNewData:(V_SlideCardCell *)cell;

@end
