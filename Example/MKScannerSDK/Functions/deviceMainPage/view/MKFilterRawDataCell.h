//
//  MKFilterRawDataCell.h
//  MKBLEGateway
//
//  Created by aa on 2020/5/7.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@class MKFilterRawDataCellModel;

typedef NS_ENUM(NSInteger, mk_filterRawDataCellTextType) {
    mk_filterRawDataCellTextTypeDataType,
    mk_filterRawDataCellTextTypeMinIndex,
    mk_filterRawDataCellTextTypeMaxIndex,
    mk_filterRawDataCellTextTypeRawDataType,
};

@protocol MKFilterRawDataCellDelegate <NSObject>

/// 输入框内容发生改变
/// @param textType 哪个输入框发生改变了
/// @param index 当前cell所在的row
/// @param textValue 当前textField内容
- (void)rawFilterDataChanged:(mk_filterRawDataCellTextType)textType
                       index:(NSInteger)index
                   textValue:(NSString *)textValue;

@end
@interface MKFilterRawDataCell : MKBaseCell

@property (nonatomic, strong)MKFilterRawDataCellModel *dataModel;

@property (nonatomic, weak)id <MKFilterRawDataCellDelegate>delegate;

+ (MKFilterRawDataCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
