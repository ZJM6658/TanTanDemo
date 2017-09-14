//
//  V_SlideCard.m
//  TanTanDemo
//
//  Created by zhujiamin on 2016/11/16.
//  Copyright © 2016年 zhujiamin. All rights reserved.
//

#import "V_SlideCard.h"

@interface V_SlideCard () <V_SlideCardCellDelegate> {
    CGFloat _buttonWidth;
    CGFloat _realCardNum;
}

@property (nonatomic, strong) V_SlideCardCell                   *topCell;
@property (nonatomic, strong) NSMutableArray<V_SlideCardCell *> *underCells;
@property (nonatomic)         NSInteger latestItemIndex;

@property (nonatomic, strong) UIButton  *likeButton;
@property (nonatomic, strong) UIButton  *hateButton;

@end

@implementation V_SlideCard

#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self setUpConfig];
    }
    return self;
}

- (void)setUpConfig {
    self.latestItemIndex = 0;
    _buttonWidth = 60;
    _realCardNum = MOST_CARD_NUM + 1;
    [self addAllObserver];
}

- (void)dealloc {
    NSLog(@"card dealloc");
    [self removeAllObserver];
}

#warning 可以在没有数据了加个loading页面
- (void)layoutSlideCards {
    CGFloat offsetX = 12;
    CGFloat offsetY = 10;
    CGFloat cardXSpace = 14 / (MOST_CARD_NUM - 1);
    CGFloat cardYSpace = 2 * offsetY;
    CGFloat cardHeightSpace = 10;

    NSInteger cardNum = [self numberOfItemsInSlideCard:self] > _realCardNum ? _realCardNum : [self numberOfItemsInSlideCard:self];
    
    
    for (NSInteger i = 0; i < cardNum; i ++) {
        if (i < MOST_CARD_NUM && i > 0) {
            offsetX += cardXSpace;
            offsetY += cardYSpace;
            offsetY += cardHeightSpace / MOST_CARD_NUM * (MOST_CARD_NUM - i);
        }

        CGFloat cellWidth = [self slideCard:self widthForItemAtIndex:i] - 2 * offsetX;
        CGFloat cellHeight = [self slideCard:self heightForItemAtIndex:i] - cardYSpace * i;
        
        V_SlideCardCell *cell = [[V_SlideCardCell alloc] initWithFrame:CGRectMake(0, 0, cellWidth, cellHeight)];
        
#warning 初始化之后改变frame属性,因为没有约束,cell的放大,子View的frame会有问题！！
//        cell.origin = CGPointMake(offsetX, offsetY);
#warning 这里y的偏移不应该写死的  应该根据比例来
        cell.center = CGPointMake(self.center.x, self.center.y - 60 + MARGIN_Y * i);
        [self.underCells addObject:cell];
        
        //初始位置放在屏幕外, 便于做旋转飞入的动画
//        cell.x = - cell.height;
//        cell.transform = CGAffineTransformMakeRotation((-90.0f * M_PI) / 180.0f);
    }
    [self reloadCardsContent];
}

- (void)reloadCardsContent {
    for (NSInteger i = 0; i < self.underCells.count; i ++) {
        V_SlideCardCell *cell = self.underCells[i];
        cell.dataItem = [self slideCard:self itemForIndex:i];
        cell.currentState = i;
        cell.delegate = self;
        cell.hidden = NO;

        [cell removeFromSuperview];
        [self addSubview:cell];
        [self sendSubviewToBack:cell];
        
        self.latestItemIndex = i;
        [UIView animateWithDuration:0.3 animations:^{
            //旋转的时候需要设置基准点，否则应该先旋转回来再做其他设置
            cell.transform = CGAffineTransformMakeRotation((0.0f * M_PI) / 180.0f);
        }];
    }
}

#pragma mark - notification

- (void)addAllObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveAction:) name:MOVEACTION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetFrame:) name:RESETFRAME object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stateChangeAction:) name:STATECHANGE object:nil];
}

- (void)removeAllObserver {
    NSArray *notificationNames = @[MOVEACTION, RESETFRAME, STATECHANGE];
    for (NSString *nameStr in notificationNames) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:nameStr object:nil];
    }
}

- (void)moveAction:(NSNotification *)notification {
    NSDictionary *object = notification.object;
    CGFloat PercentX = [[object objectForKey:PERCENTX] floatValue];
    if (PercentX > 0) {
        self.likeButton.layer.borderWidth = 5 * (1 - PercentX);
    } else {
        self.hateButton.layer.borderWidth = 5 * (1 - fabs(PercentX));
    }
}

- (void)resetFrame:(NSNotification *)notification {
    [self resetButton];
}

- (void)stateChangeAction:(NSNotification *)notification {
    [self resetButton];
}

- (void)resetButton {
    [UIView animateWithDuration:0.2 animations:^{
        self.likeButton.layer.borderWidth = 5;
        self.hateButton.layer.borderWidth = 5;
    }];
}

#pragma mark - event response
- (void)likeOrHateAction:(UIButton *)sender {
    //应该能够标记当前的first cell  不用每次遍历寻找
    for (UIView *view in self.subviews) {
        if (![view isKindOfClass:[V_SlideCardCell class]]) {
            continue;
        }
        V_SlideCardCell *cell = (V_SlideCardCell *)view;
        if (cell.currentState == FirstCard) {
            [UIView animateWithDuration:0.3 animations:^{
                cell.center = (sender.tag == 520) ? CGPointMake(SCRW, cell.center.y) : CGPointMake(- SCRW, cell.center.y);
                cell.alpha = 0;
            } completion:^(BOOL finished) {
                [[NSNotificationCenter defaultCenter] postNotificationName:STATECHANGE object:nil];

            }];
        }
    }
}

#pragma mark - V_SlideCardCellDelegate

- (void)loadNewData:(V_SlideCardCell *)cell {
    if (self.latestItemIndex + 1 < [self numberOfItemsInSlideCard:self]) {
        self.latestItemIndex += 1;
        [self sendSubviewToBack:cell];
        cell.dataItem = [self slideCard:self itemForIndex:self.latestItemIndex];
        [UIView animateWithDuration:0.3 animations:^{
            cell.alpha = 1;
        }];
    } else {
        _realCardNum -= 1;
//        cell.x = -cell.height;
//        cell.transform = CGAffineTransformMakeRotation((-90.0f * M_PI) / 180.0f);
    }
    if (!_realCardNum) {
        //协议方法
        if ([self.dataSource respondsToSelector:@selector(loadNewData)]) {
            [self.dataSource loadNewData];
        }
        
        //主动刷新
        //[self reloadData];
        
        //提示
        //        [[[UIAlertView alloc] initWithTitle:@"没有更多数据了" message:@"请实现加载下一页方法" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil] show];
    }
}

#pragma mark - outside methods

- (void)reloadData {
    self.latestItemIndex = 0;
    _realCardNum = MOST_CARD_NUM + 1;
    if (self.underCells.count) {
        [self reloadCardsContent];
    } else {
        [self layoutSlideCards];
    }
}

#pragma mark - V_SlideCardDataSource

- (M_SlideCard *)slideCard:(V_SlideCard *)slideCard itemForIndex:(NSInteger)index {
    return [self.dataSource slideCard:slideCard itemForIndex:index];
}

- (NSInteger)numberOfItemsInSlideCard:(V_SlideCard *)slideCard {
    if ([self.dataSource respondsToSelector:@selector(numberOfItemsInSlideCard:)]) {
        return [self.dataSource numberOfItemsInSlideCard:slideCard];
    }
    return 3;
}

- (CGFloat)slideCard:(V_SlideCard *)slideCard heightForItemAtIndex:(NSInteger )index {
    if ([self.dataSource respondsToSelector:@selector(slideCard:heightForItemAtIndex:)]) {
        return [self.dataSource slideCard:slideCard heightForItemAtIndex:index];
    }
    return self.height - 150;
}

- (CGFloat)slideCard:(V_SlideCard *)slideCard widthForItemAtIndex:(NSInteger )index {
    if ([self.dataSource respondsToSelector:@selector(slideCard:widthForItemAtIndex:)]) {
        return [self.dataSource slideCard:slideCard widthForItemAtIndex:index];
    }
    return self.width;
}

#pragma mark - setter

- (void)setDataSource:(id<V_SlideCardDataSource>)dataSource {
    _dataSource = dataSource;
    
    [self layoutSlideCards];
    [self addSubview:self.likeButton];
    [self addSubview:self.hateButton];
    [self sendSubviewToBack:self.likeButton];
    [self sendSubviewToBack:self.hateButton];
}

#pragma mark - getter

- (NSMutableArray<V_SlideCardCell *> *)underCells {
    if (!_underCells) {
        _underCells = [[NSMutableArray alloc] init];
    }
    return _underCells;
}

- (UIButton *)likeButton {
    if (!_likeButton) {
        _likeButton = [[UIButton alloc] initWithFrame:CGRectMake((self.width - _buttonWidth * 2) / 3 * 2 + _buttonWidth, self.height - _buttonWidth - 30, _buttonWidth, _buttonWidth)];
        [_likeButton setBackgroundImage:[UIImage imageNamed:@"likeWhole"] forState:UIControlStateNormal];
        _likeButton.layer.borderColor = [UIColor grayColor].CGColor;
        _likeButton.layer.borderWidth = 5;
        _likeButton.layer.masksToBounds = YES;
        _likeButton.layer.cornerRadius = _buttonWidth / 2;
        _likeButton.tag = 520;
        [_likeButton addTarget:self action:@selector(likeOrHateAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _likeButton;
}

- (UIButton *)hateButton {
    if (!_hateButton) {
        _hateButton = [[UIButton alloc] initWithFrame:CGRectMake((self.width - _buttonWidth * 2) / 3, self.height - _buttonWidth - 30, _buttonWidth, _buttonWidth)];
        [_hateButton setBackgroundImage:[UIImage imageNamed:@"hateWhole"] forState:UIControlStateNormal];
        _hateButton.layer.borderColor = [UIColor grayColor].CGColor;
        _hateButton.layer.borderWidth = 5;
        _hateButton.layer.masksToBounds = YES;
        _hateButton.layer.cornerRadius = _buttonWidth / 2;
        _hateButton.tag = 521;
        [_hateButton addTarget:self action:@selector(likeOrHateAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _hateButton;
}

@end
