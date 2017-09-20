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

/** cell的层叠方向 */
@property (nonatomic) CellOffsetDirection cellOffsetDirection;
/** cell之间的缩放间隔 */
@property (nonatomic) CGFloat cellScaleSpace;
/** 拖拽松手后翻页的阀值, 默认是100 */
@property (nonatomic) CGFloat panDistance;
/** cell的大小 默认self.frame.size*/
@property (nonatomic) CGSize cellSize;
/** cell默认在中心的位置 设置cellCenterYOffset控制cell的中心的Y值 */
@property (nonatomic) CGFloat cellCenterYOffset;

//shadow enable 默认有阴影
//@property (nonatomic) BOOL enableShadow;

@property (nonatomic, weak)   id<V_SlideCardDelegate>       delegate;
@property (nonatomic, weak)   id<V_SlideCardDataSource>     dataSource;

- (void)reloadData;
- (void)registerCellClassName:(NSString *)aClassName;
/** 外部调用 驱动TopCard翻页 */
- (void)animateTopCardToDirection:(PanDirection)direction;
@end

@protocol V_SlideCardDataSource<NSObject>

/** 加载一组新数据 */
- (void)loadNewDataInSlideCard:(V_SlideCard *)slideCard;

/** 返回数据数量 */
- (NSInteger)numberOfItemsInSlideCard:(V_SlideCard *)slideCard;

/** cell翻页后进入最底层时，需要重新加载数据, 将cell返回给开发者自己设置 */
- (void)slideCard:(V_SlideCard *)slideCard loadNewDataInCell:(V_SlideCardCell *)cell atIndex:(NSInteger)index;

@end

@protocol V_SlideCardDelegate<NSObject>
@optional
/** 提供用户拖拽方向 & panDistance的百分比 0.0～1.0 & index*/
- (void)slideCard:(V_SlideCard *)slideCard topCell:(V_SlideCardCell *)cell didPanPercent:(CGFloat)percent withDirection:(PanDirection)direction atIndex:(NSInteger)index;

/** 提供用户点击按钮调用翻页的时候将要翻的cell & 翻页方向 & index */
- (void)slideCard:(V_SlideCard *)slideCard topCell:(V_SlideCardCell *)cell willScrollToDirection:(PanDirection)direction atIndex:(NSInteger)index;

/** 提供翻页完成后的cell & 翻页方向 & index */
- (void)slideCard:(V_SlideCard *)slideCard topCell:(V_SlideCardCell *)cell didChangedStateWithDirection:(PanDirection)direction atIndex:(NSInteger)index;

/** 提供拖拽距离不够翻页时松手恢复原状态的cell & index */
- (void)slideCard:(V_SlideCard *)slideCard didResetFrameInCell:(V_SlideCardCell *)cell atIndex:(NSInteger)index;

/** 提供用户点击的cell & index */
- (void)slideCard:(V_SlideCard *)slideCard didSelectCell:(V_SlideCardCell *)cell atIndex:(NSInteger)index;

@end
