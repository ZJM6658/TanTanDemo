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

@interface VC_Root ()<V_SlideCardDataSource, V_SlideCardDelegate> {
    NSInteger _pageNo;//数据页码
    CGFloat _buttonWidth;

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
    _buttonWidth = 60;

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

- (void)slideCardCell:(V_SlideCardCell *)cell didPanPercent:(CGFloat)percent withDirection:(PanDirection)direction {
    if (direction == PanDirectionRight) {
        self.btn_like.layer.borderWidth = 5 * (1 - percent);
    } else {
        self.btn_hate.layer.borderWidth = 5 * (1 - percent);
    }
}

- (void)slideCardCellDidResetFrame:(V_SlideCardCell *)cell {
    [self resetButton];
}

- (void)slideCardCellDidChangedState:(V_SlideCardCell *)cell {
    [self resetButton];
}

- (void)resetButton {
    [UIView animateWithDuration:0.3 animations:^{
        self.btn_like.layer.borderWidth = 5;
        self.btn_hate.layer.borderWidth = 5;
    }];
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
        //        [_listData addObject:[[M_TanTan alloc] initWithImage:@"tantan3" andName:@"陈1" andConstellation:@"狮子座" andJob:@"演员" andDistance:nil andAge:@"32岁"]];
        //        [_listData addObject:[[M_TanTan alloc] initWithImage:@"tantan2" andName:@"郑2" andConstellation:@"摩羯座" andJob:@"歌手" andDistance:@"3km" andAge:@"23岁"]];
        //
        //        [_listData addObject:[[M_TanTan alloc] initWithImage:@"tantan3" andName:@"张3" andConstellation:@"处女座" andJob:@"AV演员" andDistance:nil andAge:@"26岁"]];
        //        [_listData addObject:[[M_TanTan alloc] initWithImage:@"tantan1" andName:@"李4" andConstellation:@"双子座" andJob:@"演员" andDistance:@"1000km" andAge:@"41岁"]];
        //        [_listData addObject:[[M_TanTan alloc] initWithImage:@"tantan3" andName:@"王5" andConstellation:@"狮子座" andJob:@"演员" andDistance:nil andAge:@"32岁"]];
        //        [_listData addObject:[[M_TanTan alloc] initWithImage:@"tantan2" andName:@"赵6" andConstellation:@"摩羯座" andJob:@"歌手" andDistance:@"3km" andAge:@"23岁"]];
        //        [_listData addObject:[[M_TanTan alloc] initWithImage:@"tantan3" andName:@"任7" andConstellation:@"处女座" andJob:@"AV演员" andDistance:nil andAge:@"26岁"]];
        //        [_listData addObject:[[M_TanTan alloc] initWithImage:@"tantan1" andName:@"孙8" andConstellation:@"双子座" andJob:@"演员" andDistance:@"1000km" andAge:@"41岁"]];
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
        _btn_hate = [[UIButton alloc] initWithFrame:CGRectMake((self.view.width - _buttonWidth * 2) / 3, self.view.height - _buttonWidth - 30, _buttonWidth, _buttonWidth)];
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
@end
