//
//  UITextView+iKYPlaceholder.h
//  textviewPlaceholderDemo
//
//  Created by 郑钦洪 on 16/2/6.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextView (iKYPlaceholder)<UITextViewDelegate>
/** 占位文字左间距 */
@property (nonatomic,assign) CGFloat iky_placeholderLeftPadding;
/** 占位文字上间距 */
@property (nonatomic,assign) CGFloat iky_placeholderTopPadding;
/** 占位文字颜色 */
@property (nonatomic,strong) IBInspectable UIColor *iky_placeholderColor;
/** 占位文字 */
@property (nonatomic,strong) IBInspectable NSString *iky_placeholder;
@end
