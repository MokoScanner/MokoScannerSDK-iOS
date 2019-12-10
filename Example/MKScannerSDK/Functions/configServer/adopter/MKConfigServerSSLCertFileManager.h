//
//  MKConfigServerSSLCertFileManager.h
//  MKBLEGateway
//
//  Created by aa on 2019/7/24.
//  Copyright © 2019 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKConfigServerSSLCertFileManager : NSObject

// 监听指定目录的文件改动
- (void)startMonitoringDirectory:(void (^)(void))dfuFileDatasChangedBlock;

/**
 获取当前列表数据
 
 @return @[]
 */
- (NSArray *)getCurrentFileList;

- (void)cancel;

@end

NS_ASSUME_NONNULL_END
