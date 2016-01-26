//
//  ViewController.m
//  MyDemo
//
//  Created by gfy on 16/1/20.
//  Copyright © 2016年 gfy. All rights reserved.
//

#import "ViewController.h"
#import "GCDWebUploader.h"
#import "SecondViewController.h"
#import "KxMovieViewController.h"
#import "PDFReaderViewController.h"

@interface ViewController ()<GCDWebUploaderDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UILabel *headerLabel;
    NSMutableArray *dataArray;
    NSString *shareUrl ;
    
@private
    GCDWebUploader* _webServer;
}
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    _webServer = [[GCDWebUploader alloc] initWithUploadDirectory:documentsPath];
    _webServer.delegate = self;
    _webServer.allowHiddenItems = YES;
    if ([_webServer start]) {

        shareUrl = [NSString stringWithFormat:@"在浏览器输入网址：%@",_webServer.serverURL];
        [self.myTableView reloadData];
        
        NSLog(@"服务器地址：%@",_webServer.serverURL);
    } else {
        headerLabel.text = NSLocalizedString(@"GCDWebServer not running!", nil);
    }
}

-(void)createRightBar
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"清空" forState:UIControlStateNormal];
    [button setFrame:CGRectMake(0, 0, 60, 44)];
    [button addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = item;
}
-(void)btnClick
{
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSArray *contents = [fm contentsOfDirectoryAtPath:path error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {
        NSLog(@"fileName = = %@",filename);
        [fm removeItemAtPath:[path stringByAppendingPathComponent:filename] error:NULL];
    }
    
    
    [self loadCacheDataNew];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"首页";
    dataArray = [[NSMutableArray alloc]init];
    shareUrl = @"服务启动失败!!!请重试！";
    [self createRightBar];
    
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    
    //    [self loadCacheData];
    [self loadCacheDataNew];
    
}
-(void)loadCacheDataNew
{
    
    [dataArray removeAllObjects];
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSArray *tempArray = [fm contentsOfDirectoryAtPath:path error:nil];
    //    NSLog(@"排序前：%@\n",tempArray);
    
    NSArray *sortedPaths = [tempArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        NSString *firstUrl = [path stringByAppendingPathComponent:obj1];//获取前一个文件完整路径
        NSString *secondUrl = [path stringByAppendingPathComponent:obj2];//获取后一个文件完整路径
        NSDictionary *firstFileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:firstUrl error:nil];//获取前一个文件信息
        NSDictionary *secondFileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:secondUrl error:nil];//获取后一个文件信息
        id firstData = [firstFileInfo objectForKey:NSFileModificationDate];//获取前一个文件修改时间
        id secondData = [secondFileInfo objectForKey:NSFileModificationDate];//获取后一个文件修改时间
        
        return [secondData compare:firstData];//降序
    }];
    
    
    //    NSLog(@"排序后：%@",sortedPaths);
    
    
    for (NSString *fileName in sortedPaths) {
        BOOL flag = YES;
        NSString *fullPath = [path stringByAppendingPathComponent:fileName];
        if ([fm fileExistsAtPath:fullPath isDirectory:&flag]) {
            
        }
        NSDictionary *dict = [fm attributesOfItemAtPath:fullPath error:nil];
        NSLog(@"dict = %@\n",dict);
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        //获取文件的创建日期
        NSDate *modificationDate = (NSDate*)[dict objectForKey: NSFileModificationDate];
        //格式化文件创建日期
        NSString *modifyDate =[dateFormatter stringFromDate: modificationDate];
        
        
        
        NSDictionary *paraDict = @{@"name":fileName,
                                   @"url":fullPath,
                                   @"size":[self caculateSizeToString:[dict objectForKey:@"NSFileSize"]],
                                   @"isDir":flag?@"1":@"0",
                                   @"date":modifyDate,
                                   @"type":[self typeToString:fileName],
                                   };
        
        [dataArray addObject:paraDict];
    }
    [self.myTableView reloadData];
    
}

-(NSString *)caculateSizeToString:(NSNumber *)number
{
    
    long mSize  =  [number longLongValue];
    if (mSize < 1024) {
        return [NSString stringWithFormat:@"%ld Bytes",mSize];
    }
    else if(mSize < 1024*1024)
    {
        return  [NSString stringWithFormat:@"%.2f KB",mSize/1024.0];
    }
    else if(mSize < 1024 *1024*1024){
        return  [NSString stringWithFormat:@"%.2f M",mSize/(1024.0*1024.0)];
    }
    else {
        return  [NSString stringWithFormat:@"%.2f G",mSize/(1024.0*1024.0*1024.0)];
    }
    
    
    return @"";
}
-(NSString *)typeToString:(NSString *)fileName
{
    if([fileName rangeOfString:@".doc"].location!=NSNotFound){
        return @"doc";
    }
    else if([fileName rangeOfString:@".jpg"].location!=NSNotFound)
    {
        return @"jpg";
    }
    else if([fileName rangeOfString:@".pdf"].location!=NSNotFound)
    {
        return @"pdf";
    }
    else if([fileName rangeOfString:@".png"].location!=NSNotFound)
    {
        return @"png";
    }
    else if([fileName rangeOfString:@".ppt"].location!=NSNotFound)
    {
        return @"ppt";
    }
    else if([fileName rangeOfString:@".txt"].location!=NSNotFound)
    {
        return @"txt";
    }
    else if([fileName rangeOfString:@".xls"].location!=NSNotFound)
    {
        return @"xls";
    }
    else if([fileName rangeOfString:@".zip"].location!=NSNotFound)
    {
        return @"zip";
    }
    else
    {
        return @"none";
    }
    return @"";
}
#pragma mark UITableViewDelegate
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 40)];
    headerLabel.backgroundColor = [UIColor redColor];
    headerLabel.text = shareUrl;
    headerLabel.font = [UIFont systemFontOfSize:13];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    return headerLabel;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataArray count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *str = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:str];
    }
    
    NSDictionary *dict = [dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"name"]];
    
    if ([[dict objectForKey:@"isDir"] boolValue]) {
        cell.imageView.image = [UIImage imageNamed:@"folder_Thumbnail"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"date"]];
    }
    else
    {
        NSString *type = [NSString stringWithFormat:@"%@_Thumbnail",[dict objectForKey:@"type"]];
        cell.imageView.image = [UIImage imageNamed:type];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@   %@",[dict objectForKey:@"date"],[dict objectForKey:@"size"]];
    }
    
    
    return cell;
    
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:
(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        //        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:[[dataArray objectAtIndex:indexPath.row] objectForKey:@"url"] error:NULL];
        [dataArray removeObjectAtIndex:row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    //    @"mp4,avi,rmvb.3gp,mov,flv,m3u8,rm,wmv,mkv,mpg,vob"
    NSDictionary *ddic = [dataArray objectAtIndex:indexPath.row];
    NSString *name = [ddic objectForKey:@"name"];
    NSArray *arr = [name componentsSeparatedByString:@"."];
    if (arr !=nil && [arr count]>0 && ([@"mp4,avi,rmvb.3gp,mov,flv,m3u8,rm,wmv,mkv,mpg,vob" rangeOfString:[arr lastObject]].location != NSNotFound)) {
        
        UIViewController *vc;
        NSString *urlString = [ddic objectForKey:@"url"];
        vc = [KxMovieViewController movieViewControllerWithContentPath:urlString parameters:nil];
        [self presentViewController:vc animated:YES completion:nil];
    }
    else
    {
        
        if ([name rangeOfString:@".pdf"].location!=NSNotFound) {
            PDFReaderViewController *pdfVC = [[PDFReaderViewController alloc]init];
            pdfVC.dataDict = ddic;
            
            [self.navigationController pushViewController:pdfVC animated:YES];

        }
        else
        {
            [self performSegueWithIdentifier:@"sendValue" sender:ddic];
        }
    }
    
    
    //    SecondViewController *detailVC = [[[NSBundle mainBundle]loadNibNamed:@"SecondViewController" owner:nil options:nil] lastObject];///[[SecondViewController alloc]init];
    //    detailVC.dict = ddic;
    //    [self.navigationController pushViewController:detailVC animated:YES];
    
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"sendValue"]) {
        // segue.destinationViewController：获取连线时所指的界面（VC）
        SecondViewController *receive = segue.destinationViewController;
        receive.dict = (NSDictionary *)sender;
        // 这里不需要指定跳转了，因为在按扭的事件里已经有跳转的代码
        //		[self.navigationController pushViewController:receive animated:YES];
    }
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [_webServer stop];
    _webServer = nil;
}


/**
 *  This method is called whenever a file has been downloaded.
 */
- (void)webUploader:(GCDWebUploader*)uploader didDownloadFileAtPath:(NSString*)path
{
    NSLog(@"[DOWNLOAD] %@", path);
}
/**
 *  This method is called whenever a file has been uploaded.
 */
- (void)webUploader:(GCDWebUploader*)uploader didUploadFileAtPath:(NSString*)path {
    NSLog(@"[UPLOAD] %@", path);
    [self loadCacheDataNew];
}
/**
 *  This method is called whenever a file or directory has been moved.
 */
- (void)webUploader:(GCDWebUploader*)uploader didMoveItemFromPath:(NSString*)fromPath toPath:(NSString*)toPath {
    NSLog(@"[MOVE] %@ -> %@", fromPath, toPath);
    [self loadCacheDataNew];
}
/**
 *  This method is called whenever a file or directory has been deleted.
 */
- (void)webUploader:(GCDWebUploader*)uploader didDeleteItemAtPath:(NSString*)path {
    NSLog(@"[DELETE] %@", path);
    [self loadCacheDataNew];
}
/**
 *  This method is called whenever a directory has been created.
 */
- (void)webUploader:(GCDWebUploader*)uploader didCreateDirectoryAtPath:(NSString*)path {
    NSLog(@"[CREATE] %@", path);
    [self loadCacheDataNew];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
