//
//  PDLMapViewController+networkReachable.m
//  GFlight
//
//  Created by qiyun on 16/3/24.
//  Copyright © 2016年 GDU. All rights reserved.
//

#import "PDLMapViewController+networkReachable.h"

@interface ViewController ()<UIAlertViewDelegate>


@end

@implementation ViewController(networkReachable)

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

@end
