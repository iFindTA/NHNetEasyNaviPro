//
//  NHReuseCell.h
//  NHNetEasyNaviPro
//
//  Created by hu jiaju on 15/9/22.
//  Copyright © 2015年 hu jiaju. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NHReuseCell : UIView

- (id)initWithFrame:(CGRect)frame withIdentifier:(NSString *)identifier withChannel:(NSString *)channel;

- (void)viewWillApear;
- (void)viewWillDisappear;

- (NHReuseCell *)nh_mutableCopy;

@property (nonatomic, readonly) NSString *identifier;

@property (nonatomic, copy) NSString *channel;

@end
