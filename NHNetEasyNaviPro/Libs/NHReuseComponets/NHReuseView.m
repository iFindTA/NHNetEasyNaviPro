//
//  NHReuseView.m
//  NHNetEasyNaviPro
//
//  Created by hu jiaju on 15/9/22.
//  Copyright © 2015年 hu jiaju. All rights reserved.
//

static int NHReuseMaxCount       =     5;
static int NHReuseInvalidTag     =    -1;

#import "NHReuseView.h"

@interface NHReuseView ()<UIScrollViewDelegate>{
    
    NHReuseCell *pageCells[5];
}

@property (nonatomic, assign) BOOL swipeToRight,outTrigger;
@property (nonatomic, strong) UIScrollView *scrollView;
//@property (nonatomic, strong) NHReuseCell *onePgV,*twoPgv,*thrPgv,*forPgv,*fivPgv;
@property (nonatomic, assign) NSUInteger trackerIdx,pageCount,sizeCount;
@property (nonatomic, strong) NSMutableDictionary *identifierDict;
//@property (nonatomic, strong) NSMutableArray *inUsePages;

@end

@implementation NHReuseView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.identifierDict = [NSMutableDictionary dictionary];
        self.pageCount = 0;
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.scrollView.contentMode = UIViewContentModeCenter;
        self.scrollView.contentSize = CGSizeMake(NHReuseMaxCount*CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
        self.scrollView.delegate = self;
        self.scrollView.pagingEnabled = true;
        self.scrollView.showsHorizontalScrollIndicator = false;
        self.scrollView.scrollsToTop = false;
        [self addSubview:self.scrollView];
    }
    return self;
}

- (NSUInteger)pageCount{
    NSAssert(_dataSource != nil, @"datasource can not be nil!");
    NSUInteger counts = [_dataSource numberOfCountsInReuseView:self];
    NSAssert(counts > 0, @"review page number must more than one !");
    _sizeCount = MIN(counts, NHReuseMaxCount);
    self.scrollView.contentSize = CGSizeMake(_sizeCount*CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    return counts;
}

- (NHReuseCell *)setupPageCell:(NSUInteger)pageIdx {
    NSAssert(_dataSource != nil, @"datasource can not be nil!");
    NHReuseCell *cell = [_dataSource review:self pageViewAtIndex:pageIdx];
    return cell;
}

- (void)setReuseSelectIndex:(NSInteger)index {
    NSInteger currentPage = _trackerIdx + [self scrollViewInnerPage];
    if (index == currentPage) {
        return;
    }
    _outTrigger = true;
    if (index >= _trackerIdx && index < (_trackerIdx+_sizeCount)) {
        ///在窗口内
        NSInteger offset = index-_trackerIdx;
        [_scrollView setContentOffset:CGPointMake(offset*CGRectGetWidth(self.scrollView.bounds), 0) animated:true];
    }else{
        ///窗口外
        if (index > _trackerIdx) {
            ///在右边
            [self clearPointer];
            _trackerIdx = index-_sizeCount+1;
            CGPoint offset = CGPointMake((_sizeCount-1)*CGRectGetWidth(self.scrollView.bounds), 0);
            NHReuseCell *newPage = [self setupPageCell:index];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.scrollView addSubview:newPage];
            });
            pageCells[_sizeCount-1] = newPage;
            [self updateInuseCellFrame];
            [self.scrollView setContentOffset:offset animated:true];
            //[self.scrollView setContentOffset:offset];
        }else{
            ///在左边
            [self clearPointer];
            _trackerIdx = index;
            CGPoint offset = CGPointZero;
            NHReuseCell *newPage = [self setupPageCell:index];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.scrollView addSubview:newPage];
            });
            pageCells[0] = newPage;
            [self updateInuseCellFrame];
            [self.scrollView setContentOffset:offset animated:true];
            //[self.scrollView setContentOffset:offset];
        }
    }
}

- (NSInteger)scrollViewInnerPage{
    float contentOffset_x = self.scrollView.contentOffset.x;
    CGFloat width = CGRectGetWidth(self.scrollView.bounds);
    NSInteger page = (contentOffset_x + (0.5f * width)) / width;
    return page;
}

- (void)setDataSource:(id<NHReViewDataSource>)dataSource {
    _dataSource = dataSource;
    [self reloadData];
}

- (void)reloadData {
    NSAssert(_dataSource != nil, @"datasource can not be nil!");
    if ([_dataSource respondsToSelector:@selector(numberOfCountsInReuseView:)]) {
        NSUInteger counts  = [self pageCount];
        if (counts > 0) {
            _outTrigger = false;
            self.trackerIdx = 0;///window's index
            [_identifierDict removeAllObjects];
            [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            self.scrollView.contentOffset = CGPointZero;
            int count = [self pageSize];
            for (int i = 0; i < count; i++) {
                NHReuseCell *pageCell = [self setupPageCell:self.trackerIdx+i];
                [self.scrollView addSubview:pageCell];
                pageCells[i] = pageCell;
            }
            [self updateInuseCellFrame];
        }
    }
}

- (NSMutableArray *)obtainCacheWithIdentifier:(NSString *)identifier{
    NSMutableArray *pageCacheArr = [_identifierDict objectForKey:identifier];
    if (pageCacheArr == nil || [pageCacheArr count] <= 0) {
        pageCacheArr = [NSMutableArray array];
        [_identifierDict setObject:pageCacheArr forKey:identifier];
    }
    //NSInteger count = [pageCacheArr count];
    //NSLog(@"reuse queue counts:%zd",count);
    return pageCacheArr;
}

- (void)queueReusablePageWithIdentifier:(NHReuseCell *)page {
    if (page == nil) {
        return;
    }
    NSMutableArray *pageCacheArr = [self obtainCacheWithIdentifier:page.identifier];
    [pageCacheArr addObject:page];
    [page removeFromSuperview];
}

- (NHReuseCell *)dequeueReusablePageWithIdentifier:(NSString *)identifier {
    NSMutableArray *pageCacheArr = [self obtainCacheWithIdentifier:identifier];
    NHReuseCell *page = [pageCacheArr lastObject];
    NHReuseCell *dstCell = nil;
    if (page) {
        //NSLog(@"reuse old page");
        //dstCell = [page mutableCopy];
        dstCell = [page nh_mutableCopy];
        [pageCacheArr removeObject:page];
    }
    return dstCell;
}

- (void)setTrackerIdx:(NSUInteger)trackerIdx{
    _trackerIdx = trackerIdx;
}

#pragma mark -- ScrollView Delegate --

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (_outTrigger) {
        //return;
    }
    
    float contentOffset_x = scrollView.contentOffset.x;
    //NSLog(@"offset_x:%f",contentOffset_x);
    CGFloat width = CGRectGetWidth(scrollView.bounds);
    int page_idx = NHReuseInvalidTag;
    if (contentOffset_x == 0) {
        page_idx = 0;
    }
    if (contentOffset_x > 0 && contentOffset_x <= width){
        //马上显示第2页
        page_idx = 1;
    }else if (contentOffset_x > width && contentOffset_x <= width*2){
        //马上显示第3页
        page_idx = 2;
    }else if (contentOffset_x > width*2 && contentOffset_x <= width*3){
        //马上显示第4页
        page_idx = 3;
    }else if (contentOffset_x > width*3 && contentOffset_x <= width*4){
        //马上显示第5页
        page_idx = 4;
    }
    ///display the five page
    if (page_idx != NHReuseInvalidTag && page_idx < NHReuseMaxCount) {
        if (pageCells[page_idx] == nil) {
            NSLog(@"中间移动 idx:%zd",page_idx);
            NSInteger winIndex = self.trackerIdx+page_idx;
            NHReuseCell *newPage = [self setupPageCell:winIndex];
            //CGRect infoRect = CGRectMake(page_idx*CGRectGetWidth(self.scrollView.bounds), 0, CGRectGetWidth(self.scrollView.bounds), CGRectGetHeight(self.scrollView.bounds));
            //newPage.frame = infoRect;
            [self.scrollView addSubview:newPage];
            pageCells[page_idx] = newPage;
            [self updateInuseCellFrame];
        }
    }
    
    if (contentOffset_x < 0) {
        //是否向前翻页
        _swipeToRight = false;
        NSInteger winIndex = self.trackerIdx-1;
        if (winIndex >= 0) {
            NSLog(@"需要向左移动");
            /// dismiss notify
            if (_delegate && [_delegate respondsToSelector:@selector(review:willDismissIndex:)]) {
                [_delegate review:self willDismissIndex:self.trackerIdx];
            }
            [self updatePotinterAhead:true];
            ///首先移动tracker index
            self.trackerIdx--;
            
            NHReuseCell *newPage = [self setupPageCell:winIndex];
//            int size = [self pageSize];
//            newPage.channel = [NSString stringWithFormat:@"%zd",winIndex];
            [self.scrollView addSubview:newPage];
            pageCells[0] = newPage;
            [self updateInuseCellFrame];
            [self updateScrollViewContentOffset];
            
            if (_delegate && [_delegate respondsToSelector:@selector(review:didChangeToIndex:)]) {
                [_delegate review:self didChangeToIndex:winIndex];
            }
        }
    }
    
    if (contentOffset_x > width*4 && contentOffset_x <= width*5){
        //是否向后翻页
        _swipeToRight = true;
        NSInteger winIndex = self.trackerIdx+_sizeCount;
        if (winIndex < self.pageCount) {
            NSLog(@"需要向右移动");
            /// dismiss notify
            if (_delegate && [_delegate respondsToSelector:@selector(review:willDismissIndex:)]) {
                [_delegate review:self willDismissIndex:self.trackerIdx];
            }
            [self updatePotinterAhead:false];
            ///首先移动tracker index
            self.trackerIdx++;
            
            NHReuseCell *newPage = [self setupPageCell:winIndex];
            int size = [self pageSize];
//            newPage.channel = [NSString stringWithFormat:@"%zd",winIndex];
            [self.scrollView addSubview:newPage];
            pageCells[size-1] = newPage;
            [self updateInuseCellFrame];
            [self updateScrollViewContentOffset];
            
            if (_delegate && [_delegate respondsToSelector:@selector(review:didChangeToIndex:)]) {
                [_delegate review:self didChangeToIndex:winIndex];
            }
            
        }
    }
    
    
    //NSLog(@"page_idx:%d",page_idx);
    
}

- (int)pageSize{
    int count = sizeof(pageCells)/sizeof(pageCells[0]);
    return count;
}

- (void)clearPointer{
    int count = [self pageSize];
    for (int i = 0; i< count; i++) {
        [self queueReusablePageWithIdentifier:pageCells[i]];
        pageCells[i] = nil;
    }
}

- (void)updatePotinterAhead:(BOOL)ahead{
    
    int count = sizeof(pageCells)/sizeof(pageCells[0]);
    if (ahead) {
        [self queueReusablePageWithIdentifier:pageCells[count-1]];
        //NHReuseCell *firstPointer = pageCells[count-1];
        for (int i = count-1; i > 0; i--) {
            pageCells[i] = pageCells[i-1];
        }
        pageCells[0] = nil;
    }else{
        ///将第一页缓存
        [self queueReusablePageWithIdentifier:pageCells[0]];
        //NHReuseCell *firstPointer = pageCells[0];
        for (int i = 0; i< count-1; i++) {
            pageCells[i] = pageCells[i+1];
        }
        pageCells[count-1] = nil;
    }
}

- (void)updateInuseCellFrame {
    
    int count = sizeof(pageCells)/sizeof(pageCells[0]);
    for (int i = 0; i< count; i++) {
        CGRect infoRect = CGRectMake(i*CGRectGetWidth(self.scrollView.bounds), 0, CGRectGetWidth(self.scrollView.bounds), CGRectGetHeight(self.scrollView.bounds));
        if (pageCells[i] != nil) {
            pageCells[i].frame = infoRect;
            //NSLog(@"frame:%@--%@",NSStringFromCGRect(infoRect),pageCells[i].channel);
        }
    }
}

- (void)updateReuseCellFrameAhead:(BOOL)ahead {
    @synchronized(_scrollView) {
        CGFloat width = CGRectGetWidth(self.scrollView.bounds);
        NSArray *subviews = [_scrollView subviews];
        for (UIView *tmp in subviews) {
            if ([tmp isKindOfClass:[NHReuseCell class]]) {
                CGRect frame = tmp.frame;
                ahead?(frame.origin.x+=width):(frame.origin.x-=width);
            }
        }
        CGPoint offset = CGPointMake(ahead?1*width:4*width, 0);
        [self.scrollView setContentOffset:offset];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
}

- (void)updateScrollViewContentOffset{
    ///change offset
    [self.scrollView setContentOffset:CGPointMake(_swipeToRight?CGRectGetWidth(self.scrollView.bounds)*(_sizeCount-2):CGRectGetWidth(self.scrollView.bounds), 0)];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    float contentOffset_x = scrollView.contentOffset.x;
    CGFloat width = CGRectGetWidth(scrollView.bounds);
    NSInteger page = (contentOffset_x + (0.5f * width)) / width;
    NSLog(@"dst page:%zd",page);
    
    NSInteger winIndex = _trackerIdx+page;
    if (_delegate && [_delegate respondsToSelector:@selector(review:didChangeToIndex:)]) {
        [_delegate review:self didChangeToIndex:winIndex];
    }
    
    _outTrigger = false;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
