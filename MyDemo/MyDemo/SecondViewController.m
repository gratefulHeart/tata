//
//  SecondViewController.m
//  HttpSever
//
//  Created by gfy on 16/1/18.
//  Copyright © 2016年 gfy. All rights reserved.
//

#import "SecondViewController.h"
#include "avformat.h"
#include "avcodec.h"
#import "KxMovieViewController.h"
@interface SecondViewController ()<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *myWebView;
@end

@implementation SecondViewController

-(void)createRightBar
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"播放不了点我" forState:UIControlStateNormal];
    [button setFrame:CGRectMake(0, 0, 200, 44)];
    [button addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = item;
    
    
}

-(void)btnClick
{
    UIViewController *vc;
    NSString *urlString = [self.dict objectForKey:@"url"];
    vc = [KxMovieViewController movieViewControllerWithContentPath:urlString parameters:nil];
    [self presentViewController:vc animated:YES completion:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
//    [self createRightBar];
    
    
    NSLog(@"self.dict = = = =%@",self.dict);
    
    NSString *urlString = [self.dict objectForKey:@"url"];
    NSURL *targetURL =[NSURL fileURLWithPath:urlString];
    NSURLRequest*request =[NSURLRequest requestWithURL:targetURL];
    self.myWebView.delegate = self;
    
    [self.myWebView loadRequest:request];
}
-(void)webViewDidStartLoad:(UIWebView *)webView
{
}
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"错误原因:%@",[error localizedDescription]);

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
