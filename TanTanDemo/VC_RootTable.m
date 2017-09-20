//
//  VC_RootTable.m
//  TanTanDemo
//
//  Created by zhujiamin on 2017/9/18.
//  Copyright © 2017年 zhujiamin. All rights reserved.
//

#import "VC_RootTable.h"
#import "VC_Example.h"

@interface VC_RootTable () {
    NSArray *_rowTitles;
}

@end

@implementation VC_RootTable

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Demo";
    _rowTitles = @[@"空白控件", @"探探", @"BOSS直聘", @"招才猫直聘"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _rowTitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = _rowTitles[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 3) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.detailTextLabel.text = @"有点懒, 没写, 嘿嘿😁";
        return;
    }
    VC_Example *example = [[VC_Example alloc] init];
    example.exampleType = indexPath.row;
    [self.navigationController pushViewController:example animated:YES];
}

@end
