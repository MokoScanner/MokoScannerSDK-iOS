//
//  MKCertListController.m
//  MKBLEGateway
//
//  Created by aa on 2019/7/24.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKCertListController.h"
#import "MKConfigServerSSLCertFileManager.h"

@interface MKCertListController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

@property (nonatomic, strong)MKConfigServerSSLCertFileManager *fileManager;

@end

@implementation MKCertListController

#pragma mark -
- (void)dealloc {
    NSLog(@"MKCertListController销毁");
    [self.fileManager cancel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self getDatasFromSource];
    WS(weakSelf);
    [self.fileManager startMonitoringDirectory:^{
        [weakSelf getDatasFromSource];
    }];
    // Do any additional setup after loading the view.
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    NSString *filePath = [document stringByAppendingPathComponent:self.dataList[indexPath.row]];
//    NSData *fileDatas = [NSData dataWithContentsOfFile:filePath];
    NSLog(@"%@",self.dataList[indexPath.row]);
    if ([self.delegate respondsToSelector:@selector(mk_certSelectedMethod:certName:)]) {
        [self.delegate mk_certSelectedMethod:self.pageType certName:self.dataList[indexPath.row]];
    }
    [self performSelector:@selector(leftButtonMethod) withObject:nil afterDelay:0.3f];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MKCertListControllerIdenty"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKCertListControllerIdenty"];
    }
    cell.contentView.backgroundColor = COLOR_WHITE_MACROS;
    cell.textLabel.text = self.dataList[indexPath.row];
    cell.textLabel.textColor = DEFAULT_TEXT_COLOR;
    return cell;
}

#pragma mark -
- (void)getDatasFromSource{
    NSArray *list = [self.fileManager getCurrentFileList];
    [self.dataList removeAllObjects];
    [self.dataList addObjectsFromArray:list];
    [self.tableView reloadData];
}

- (void)loadSubViews {
    self.custom_naviBarColor = UIColorFromRGB(0x0188cc);
    self.titleLabel.textColor = COLOR_WHITE_MACROS;
    self.defaultTitle = @"File Select";
    [self.rightButton setHidden:YES];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(defaultTopInset);
        make.bottom.mas_equalTo(-VirtualHomeHeight);
    }];
}

#pragma mark - setter & getter
- (MKBaseTableView *)tableView {
    if (!_tableView) {
        _tableView = [[MKBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (NSMutableArray *)dataList {
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (MKConfigServerSSLCertFileManager *)fileManager {
    if (!_fileManager) {
        _fileManager = [[MKConfigServerSSLCertFileManager alloc] init];
    }
    return _fileManager;
}

@end
