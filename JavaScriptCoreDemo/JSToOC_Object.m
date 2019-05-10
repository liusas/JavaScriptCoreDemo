//
//  JSToOC_Object.m
//  JavaScriptCoreDemo
//
//  Created by 刘峰 on 2019/5/10.
//  Copyright © 2019年 Liufeng. All rights reserved.
//

#import "JSToOC_Object.h"

@implementation JSToOC_Object

- (void)getSystemImage {
    NSLog(@"JS调用了打开系统相册， 这里走的是子线程，如果对UI操作需要回到主线程");
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(getSystemImage)]) {
            [self.delegate getSystemImage];
        }
    });
}

//连接字符串1和字符串2
- (NSString *)connetText1:(NSString *)str1 withText2:(NSString *)str2 {
    NSString *connectText = [NSString stringWithFormat:@"%@,我选择%@", str1, str2];
    return connectText;
}

@end
