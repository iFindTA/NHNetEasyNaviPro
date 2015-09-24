//
//  ViewController.m
//  NHNetEasyNaviPro
//
//  Created by hu jiaju on 15/9/14.
//  Copyright (c) 2015年 hu jiaju. All rights reserved.
//

#import "ViewController.h"
#import "NHNaviSubscriber.h"
#import "NHReuseView.h"

@interface ViewController ()<NHNaviSubscriberDataSource,NHNaviSubscriberDelegate, NHReViewDelegate, NHReViewDataSource>

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NHNaviSubscriber *scriber;
@property (nonatomic, strong) NHReuseView *reuseView;

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.automaticallyAdjustsScrollViewInsets = false;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"网易新闻";
    
    CGRect infoRect = CGRectMake(0, 64, self.view.bounds.size.width, 40);
    NHNaviSubscriber *scriber = [[NHNaviSubscriber alloc] initWithFrame:infoRect forStyle:NHNaviStyleBack];
    //scriber.backgroundColor = [UIColor cyanColor];
    scriber.dataSource = self;
    scriber.delegate = self;
    [self.view addSubview:scriber];
    _scriber = scriber;
    [_scriber reloadData];
    
    _dataSource = [NSMutableArray arrayWithArray:[self tempArray]];
    infoRect.origin.y += 40;
    infoRect.size.height = 500;
    NHReuseView *reuseView = [[NHReuseView alloc] initWithFrame:infoRect];
    reuseView.dataSource = self;
    reuseView.delegate = self;
    [self.view addSubview:reuseView];
    _reuseView = reuseView;
    
    //[self _initSetup];
}

- (NSArray *)tempArray{
    NSMutableArray *listTop = [[NSMutableArray alloc] initWithArray:@[@"推荐",@"热点",@"杭州财经报社",@"社会",@"娱乐",@"科技",@"汽车",@"体育",@"订阅",@"财经",@"军事",@"国际",@"正能量",@"段子",@"趣图",@"美女",@"健康",@"教育",@"特卖",@"彩票",@"辟谣"]];
    return listTop;
}

- (NSArray *)exsitDataForSubscriber:(NHNaviSubscriber *)scriber{
    NSMutableArray *listTop = [[NSMutableArray alloc] initWithArray:@[@"推荐",@"热点",@"杭州财经报社",@"社会",@"娱乐",@"科技",@"汽车",@"体育",@"订阅",@"财经",@"军事",@"国际",@"正能量",@"段子",@"趣图",@"美女",@"健康",@"教育",@"特卖",@"彩票",@"辟谣"]];
    return listTop;
}

- (NSArray *)newDataForSubscriber:(NHNaviSubscriber *)scriber{
    NSMutableArray *listBottom = [[NSMutableArray alloc] initWithArray:@[@"电影",@"数码",@"时尚",@"奇葩",@"游戏",@"旅游",@"育儿",@"减肥",@"养生",@"美食",@"政务",@"历史",@"探索",@"故事",@"美文",@"情感",@"语录",@"美图",@"房产",@"家居",@"搞笑",@"星座",@"文化",@"毕业生",@"视频"]];
    return listBottom;
}

- (BOOL)subscriber:(NHNaviSubscriber *)scriber canEditForTitle:(NSString *)title{
    return true;
}

- (void)subscriber:(NHNaviSubscriber *)scriber didSelectIndex:(NSInteger)index{
    NSLog(@"did select index:%zd",index);
    [_reuseView setReuseSelectIndex:index];
}

- (void)didSelectArrowForSubscriber:(NHNaviSubscriber *)scriber {
    NSLog(@"did select scriber's arrow");
}

#pragma mark -- ReView --

- (NSUInteger)numberOfCountsInReuseView:(NHReuseView *)view {
    return [_dataSource count];
}

- (NHReuseCell *)review:(NHReuseView *)view pageViewAtIndex:(NSUInteger)index{
    static NSString *identifier = @"cell";
    NHReuseCell *cell = [view dequeueReusablePageWithIdentifier:identifier];
    if (cell == nil) {
        NSString *channel = [_dataSource objectAtIndex:index];
        cell = [[NHReuseCell alloc] initWithFrame:view.bounds withIdentifier:identifier withChannel:channel];
    }
    NSString *channel = [_dataSource objectAtIndex:index];
    cell.channel = channel;
    //NSLog(@"cell for row:%zd",index);
    return cell;
}

-  (void)review:(NHReuseView *)view willDismissIndex:(NSUInteger)index{
    NSLog(@"will dismiss index :%zd",index);
}

- (void)review:(NHReuseView *)view didChangeToIndex:(NSUInteger)index{
    NSLog(@"did changed to index :%zd",index);
    [_scriber setSubscriberSelectIndex:index];
}

- (void)editEvent{
    [_scriber setSubscriberSelectIndex:8];
}

-(UIColor *)randomColor{
    static BOOL seeded = NO;
    if (!seeded) {
        seeded = YES;
        srandom(time(NULL));
    }
    CGFloat red =  (CGFloat)random()/(CGFloat)RAND_MAX;
    CGFloat blue = (CGFloat)random()/(CGFloat)RAND_MAX;
    CGFloat green = (CGFloat)random()/(CGFloat)RAND_MAX;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
