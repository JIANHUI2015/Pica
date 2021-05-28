//
//  PCTabBarViewController.m
//  Pica
//
//  Created by fancy on 2020/11/2.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCTabBarViewController.h"
#import "PCNavigationController.h"
#import "PCCategoryController.h"
#import "PCProfileController.h"
#import "UIImage+PCAdd.h"
 
@interface PCTabBarViewController ()

@property (nonatomic, strong) PCCategoryController *categoryController;
@property (nonatomic, strong) PCProfileController  *profileController;

@end

@implementation PCTabBarViewController
 
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didInitialize {
    [super didInitialize];
 
    PCNavigationController *category = [[PCNavigationController alloc] initWithRootViewController:self.categoryController];
    category.tabBarItem = [self tabBarItemWithTitle:@"分类"
                                              image:[UIImage pc_iconWithText:ICON_MODULAR size:22 color:UIColorGrayLighten]
                                      selectedImage:[UIImage pc_iconWithText:ICON_MODULAR size:22 color:UIColorBlue]
                                                tag:0];
     
    PCNavigationController *me = [[PCNavigationController alloc] initWithRootViewController:self.profileController];
    me.tabBarItem = [self tabBarItemWithTitle:@"我的"
                                        image:[UIImage pc_iconWithText:ICON_USER size:22 color:UIColorGrayLighten]
                                selectedImage:[UIImage pc_iconWithText:ICON_USER size:22 color:UIColorBlue]
                                          tag:1];
    
//    PCNavigationController *setting = [[PCNavigationController alloc] initWithRootViewController:self.settingController];
//    setting.tabBarItem = [self tabBarItemWithTitle:@"设置"
//                                             image:[UIImage pc_iconWithText:ICON_SETTING size:22 color:UIColorGrayLighten]
//                                     selectedImage:[UIImage pc_iconWithText:ICON_SETTING size:22 color:UIColorBlue]
//                                               tag:2];
     
    self.viewControllers = @[category, me];
}

#pragma mark - Method
- (UITabBarItem *)tabBarItemWithTitle:(NSString *)title
                                image:(UIImage *)image
                        selectedImage:(UIImage *)selectedImage
                                  tag:(NSInteger)tag {
    UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:image tag:tag];
    tabBarItem.selectedImage = selectedImage;
    return tabBarItem;
}

#pragma mark - Get
 
- (PCCategoryController *)categoryController {
    if (!_categoryController) {
        _categoryController = [[PCCategoryController alloc] init];
        _categoryController.hidesBottomBarWhenPushed = NO;
    }
    return _categoryController;
}
 
- (PCProfileController *)profileController {
    if (!_profileController) {
        _profileController = [[PCProfileController alloc] init];
        _profileController.hidesBottomBarWhenPushed = NO;
    }
    return _profileController;
}

@end
