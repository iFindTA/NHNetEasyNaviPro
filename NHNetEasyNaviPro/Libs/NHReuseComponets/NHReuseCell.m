//
//  NHReuseCell.m
//  NHNetEasyNaviPro
//
//  Created by hu jiaju on 15/9/22.
//  Copyright © 2015年 hu jiaju. All rights reserved.
//

#import "NHReuseCell.h"

@interface NHReuseCell ()<UITableViewDelegate, UITableViewDataSource, NSCopying, NSMutableCopying>

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic) NSString *identifier;

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

- (id)copyWithZone:(NSZone *)zone {
    NHReuseCell *copy = [[[self class] allocWithZone:zone] init];
    copy.identifier = [_identifier copy];
    copy.channel = [_channel copy];
    copy.dataSource = [_dataSource copy];
    //copy.tableView = [_tableView copy];
    return copy;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    NHReuseCell *copy = [[[self class] allocWithZone:zone] init];
    copy.identifier = [_identifier copy];
    copy.channel = [_channel copy];
    copy.dataSource = [_dataSource copy];
    //copy.tableView = [_tableView copy];
    return copy;
}

- (NHReuseCell *)nh_mutableCopy {
    __block NHReuseCell *item = [[NHReuseCell alloc] initWithFrame:self.bounds];
    item.identifier = self.identifier;
    item.channel = self.channel;
    item.dataSource = self.dataSource;
    item.tableView = self.tableView;
    item.tableView.dataSource = item;
    item.tableView.delegate = item;
    [item addSubview:item.tableView];
    item.label = self.label;
    [item addSubview:item.label];
    
    //NSArray *subviews = [self subviews];
    //[self deepCopyAllSubviews:subviews newView:item];
    
//    id copyOfView =
//    [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
//    NHReuseCell *copy = (NHReuseCell *)copyOfView;
//    item = copy;
    
    return item;
}

- (void)deepCopyAllSubviews:(NSArray *)subviews newView:(UIView *)view{
    [subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        CGRect frame = [obj frame];
        frame.origin.x = [obj.superview convertPoint:frame.origin toView:view].x;
        [obj setFrame:frame];
        [view addSubview:obj];
        NSArray *subs = [obj subviews];
        if ([subs count]>0) {
            [self deepCopyAllSubviews:subs newView:view];
        }
    }];
}

- (void)_initSetup {
    
    _dataSource = [NSMutableArray array];
    for (int i = 0; i < 25; i++) {
        NSString *tmp = [NSString stringWithFormat:@"第%zd行",i+1];
        [_dataSource addObject:tmp];
    }
    CGRect infoRect = self.bounds;
    _tableView = [[UITableView alloc] initWithFrame:infoRect style:UITableViewStylePlain];
    _tableView.separatorInset = UIEdgeInsetsZero;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    //[self addSubview:_tableView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:infoRect];
    label.font = [UIFont systemFontOfSize:30];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = _channel;
    label.backgroundColor = [self randomColor];
    [self addSubview:label];
    _label = label;
}

- (void)setChannel:(NSString *)channel{
    if (channel && ![channel isEqualToString:_channel]) {
        _channel = channel;
        _label.text = channel;
        //NSLog(@"改变了channel");
    }
}

#pragma mark -- UITableView --

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count = [_dataSource count];
    
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"celld";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.contentView.backgroundColor = [self randomColor];
    cell.textLabel.text = [_dataSource objectAtIndex:indexPath.row];
    cell.textLabel.backgroundColor = [self randomColor];
    return cell;
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
