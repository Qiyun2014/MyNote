//
//  YNSerialOpration.m
//  Demo
//
//  Created by qiyun on 16/4/6.
//  Copyright © 2016年 ProDrone. All rights reserved.
//

#import "YNSerialOperation.h"

@interface YNSerialOperation ()

@property (nonatomic,strong) NSOperationQueue *operationQueue;

@end

@implementation YNSerialOperation

static YNSerialOperation    *serialOpration = nil;

+ (instancetype)shareInstanceWithOperation{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        serialOpration = [[YNSerialOperation alloc] init];
        if (serialOpration) {
            
            serialOpration.operationQueue = [[NSOperationQueue alloc] init];
            
            [serialOpration.operationQueue setName:[[NSString alloc]
                                                    initWithUTF8String:object_getClassName(serialOpration.operationQueue)]];
        }
    });
    return serialOpration;
}


//adding
- (void)addOperation:(NSOperationQueue *)operationQueue{
    
    
}

//cancle
- (void)cancleOperation:(NSString *)operationName{
    
    
}

//suspended
- (void)suspendedOperation:(NSString *)operationName{
    
    
}


@end
