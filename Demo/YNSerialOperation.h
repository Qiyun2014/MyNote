//
//  YNSerialOpration.h
//  Demo
//
//  Created by qiyun on 16/4/6.
//  Copyright © 2016年 ProDrone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YNSerialOperation : NSObject

+ (instancetype)shareInstanceWithOperation;


//adding
- (void)addOperation:(NSOperationQueue *)operationQueue;

//cancle
- (void)cancleOperation:(NSString *)operationName;

//suspended
- (void)suspendedOperation:(NSString *)operationName;


@end
