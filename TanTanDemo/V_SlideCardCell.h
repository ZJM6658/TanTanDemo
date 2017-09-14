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
    UnderThirdCard,
};

@class V_SlideCardCell;

@protocol V_SlideCardCellDelegate <NSObject>
- (void)loadNewData:(V_SlideCardCell *)cell;
@end

@interface V_SlideCardCell : UIView

@property (nonatomic, weak) id<V_SlideCardCellDelegate> delegate;

@property (nonatomic, strong) UIImage       *userImage;
@property (nonatomic, strong) NSString      *userName;
@property (nonatomic, strong) M_SlideCard   *dataItem;
@property (nonatomic)         CGFloat       signAlpha;
@property (nonatomic)         CardState     currentState;

- (void)shouldDoSomethingWithState:(CardState)state;

@end
