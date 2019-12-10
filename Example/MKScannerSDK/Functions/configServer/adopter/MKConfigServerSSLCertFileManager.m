//
//  MKConfigServerSSLCertFileManager.m
//  MKBLEGateway
//
//  Created by aa on 2019/7/24.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKConfigServerSSLCertFileManager.h"

@interface MKConfigServerSSLCertFileManager ()

@property (nonatomic, strong)dispatch_queue_t watchQueue;

@property (nonatomic, strong)dispatch_source_t watchSource;

@end

@implementation MKConfigServerSSLCertFileManager

#pragma mark - Public method

// 监听指定目录的文件改动
- (void)startMonitoringDirectory:(void (^)(void))dfuFileDatasChangedBlock
{
    NSString *directoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSURL *directoryURL = [NSURL URLWithString:directoryPath];
    // 创建 file descriptor (需要将NSString转换成C语言的字符串)
    // open() 函数会建立 file 与 file descriptor 之间的连接
    int filedes = open([[directoryURL path] fileSystemRepresentation], O_EVTONLY);
    if (filedes < 0) {
        NSLog(@"Unable to open the path = %@", [directoryURL path]);
        return;
    }
    // 创建 dispatch queue, 当文件改变事件发生时会发送到该 queue
    self.watchQueue = dispatch_queue_create("ZFileMonitorQueue", 0);
    
    // 创建 GCD source. 将用于监听 file descriptor 来判断是否有文件写入操作
    self.watchSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, filedes, DISPATCH_VNODE_WRITE, self.watchQueue);
    // 当文件发生改变时会调用该 block
    dispatch_source_set_event_handler(self.watchSource, ^{
        // 在文件发生改变时发出通知
        // 在子线程发送通知, 这个通知触发的方法会在子线程当中执行
        moko_dispatch_main_safe(^{
            if (dfuFileDatasChangedBlock) {
                dfuFileDatasChangedBlock();
            }
        });
    });
    
    // 当文件监听停止时会调用该 block
    dispatch_source_set_cancel_handler(self.watchSource, ^{
        // 关闭文件监听时, 关闭该 file descriptor
        close(filedes);
    });
    
    // 开始监听文件
    dispatch_resume(self.watchSource);
}

- (NSArray *)getCurrentFileList{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    // 获取指定路径对应文件夹下的所有文件
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:document error:&error];
    return fileList;
}

/**
 根据名字来获取dfu文件路径
 
 @param fileName dfu文件名字
 @return 路径
 */
- (NSString *)getDfuFilePathWithFileName:(NSString *)fileName{
    if (!ValidStr(fileName)) {
        return @"";
    }
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return [document stringByAppendingPathComponent:fileName];
}

- (void)cancel{
    if (!self.watchSource) {
        return;
    }
    dispatch_cancel(self.watchSource);
}

@end
