//
//  V_SlideCardCell.h
//  TanTanDemo
//
//  Created by zhujiamin on 2016/11/16.
//  Copyright © 2016年 zhujiamin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PanDirection) {
    PanDirectionNone = 0,
    PanDirectionLeft,
    PanDirectionRight,
};

typedef NS_ENUM(NSInteger, CardState) {
    FirstCard = 0,
    SecondCard,
    ThirdCard,
    OtherCard,
};

typedef NS_ENUM(NSInteger, CellOffsetDirection) {
    CellOffsetDirectionBottom = 0,
    CellOffsetDirectionTop,
};

@protocol V_SlideCardCellDelegate;

@interface V_SlideCardCell : UIView

/** 子类视图内容需要加在contentView中,默认有圆角 */
@property (nonatomic, strong) UIView *contentView;
/** 初始中心位置 */
@property (nonatomic, readonly) CGPoint originalCenter;
/** cell当前所处的状态 */
@property (nonatomic)         CardState     currentState;
/** cell之间的Y偏移, 显示层叠效果*/
@property (nonatomic)         CGFloat       heightSpace;
/** cell之间的缩放间隔 */
@property (nonatomic) CGFloat scaleSpace;
/** 中心Y偏移值*/
@property (nonatomic) CGFloat centerYOffset;
/** 数据源的Index */
@property (nonatomic) NSInteger index;
/** 层叠方向 */
@property (nonatomic) CellOffsetDirection offsetDirection;

@property (nonatomic, weak)   id<V_SlideCardCellDelegate> delegate;

//将cell移到放到屏幕外左边
- (void)hideToLeft;
//移动cell
- (void)moveWithParams:(NSDictionary *)params;
//子类需要继承实现的方法
- (void)setUpConfig;
- (void)initUI;

@end

@protocol V_SlideCardCellDelegate <NSObject>

- (void)setAnimatingState:(BOOL)animating;
- (void)loadNewData:(V_SlideCardCell *)cell;

@end
