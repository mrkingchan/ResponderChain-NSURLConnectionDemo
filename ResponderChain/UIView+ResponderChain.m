//
//  UIView+ResponderChain.m
//  ResponderChain
//
//  Created by Chan on 2017/11/16.
//  Copyright © 2017年 Chan. All rights reserved.
//

#import "UIView+ResponderChain.h"
#import <objc/runtime.h>

@implementation UIView (ResponderChain)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL beganOriginalSel = @selector(touchesBegan:withEvent:);
        SEL beganNewSel = @selector(customtouchesBegan:withEvent:);
        Method originalMethod = class_getInstanceMethod([self class], beganOriginalSel);
        Method newMethod =  class_getInstanceMethod([self class], beganNewSel);
        method_exchangeImplementations(originalMethod, newMethod);
    });
}

- (void)customtouchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"%@ -- %s",[self class],__FUNCTION__);
}

@end
