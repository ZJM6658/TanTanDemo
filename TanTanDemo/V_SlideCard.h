//
//  V_SlideCard.h
//  TanTanDemo
//
//  Created by zhujiamin on 2016/11/16.
//  Copyright © 2016年 zhujiamin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "V_SlideCardCell.h"

@protocol V_SlideCardDataSource;

@interface V_SlideCard : UIView

@property (nonatomic, weak)   id<V_SlideCardDataSource>     dataSource;

- (void)reloadData;

@end

@protocol V_SlideCardDataSource<NSObject>

- (void)loadNewData;

- (M_SlideCard *)slideCard:(V_SlideCard *)slideCard itemForIndex:(NSInteger)index;

@optional

- (NSInteger)numberOfItemsInSlideCard:(V_SlideCard *)slideCard;//default is 4;

- (CGSize)slideCard:(V_SlideCard *)slideCard sizeForItemAtIndex:(NSInteger)index;

@end
