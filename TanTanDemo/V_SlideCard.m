//
//  V_SlideCard.m
//  TanTanDemo
//
//  Created by zhujiamin on 2016/11/16.
//  Copyright © 2016年 zhujiamin. All rights reserved.
//

#import "V_SlideCard.h"

@interface V_SlideCard () <V_SlideCardCellDelegate> {
    CGFloat _cardNumber;//创建的cell数量
    CGFloat _showingCardNumber;//显示中的cell
    BOOL _isCellAnimating;//是否在动画中
}

@property (nonatomic, strong) NSMutableArray<V_SlideCardCell *> *underCells;
@property (nonatomic)         NSInteger latestItemIndex;

@property (nonatomic, strong) UIButton  *btn_nodata;
@property (nonatomic, strong) NSString *cellClassName;

@property (nonatomic, strong) V_SlideCardCell *topCard;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@end

@implementation V_SlideCard

- (UIPanGestureRecognizer *)panGesture {
    if (_panGesture == nil) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panUserAction:)];
        _panGesture.maximumNumberOfTouches = 1;
        _panGesture.minimumNumberOfTouches = 1;
    }
    return _panGesture;
}
#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUpConfig];
        [self initUI];
    }
    return self;
}

- (void)setUpConfig {
    self.latestItemIndex = 0;
    _cardNumber = 4;
    _showingCardNumber = _cardNumber;
    _isCellAnimating = NO;
    [self addAllObserver];
}

- (void)initUI {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.btn_nodata];
}

- (void)dealloc {
    NSLog(@"card dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSlideCards {
    for (NSInteger i = 0; i < _cardNumber; i ++) {
        CGSize cellSize = [self slideCard:self sizeForItemAtIndex:i];;
        V_SlideCardCell *cell = [[[self currentClass] alloc] initWithFrame:CGRectMake(0, 0, cellSize.width, cellSize.height)];
        cell.cellMarginY = cellSize.height * TRANSFORM_SPACE - 5;
        cell.delegate = self;
        [self.underCells addObject:cell];
    }
    [self reloadCardsContent];
}

- (void)reloadCardsContent {
    self.btn_nodata.hidden = YES;
    [self sendSubviewToBack:self.btn_nodata];
    
    for (NSInteger i = 0; i < self.underCells.count; i ++) {
        V_SlideCardCell *cell = self.underCells[i];
        [cell removeFromSuperview];
        [self addSubview:cell];
        [cell removeGestureRecognizer:self.panGesture];
        [self.dataSource loadNewDataInCell:cell atIndex:i];
        cell.alpha = 1;

        //先设置到左边 再动画进入
        [cell hideToLeft];
        
        [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            cell.currentState = i;
        } completion:^(BOOL finished) {
            //添加拖拽手势
            if (i == FirstCard) {
                [cell addGestureRecognizer:self.panGesture];
                self.topCard = cell;
            }
        }];
        
        self.latestItemIndex = i;
    }
}

- (void)registerCellClassName:(NSString *)aClassName {
    self.cellClassName = aClassName;
    [self layoutSlideCards];
}

- (Class)currentClass {
    if (self.cellClassName.length > 0) {
        Class cellClass = NSClassFromString(self.cellClassName);
        NSAssert([cellClass isSubclassOfClass:[V_SlideCardCell class]], @"必须先调用registerCellClassName:设置自定义cell class，且必须继承自V_SlideCardCell");

        return cellClass;
    }
    return [V_SlideCardCell class];
}

#pragma mark - UIPanGestureRecognizer
- (void)panUserAction:(UIPanGestureRecognizer *)sender {
    V_SlideCardCell *topCell = (V_SlideCardCell *)sender.view;
    if (_isCellAnimating == NO && topCell.currentState == FirstCard) {
        CGPoint oldCenter = topCell.center;
        //横、纵坐标转换在父视图上拖动了多少像素
        CGPoint translation = [sender translationInView:self];
        topCell.center = CGPointMake(oldCenter.x + translation.x, oldCenter.y + translation.y);
        [sender setTranslation:CGPointZero inView:self];
        
        CGPoint newCenter = topCell.center;
        if (sender.state == UIGestureRecognizerStateChanged) {
            CGFloat percentX = (newCenter.x - topCell.originalCenter.x) / DROP_DISTANCE;
            CGFloat percentY = (newCenter.y - topCell.originalCenter.y) / DROP_DISTANCE;
            
            //这里需要发送的是x／y的变化较大者的绝对值，且轻微移动不做缩放操作 绝对值 -0.15
            CGFloat sendPercent = fabs(percentX) > fabs(percentY) ? fabs(percentX) : fabs(percentY);
            sendPercent = sendPercent < 0.15 ? 0: sendPercent - 0.15;
            sendPercent = sendPercent >= 1 ? 1 : sendPercent;
            
            PanDirection direction = (percentX > 0) ? PanDirectionRight : PanDirectionLeft;
            [[NSNotificationCenter defaultCenter] postNotificationName:MOVEACTION object:@{PERCENTMAIN:[NSNumber numberWithFloat:sendPercent], PERCENTX:[NSNumber numberWithFloat:fabs(percentX)], DIRECTION:@(direction)}];
        } else if (sender.state == UIGestureRecognizerStateEnded) {
            CGFloat offsetX = newCenter.x - topCell.originalCenter.x;
            if (fabs(offsetX) > DROP_DISTANCE) {
                PanDirection direction = (offsetX > 0) ? PanDirectionRight : PanDirectionLeft;
                [self setTopCardScrollToDirection:direction fromClick:NO];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:RESETFRAME object:nil];
            }
        }
    }
}

- (void)setTopCardScrollToDirection:(PanDirection)direction fromClick:(BOOL)fromClick{
    for (V_SlideCardCell *cell in self.underCells) {
        if (fromClick) {
            //按钮点击的时候页面上的按钮需要有体现
            if (cell.currentState == FirstCard) {
                if ([self.delegate respondsToSelector:@selector(slideCardCell:willScrollToDirection:)]) {
                    [self.delegate slideCardCell:cell willScrollToDirection:direction];
                }
            }
            
            _isCellAnimating = YES;
#warning 这个动画时间可能有点长，找时间再调
            [UIView animateKeyframesWithDuration:0.7 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeCubicPaced animations:^{
                [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:1/4.0 animations:^{
                    //FirstCard先回撤
                    if (cell.currentState == FirstCard) {
                        CGFloat angle = 5.0 / 180 * M_PI;
                        CGFloat centerOffsetX = 10;
                        if (direction == PanDirectionRight) {
                            angle = - angle;
                            centerOffsetX = - centerOffsetX;
                        }
                        cell.center = CGPointMake(cell.center.x + centerOffsetX, cell.center.y);
                        cell.transform = CGAffineTransformMakeRotation(angle);
                    }
                }];
                [UIView addKeyframeWithRelativeStartTime:1/4.0 relativeDuration:1/4.0 animations:^{
                    //FirstCard再恢复原位
                    if (cell.currentState == FirstCard) {
                        cell.center = cell.originalCenter;
                        cell.transform = CGAffineTransformMakeRotation(0);
                    }
                }];
                //正常调用moveAction
                [UIView addKeyframeWithRelativeStartTime:1/2.0 relativeDuration:1/2.0 animations:^{
                    CGFloat percentX = (0 - cell.originalCenter.x) / DROP_DISTANCE;
                    CGFloat moveToX = - SCRW;
                    if (direction == PanDirectionRight) {
                        percentX = (SCRW - cell.originalCenter.x) / DROP_DISTANCE;
                        moveToX = SCRW * 2;
                    }
                    CGFloat sendPercent = fabs(percentX);
                    sendPercent = sendPercent >= 1 ? 1 : sendPercent;
                    [cell moveWithParams:@{PERCENTMAIN:[NSNumber numberWithFloat:sendPercent], PERCENTX:[NSNumber numberWithFloat:percentX], @"MoveToX":[NSNumber numberWithFloat:moveToX]}];
                }];
            } completion:^(BOOL finished) {
                [self changedStateCell:cell withDirection:direction fromClick:fromClick];
            }];
        } else {
            [self changedStateCell:cell withDirection:direction fromClick:fromClick];
        }
    }
}

//动画结束
- (void)changedStateCell:(V_SlideCardCell *)cell withDirection:(PanDirection)direction fromClick:(BOOL)fromClick {
    if (cell.currentState == FirstCard) {
        CGPoint toPoint = CGPointMake(- SCRW, cell.originalCenter.y);
        NSTimeInterval duration = fromClick ? 0 : 0.3;

        if (direction == PanDirectionRight) {
            toPoint = CGPointMake(SCRW * 2, cell.originalCenter.y);
        }
        
        _isCellAnimating = YES;
        [UIView animateWithDuration:duration animations:^{
            cell.center = toPoint;
            cell.transform = CGAffineTransformMakeRotation(0);
            cell.alpha = 0;
        } completion:^(BOOL finished) {
            if ([self.delegate respondsToSelector:@selector(slideCardCell:didChangedStateWithDirection:atIndex:)]) {
                [self.delegate slideCardCell:cell didChangedStateWithDirection:direction atIndex:self.latestItemIndex];
            }
            cell.currentState = OtherCard;
            [self loadNewData:cell];
            _isCellAnimating = NO;
        }];
    } else {
        NSInteger toState = cell.currentState - 1;
        cell.currentState = toState;
        if (toState == FirstCard) {
            [cell addGestureRecognizer:self.panGesture];
            self.topCard = cell;
        }
    }
}

#pragma mark - notification

- (void)addAllObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveAction:) name:MOVEACTION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetFrame:) name:RESETFRAME object:nil];
}

- (void)moveAction:(NSNotification *)notification {
    NSDictionary *object = notification.object;
    CGFloat percentX = [[object objectForKey:PERCENTX] floatValue];
    PanDirection direction = [[object objectForKey:DIRECTION] integerValue];
    if ([self.delegate respondsToSelector:@selector(slideCardCell:didPanPercent:withDirection:)]) {
        [self.delegate slideCardCell:self.topCard didPanPercent:percentX withDirection:direction];
    }
}

- (void)resetFrame:(NSNotification *)notification {
    if ([self.delegate respondsToSelector:@selector(slideCardCellDidResetFrame:)]) {
        [self.delegate slideCardCellDidResetFrame:self.topCard];
    }
}

#pragma mark - event response

- (void)animateTopCardToDirection:(PanDirection)direction {
    if (_isCellAnimating) return;
    [self setTopCardScrollToDirection:direction fromClick:YES];
}

- (void)loadMoreData {
    //加载下一组数据
    if ([self.dataSource respondsToSelector:@selector(loadNewData)]) {
        [self.dataSource loadNewData];
    }
}

#pragma mark - V_SlideCardCellDelegate

- (void)setAnimatingState:(BOOL)animating {
    _isCellAnimating = animating;
}

- (void)loadNewData:(V_SlideCardCell *)cell {
    if (self.latestItemIndex + 1 < [self numberOfItemsInSlideCard:self]) {
        self.latestItemIndex += 1;
        [self sendSubviewToBack:cell];
        [self.dataSource loadNewDataInCell:cell atIndex:self.latestItemIndex];
        [UIView animateWithDuration:0.2 animations:^{
            cell.alpha = 1;
        }];
    } else {
        _showingCardNumber -= 1;
        [cell hideToLeft];
    }
    if (_showingCardNumber <= 0) {
        self.btn_nodata.hidden = NO;
        [self bringSubviewToFront:self.btn_nodata];
    }
}

#pragma mark - outside methods

- (void)reloadData {
    self.latestItemIndex = 0;
    _showingCardNumber = _cardNumber;
    if (self.underCells.count) {
        [self reloadCardsContent];
    } else {
        [self layoutSlideCards];
    }
}

#pragma mark - V_SlideCardDataSource

- (NSInteger)numberOfItemsInSlideCard:(V_SlideCard *)slideCard {
    if ([self.dataSource respondsToSelector:@selector(numberOfItemsInSlideCard:)]) {
        return [self.dataSource numberOfItemsInSlideCard:slideCard];
    }
    return _cardNumber;
}

- (CGSize)slideCard:(V_SlideCard *)slideCard sizeForItemAtIndex:(NSInteger)index {
    if ([self.dataSource respondsToSelector:@selector(slideCard:sizeForItemAtIndex:)]) {
        return [self.dataSource slideCard:self sizeForItemAtIndex:index];
    }
    return self.frame.size;
}

#pragma mark - setter

- (void)setDataSource:(id<V_SlideCardDataSource>)dataSource {
    _dataSource = dataSource;
}

#pragma mark - getter

- (NSMutableArray<V_SlideCardCell *> *)underCells {
    if (_underCells == nil) {
        _underCells = [[NSMutableArray alloc] init];
    }
    return _underCells;
}

- (UIButton *)btn_nodata {
    if (_btn_nodata == nil) {
        _btn_nodata = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 60)];
        _btn_nodata.center = self.center;
        [_btn_nodata setTitle:@"没有更多数据了\n点击加载下一页" forState:UIControlStateNormal];
        _btn_nodata.titleLabel.numberOfLines = 0;
        [_btn_nodata setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btn_nodata setBackgroundColor:[UIColor colorWithRed:220.0/255.0 green:100.0/255.0 blue:50.0/255.0 alpha:1]];
        _btn_nodata.layer.cornerRadius = 5;
        _btn_nodata.layer.masksToBounds = YES;
        _btn_nodata.hidden = YES;
        [_btn_nodata addTarget:self action:@selector(loadMoreData) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btn_nodata;
}

@end
