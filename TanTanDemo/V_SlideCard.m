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
    CGFloat _cardNumber;//创建的cell数量
    CGFloat _showingCardNumber;
}

@property (nonatomic, strong) V_SlideCardCell                   *topCell;
@property (nonatomic, strong) NSMutableArray<V_SlideCardCell *> *underCells;
@property (nonatomic)         NSInteger latestItemIndex;

@property (nonatomic, strong) UIButton  *btn_like;
@property (nonatomic, strong) UIButton  *btn_hate;

@property (nonatomic, strong) UIButton  *btn_nodata;

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
    self.latestItemIndex = 0;
    _buttonWidth = 60;
    _cardNumber = 4;
    _showingCardNumber = _cardNumber;
    [self addAllObserver];
}

- (void)initUI {
    self.backgroundColor = [UIColor whiteColor];

    [self addSubview:self.btn_like];
    [self addSubview:self.btn_hate];
    [self sendSubviewToBack:self.btn_like];
    [self sendSubviewToBack:self.btn_hate];
    [self addSubview:self.btn_nodata];
}

- (void)dealloc {
    NSLog(@"card dealloc");
    [self removeAllObserver];
}

#warning 可以在没有数据了加个loading页面
- (void)layoutSlideCards {
    for (NSInteger i = 0; i < _cardNumber; i ++) {
        CGSize cellSize = [self slideCard:self sizeForItemAtIndex:i];;
        V_SlideCardCell *cell = [[V_SlideCardCell alloc] initWithFrame:CGRectMake(0, 0, cellSize.width, cellSize.height)];
        cell.cellMarginY = cellSize.height * TRANSFORM_SPACE - 5;
        cell.delegate = self;
        [self.underCells addObject:cell];
        
        //初始位置放在屏幕外, 便于做旋转飞入的动画
        //        cell.x = - cell.height;
        //        cell.transform = CGAffineTransformMakeRotation((-90.0f * M_PI) / 180.0f);
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
        [self sendSubviewToBack:cell];
        
        cell.hidden = NO;
        cell.dataItem = [self slideCard:self itemForIndex:i];
        cell.currentState = i;
        self.latestItemIndex = i;
//        [UIView animateWithDuration:0.3 animations:^{
//            //旋转的时候需要设置基准点，否则应该先旋转回来再做其他设置
//            cell.transform = CGAffineTransformMakeRotation((0.0f * M_PI) / 180.0f);
//        }];
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
        self.btn_like.layer.borderWidth = 5 * (1 - PercentX);
    } else {
        self.btn_hate.layer.borderWidth = 5 * (1 - fabs(PercentX));
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
        self.btn_like.layer.borderWidth = 5;
        self.btn_hate.layer.borderWidth = 5;
    }];
}

#pragma mark - event response

- (void)likeOrHateAction:(UIButton *)sender {
    BOOL choosedLike = NO;
    NSInteger toCenterX = 0;
    if (sender.tag == 520) {
        choosedLike = YES;
        toCenterX = SCRW;
    }
    
#warning 点击按钮应该也先动画再改变状态
    
//    for (NSInteger i = 0; i < 2000; i ++) {
//        CGFloat PercentX = (i / 10.0 - self.center.x) / DROP_DISTANCE;
//        
//        //这里需要发送的是x／y的变化较大者的绝对值
//        CGFloat sendPercent = fabs(PercentX);
//        //轻微移动不做缩放操作 绝对值 -0.15
//        sendPercent = sendPercent < 0.15 ? 0: sendPercent - 0.15;
//        sendPercent = sendPercent >= 1 ? 1 : sendPercent;
//        [[NSNotificationCenter defaultCenter] postNotificationName:MOVEACTION object:@{PERCENTMAIN:[NSNumber numberWithFloat:sendPercent], PERCENTX:[NSNumber numberWithFloat:PercentX]}];
//    }

    [[NSNotificationCenter defaultCenter] postNotificationName:STATECHANGE object:@{@"RESULT":@(choosedLike)}];
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
        _showingCardNumber -= 1;
//        cell.x = - cell.height;
//        cell.transform = CGAffineTransformMakeRotation((-90.0f * M_PI) / 180.0f);
    }
    if (_showingCardNumber <= 0) {
        
        self.btn_nodata.hidden = NO;
        [self bringSubviewToFront:self.btn_nodata];
        //协议方法
//        if ([self.dataSource respondsToSelector:@selector(loadNewData)]) {
//            [self.dataSource loadNewData];
//        }
        
        //主动刷新
        //[self reloadData];
        
        //提示
        //        [[[UIAlertView alloc] initWithTitle:@"没有更多数据了" message:@"请实现加载下一页方法" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil] show];
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

- (M_SlideCard *)slideCard:(V_SlideCard *)slideCard itemForIndex:(NSInteger)index {
    return [self.dataSource slideCard:slideCard itemForIndex:index];
}

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
    return CGSizeMake(self.width - 30, self.height - 150);
}

#pragma mark - setter

- (void)setDataSource:(id<V_SlideCardDataSource>)dataSource {
    _dataSource = dataSource;
    [self layoutSlideCards];
}

#pragma mark - getter

- (NSMutableArray<V_SlideCardCell *> *)underCells {
    if (_underCells == nil) {
        _underCells = [[NSMutableArray alloc] init];
    }
    return _underCells;
}

- (UIButton *)btn_like {
    if (_btn_like == nil) {
        _btn_like = [[UIButton alloc] initWithFrame:CGRectMake((self.width - _buttonWidth * 2) / 3 * 2 + _buttonWidth, self.height - _buttonWidth - 30, _buttonWidth, _buttonWidth)];
        [_btn_like setBackgroundImage:[UIImage imageNamed:@"likeWhole"] forState:UIControlStateNormal];
        _btn_like.layer.borderColor = [UIColor grayColor].CGColor;
        _btn_like.layer.borderWidth = 5;
        _btn_like.layer.masksToBounds = YES;
        _btn_like.layer.cornerRadius = _buttonWidth / 2;
        _btn_like.tag = 520;
        [_btn_like addTarget:self action:@selector(likeOrHateAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btn_like;
}

- (UIButton *)btn_hate {
    if (_btn_hate == nil) {
        _btn_hate = [[UIButton alloc] initWithFrame:CGRectMake((self.width - _buttonWidth * 2) / 3, self.height - _buttonWidth - 30, _buttonWidth, _buttonWidth)];
        [_btn_hate setBackgroundImage:[UIImage imageNamed:@"hateWhole"] forState:UIControlStateNormal];
        _btn_hate.layer.borderColor = [UIColor grayColor].CGColor;
        _btn_hate.layer.borderWidth = 5;
        _btn_hate.layer.masksToBounds = YES;
        _btn_hate.layer.cornerRadius = _buttonWidth / 2;
        _btn_hate.tag = 521;
        [_btn_hate addTarget:self action:@selector(likeOrHateAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btn_hate;
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
    }
    return _btn_nodata;
}

@end
