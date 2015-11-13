//
//  NHReuseView.h
//  NHNetEasyNaviPro
//
//  Created by hu jiaju on 15/9/22.
//  Copyright © 2015年 hu jiaju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NHReuseCell.h"

@protocol NHReViewDelegate;
@protocol NHReViewDataSource;
@interface NHReuseView : UIView

@property (nonatomic, assign) id<NHReViewDataSource> dataSource;

@property (nonatomic, assign) id<NHReViewDelegate> delegate;

- (NHReuseCell *)dequeueReusablePageWithIdentifier:(NSString *)identifier;

- (void)setReuseSelectIndex:(NSInteger)index;

- (void)reloadData;

@end

@protocol NHReViewDataSource <NSObject>
@required
- (NSUInteger)numberOfCountsInReuseView:(NHReuseView *)view;
- (NHReuseCell *)review:(NHReuseView *)view pageViewAtIndex:(NSUInteger)index;

@end

@protocol NHReViewDelegate <NSObject>
@optional
- (void)review:(NHReuseView *)view willDismissIndex:(NSUInteger)index;
- (void)review:(NHReuseView *)view didChangeToIndex:(NSUInteger)index;

@end