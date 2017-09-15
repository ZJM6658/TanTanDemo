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
    BOOL _isCellAnimating;
}

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
    _isCellAnimating = NO;
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSlideCards {
    for (NSInteger i = 0; i < _cardNumber; i ++) {
        CGSize cellSize = [self slideCard:self sizeForItemAtIndex:i];;
        V_SlideCardCell *cell = [[V_SlideCardCell alloc] initWithFrame:CGRectMake(0, 0, cellSize.width, cellSize.height)];
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
        
        cell.dataItem = [self slideCard:self itemForIndex:i];
        cell.alpha = 1;

        //先设置到左边 再动画进入
        [cell hideToLeft];
        [UIView animateWithDuration:0.5 animations:^{
            cell.currentState = i;
        }];
        
        self.latestItemIndex = i;
    }
}

#pragma mark - notification

- (void)addAllObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveAction:) name:MOVEACTION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetFrame:) name:RESETFRAME object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stateChangeAction:) name:STATECHANGE object:nil];
}

- (void)moveAction:(NSNotification *)notification {
    NSDictionary *object = notification.object;
    CGFloat percentX = [[object objectForKey:PERCENTX] floatValue];
    if (percentX > 0) {
        self.btn_like.layer.borderWidth = 5 * (1 - percentX);
    } else {
        self.btn_hate.layer.borderWidth = 5 * (1 - fabs(percentX));
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
    if (_isCellAnimating) {
        return;
    }
    
    BOOL choosedLike = NO;
    NSInteger toCenterX = 0;
    if (sender.tag == 520) {
        choosedLike = YES;
        toCenterX = SCRW;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:STATECHANGE object:@{@"RESULT":@(choosedLike), @"CLICK": @YES}];
}

- (void)loadMoreData {
//    加载下一组数据
    if ([self.dataSource respondsToSelector:@selector(loadNewData)]) {
        [self.dataSource loadNewData];
    }
}

#pragma mark - V_SlideCardCellDelegate

- (BOOL)isAnimating {
    return _isCellAnimating;
}

- (void)setAnimatingState:(BOOL)animating {
    _isCellAnimating = animating;
}

- (void)loadNewData:(V_SlideCardCell *)cell {
    if (self.latestItemIndex + 1 < [self numberOfItemsInSlideCard:self]) {
        self.latestItemIndex += 1;
        [self sendSubviewToBack:cell];
        cell.dataItem = [self slideCard:self itemForIndex:self.latestItemIndex];
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

#warning 按钮事件的控制  连续点击  应该等一个跑完
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
        [_btn_nodata addTarget:self action:@selector(loadMoreData) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btn_nodata;
}

@end
