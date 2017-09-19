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
/** 拖拽松手后翻页的阀值，默认是100 */
@property (nonatomic) CGFloat panDistance;
/** cell的大小 默认self.frame.size*/
@property (nonatomic) CGSize cellSize;
/** cell默认在中心的位置 设置cellCenterYOffset控制cell的中心的Y值 */
@property (nonatomic) CGFloat cellCenterYOffset;//这个字段设置的早晚也要考虑到cell刷新的问题
//shadow enable
@property (nonatomic) BOOL enableShadow __deprecated;

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
