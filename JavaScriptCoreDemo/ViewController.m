//
//  ViewController.m
//  UIWebViewJSDemo
//
//  Created by 刘峰 on 2019/5/8.
//  Copyright © 2019年 Liufeng. All rights reserved.
//

#import "ViewController.h"
#import <objc/Message.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "JSToOC_Object.h"

#define IPHONEXSeries           ([UIScreen mainScreen].bounds.size.height >= 810)
// 状态栏高度
#define STATUS_BAR_HEIGHT       (IPHONEXSeries ? 44.f : 20.f)
// 导航栏高度
#define NAVIGATION_BAR_HEIGHT   (IPHONEXSeries ? 88.f : 64.f)
// tabBar高度
#define TAB_BAR_HEIGHT          (IPHONEXSeries ? (49.f+34.f) : 49.f)
// home indicator
#define HOME_INDICATOR_HEIGHT   (IPHONEXSeries ? 34.f : 0.f)

@interface ViewController () <UIWebViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate, JSToOC_Protocol>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) JSContext *jsContext;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-HOME_INDICATOR_HEIGHT)];
    self.webView.delegate = self;
    self.webView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.webView];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"UIWebView.html" withExtension:nil];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [self.webView loadRequest:request];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"webview开始加载");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.title = title;
    NSLog(@"webView加载完成");
    
    //拦截JS的回调
    JSContext *jsContext = self.jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    //JS调用OC方法一，value、action、token为js传递过来的三个参数，
    //注意：这里面是子线程
    jsContext[@"loadUrl"] = ^(JSValue *value, NSString *action, NSString *token) {
        NSLog(@"value = %@", [JSValue valueWithObject:value inContext:[JSContext currentContext]]);
        NSLog(@"action = %@", action);
        NSLog(@"token = %@", token);
    
        dispatch_async(dispatch_get_main_queue(), ^{
            SEL sel = NSSelectorFromString([NSString stringWithFormat:@"%@:", action]);
            objc_msgSend(self, sel, token);
        });
    };
    
    //JS调用OC方法二，使用JSExport协议
    JSToOC_Object *jsToOC_Object = [JSToOC_Object new];
    jsToOC_Object.delegate = self;
    //把OC的JSToOC_Object对象传递给JS，供JS调用OC方法
    jsContext[@"jsToOC_Object"] = jsToOC_Object;
    NSLog(@"%@", [jsToOC_Object connetText1:@"我OC对象" withText2:@"调用方法试试好不好用"]);
    
    //异常收集
    jsContext.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        NSLog(@"exceptionHandler = %@", exception);
    };
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"webview加载失败:%@",error);
}

#pragma mark - Private
//第一个按钮点击事件
- (void)firstClick:(NSString *)str {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:str preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:confirm];
    [self presentViewController:alertController animated:YES completion:nil];
}

//第二个按钮点击事件
- (void)secondClick:(NSString *)str {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:str preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:confirm];
    [self presentViewController:alertController animated:YES completion:nil];
}

//第三个按钮点击事件
- (void)thirdClick:(NSString *)str {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:str preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:confirm];
    [self presentViewController:alertController animated:YES completion:nil];
}

//第五个按钮点击事件，调用OC执行JS来调用JS的弹窗
- (void)callOCToCallJSClick:(NSString *)str {
    //OC调用JS方法一, webview的stringByEvaluatingJavaScriptFromString
//    [self.webView stringByEvaluatingJavaScriptFromString:@"ocToJS('OC调用JS连接两个字符串', '哈哈啊哈')"];
    //OC调用JS方法二,JSContext的callWithArguments
    NSString *str1 = @"OC调用JS连接两个字符串";
    NSString *str2 = @"试试好不好用";
    [self.jsContext[@"ocToJS"] callWithArguments:@[str1, str2]];
}

- (void)openSystemPhotoLibrary {
    if (!self.imagePicker) {
        self.imagePicker = [[UIImagePickerController alloc] init];
    }
    self.imagePicker.delegate = self;
    self.imagePicker.allowsEditing = YES;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

#pragma mark - JSToOC_Protocol
//打开系统相册获取图片
- (void)getSystemImage {
    [self openSystemPhotoLibrary];
}

#pragma mark -- UIImagePickerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSLog(@"info---%@",info);
    UIImage *resultImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    NSData *imgData = UIImageJPEGRepresentation(resultImage, 0.01);
    NSString *encodedImageStr = [imgData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    [self dismissViewControllerAnimated:YES completion:nil];
    NSString *imageString = [self clearImageString:encodedImageStr];
    
    NSString *jsFunctStr = [NSString stringWithFormat:@"showImageOnDiv('%@')",imageString];
    //OC调用JS
    [self.webView stringByEvaluatingJavaScriptFromString:jsFunctStr];
}

//清除base64串里面的东西
- (NSString *)clearImageString:(NSString *)str {
    NSString *temp = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return temp;
}

@end
