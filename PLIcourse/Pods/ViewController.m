//
//  ViewController.m
//  NetWorking
//
//  Created by admin on 16/9/20.
//  Copyright © 2016年 xukelun. All rights reserved.
//

#import "ViewController.h"
#import "JSONS.h"

@interface ViewController () <NSURLSessionDelegate> //总协议，一旦签署相当于所有与会话相关的子协议都签署

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //设置我们将要请求的网址
    NSString *weatherURLStr = @"http://api.openweathermap.org/data/2.5/weather?q=Wuxi,cn&appid=7b165a7c7b1f3c22bad6bd2c9fb36a93";
    //将NSString转换成NSURL数据类型
    NSURL *weatherURL = [NSURL URLWithString:weatherURLStr];
    //初始化一个NSURLSession对象（网络请求会话对象）（这里使用系统默认的会话配置包，不使用自定义配置包）
    NSURLSession *session = [NSURLSession sharedSession];
    //用上述NSURLSession对象创建一个普通任务（NSURLSessionDataTask对象）
    NSURLSessionDataTask *jsonDataTask = [session dataTaskWithURL:weatherURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        //判断网络请求是否成功（有没有错误）
        if (error) {
            NSLog(@"%@",error.description);
        } else {
            //将NSURLResponse对象强制转换和那个NSHTTPURLResponse对象（前提是网络请求是一个用http或者https协议的请求）
            NSHTTPURLResponse *httpRes = (NSHTTPURLResponse *)response;
            //判断返回码是不是200（返回有没有正常拿到）
            if (httpRes.statusCode != 200) {
                NSLog(@"%ld", (long)httpRes.statusCode);
            } else {
                //将JSON格式的数据流通过NSData的Category中的JSONCol方法转化为id对象，并将这个id对象强制转换为字典对象（因为我们知道结果的结构是一个字典结构）
                NSDictionary *JSONObj = (NSDictionary *)[data JSONCol];
                NSLog(@"%@", JSONObj);
            }
        }
    }];
    //触发上述任务
    [jsonDataTask resume];
    
    //创建一个网址请求对象
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://7u2h3s.com2.z0.glb.qiniucdn.com/activityImg_1_885E76C7-7EA0-423D-B029-2085C0F769E6"]];
    //创建一个会话配置包
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    //表示支持2G/3G/4G等移动网络（可以认为支持所有网络类型）
    sessionConfig.allowsCellularAccess = YES;
    //设置请求超时时间为30s
    sessionConfig.timeoutIntervalForRequest = 30.f;
    //设置资源超时时间为60s
    sessionConfig.timeoutIntervalForResource = 60.f;
    //创建一个会话，使用上述配置包，并且使用协议
    NSURLSession *configuredSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
    //使用上述会话创建一个下载任务
    NSURLSessionDownloadTask *imgDownloadTask = [configuredSession downloadTaskWithRequest:imageRequest];
    //触发任务执行
    [imgDownloadTask resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//当下载任务执行完成时调用该方法
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    //无论下载成功失败统一先将进度条隐藏
    dispatch_async(dispatch_get_main_queue(), ^{
        _progressView.hidden = YES;
        _progressView.progress = 0.f;
    });
    //absoluteString方法可以将NSURL对象转换成NSSTring对象
    NSLog(@"%@", location.absoluteString);
    //判断location是否存在（判断下载是否成功）
    if (location) {
        //将一个URL路径下的文件读取成为数据流格式
        NSData *data = [NSData dataWithContentsOfURL:location];
        //将数据流转换成为图片对象
        UIImage *image = [UIImage imageWithData:data];
        //如果图片存在再去执行需要的操作
        if (image) {
            //dispatch_get_main_queue()表示主线程，这里用dispatch_async（）方法执行异步操作，表示异步地抛回主线程里面去做某些事
            dispatch_async(dispatch_get_main_queue(), ^{
               //将下载得到的图片（作为临时文件存放在沙盒里的图片对象）显示在图片视图上
                _imageView.image = image;
            });
        }
        
        //将图片转换为png格式的数据流
        NSData *pngImgData = UIImagePNGRepresentation(image);
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
        //创建一个上传任务，将pngImgData数据流上传到百度空间中（这里只是演示代码，并不能真的传到百度去)
        NSURLSessionUploadTask *imageUploadTask = [session uploadTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com/"]] fromData:pngImgData];
        [imageUploadTask resume];
    }
}

//当下载进行中（每有新的一滴小水滴滴下来时）调用该方法
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
//    //BytesWritten表示当前一滴小水滴的大小
//    NSLog(@"bytesWritten = %lld", bytesWritten);
//    //totalBytesWritten表示总共已经下载到的数据量的总大小
//    NSLog(@"totalBytesWritten = %lld", totalBytesWritten);
//    //totalBytesExpectedToWrite表示总共还剩的每有下载的数据量的总大小
//    NSLog(@"totalBytesExpectedToWrite = %lld", totalBytesExpectedToWrite);
    //计算当前下载进度的百分比值
    CGFloat progress = (CGFloat) totalBytesWritten / (CGFloat) totalBytesExpectedToWrite;
    NSLog(@"%f", progress);
    dispatch_async(dispatch_get_main_queue(), ^{
        _progressView.hidden = NO;
        _progressView.progress = progress;
    });
}

@end
