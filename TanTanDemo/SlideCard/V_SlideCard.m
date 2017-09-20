//
//  V_SlideCard.m
//  TanTanDemo
//
//  Created by zhujiamin on 2016/11/16.
//  Copyright © 2016年 zhujiamin. All rights reserved.
//

#import "V_SlideCard.h"

#define SCRW  [[UIScreen mainScreen] bounds].size.width

@interface V_SlideCard () <V_SlideCardCellDelegate> {
    NSInteger _cardNumber;//创建的cell数量
    NSInteger _showingCardNumber;//显示中的cell
    BOOL _isCellAnimating;//是否在动画中
}

@property (nonatomic, strong) NSMutableArray<V_SlideCardCell *> *underCells;
@property (nonatomic)         NSInteger latestItemIndex;

@property (nonatomic, strong) UIButton  *btn_nodata;
@property (nonatomic, strong) NSString *cellClassName;

@property (nonatomic, strong) V_SlideCardCell *topCard;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@end

@implementation V_SlideCard

#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUpConfig];
        [self initUI];
    }
    return self;
}

- (void)setUpConfig {
    _latestItemIndex = 0;
    _panDistance = 100;
    _cellScaleSpace = 0.1;
    _cellSize = self.frame.size;
    _cellCenterYOffset = 0;
    _cellOffsetDirection = CellOffsetDirectionBottom;
    _cardNumber = 4;
    _showingCardNumber = _cardNumber;
    _isCellAnimating = NO;
    [self addAllObserver];
}

- (void)initUI {
    [self addSubview:self.btn_nodata];
}

- (void)dealloc {
    NSLog(@"card dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSlideCards {
    for (V_SlideCardCell *cell in self.underCells) {
        [cell removeFromSuperview];
    }
    [self.underCells removeAllObjects];

    for (NSInteger i = 0; i < _cardNumber; i ++) {
        if (self.cellSize.width <= 0 || self.cellSize.height <= 0) {
            self.cellSize = self.frame.size;
        }
        V_SlideCardCell *cell = [[[self currentClass] alloc] initWithFrame:CGRectMake(0, 0, self.cellSize.width, self.cellSize.height)];
        cell.offsetDirection = self.cellOffsetDirection;
        cell.centerYOffset = self.cellCenterYOffset;
        cell.scaleSpace = self.cellScaleSpace;
        cell.heightSpace = self.cellSize.height * self.cellScaleSpace;
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
        [cell removeGestureRecognizer:self.tapGesture];

        cell.index = i;
        if ([self shouldCallDelegateOrDataSource:cell]) {
            [self.dataSource slideCard:self loadNewDataInCell:cell atIndex:i];
        }
        cell.alpha = 1;

        //先设置到左边 再动画进入
        [cell hideToLeft];
        
        [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            cell.currentState = i;
        } completion:^(BOOL finished) {
            //添加拖拽手势
            if (i == FirstCard) {
                [cell addGestureRecognizer:self.panGesture];
                [cell addGestureRecognizer:self.tapGesture];
                self.topCard = cell;
            }
        }];
        
        self.latestItemIndex = i;
    }
}

#pragma mark - UIPanGestureRecognizer

- (void)panCellAction:(UIPanGestureRecognizer *)sender {
    V_SlideCardCell *topCell = (V_SlideCardCell *)sender.view;
    if (_isCellAnimating == NO && topCell.currentState == FirstCard) {
        CGPoint oldCenter = topCell.center;
        //横、纵坐标转换在父视图上拖动了多少像素
        CGPoint translation = [sender translationInView:self];
        topCell.center = CGPointMake(oldCenter.x + translation.x, oldCenter.y + translation.y);
        [sender setTranslation:CGPointZero inView:self];
        
        CGPoint newCenter = topCell.center;
        if (sender.state == UIGestureRecognizerStateChanged) {
            CGFloat percentX = (newCenter.x - topCell.originalCenter.x) / _panDistance;
            CGFloat percentY = (newCenter.y - topCell.originalCenter.y) / _panDistance;
            
            PanDirection direction = (percentX > 0) ? PanDirectionRight : PanDirectionLeft;

            percentX = fabs(percentX);
            percentY = fabs(percentY);
            if (percentX > 1) percentX = 1;
            if (percentY > 1) percentY = 1;
            
            //这里需要发送的是x／y的变化较大者的绝对值，
            CGFloat sendPercent = percentX > percentY ? percentX : percentY;
            //轻微移动不做缩放操作 绝对值 -0.15
            // sendPercent = sendPercent < 0.15 ? 0: sendPercent - 0.15;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:MOVEACTION object:@{PERCENTMAIN:[NSNumber numberWithFloat:sendPercent], PERCENTX:[NSNumber numberWithFloat:percentX], DIRECTION:@(direction)}];
        } else if (sender.state == UIGestureRecognizerStateEnded) {
            CGFloat offsetX = newCenter.x - topCell.originalCenter.x;
            if (fabs(offsetX) > _panDistance) {
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
            [self scrollCell:cell toDirection:direction];
        } else {
            [self changedStateCell:cell withDirection:direction fromClick:NO];
        }
    }
}

- (BOOL)shouldCallDelegateOrDataSource:(V_SlideCardCell *)cell {
//    if (self.cellClassName.length > 0) {
//        Class class = NSClassFromString(self.cellClassName);
//        if ([cell isKindOfClass:class]) {
//            return YES;
//        }
//    }
    return YES;
}

//直接动画翻页后状态变更
- (void)scrollCell:(V_SlideCardCell *)cell toDirection:(PanDirection)direction {
    //按钮点击的时候页面上的按钮需要有体现
    if (cell.currentState == FirstCard) {
        if ([self.delegate respondsToSelector:@selector(slideCard:topCell:willScrollToDirection:atIndex:)] && [self shouldCallDelegateOrDataSource:cell]) {
            [self.delegate slideCard:self topCell:cell willScrollToDirection:direction atIndex:cell.index];
        }
    }
    
    _isCellAnimating = YES;
//#warning 这个动画时间可能有点长，找时间再调 可以让cell移动距离小点，刚好移出屏外 缩短时间
    [UIView animateKeyframesWithDuration:0.5 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeCubicPaced animations:^{
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
            CGFloat percentX = (0 - cell.originalCenter.x) / _panDistance;
            CGFloat moveToX = - SCRW / 2 * 3;
            if (direction == PanDirectionRight) {
                percentX = (SCRW - cell.originalCenter.x) / _panDistance;
                moveToX = SCRW / 2 * 3;
            }
            CGFloat sendPercent = fabs(percentX);
            sendPercent = sendPercent >= 1 ? 1 : sendPercent;
            [cell moveWithParams:@{PERCENTMAIN:[NSNumber numberWithFloat:sendPercent], @"MoveToX":[NSNumber numberWithFloat:moveToX]}];
        }];
    } completion:^(BOOL finished) {
        [self changedStateCell:cell withDirection:direction fromClick:YES];
    }];
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
            cell.currentState = OtherCard;
            if ([self.delegate respondsToSelector:@selector(slideCard:topCell:didChangedStateWithDirection:atIndex:)] && [self shouldCallDelegateOrDataSource:cell]) {
                [self.delegate slideCard:self topCell:cell didChangedStateWithDirection:direction atIndex:self.latestItemIndex];
            }
            [self loadNewData:cell];
            _isCellAnimating = NO;
        }];
    } else {
        NSInteger toState = cell.currentState - 1;
        cell.currentState = toState;
        if (toState == FirstCard) {
            [cell addGestureRecognizer:self.panGesture];
            [cell addGestureRecognizer:self.tapGesture];
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
    if ([self.delegate respondsToSelector:@selector(slideCard:topCell:didPanPercent:withDirection:atIndex:)]) {
        [self.delegate slideCard:self topCell:self.topCard didPanPercent:percentX withDirection:direction atIndex:self.topCard.index];
    }
}

- (void)resetFrame:(NSNotification *)notification {
    if ([self.delegate respondsToSelector:@selector(slideCard:didResetFrameInCell:atIndex:)] && [self shouldCallDelegateOrDataSource:self.topCard]) {
        [self.delegate slideCard:self didResetFrameInCell:self.topCard atIndex:self.topCard.index];
    }
}

#pragma mark - event response

- (void)tapCellAction:(UITapGestureRecognizer *)sender {
    V_SlideCardCell *senderCell = (V_SlideCardCell *)sender.view;
    if ([self.delegate respondsToSelector:@selector(slideCard:didSelectCell:atIndex:)]) {
        [self.delegate slideCard:self didSelectCell:senderCell atIndex:senderCell.index];
    }
}

- (void)animateTopCardToDirection:(PanDirection)direction {
    if (_isCellAnimating) return;
    [self setTopCardScrollToDirection:direction fromClick:YES];
}

- (void)loadMoreData {
    //加载下一组数据
    if ([self.dataSource respondsToSelector:@selector(loadNewDataInSlideCard:)] && [self shouldCallDelegateOrDataSource:self.topCard]) {
        [self.dataSource loadNewDataInSlideCard:self];
    } else {
        [self reloadData];
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
        if ([self shouldCallDelegateOrDataSource:cell]) {
            cell.index = self.latestItemIndex;
            [self.dataSource slideCard:self loadNewDataInCell:cell atIndex:self.latestItemIndex];
        }
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

- (void)resetCell {
    NSInteger i = 0;
    for (V_SlideCardCell *cell in self.underCells) {
        cell.offsetDirection = self.cellOffsetDirection;
        cell.centerYOffset = self.cellCenterYOffset;
        cell.scaleSpace = self.cellScaleSpace;
        cell.heightSpace = self.cellSize.height * self.cellScaleSpace;
        
        cell.currentState = i;
        i ++;
    }
}

#pragma mark - V_SlideCardDataSource

- (NSInteger)numberOfItemsInSlideCard:(V_SlideCard *)slideCard {
    if ([self.dataSource respondsToSelector:@selector(numberOfItemsInSlideCard:)] && [self shouldCallDelegateOrDataSource:self.topCard]) {
        return [self.dataSource numberOfItemsInSlideCard:slideCard];
    }
    return _cardNumber;
}

#pragma mark - setter

- (void)setCellOffsetDirection:(CellOffsetDirection)cellOffsetDirection {
    if (_cellOffsetDirection != cellOffsetDirection) {
        _cellOffsetDirection = cellOffsetDirection;
        [self resetCell];
    }
}

- (void)setCellCenterYOffset:(CGFloat)cellCenterYOffset {
    if (_cellCenterYOffset != cellCenterYOffset) {
        _cellCenterYOffset = cellCenterYOffset;
        [self resetCell];
    }
}

- (void)registerCellClassName:(NSString *)aClassName {
    self.cellClassName = aClassName;
    [self layoutSlideCards];
}

- (void)setCellSize:(CGSize)cellSize {
    _cellSize = cellSize;
    [self layoutSlideCards];
}

- (void)setDataSource:(id<V_SlideCardDataSource>)dataSource {
    _dataSource = dataSource;
//#warning 怎么保证cellName和DataSource都有了才创建
    if (self.cellClassName.length > 0) {
        [self layoutSlideCards];
    }
}

#pragma mark - getter

- (Class)currentClass {
    if (self.cellClassName.length > 0) {
        Class cellClass = NSClassFromString(self.cellClassName);
        NSAssert([cellClass isSubclassOfClass:[V_SlideCardCell class]], @"必须先调用registerCellClassName:设置自定义cell class，且必须继承自V_SlideCardCell");
        
        return cellClass;
    }
    return [V_SlideCardCell class];
}

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
        [_btn_nodata setBackgroundColor:[UIColor blackColor]];
        _btn_nodata.layer.cornerRadius = 5;
        _btn_nodata.layer.masksToBounds = YES;
        _btn_nodata.hidden = YES;
        [_btn_nodata addTarget:self action:@selector(loadMoreData) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btn_nodata;
}

- (UIPanGestureRecognizer *)panGesture {
    if (_panGesture == nil) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panCellAction:)];
        _panGesture.maximumNumberOfTouches = 1;
        _panGesture.minimumNumberOfTouches = 1;
    }
    return _panGesture;
}

- (UITapGestureRecognizer *)tapGesture {
    if (_tapGesture == nil) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCellAction:)];
    }
    return _tapGesture;
}

@end
