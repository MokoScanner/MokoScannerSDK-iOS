//
//  MKFilterRawDataCellModel.m
//  MKBLEGateway
//
//  Created by aa on 2020/5/7.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKFilterRawDataCellModel.h"

@implementation MKFilterRawDataCellModel

- (BOOL)validParamsSuccess {
    if (!ValidStr(self.dataType) || self.dataType.length != 2) {
        return NO;
    }
    NSArray *typeList = [self dataTypeList];
    if (![typeList containsObject:[self.dataType uppercaseString]]) {
        return NO;
    }
    if (!ValidStr(self.minIndex) && !ValidStr(self.maxIndex)) {
        //
        return [self validRawDatas];
    }
    if (!ValidStr(self.minIndex) || self.minIndex.length > 2 || ![self.minIndex regularExpressions:isRealNumbers] || [self.minIndex integerValue] < 0 || [self.minIndex integerValue] > 29) {
        return NO;
    }
    if ([self.minIndex integerValue] == 0) {
        //可以不填写maxIndex或者maxIndex只能写0
        if ((!ValidStr(self.maxIndex) || [self.maxIndex integerValue] == 0) && [self validRawDatas]) {
            return YES;
        }
        return NO;
    }
    if (!ValidStr(self.maxIndex) || self.maxIndex.length > 2 || ![self.maxIndex regularExpressions:isRealNumbers] || [self.maxIndex integerValue] < 0 || [self.maxIndex integerValue] > 29) {
        return NO;
    }
    if ([self.maxIndex integerValue] < [self.minIndex integerValue]) {
        return NO;
    }
    if (!ValidStr(self.rawData) || self.rawData.length > 58 || ![self.rawData regularExpressions:isHexadecimal]) {
        return NO;
    }
    NSInteger totalLen = ([self.maxIndex integerValue] - [self.minIndex integerValue] + 1) * 2;
    if (self.rawData.length != totalLen) {
        return NO;
    }
    return YES;
}

- (BOOL)validRawDatas {
    if (!ValidStr(self.rawData) || self.rawData.length > 58 || ![self.rawData regularExpressions:isHexadecimal]) {
        return NO;
    }
    if (self.rawData.length % 2 != 0) {
        return NO;
    }
    return YES;
}

- (NSArray *)dataTypeList {
    return @[@"01",@"02",@"03",@"04",@"05",
             @"06",@"07",@"08",@"09",@"0A",
             @"0D",@"0E",@"0F",@"10",@"11",
             @"12",@"14",@"15",@"16",@"17",
             @"18",@"19",@"1A",@"1B",@"1C",
             @"1D",@"1E",@"1F",@"20",@"21",
             @"22",@"23",@"24",@"25",@"26",
             @"27",@"28",@"29",@"2A",@"2B",
             @"2C",@"2D",@"3D",@"FF"];
}

@end
