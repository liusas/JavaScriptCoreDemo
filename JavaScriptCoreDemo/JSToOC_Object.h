//
//  JSToOC_Object.h
//  JavaScriptCoreDemo
//
//  Created by 刘峰 on 2019/5/10.
//  Copyright © 2019年 Liufeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JSToOC_Protocol <JSExport, NSObject>
//打开系统相册获取图片
- (void)getSystemImage;
//连接两个字符串
JSExportAs(getConnectText,
           - (NSString *)connetText1:(NSString *)str1 withText2:(NSString *)str2);

@end

@interface JSToOC_Object : NSObject <JSToOC_Protocol>

@property (nonatomic, weak) id<JSToOC_Protocol> delegate;

@end

NS_ASSUME_NONNULL_END
