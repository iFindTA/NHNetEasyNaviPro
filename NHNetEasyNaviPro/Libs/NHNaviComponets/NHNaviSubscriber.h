//
//  NHNaviSubscriber.h
//  NHNetEasyNaviPro
//
//  Created by hu jiaju on 15/9/14.
//  Copyright (c) 2015年 hu jiaju. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    NHNaviStyleBack = 1 << 0,
    NHNaviStyleUnderline = 1 << 1
}NHNaviStyle;

@protocol NHNaviSubscriberDataSource;
@protocol NHNaviSubscriberDelegate;

@interface NHNaviSubscriber : UIView

@property (nonatomic, assign) id<NHNaviSubscriberDelegate> delegate;
@property (nonatomic, assign) id<NHNaviSubscriberDataSource> dataSource;

@property (nonatomic, strong, readonly, getter=getExistData) NSArray *exsitData;

/**
 *	@brief	init method
 *
 *	@param 	frame 	instance's frame
 *	@param 	style 	the navi style
 *
 *	@return	the instance
 */
- (id)initWithFrame:(CGRect)frame forStyle:(NHNaviStyle)style;

/**
 *	@brief	<#Description#>
 *
 *	@param 	index 	<#index description#>
 */
- (void)setSubscriberSelectIndex:(NSInteger)index;

/**
 *	@brief	<#Description#>
 *
 *	@param 	rotate 	<#rotate description#>
 */
- (void)enableArrowRotation:(BOOL)rotate;


/**
 *	@brief	must call this function after init method and set the datasource
 */
- (void)reloadData;


@end

@protocol NHNaviSubscriberDataSource <NSObject>

@required
- (NSArray *)exsitDataForSubscriber:(NHNaviSubscriber *)scriber;
- (NSArray *)newDataForSubscriber:(NHNaviSubscriber *)scriber;
- (BOOL)subscriber:(NHNaviSubscriber *)scriber canEditForTitle:(NSString *)title;

@end

@protocol NHNaviSubscriberDelegate <NSObject>

- (void)willEditForSubscriber:(NHNaviSubscriber *)scriber;
- (void)subscriber:(NHNaviSubscriber *)scriber didInsert:(NSArray *)data;
- (void)subscriber:(NHNaviSubscriber *)scriber didDelete:(NSArray *)data;
- (void)subscriber:(NHNaviSubscriber *)scriber didSelectIndex:(NSInteger)index;
- (void)didSelectArrowForSubscriber:(NHNaviSubscriber *)scriber;

@end
