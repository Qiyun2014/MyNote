//
//  ViewController.h
//  Demo
//
//  Created by qiyun on 16/3/22.
//  Copyright © 2016年 ProDrone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import <GLKit/GLKit.h>
#import "PDLAlertView.h"

typedef NS_ENUM(NSInteger, GDUNetworkConnectionStatus) {
    
    GDUNetworkConnectionStatus_Unknown = 0,
    GDUNetworkConnectionStatus_WIFI,
    GDUNetworkConnectionStatus_WWAN,
    
};

typedef void (^reachability_action_block) (GDUNetworkConnectionStatus status);


@interface ViewController : UIViewController

{
    EAGLContext *context;
}

@property (nonatomic,strong) Reachability *networReachability;

@property (nonatomic,weak) reachability_action_block    action_block;


@end

