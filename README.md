# 一个简单的demo，用于一些例子，及笔记记录


##OpenGLES2.0

>创建一个上下文对象，EAGLContext
```
EAGLContext* CreateBestEAGLContext()
{
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (context == nil) {
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    }
    return context;
}
```
>生成EAGLRenderingAPI,并判断当前API是否支持2.0

**Example:**

```
EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
        _eaglCtx = [[EAGLContext alloc] initWithAPI:api];
        if (![EAGLContext setCurrentContext:_eaglCtx]) {
            NSLog(@"Failed to set current OpenGL context");
            exit(1);
        }

//创建渲染缓冲内容，并进行颜色清除和显示
glGenRenderbuffers(1, &_colorRenderBuffer);
glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
[_eaglCtx renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
        
GLuint framebuffer;
glGenFramebuffers(1, &framebuffer);
glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                           GL_RENDERBUFFER, _colorRenderBuffer);
        
glClearColor(69/255.0, 69/255.0, 69/255.0, 1.0);
glClear(GL_COLOR_BUFFER_BIT);
[_eaglCtx presentRenderbuffer:GL_RENDERBUFFER];
```

##CLLocationManager

```
-(CLLocation *)getLocation{
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    [locationManager requestAlwaysAuthorization];//添加这句
    [locationManager startUpdatingLocation];
    CLLocation *location = [locationManager location];
    [locationManager stopUpdatingLocation];
    return location;
}

```


##picture compose

```
//get image
- (UIImage *)imageFromString:(NSString *)string attributes:(NSDictionary *)attributes size:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [string drawInRect:CGRectMake(0, 0, size.width, size.height) withAttributes:attributes];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
    
//compose    
- (id)imageComposeWithBackGroundImage:(NSString *)backgroundImage otherImage:(UIImage *)otherImage{
    UIImage *bgImage = [UIImage imageNamed:backgroundImage];
    
    UIGraphicsBeginImageContextWithOptions(bgImage.size, NO, 0.0);
    [bgImage drawInRect:CGRectMake(0, 0, bgImage.size.width, bgImage.size.height)];
    
    CGFloat scale = 0.3;
    CGFloat margin = 5;
    CGFloat waterW = otherImage.size.width * scale;
    CGFloat waterH = otherImage.size.height * scale;
    CGFloat waterX = bgImage.size.width - waterW - margin;
    CGFloat waterY = bgImage.size.height - waterH - margin;
    
    [otherImage drawInRect:CGRectMake(waterX, waterY, waterW, waterH)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
```


##change the UIAlertController background Color 

```
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"网络模式设置" message:@"您确定关闭WIFI模式吗？ 在非WIFI的情况下也会进行图片网络上传下载，给您带来的流量费用将由您自己承担！" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *button = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            
        }];
        [alert addAction:button];
        
        UIAlertAction *button2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            
        }];
        [alert addAction:button2];
        
        NSLog(@"*******  %@",[self allPropertyNamesWithObject:alert]);
        alert.view.tintColor = UIColorFromRGB(0xef6f22);
        NSLog(@"%@",alert.textFields);

        [alert.textFields.firstObject setTextColor:UIColorFromRGB(0xffffff)];
        
        if ([UIDevice currentDevice].systemVersion.floatValue >= 9.0) {
            
            [[UIView appearanceWhenContainedInInstancesOfClasses:@[[alert class]]] setBackgroundColor:[UIColor lightGrayColor]];
        }else
            [[UIView appearanceWhenContainedIn:[UIAlertController class], nil] setBackgroundColor:[UIColor blackColor]];
        
        
        alert.view.layer.cornerRadius = 6;
        alert.view.clipsToBounds = YES;
        
        [self presentViewController:alert animated:YES completion:nil];
    });
```

##use Reachability
```
- (void)reachableWithResponse:(void (^) (GDUNetworkConnectionStatus status))responseBlock{
    
    self.action_block = responseBlock;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    self.networReachability = [Reachability reachabilityForInternetConnection];
    [self.networReachability startNotifier];
    [self updateInterfaceWithReachability:self.networReachability];
}


- (void)reachabilityChanged:(NSNotification* )note
{
    Reachability* curReach = [note object];
    
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    
    [self updateInterfaceWithReachability:curReach];
}


- (void)updateInterfaceWithReachability:(Reachability *) reachability
{
    if (reachability == self.networReachability)
    {
        NetworkStatus netStatus = [reachability currentReachabilityStatus];
        BOOL connectionRequired = [reachability connectionRequired];

        switch (netStatus)
        {
            case NotReachable:        {
                NSLog(@"%@",NSLocalizedString(@"Access Not Available", @"Text field text for access is not available"));
                /*
                 Minor interface detail- connectionRequired may return YES even when the host is unreachable. We cover that up here...
                 */
                connectionRequired = NO;
                break;
            }
                
            case ReachableViaWWAN:        {
                NSLog(@"%@",NSLocalizedString(@"Reachable WWAN", @""));

                break;
            }
            case ReachableViaWiFi:        {
                NSLog(@"%@",NSLocalizedString(@"Reachable WiFi", @""));
                break;
            }
        }
        
        if (self.action_block) self.action_block((GDUNetworkConnectionStatus)netStatus);
    }
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}
```

