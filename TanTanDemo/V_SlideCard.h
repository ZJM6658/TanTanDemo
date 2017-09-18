//
//  V_SlideCard.h
//  TanTanDemo
//
//  Created by zhujiamin on 2016/11/16.
//  Copyright © 2016年 zhujiamin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "V_SlideCardCell.h"

@protocol V_SlideCardDelegate, V_SlideCardDataSource;

@interface V_SlideCard : UIView


@property (nonatomic) CGSize cellSize;
//cell中心的位置 偏移
@property (nonatomic) CGFloat celloffsetY;
//shadow enable
@property (nonatomic) BOOL enableShadow;

@property (nonatomic, weak)   id<V_SlideCardDelegate>       delegate;
@property (nonatomic, weak)   id<V_SlideCardDataSource>     dataSource;

- (void)reloadData;
- (void)registerCellClassName:(NSString *)aClassName;
/**外部调用 让动画驱动翻一页*/
- (void)animateTopCardToDirection:(PanDirection)direction;
@end

@protocol V_SlideCardDataSource<NSObject>

- (void)loadNewData;

- (NSInteger)numberOfItemsInSlideCard:(V_SlideCard *)slideCard;
- (void)loadNewDataInCell:(V_SlideCardCell *)cell atIndex:(NSInteger)index;

@end



@protocol V_SlideCardDelegate<NSObject>
@optional
- (void)slideCardCell:(V_SlideCardCell *)cell didPanPercent:(CGFloat)percent withDirection:(PanDirection)direction;

- (void)slideCardCell:(V_SlideCardCell *)cell willScrollToDirection:(PanDirection)direction;

- (void)slideCardCell:(V_SlideCardCell *)cell didChangedStateWithDirection:(PanDirection)direction atIndex:(NSInteger)index;

- (void)slideCardCellDidResetFrame:(V_SlideCardCell *)cell;

- (void)didSelectCell:(V_SlideCardCell *)cell atIndex:(NSInteger)index;

@end
