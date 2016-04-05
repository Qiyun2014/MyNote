//
//  PDLAlertView.h
//  Demo
//
//  Created by qiyun on 16/3/30.
//  Copyright © 2016年 ProDrone. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^PDLAlertView_okay_block) (void);
typedef void (^PDLAlertView_cancle_block) (void);

@interface PDLAlertView : UIView

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *cancleButtonTitle;
@property (nonatomic, copy) NSString *okayButtonTitle;


- (id)initWithFrame:(CGRect)frame buttonClickResponse:(void (^) (void))okay cancleResponse:(void (^) (void))cancle;


+ (void)showAlertViewWithTitle:(NSString *)title
                       message:(NSString *)message
                  responseOkay:(PDLAlertView_okay_block)okay
                responseCancle:(PDLAlertView_cancle_block)cancle;

+ (void)hiddenAlertView;

@end
