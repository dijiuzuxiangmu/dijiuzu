//
//  PlcLobbyViewController.m
//  PLLiveCourse
//
//  Created by admin on 16/9/8.
//  Copyright © 2016年 zhongrui education. All rights reserved.
//

#import "PlcLobbyViewController.h"
#import "PlcBroadcastRoomViewController.h"
@interface PlcLobbyViewController ()

@end

@implementation PlcLobbyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.titleView = ({
        UILabel *titleLable = [[UILabel alloc] init];
        titleLable.text = @"大厅";
        [titleLable sizeToFit];
        titleLable;
    });
    
    self.navigationItem.rightBarButtonItem = ({
        UIBarButtonItem *button = [[UIBarButtonItem alloc]init];
        button.title = @"直播";
        button.target = self;
        button.action = @selector(_onPressedBeginBroadcastButton:);
        button;
    });
}

- (void)_onPressedBeginBroadcastButton:(id)sender {
    PlcBroadcastRoomViewController *viewController = [[PlcBroadcastRoomViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
