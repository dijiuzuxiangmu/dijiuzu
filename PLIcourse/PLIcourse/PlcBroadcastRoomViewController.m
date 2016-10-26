//
//  PlcBroadcastRoomViewController.m
//  PLLiveCourse
//
//  Created by admin on 16/9/8.
//  Copyright © 2016年 zhongrui education. All rights reserved.
//

#import "PlcBroadcastRoomViewController.h"

#import <PLCameraStreamingKit/PLCameraStreamingKit.h>
@interface PlcBroadcastRoomViewController ()
@property (nonatomic, strong) PLCameraStreamingSession *cameraStremaingSession;;
@property (nonatomic, strong) NSString *roomID;
@end

@implementation PlcBroadcastRoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cameraStremaingSession = [self _generateCameraStreamingSession];
    [self requireDevicePermissionWithComplete:^(bool granted) {
        if (granted) {
            //获取了设备权限，此时显示出preview
            [self.view addSubview:({
                UIView *preview = self.cameraStremaingSession.previewView;
                preview.frame = self.view.bounds;
                preview.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                    UIViewAutoresizingFlexibleHeight;
                preview;
            })];
        }
    }];
    __weak typeof(self) weakSelf = self;
    [self _generatePushURLWithComplete:^(PLStream *stream) {
        __strong typeof(self) strongSelf = weakSelf;
        //当是一代pushURL时，view controller可能已经提前关闭和销毁，此时不可进行推流
        if (strongSelf) {
            strongSelf.cameraStremaingSession.stream = stream;
            [strongSelf.cameraStremaingSession startWithCompleted:^(BOOL success) {
                if (!success) {
                    NSLog(@"推流失败了！");
                }
            }];
        }
    }];
}

- (void)requireDevicePermissionWithComplete:(void(^)(bool granted))complete {
    switch ([PLCameraStreamingSession cameraAuthorizationStatus]) {
        case PLAuthorizationStatusAuthorized:
            complete(YES);
            break;
        case PLAuthorizationStatusNotDetermined: {
            [PLCameraStreamingSession requestCameraAccessWithCompletionHandler:^(BOOL granted) {
                complete(granted);
            }];
            break;
        }
            default:
            complete(NO);
            break;
    }
}

- (void)_generatePushURLWithComplete:(void(^)(PLStream *stream))complete {
    NSString *url = [NSString stringWithFormat:@"%@%@", kHost@["/api/pilipili"]];
    NSLog(@"connect to %@",url);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";
    request.timeoutInterval = 10;
    [request setHTTPBody:[@"title = room" dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable responseError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = responseError;
            if (error != nil || response == nil || data ==nil) {
                NSLog(@"获取推流URL失败%@", error);
                return ;
            }
            NSDictionary *streamJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            NSLog(@"streamJSON: %@", streamJSON);
            self.roomID = streamJSON[@"id"];
            PLStream *stream = [PLStream streamWithJSON:streamJSON];
            if (complete) {
                complete(stream);
            }
        });
    }];
    [task resume];
}


- (PLCameraStreamingSession *)_generateCameraStreamingSession {
    //视频采集配置，对应的是摄像头
    PLVideoCaptureConfiguration *videoCaptureConfiguration;
    //视频推流配置，对应的是推流出去的画面
    PLVideoStreamingConfiguration *videoStreamingConfiguration;
    //音频采集设置，对应的是麦克风
    PLAudioCaptureConfiguration *audioCaptureConfiguration;
    //音频推流设置，对应的是推流出去的声音
    PLAudioStreamingConfiguration *audioSreamingConfiguration;
    
    videoCaptureConfiguration = [PLVideoCaptureConfiguration defaultConfiguration];
    videoStreamingConfiguration = [PLVideoStreamingConfiguration defaultConfiguration];
    audioCaptureConfiguration = [PLAudioCaptureConfiguration defaultConfiguration];
    audioSreamingConfiguration = [PLAudioStreamingConfiguration defaultConfiguration];
    
    //设置摄像头采集的方向
    AVCaptureVideoOrientation captureOrientation = AVCaptureVideoOrientationPortrait;
    
    PLStream *stream = nil;
    return [[PLCameraStreamingSession alloc] initWithVideoCaptureConfiguration:videoCaptureConfiguration audioCaptureConfiguration:audioCaptureConfiguration videoStreamingConfiguration:videoStreamingConfiguration audioStreamingConfiguration:audioSreamingConfiguration stream:stream videoOrientation:captureOrientation];
}



@end
