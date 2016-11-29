//
//  VC_Root.m
//  TanTanDemo
//
//  Created by zhujiamin on 2016/11/15.
//  Copyright © 2016年 zhujiamin. All rights reserved.
//

#import "VC_Root.h"

@interface VC_Root ()

@property (nonatomic, strong) NSMutableArray *listData;
@property (nonatomic, strong) V_SlideCard *slideCard;

@end

@implementation VC_Root

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.height -= 64;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.modalPresentationCapturesStatusBarAppearance = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"TanTan";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"更多" style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonClick)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"消息" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonClick)];

    [self.view addSubview:self.slideCard];
}

#pragma mark - getter
- (NSMutableArray *)listData {
    if (!_listData) {
        _listData = [[NSMutableArray alloc] init];

        _listData = [[self getDataSourceWithPageNo:0] copy];
//        [_listData addObject:[[M_SlideCard alloc] initWithImage:@"tantan3" andName:@"陈1" andConstellation:@"狮子座" andJob:@"演员" andDistance:nil andAge:@"32岁"]];
//        [_listData addObject:[[M_SlideCard alloc] initWithImage:@"tantan2" andName:@"郑2" andConstellation:@"摩羯座" andJob:@"歌手" andDistance:@"3km" andAge:@"23岁"]];
//
//        [_listData addObject:[[M_SlideCard alloc] initWithImage:@"tantan3" andName:@"张3" andConstellation:@"处女座" andJob:@"AV演员" andDistance:nil andAge:@"26岁"]];
//        [_listData addObject:[[M_SlideCard alloc] initWithImage:@"tantan1" andName:@"李4" andConstellation:@"双子座" andJob:@"演员" andDistance:@"1000km" andAge:@"41岁"]];
//        [_listData addObject:[[M_SlideCard alloc] initWithImage:@"tantan3" andName:@"王5" andConstellation:@"狮子座" andJob:@"演员" andDistance:nil andAge:@"32岁"]];
//        [_listData addObject:[[M_SlideCard alloc] initWithImage:@"tantan2" andName:@"赵6" andConstellation:@"摩羯座" andJob:@"歌手" andDistance:@"3km" andAge:@"23岁"]];
//        [_listData addObject:[[M_SlideCard alloc] initWithImage:@"tantan3" andName:@"任7" andConstellation:@"处女座" andJob:@"AV演员" andDistance:nil andAge:@"26岁"]];
//        [_listData addObject:[[M_SlideCard alloc] initWithImage:@"tantan1" andName:@"孙8" andConstellation:@"双子座" andJob:@"演员" andDistance:@"1000km" andAge:@"41岁"]];
    }
    return _listData;
}

- (NSMutableArray *)getDataSourceWithPageNo:(NSInteger)pageNo {
    NSMutableArray *itemArray = [[NSMutableArray alloc] init];

    for (NSInteger i = 0; i < 10; i++) {
        NSString *imageName = [NSString stringWithFormat:@"tantan%lu%lu", pageNo,i];
        NSString *nickName = [NSString stringWithFormat:@"姓名%lu%lu", pageNo,i];

        [itemArray addObject:[[M_SlideCard alloc] initWithImage:imageName andName:nickName andConstellation:@"某星座" andJob:@"职位" andDistance:[NSString stringWithFormat:@"%lu%lukm", pageNo,i] andAge:@"23岁"]];
    }
    return itemArray;
}

- (V_SlideCard *)slideCard {
    if (!_slideCard) {
        _slideCard = [[V_SlideCard alloc] initWithFrame:self.view.bounds];
        _slideCard.dataSource = self;
    }
    return _slideCard;
}

#pragma mark - V_SlideCardDataSource
- (M_SlideCard *)slideCard:(V_SlideCard *)slideCard itemForIndex:(NSInteger)index {
    M_SlideCard *item = [self.listData objectAtIndex:index];
    return item;
}

- (NSInteger)numberOfItemsInSlideCard:(V_SlideCard *)slideCard {
    return self.listData.count;
}

#pragma mark - private methods
- (void)leftBarButtonClick { }
- (void)rightBarButtonClick { }
@end
