//
//  VC_Root.m
//  TanTanDemo
//
//  Created by zhujiamin on 2016/11/15.
//  Copyright © 2016年 zhujiamin. All rights reserved.
//

#import "VC_Root.h"
#import "V_SlideCard.h"
#import "M_TanTan.h"
#import "V_TanTan.h"

@interface VC_Root ()<V_SlideCardDataSource, V_SlideCardDelegate, UICollectionViewDelegate> {
    NSInteger _pageNo;//数据页码
    CGFloat _buttonWidth;
    CGFloat _buttonBorderWidth;

}

@property (nonatomic, strong) NSMutableArray *listData;
@property (nonatomic, strong) V_SlideCard *slideCard;

@property (nonatomic, strong) UIButton  *btn_like;
@property (nonatomic, strong) UIButton  *btn_hate;

@end

@implementation VC_Root

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    _pageNo = 0;
    _buttonWidth = 70;
    _buttonBorderWidth = 8;
    
    self.view.height -= 64;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.modalPresentationCapturesStatusBarAppearance = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"TanTan";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"更多" style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonClick)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"消息" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonClick)];

    [self.view addSubview:self.slideCard];
    
    [self.view addSubview:self.btn_like];
    [self.view addSubview:self.btn_hate];
}

#pragma mark - event response

- (void)likeOrHateAction:(UIButton *)sender {
    if (sender.tag == 520) {
        [self.slideCard animateTopCardToDirection:PanDirectionRight];
    } else {
        [self.slideCard animateTopCardToDirection:PanDirectionLeft];
    }
}
#pragma mark - V_SlideCardDataSource

- (void)loadNewData {
    _pageNo ++;
    self.listData = [self getDataSourceWithPageNo:_pageNo];
    [self.slideCard reloadData];
}

- (void)loadNewDataInCell:(V_TanTan *)cell atIndex:(NSInteger)index {
    M_TanTan *item = [self.listData objectAtIndex:index];
    cell.dataItem = item;
}

- (NSInteger)numberOfItemsInSlideCard:(V_SlideCard *)slideCard {
    return self.listData.count;
}

- (CGSize)slideCard:(V_SlideCard *)slideCard sizeForItemAtIndex:(NSInteger)index {
    return CGSizeMake(350, 400);
}

#pragma mark - V_SlideCardDelegate

- (void)slideCardCell:(V_TanTan *)cell didPanPercent:(CGFloat)percent withDirection:(PanDirection)direction {
    
    NSLog(@"panpercent= %f, state%d", percent, (int)cell.currentState);
    if (direction == PanDirectionRight) {
        cell.iv_like.alpha = percent;
        self.btn_like.layer.borderWidth = _buttonBorderWidth * (1 - percent);
    } else {
        cell.iv_hate.alpha = percent;
        self.btn_hate.layer.borderWidth = _buttonBorderWidth * (1 - percent);
    }
}

- (void)slideCardCell:(V_TanTan *)cell willScrollToDirection:(PanDirection)direction {
    if (direction == PanDirectionRight) {
        cell.iv_like.alpha = 1;
    } else {
        cell.iv_hate.alpha = 1;
    }
}

- (void)slideCardCell:(V_TanTan *)cell didChangedStateWithDirection:(PanDirection)direction atIndex:(NSInteger)index {
    [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.btn_like.layer.borderWidth = _buttonBorderWidth;
        self.btn_hate.layer.borderWidth = _buttonBorderWidth;
        cell.iv_like.alpha = 0;
        cell.iv_hate.alpha = 0;
    } completion:nil];
}

- (void)slideCardCellDidResetFrame:(V_TanTan *)cell {
    [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.btn_like.layer.borderWidth = _buttonBorderWidth;
        self.btn_hate.layer.borderWidth = _buttonBorderWidth;
        cell.iv_like.alpha = 0;
        cell.iv_hate.alpha = 0;
    } completion:nil];
}

#pragma mark - private methods

- (void)leftBarButtonClick { }
- (void)rightBarButtonClick { }

#pragma mark - getter

- (V_SlideCard *)slideCard {
    if (_slideCard == nil) {
        _slideCard = [[V_SlideCard alloc] initWithFrame:self.view.bounds];
        _slideCard.dataSource = self;
        _slideCard.delegate = self;
        [_slideCard registerCellClassName:@"V_TanTan"];
    }
    return _slideCard;
}

- (NSMutableArray *)listData {
    if (_listData == nil) {
        _listData = [[NSMutableArray alloc] init];
        _listData = [[self getDataSourceWithPageNo:0] copy];
    }
    return _listData;
}

- (NSMutableArray *)getDataSourceWithPageNo:(NSInteger)pageNo {
    NSMutableArray *itemArray = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < 10; i++) {
        NSString *imageName = [NSString stringWithFormat:@"tantan%d%lu", 0,i];
        NSString *nickName = [NSString stringWithFormat:@"姓名%lu%lu", pageNo,i];
        
        [itemArray addObject:[[M_TanTan alloc] initWithImage:imageName andName:nickName andConstellation:@"某星座" andJob:@"职位" andDistance:[NSString stringWithFormat:@"%lu%lukm", pageNo,i] andAge:@"23岁"]];
    }
    return itemArray;
}

- (UIButton *)btn_like {
    if (_btn_like == nil) {
        _btn_like = [[UIButton alloc] initWithFrame:CGRectMake((self.view.width - _buttonWidth * 2) / 3 * 2 + _buttonWidth, self.view.height - _buttonWidth - 30, _buttonWidth, _buttonWidth)];
        [_btn_like setBackgroundImage:[UIImage imageNamed:@"likeWhole"] forState:UIControlStateNormal];
        _btn_like.layer.borderColor = [UIColor colorWithWhite:0.2 alpha:0.9].CGColor;
        _btn_like.layer.borderWidth = _buttonBorderWidth;
        _btn_like.layer.masksToBounds = YES;
        _btn_like.layer.cornerRadius = _buttonWidth / 2;
        _btn_like.tag = 520;
        [_btn_like addTarget:self action:@selector(likeOrHateAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btn_like;
}

- (UIButton *)btn_hate {
    if (_btn_hate == nil) {
        _btn_hate = [[UIButton alloc] initWithFrame:CGRectMake((self.view.width - _buttonWidth * 2) / 3, self.view.height - _buttonWidth - 30, _buttonWidth, _buttonWidth)];
        [_btn_hate setBackgroundImage:[UIImage imageNamed:@"hateWhole"] forState:UIControlStateNormal];
        _btn_hate.layer.borderColor = [UIColor colorWithWhite:0.2 alpha:0.9].CGColor;
        _btn_hate.layer.borderWidth = _buttonBorderWidth;
        _btn_hate.layer.masksToBounds = YES;
        _btn_hate.layer.cornerRadius = _buttonWidth / 2;
        _btn_hate.tag = 521;
        [_btn_hate addTarget:self action:@selector(likeOrHateAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btn_hate;
}
@end
