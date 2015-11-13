//
//  NHReuseCell.m
//  NHNetEasyNaviPro
//
//  Created by hu jiaju on 15/9/22.
//  Copyright © 2015年 hu jiaju. All rights reserved.
//

#import "NHReuseCell.h"

@interface NHReuseCell ()<UITableViewDelegate>

@property (nonatomic, readwrite) UITableView *tableView;
@property (nonatomic, readwrite) NSString *identifier;

@end

@implementation NHReuseCell

- (id)initWithFrame:(CGRect)frame withIdentifier:(NSString *)identifier withChannel:(NSString *)channel {
    self = [super initWithFrame:frame];
    if (self) {
        _identifier = [identifier copy];
        _channel = [channel copy];
        [self _initSetup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _initSetup];
    }
    return self;
}

- (void)_initSetup {
    
//    _dataSource = [NSMutableArray array];
//    for (int i = 0; i < 25; i++) {
//        NSString *tmp = [NSString stringWithFormat:@"第%zd行",i+1];
//        [_dataSource addObject:tmp];
//    }
    CGRect infoRect = self.bounds;
    _tableView = [[UITableView alloc] initWithFrame:infoRect style:UITableViewStylePlain];
    _tableView.separatorInset = UIEdgeInsetsZero;
    _tableView.delegate = self;
    [self addSubview:_tableView];
}

- (void)setChannel:(NSString *)channel{
    if (channel && ![channel isEqualToString:_channel]) {
        _channel = channel;
        //NSLog(@"改变了channel");
    }
}

-(UIColor *)randomColor{
    static BOOL seeded = NO;
    if (!seeded) {
        seeded = YES;
        srandom((unsigned)time(NULL));
    }
    CGFloat red =  (CGFloat)random()/(CGFloat)RAND_MAX;
    CGFloat blue = (CGFloat)random()/(CGFloat)RAND_MAX;
    CGFloat green = (CGFloat)random()/(CGFloat)RAND_MAX;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    //NSLog(@"%s",__FUNCTION__);
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    //NSLog(@"%s",__FUNCTION__);
}

- (void)viewWillApear{
    
}

- (void)viewWillDisappear{
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"%s---channel:%@",__FUNCTION__,self.channel);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
