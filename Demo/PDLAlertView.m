//
//  PDLAlertView.m
//  Demo
//
//  Created by qiyun on 16/3/30.
//  Copyright © 2016年 ProDrone. All rights reserved.
//

#import "PDLAlertView.h"
#import <objc/runtime.h>


@interface PDLAlertView ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancleButton;
@property (weak, nonatomic) IBOutlet UIButton *okayButton;

- (IBAction)cancleAction:(id)sender;
- (IBAction)okayAction:(id)sender;

@property (copy, nonatomic) PDLAlertView_okay_block okayBlock;
@property (copy, nonatomic) PDLAlertView_cancle_block cancleBlock;

@end


@implementation PDLAlertView


- (IBAction)cancleAction:(id)sender {

    if (self.cancleBlock) self.cancleBlock();
}

- (IBAction)okayAction:(id)sender {

    if (self.okayBlock) self.okayBlock();
}

- (id)initWithFrame:(CGRect)frame buttonClickResponse:(void (^) (void))okay cancleResponse:(void (^) (void))cancle{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self = [[[NSBundle mainBundle] loadNibNamed:[NSString stringWithUTF8String:object_getClassName(self)] owner:self options:nil] firstObject];

        CGRect rect;
        rect.origin.x = ([UIScreen mainScreen].bounds.size.width - 315)/2;
        rect.origin.y = ([UIScreen mainScreen].bounds.size.height - 200)/2;
        rect.size = CGSizeMake(315, 200);
        self.frame = rect;
        self.okayBlock = okay;
        self.cancleBlock = cancle;
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"alertview_background@2x.png"]];
    }
    return self;
}


+ (void)showAlertViewWithTitle:(NSString *)title
                       message:(NSString *)message
                  responseOkay:(PDLAlertView_okay_block)okay
                responseCancle:(PDLAlertView_cancle_block)cancle{

    UIWindow *window = objc_getAssociatedObject(self, @"window");
    if (!window) 
        window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    window.windowLevel = UIWindowLevelAlert + 1;
    window.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.88];
    [window makeKeyAndVisible];

    PDLAlertView *alertView = [[PDLAlertView alloc] initWithFrame:CGRectMake(20, 200, 315, 200)
                                              buttonClickResponse:^{

                                                  if (okay) okay();
                                                  [PDLAlertView hiddenAlertView];
                                                  
                                              } cancleResponse:^{

                                                  if (cancle) cancle();
                                                  [PDLAlertView hiddenAlertView];
                                              }];
    alertView.title = @"这里是标题";
    alertView.message = @"这里是富文本，哈哈哈哈哈哈,回答客户端打开活动案开会到会大大搜狐帝豪好的";
    [window addSubview:alertView];

    objc_setAssociatedObject(self, @"window", window, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)hiddenAlertView{

    UIWindow *window = objc_getAssociatedObject(self, @"window");
    if (window) {

        window.userInteractionEnabled = YES;
        window.hidden = YES;
        [window resignKeyWindow];
    }
}

- (void)setTitle:(NSString *)title{
    
    if (!title)  [self.titleLabel removeFromSuperview];
    else [self.titleLabel setText:title];
}

- (void)setMessage:(NSString *)message{
    
    if (!message) [self.messageLabel removeFromSuperview];
    else [self.messageLabel setText:message];
}

- (void)setAgreeButtonTitle:(NSString *)agreeButtonTitle{
    
    [self.okayButton setTitle:agreeButtonTitle forState:UIControlStateNormal];
}

- (void)setDisagreeButtonTitle:(NSString *)disagreeButtonTitle{
    
    if (!disagreeButtonTitle) [self.cancleButton removeFromSuperview];
    else{
        [self.cancleButton setTitle:disagreeButtonTitle forState:UIControlStateNormal];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
