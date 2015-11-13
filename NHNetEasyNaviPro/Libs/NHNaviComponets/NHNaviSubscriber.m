//
//  NHNaviSubscriber.m
//  NHNetEasyNaviPro
//
//  Created by hu jiaju on 15/9/14.
//  Copyright (c) 2015年 hu jiaju. All rights reserved.
//

#define kItemDistance       30
#define kExtradPadding      20
#define kItemFontSize       13
#define kEditArrowWidth     40
#define kAnimationDuration  0.25
#define RGBColor(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

#import "NHNaviSubscriber.h"

#define kScreenW [UIScreen mainScreen].bounds.size.width
#define itemPerLine 4
#define kItemW (kScreenW-kExtradPadding*(itemPerLine+1))/itemPerLine
#define kItemH 25

#pragma mark -- Item

typedef enum{
    top = 0,
    bottom = 1
}Location;

@interface NHCItem : UIButton

@property (nonatomic,strong) UIView   *hitTextLabel;
@property (nonatomic,strong) UIButton *deleteBtn;
@property (nonatomic,strong) UIButton *hiddenBtn;
@property (nonatomic,assign) Location location;
@property (nonatomic,copy) NSString *itemName;

@end

@implementation NHCItem

- (void)setItemName:(NSString *)itemName{
    _itemName = itemName;
    
    [self setTitle:itemName forState:0];
    [self setTitleColor:RGBColor(111.0, 111.0, 111.0) forState:0];
    self.titleLabel.font = [UIFont systemFontOfSize:kItemFontSize];
    self.layer.cornerRadius = 4;
    self.layer.borderColor = [RGBColor(200.0, 200.0, 200.0) CGColor];
    self.layer.borderWidth = 0.5;
    self.backgroundColor = [UIColor whiteColor];
    [self addTarget:self
             action:@selector(operationWithoutHidBtn)
   forControlEvents:1<<6];
}

- (void)operationWithoutHidBtn{
    NSLog(@"touched item");
}

@end

#pragma mark -- Edit View --

@protocol NHEditDataSource <NSObject>

- (NSArray *)existData;
- (NSArray *)newData;

@end

@interface NHEditChannel : UIView

@property (nonatomic, strong) UIView *superView;
@property (nonatomic, strong) UILabel *hitText;
@property (nonatomic, strong) UIButton *sortBtn;
@property (nonatomic, strong) UIScrollView *scroll;
@property (nonatomic, assign) id<NHEditDataSource> dataSource;
@property (nonatomic, assign) CGFloat selfOriginHeight;

- (id)initWithFrame:(CGRect)frame withSuperView:(UIView *)view;

- (void)expand:(BOOL)expand;

@end

@implementation NHEditChannel

- (id)initWithFrame:(CGRect)frame withSuperView:(UIView *)view withDataSource:(id<NHEditDataSource>)dataSource{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = RGBColor(238.0, 238.0, 238.0);
        _superView = view;
        _dataSource = dataSource;
        _selfOriginHeight = frame.size.height;
        [self _initSetup];
    }
    return self;
}

- (void)_initSetup {
    
    [self.scroll setHidden:true];
    [self addSubview:self.scroll];
    
    CGSize selfSize = [self bounds].size;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(kExtradPadding, 0, selfSize.width-kEditArrowWidth, selfSize.height)];
    label.font = [UIFont systemFontOfSize:kItemFontSize+2];
    label.textColor = [UIColor blackColor];
    label.text = @"我的频道";
    [self addSubview:label];
    
    [self addSubview:self.hitText];
    
    [self addSubview:self.sortBtn];
    
    
}

- (UILabel *)hitText{
    if (!_hitText) {
        CGSize selfSize = [self bounds].size;
        _hitText = [[UILabel alloc] initWithFrame:CGRectMake(90,0, 100, selfSize.height)];
        _hitText.font = [UIFont systemFontOfSize:kItemFontSize-2];
        _hitText.text = @"拖拽可以排序";
        _hitText.textColor = RGBColor(170.0, 170.0, 170.0);
        _hitText.hidden = YES;
    }
    return _hitText;
}

- (UIButton *)sortBtn{
    if (_sortBtn == nil) {
        CGSize selfSize = [self bounds].size;
        CGFloat btn_width = 50;
        CGRect infoRect = CGRectMake(selfSize.width-kEditArrowWidth-btn_width-kExtradPadding, (selfSize.height-kExtradPadding)*0.5, btn_width, kExtradPadding);
        _sortBtn = [[UIButton alloc] initWithFrame:infoRect];
        [_sortBtn setTitle:@"排序" forState:0];
        [_sortBtn setTitleColor:[UIColor redColor] forState:0];
        _sortBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        _sortBtn.layer.cornerRadius = 5;
        _sortBtn.layer.borderWidth = 0.5;
        [_sortBtn.layer setMasksToBounds:YES];
        _sortBtn.layer.borderColor = [[UIColor redColor] CGColor];
        [_sortBtn addTarget:self
                         action:@selector(sortBtnClick:)
               forControlEvents:1<<6];
    }
    return _sortBtn;
}

- (UIScrollView *)scroll{
    if (!_scroll) {
        CGSize selfSize = [self bounds].size;
        CGSize superSize = _superView.bounds.size;
        CGFloat height = superSize.height-selfSize.height;
        CGRect infoRect = CGRectMake(0, selfSize.height, selfSize.width, height);
        _scroll = [[UIScrollView alloc] initWithFrame:infoRect];
        _scroll.backgroundColor = [UIColor whiteColor];
        _scroll.showsHorizontalScrollIndicator = false;
        _scroll.showsVerticalScrollIndicator = false;
        
        NSAssert(_dataSource != nil, @"edit scroll dataSource can not be nil !");
        NSArray *topSources = [_dataSource existData];
        NSArray *downSources = [_dataSource newData];
        infoRect = CGRectMake(0, kExtradPadding+(kExtradPadding + kItemH)*((topSources.count -1)/itemPerLine+1), selfSize.width, selfSize.height);
        UIView *tmpView = [[UIView alloc] initWithFrame:infoRect];
        tmpView.backgroundColor = RGBColor(238.0, 238.0, 238.0);
        UILabel *moreText = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 100, 20)];
        moreText.backgroundColor = [UIColor clearColor];
        moreText.text = @"点击添加频道";
        moreText.font = [UIFont systemFontOfSize:kItemFontSize+2];
        [tmpView addSubview:moreText];
        [_scroll addSubview:tmpView];
        
        __weak typeof(self) weakSelf = self;
        [topSources enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL *stop) {
            CGRect tmpRect = CGRectMake(kExtradPadding+(kExtradPadding+kItemW)*(idx% itemPerLine), kExtradPadding+(kItemH + kExtradPadding)*(idx/itemPerLine), kItemW, kItemH);
            NHCItem *item = [NHCItem buttonWithType:UIButtonTypeCustom];
            item.frame = tmpRect;
            item.itemName = title;
            item.location = top;
            [weakSelf.scroll addSubview:item];
        }];
    }
    return _scroll;
}

-(void)sortBtnClick:(UIButton *)sender{
    if (sender.selected) {
        [sender setTitle:@"排序" forState:0];
        self.hitText.hidden = YES;
    }
    else{
        [sender setTitle:@"完成" forState:0];
        self.hitText.hidden = NO;
    }
    sender.selected = !sender.selected;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"sortBtnClick"
                                                        object:sender
                                                      userInfo:nil];
}

- (void)expand:(BOOL)expand{
    self.hidden = !expand;
    CGSize superSize = _superView.bounds.size;
    CGRect selfFrame = [self frame];
    selfFrame.size.height = expand?superSize.height:_selfOriginHeight;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        //_scroll.hidden = !expand;
        //self.frame = selfFrame;
        self.hidden = !expand;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)_initScrollSubviews{
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
}

@end

#pragma mark -- Main View --

@interface NHNaviSubscriber ()<NHEditDataSource>

@property (nonatomic, assign) NHNaviStyle style;
@property (nonatomic, strong) NSMutableArray *exsitData, *btnSets;
@property (nonatomic, assign) BOOL expadding, outTrigger;
@property (nonatomic, strong) UIView *flagView, *sortBar;
@property (nonatomic, strong) CALayer *lineLayer;
@property (nonatomic, assign) CGFloat maxWidth;
@property (nonatomic, strong) UIScrollView *displayScroll, *editScroll;
@property (nonatomic, assign) NSInteger selectIndex;

@end

static CGFloat kFlagOffset = 10;
static CGFloat kFlagHeight = 20;

@implementation NHNaviSubscriber

- (id)initWithFrame:(CGRect)frame forStyle:(NHNaviStyle)style {
    self = [super initWithFrame:frame];
    if (self) {
        _style = style;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (void)setSubscriberSelectIndex:(NSInteger)index {
    
    NSAssert(_dataSource != nil, @"subcriber's datasource must not be nil !");
    NSArray *exsitArr = [_dataSource exsitDataForSubscriber:self];
    NSInteger counts = [exsitArr count];
    if (index < 0 || index >= counts) {
        return;
    }
    _outTrigger = true;
    [self focusIndex:index];
}

- (void)reloadData {
    
    _expadding = false;
    _selectIndex = 0;
    if (_btnSets || [_btnSets count]) {
        [_btnSets removeAllObjects];
        _btnSets = nil;
    }
    _btnSets = [[NSMutableArray alloc] initWithCapacity:0];
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSAssert(_dataSource != nil, @"subcriber's datasource must not be nil !");
    [self _initSetup];
}

- (void)_initSetup {
    
    _outTrigger = false;
    __block CGSize selfSize = self.bounds.size;
    //CGSize superSize = [_superView bounds].size;
    NSArray *exist_data = [_dataSource exsitDataForSubscriber:self];
    NSAssert(exist_data.count > 0, @"exsit data must one more thing !");
    
    CGRect infoRect;
    
    _maxWidth = kFlagHeight;
    //generate items for display scroll
    [self addSubview:self.displayScroll];
    [_displayScroll addSubview:self.flagView];
    
    __block CGFloat tmpWidthSum = kFlagHeight;
    __block UIColor *btnColor = [self btnTitleColor];
    __block UIColor *selectColor = _style == NHNaviStyleBack?[UIColor whiteColor]:[UIColor redColor];
    [exist_data enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL *stop) {
       
        if (title.length > 0) {
            CGSize itemSize = [self calculateSizeWithFont:kItemFontSize Text:title];
            CGRect tmpRect = CGRectMake( tmpWidthSum, 0, itemSize.width, selfSize.height);
            UIButton *tmpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            tmpBtn.frame = tmpRect;
            tmpBtn.tag = idx;
            tmpBtn.exclusiveTouch = true;
            tmpBtn.titleLabel.font = [UIFont systemFontOfSize:kItemFontSize];
            [tmpBtn setTitle:title forState:UIControlStateNormal];
            [tmpBtn setTitleColor:btnColor forState:UIControlStateNormal];
            [tmpBtn addTarget:self action:@selector(itemClicked:) forControlEvents:UIControlEventTouchUpInside];
            if (idx == _selectIndex) {
                [tmpBtn setTitleColor:selectColor forState:UIControlStateNormal];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [_displayScroll addSubview:tmpBtn];
            });
            [_btnSets addObject:tmpBtn];
            tmpWidthSum += (itemSize.width + kItemDistance);
        }
    }];
    tmpWidthSum += kFlagHeight - kItemDistance;
    CGSize contentSize = CGSizeMake(tmpWidthSum, selfSize.height);
    [_displayScroll setContentSize:contentSize];
    
    infoRect = CGRectMake(selfSize.width-kEditArrowWidth, 0, kEditArrowWidth, selfSize.height);
    UIImage *image = [UIImage imageNamed:@"Arrow"];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = infoRect;
    [btn setImage:image forState:UIControlStateNormal];
    btn.backgroundColor = [self mainBackgroundColor];
    [btn addTarget:self action:@selector(arrowBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
}

- (void)itemClicked:(UIButton *)btn{
    _outTrigger = false;
    NSInteger btn_tag = [btn tag];
    if (btn_tag < 0 || btn_tag >= [_btnSets count]) {
        return;
    }
    if (btn_tag != _selectIndex) {
        _selectIndex = btn_tag;
        ///modify btn's title color
        [self updateBtnItemsTitleColor];
        ///re move the flag view
        [self updateFlagViewFor:btn];
        ///notify the delegate
        if (_delegate && [_delegate respondsToSelector:@selector(subscriber:didSelectIndex:)]) {
            [_delegate subscriber:self didSelectIndex:_selectIndex];
        }
    }
}

- (void)focusIndex:(NSInteger)index {
    UIButton *dst_btn;
    for (UIButton *tmp in _btnSets) {
        if (index == tmp.tag) {
            dst_btn = tmp;
            break;
        }
    }
    if (index != _selectIndex) {
        _selectIndex = index;
        ///modify btn's title color
        [self updateBtnItemsTitleColor];
        ///re move the flag view
        [self updateFlagViewFor:dst_btn];
        ///notify the delegate
        if (_delegate && [_delegate respondsToSelector:@selector(subscriber:didSelectIndex:)] && !_outTrigger) {
            [_delegate subscriber:self didSelectIndex:_selectIndex];
        }
        _outTrigger = false;
    }
}

- (void)updateBtnItemsTitleColor {
    UIColor *color_n = [self btnTitleColor];
    UIColor *color_s = _style == NHNaviStyleBack?[UIColor whiteColor]:[UIColor redColor];
    @synchronized(_btnSets){
        for (UIButton *tmp in _btnSets) {
            [tmp setTitleColor:tmp.tag == _selectIndex?color_s:color_n forState:UIControlStateNormal];
        }
    }
}

- (void)updateFlagViewFor:(UIButton *)btn{
    if (btn) {
        __block CGSize selfSize = self.bounds.size;
        CGRect btn_rect = [btn frame];
        CGSize btn_size = btn_rect.size;
        CGRect flagBounds = _flagView.frame;
        flagBounds.size.width = btn_size.width+kExtradPadding;
        CGRect layerFrame = _lineLayer.frame;
        layerFrame.size.width = flagBounds.size.width;
        CGFloat offset_x = btn.frame.origin.x - kExtradPadding*0.5 - kFlagOffset;
        CGAffineTransform trans = CGAffineTransformMakeTranslation(offset_x, 0);
        CGPoint offsetPt;
        CGSize scrollSize = _displayScroll.bounds.size;
        if (btn_rect.origin.x >= selfSize.width-150 && btn_rect.origin.x < _displayScroll.contentSize.width-scrollSize.width) {
            offsetPt = CGPointMake(btn_rect.origin.x-200, 0);
        }else if (btn_rect.origin.x >= _displayScroll.contentSize.width-scrollSize.width){
            offsetPt = CGPointMake(_displayScroll.contentSize.width-scrollSize.width, 0);
        }else{
            offsetPt = CGPointZero;
        }
        [UIView animateWithDuration:kAnimationDuration animations:^{
            _lineLayer.frame = layerFrame;
            _flagView.frame = flagBounds;
            _flagView.transform = trans;
        } completion:^(BOOL finished) {
            [_displayScroll setContentOffset:offsetPt animated:true];
        }];
    }
}

- (UIColor *)mainBackgroundColor {
    return RGBColor(238.0, 238.0, 238.0);
}

- (UIColor *)btnTitleColor {
    return RGBColor(111.0, 111.0, 111.0);
}

- (UIView *)flagView {
    if (!_flagView) {
        CGRect infoRect;UIColor *bgColor;
        CGSize selfSize = self.bounds.size;
        _flagView = [[UIView alloc] initWithFrame:infoRect];
        _flagView.layer.cornerRadius = 5;
        if (_style == NHNaviStyleBack) {
            infoRect = CGRectMake(_maxWidth*0.5, (selfSize.height-kFlagHeight)*0.5, 50, kFlagHeight);
            bgColor = RGBColor(202.0, 51.0, 54.0);
        }else{
            infoRect = CGRectMake(_maxWidth*0.5, selfSize.height-kFlagOffset, 50, kFlagOffset*0.5);
            bgColor = [UIColor whiteColor];
            _lineLayer = [CALayer layer];
            [_lineLayer setBackgroundColor:[UIColor cyanColor].CGColor];
            [_lineLayer setFrame:CGRectMake(0, CGRectGetHeight(infoRect) - 4, CGRectGetWidth(infoRect)-2, 2)];
            [_flagView.layer insertSublayer:_lineLayer atIndex:0];
        }
        _flagView.frame = infoRect;
        _flagView.backgroundColor = bgColor;
        _flagView.layer.cornerRadius = 5;
    }
    return _flagView;
}

- (UIScrollView *)displayScroll{
    if (_displayScroll == nil) {
        CGSize selfSize = self.bounds.size;
        CGRect infoRect = CGRectMake(0, 0, selfSize.width-kEditArrowWidth, selfSize.height);
        _displayScroll = [[UIScrollView alloc] initWithFrame:infoRect];
        _displayScroll.backgroundColor = [self mainBackgroundColor];
        //_displayScroll.backgroundColor = [UIColor redColor];
        _displayScroll.showsHorizontalScrollIndicator = false;
        _displayScroll.showsVerticalScrollIndicator = false;
    }
    return _displayScroll;
}

- (void)arrowBtnEvent:(UIButton *)btn{
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectArrowForSubscriber:)]) {
        [_delegate didSelectArrowForSubscriber:self];
    }
    //[self updateArrowState:btn];
}

- (void)updateArrowState:(UIButton *)btn{
    _expadding = !_expadding;
    CGAffineTransform rotation = _expadding?CGAffineTransformMakeRotation(M_PI):CGAffineTransformIdentity;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        btn.imageView.transform = rotation;
    } completion:^(BOOL finished) {
        /// notify the delegate
    }];
}

- (NSArray *)existData{
    return [_dataSource exsitDataForSubscriber:self];
}

- (NSArray *)newData{
    return [_dataSource newDataForSubscriber:self];
}

#pragma mark -- UTIL --

-(CGSize)calculateSizeWithFont:(NSInteger)Font Text:(NSString *)Text{
    NSDictionary *attr = @{NSFontAttributeName : [UIFont systemFontOfSize:Font]};
    CGRect bounds = [Text boundingRectWithSize:CGSizeMake(MAXFLOAT, self.frame.size.height)
                                     options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin
                                  attributes:attr
                                     context:nil];
    return bounds.size;
}

@end
