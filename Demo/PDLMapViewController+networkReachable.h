//
//  PDLMapViewController+networkReachable.h
//  GFlight
//
//  Created by qiyun on 16/3/24.
//  Copyright © 2016年 GDU. All rights reserved.
//

#import "ViewController.h"
#import <UIKit/UIKit.h>



/**
 *  @discussion UIViewController：良好的设计，此处应该是一个基类，用于观测全局
 *  @brief 写入启动程序入口开始检测整个应用在runloop机制中网络的变化（更好）
 */

@interface ViewController(networkReachable)


- (void)reachableWithResponse:(void (^) (GDUNetworkConnectionStatus status))responseBlock;


@end
