//
//  PCComicsListController.m
//  Pica
//
//  Created by fancy on 2020/11/3.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCComicsListController.h"
#import "PCRandomRequest.h"
#import "PCComicsRequest.h"
#import "PCSearchRequest.h"
#import "PCComicsListCell.h"
#import "PCComicsDetailController.h"

@interface PCComicsListController ()

@property (nonatomic, assign) PCComicsListType type;
@property (nonatomic, strong) PCComicsRequest *categoryRequest;
@property (nonatomic, strong) PCSearchRequest *searchRequest;
@property (nonatomic, strong) PCRandomRequest *randomRequest;
@property (nonatomic, strong) NSMutableArray <PCComicsList *>*comicsArray;

@end

@implementation PCComicsListController

- (instancetype)initWithType:(PCComicsListType)type {
    if (self = [super init]) {
        self.type = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
     
    [self requestComics];
    
    switch (self.type) {
        case PCComicsListTypeRandom:
            
            break;
        default:
            self.navigationItem.rightBarButtonItem = [UIBarButtonItem qmui_itemWithTitle:@"新到旧" target:self action:@selector(sortAction:)];
            break;
    }
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
    
    switch (self.type) {
        case PCComicsListTypeRandom:
            self.title = @"随机本子";
            break;
        default:
            self.title = self.keyword;
            break;
    }
}

- (void)initTableView {
    [super initTableView];
    
    [self.tableView registerClass:[PCComicsListCell class] forCellReuseIdentifier:@"PCComicsListCell"];
    self.tableView.rowHeight = 130;
     
    if (self.type != PCComicsListTypeRandom) {
        @weakify(self)
        self.tableView.mj_footer = [MJRefreshBackStateFooter footerWithRefreshingBlock:^{
            @strongify(self)
            PCComicsList *list = self.comicsArray.lastObject;
            if (list.page < list.pages) {
                switch (self.type) {
                    case PCComicsListTypeSearch:
                        self.searchRequest.page ++;
                        break;
                    case PCComicsListTypeCategory:
                        self.categoryRequest.page ++;
                        break;
                    default:
                        break;
                }
               
                [self requestComics];
            } else {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
        }];
    }
}
 
#pragma mark - Action
- (void)sortAction:(id)sender {
    NSDictionary *sorts = @{ @"新到旧" : @"dd",
                             @"旧到新" : @"da",
                             @"爱心数" : @"ld",
                             @"翻牌数" : @"vd"};
    NSString *sort = self.keyword ? self.searchRequest.sort : self.categoryRequest.s;
     
    QMUIDialogSelectionViewController *dialogViewController = [[QMUIDialogSelectionViewController alloc] init];
    dialogViewController.selectedItemIndex = [sorts.allValues indexOfObject:sort];
    dialogViewController.title = @"排序方式";
    dialogViewController.items = sorts.allKeys;
    [dialogViewController addCancelButtonWithText:@"取消" block:nil];
    [dialogViewController addSubmitButtonWithText:@"确定" block:^(QMUIDialogSelectionViewController *controller) {
        NSInteger index = controller.selectedItemIndex;
        NSString *key = sorts.allKeys[index];
        NSString *value = [sorts valueForKey:key];
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem qmui_itemWithTitle:key target:self action:@selector(sortAction:)];
        
        switch (self.type) {
            case PCComicsListTypeSearch:
                self.searchRequest.sort = value;
                self.searchRequest.page = 1;
                break;
            case PCComicsListTypeCategory:
                self.categoryRequest.s = value;
                self.categoryRequest.page = 1;
                break;
            default:
                break;
        }
        [self requestComics];
        [controller hideWithAnimated:YES completion:nil];
    }];
    [dialogViewController show];
}

#pragma mark - Net
- (void)requestComics {
    switch (self.type) {
        case PCComicsListTypeRandom:
            [self requestRandomComics];
            break;
        case PCComicsListTypeSearch:
            [self requestSearchComics];
            break;
        case PCComicsListTypeCategory:
            [self requestCategoryComics];
            break;
        default:
            break;
    }
}

- (void)requestCategoryComics {
    if (self.categoryRequest.page == 1) {
        [self showEmptyViewWithLoading];
    }
    
    [self.categoryRequest sendRequest:^(PCComicsList *list) {
        [self requestFinishedWithList:list];
    } failure:^(NSError * _Nonnull error) {
        [self requestFinishedWithError:error];
    }];
}

- (void)requestSearchComics {
    if (self.searchRequest.page == 1) {
        [self showEmptyViewWithLoading];
    }
    
    [self.searchRequest sendRequest:^(PCComicsList *list) {
        [self requestFinishedWithList:list];
    } failure:^(NSError * _Nonnull error) {
        [self requestFinishedWithError:error];
    }];
}

- (void)requestRandomComics {
    [self showEmptyViewWithLoading];
    
    [self.randomRequest sendRequest:^(PCComicsList *list) {
        [self requestFinishedWithList:list];
    } failure:^(NSError * _Nonnull error) {
        [self requestFinishedWithError:error];
    }];
}

- (void)requestFinishedWithList:(PCComicsList *)list {
    switch (self.type) {
        case PCComicsListTypeSearch:
            if (self.searchRequest.page == 1) {
                [self.comicsArray removeAllObjects];
            }
            break;
        case PCComicsListTypeCategory:
            if (self.categoryRequest.page == 1) {
                [self.comicsArray removeAllObjects];
            }
            break;
        default:
            break;
    }
    
    [self hideEmptyView];
    [self.tableView.mj_footer endRefreshing];
    [self.comicsArray addObject:list];
    [self.tableView reloadData];
}

- (void)requestFinishedWithError:(NSError *)error {
    SEL sel = NULL;
    switch (self.type) {
        case PCComicsListTypeRandom:
            sel = @selector(requestRandomComics);
            break;
        case PCComicsListTypeSearch:
            sel = @selector(searchRequest);
            break;
        case PCComicsListTypeCategory:
            sel = @selector(requestCategoryComics);
            break;
        default:
            break;
    }
    [self showEmptyViewWithText:@"网络错误" detailText:nil buttonTitle:@"重新请求" buttonAction:sel];
}


#pragma mark - Table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.comicsArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.comicsArray[section].docs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PCComicsListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PCComicsListCell" forIndexPath:indexPath];
    cell.comics = self.comicsArray[indexPath.section].docs[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PCComics *comics = self.comicsArray[indexPath.section].docs[indexPath.row];
    
    PCComicsDetailController *detail = [[PCComicsDetailController alloc] initWithComicsId:comics.comicsId];
    [self.navigationController pushViewController:detail animated:YES];
}

#pragma mark - Get
- (NSMutableArray<PCComicsList *> *)comicsArray {
    if (!_comicsArray) {
        _comicsArray = [NSMutableArray array];
    }
    return _comicsArray;
}

- (PCComicsRequest *)categoryRequest {
    if (!_categoryRequest) {
        _categoryRequest = [[PCComicsRequest alloc] init];
        _categoryRequest.c = self.keyword;
    }
    return _categoryRequest;
}

- (PCSearchRequest *)searchRequest {
    if (!_searchRequest) {
        _searchRequest = [[PCSearchRequest alloc] init];
        _searchRequest.keyword = self.keyword;
    }
    return _searchRequest;
}

- (PCRandomRequest *)randomRequest {
    if (!_randomRequest) {
        _randomRequest = [[PCRandomRequest alloc] init];
    }
    return _randomRequest;
}

@end
