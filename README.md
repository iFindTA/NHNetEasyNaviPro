# NHNetEasyNaviPro
###仿照网易首页ScrollView的循环重用机制（for iOS）
最多创建5个页面节省内存！
![image](https://github.com/iFindTA/screenshots/blob/master/ios_navi_0.png)
![image](https://github.com/iFindTA/screenshots/blob/master/iOS_navi_1.png)
###Usage
###### Init Method
```
	NHNaviSubscriber *scriber = [[NHNaviSubscriber alloc] initWithFrame:infoRect forStyle:NHNaviStyleBack];
    scriber.dataSource = self;
    scriber.delegate = self;
    [self.view addSubview:scriber];
```
###### Delegate && DataSource
```
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
```