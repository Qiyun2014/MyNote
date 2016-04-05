//
//  ViewController.m
//  Demo
//
//  Created by qiyun on 16/3/22.
//  Copyright © 2016年 ProDrone. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "PDLMapViewController+networkReachable.h"
#import <OpenGLES/EAGL.h>
#import <GLKit/GLKit.h>
#import <objc/runtime.h>

@interface ViewController ()<CLLocationManagerDelegate,GLKViewDelegate>
{
    CLLocationManager   *locationManager;
    CLLocation *currentLocation;
    UIView  *_convertionsDocument;
    
    GLKView *gl_view;
}
@end

@implementation ViewController

EAGLContext* CreateBestEAGLContext()
{
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (context == nil) {
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    }
    return context;
}


- (void)viewWillLayoutSubviews{
    
    [super viewWillLayoutSubviews];
    
    _convertionsDocument.frame = CGRectInset(self.view.frame, 30, 50);
}

- (NSArray *)allPropertyNamesWithObject:(NSObject *)object
{
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([object class], &count);
    
    NSMutableArray *rv = [NSMutableArray array];
    
    unsigned i;
    for (i = 0; i < count; i++)
    {
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        [rv addObject:name];
    }
    
    free(properties);
    
    return rv;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    /*
    context = CreateBestEAGLContext();
    
    GLKView *view = (GLKView *)self.view;
    [view setContext:context];
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [EAGLContext setCurrentContext:context];
    glEnable(GL_DEPTH_TEST);
    glClearColor(0.1, 0.2, 0.3, 1);
    
    */

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        [PDLAlertView showAlertViewWithTitle:nil message:nil
                                responseOkay:^{

                                    NSLog(@"ok");
        } responseCancle:^{

            NSLog(@"cancle");
        }];
    });

    return;
    [self test1];
    [self test2];
}


-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);  //清除surface内容，恢复至初始状态。
}


static dispatch_source_t gf_source(NSTimeInterval eventCount, NSTimeInterval walltime, void (^realTimeEvent) (void), void (^timeFinished) (void)){
    
    __block int timeout = eventCount;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),walltime * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout <= 0){
            
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (realTimeEvent) realTimeEvent();
            });
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (timeFinished) timeFinished();
            });
            timeout--;
        }
    });
    dispatch_resume(_timer);
    return _timer;
}

- (void)test1{
    
    //得到第一个UIView
    _convertionsDocument = [[[NSBundle mainBundle] loadNibNamed:@"GFLConventionsDocument" owner:self options:nil] firstObject];
    [self.view addSubview:_convertionsDocument];
    
    if (/* DISABLES CODE */ (3) != (2 | 3)) NSLog(@"正确");
    
    if (/* DISABLES CODE */ (3) != 2 || 3 != 3) NSLog(@"正确..");
    
    
    [self reachableWithResponse:^(GDUNetworkConnectionStatus status) {
        
        NSLog(@"status = %ld",(long)status);
    }];
    
    gf_source(1000, 1, ^{
        
        NSLog(@"111");
        
    }, ^{
        NSLog(@"...");
    });
        
    currentLocation = [self getLocation];
    NSLog(@"latitude = %f",currentLocation.coordinate.latitude);
    NSLog(@"longitude = %f",currentLocation.coordinate.longitude);
    
    CLGeocoder *reverseGeocoder = [[CLGeocoder alloc] init];
    
    [reverseGeocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        
        NSLog(@"reverseGeocodeLocation:completionHandler: Completion Handler called!");
        
        if (error){
            NSLog(@"Geocode failed with error: %@", [error description]);
            return;
        }
        
        // NSLog(@"Received placemarks: %@", placemarks);
        
        CLPlacemark *myPlacemark = [placemarks firstObject];
        NSString *countryCode = myPlacemark.ISOcountryCode;
        NSString *countryName = myPlacemark.country;
        NSLog(@"My country code: %@ and countryName: %@", countryCode, countryName);
        
    }];
}
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


- (void)test2{
    
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
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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


- (UIImage *)imageFromString:(NSString *)string attributes:(NSDictionary *)attributes size:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [string drawInRect:CGRectMake(0, 0, size.width, size.height) withAttributes:attributes];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

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


//动态制作图钉上方UIImageView,不包含站点图片
+(UIImage *)getHeadImageWithText:(NSString *)text isLocal:(BOOL)local{
    NSString *headName;
    CGFloat imageWidth;
    UIColor *color;
    if(local){
        headName = @"map_pin_head_current";
        color = [UIColor whiteColor];
    }else{
        headName = @"map_pin_head";
        color = [UIColor blackColor];
    }
    if([UIScreen mainScreen].scale >= 3.0)
        imageWidth = 60;
    else
        imageWidth = 42;
    UIImage *head = [UIImage imageNamed:headName];
    UIFont *font = [UIFont boldSystemFontOfSize:20];
    CGSize fontSize = [text sizeWithAttributes:@{NSFontAttributeName : font}];
    CGSize imageSize = CGSizeMake(fontSize.width + imageWidth + 10, imageWidth);
    UIImage *headImage/* = [KLUtil imageWithImage:head scaledToSize:imageSize]*/;
    
    //开始混合绘图
    UIGraphicsBeginImageContext(imageSize);
    [headImage drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
    
    NSMutableAttributedString* attString = [[NSMutableAttributedString alloc] initWithString:text];
    NSRange range = NSMakeRange(0, [attString length]);
    [attString addAttribute:NSFontAttributeName value:font range:range];
    [attString addAttribute:NSForegroundColorAttributeName value:color range:range];
    [attString drawInRect:CGRectMake(imageWidth, imageWidth/2 -fontSize.height/2, fontSize.width, fontSize.height)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

//加入站点图片
+(UIImage *)getFullImageOfHead:(UIImage*)zoneHeadImage byOrigialImage:(UIImage *)image{
    CGFloat imageWidth;
    if([UIScreen mainScreen].scale >= 3.0)
        imageWidth = 60;
    else
        imageWidth = 42;
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    [zoneHeadImage drawInRect:CGRectMake(5, 5, imageWidth - 10, imageWidth - 10)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

//加入底图
+(UIImage *)getFullImageOfMappin:(UIImage *)headerImage andFootImage:(UIImage *)footImage{
    UIGraphicsBeginImageContext(footImage.size);
    [footImage drawInRect:CGRectMake(0,0,footImage.size.width,footImage.size.height)];
    CGFloat offsetX = (footImage.size.width - headerImage.size.width)/2;
    [headerImage drawInRect:CGRectMake(offsetX, footImage.size.height/3, headerImage.size.width, headerImage.size.height)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
