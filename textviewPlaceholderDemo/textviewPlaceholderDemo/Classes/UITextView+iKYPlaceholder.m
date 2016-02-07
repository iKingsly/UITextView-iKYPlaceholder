//
//  UITextView+iKYPlaceholder.m
//  textviewPlaceholderDemo
//
//  Created by 郑钦洪 on 16/2/6.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import "UITextView+iKYPlaceholder.h"
#import <objc/runtime.h>
/// 默认的间距
static CGFloat const iKY_Default_Padding = 8;
@implementation UITextView (iKYPlaceholder)
@dynamic  iky_placeholder,iky_placeholderColor,iky_placeholderTopPadding,iky_placeholderLeftPadding;
- (CGFloat )iky_placeholderLeftPadding{
    id placeholderLeftPadding = objc_getAssociatedObject(self, _cmd);
    return placeholderLeftPadding ? [placeholderLeftPadding doubleValue] : iKY_Default_Padding;
}

- (CGFloat)iky_placeholderTopPadding{
    id placeholderTopPadding = objc_getAssociatedObject(self, _cmd);
    return placeholderTopPadding ? [placeholderTopPadding doubleValue] : iKY_Default_Padding;
}

- (void)setIky_placeholderLeftPadding:(CGFloat)iky_placeholderLeftPadding{
    objc_setAssociatedObject(self, @selector(iky_placeholderLeftPadding), @(iky_placeholderLeftPadding), OBJC_ASSOCIATION_ASSIGN);
}

- (void)setIky_placeholderTopPadding:(CGFloat)iky_placeholderTopPadding{
    objc_setAssociatedObject(self, @selector(iky_placeholderTopPadding), @(iky_placeholderTopPadding), OBJC_ASSOCIATION_ASSIGN);
}

- (UIColor *)iky_placeholderColor{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setIky_placeholderColor:(UIColor *)iky_placeholderColor{
    if ([self iky_placeholderLabel]) {
        [self iky_placeholderLabel].textColor = iky_placeholderColor;
    }
    objc_setAssociatedObject(self, @selector(iky_placeholderColor), iky_placeholderColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)iky_placeholder{
    return [self iky_placeholderLabel].text;
}

- (void)setIky_placeholder:(NSString *)iky_placeholder{
    if (self.delegate) { // 设置了代理对象
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            Class delegateClass = [self.delegate class];
            Class swizzleClass = [self class];
            
            SEL originalSelector = @selector(textViewDidChange:);
            SEL swizzleSelector = @selector(iky_textViewDidChange:);
            
            Method originalMethod = class_getInstanceMethod(delegateClass, originalSelector);
            Method swizzleMethod = class_getInstanceMethod(swizzleClass, swizzleSelector);
            
            if (class_addMethod(delegateClass, swizzleSelector, method_getImplementation(swizzleMethod), method_getTypeEncoding(swizzleMethod))) {
                BOOL isAddMethod = class_addMethod(delegateClass, originalSelector, method_getImplementation(swizzleMethod), method_getTypeEncoding(swizzleMethod));
                if (isAddMethod) { // 添加了原来没有的方法 ， 替换添加的方法
                    Method newSwizzleMethod = class_getInstanceMethod(swizzleClass, originalSelector);
                    class_replaceMethod(delegateClass, originalSelector, method_getImplementation(newSwizzleMethod), method_getTypeEncoding(newSwizzleMethod));
                } else{ // 原来已经存在这个方法,交换实现方法
                    Method newSwizzleMethod = class_getInstanceMethod(delegateClass, swizzleSelector);
                    method_exchangeImplementations(originalMethod, newSwizzleMethod);
                }
            }
            
        });
    }else{
        self.delegate = self;
    }

    UILabel *placeholderLabel = [self iky_placeholderLabel];
    if (!placeholderLabel) {
        placeholderLabel = [UILabel new];
        placeholderLabel.textColor = self.iky_placeholderColor ?: [UIColor lightGrayColor];
        placeholderLabel.font = self.font;
        placeholderLabel.frame = CGRectMake(self.iky_placeholderLeftPadding, self.iky_placeholderTopPadding, 10, 10);
        [self addSubview:placeholderLabel];
        [self setIky_placeholderLabel:placeholderLabel];
    }
    placeholderLabel.text = iky_placeholder;
    [placeholderLabel sizeToFit];
}
#pragma mark - 私有方法
- (UILabel *)iky_placeholderLabel{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setIky_placeholderLabel:(UILabel *)iky_placeholderLabel{
    objc_setAssociatedObject(self, @selector(iky_placeholderLabel), iky_placeholderLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - 输入文字取消占位
- (void)iky_textViewDidChange:(UITextView *)textView{
    [self iky_textViewDidChange:textView];
    [self iky_placeholderLabel].hidden = (textView.text.length > 0);
}

- (void)textViewDidChange:(UITextView *)textView{ // 当输入文字长度大于0时，隐藏占位文字
    [self iky_placeholderLabel].hidden = (textView.text.length > 0);
}
@end
