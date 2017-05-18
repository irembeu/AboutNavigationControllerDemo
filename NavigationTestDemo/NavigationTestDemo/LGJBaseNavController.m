//
//  LGJBaseNavController.m
//  NavigationTestDemo
//
//  Created by Mac on 2017/5/18.
//  Copyright © 2017年 Jason. All rights reserved.
//

#import "LGJBaseNavController.h"

@interface LGJBaseNavController ()<UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@end

@implementation LGJBaseNavController

#pragma mark - 初始化导航栏样式
+ (void)initialize {
    
    //bar样式
    UINavigationBar *bar = [UINavigationBar appearance];
    [bar setBarStyle:UIBarStyleDefault];
    [bar setBarTintColor:[UIColor blackColor]];
    
    [bar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil]];
    
    //barButton样式
    UIBarButtonItem *item = [UIBarButtonItem appearance];
    
    //Normal
    NSMutableDictionary *textAtts = [NSMutableDictionary dictionary];
    textAtts[NSForegroundColorAttributeName] = [UIColor orangeColor];
    textAtts[NSFontAttributeName] = [UIFont systemFontOfSize:13];
    [item setTitleTextAttributes:textAtts forState:UIControlStateNormal];
    
    //不可用状态
    NSMutableDictionary *disableTextAtts = [NSMutableDictionary dictionary];
    disableTextAtts[NSForegroundColorAttributeName] = [UIColor colorWithRed:123/255.0 green:123/255.0 blue:123/255.0 alpha:1];
    disableTextAtts[NSFontAttributeName] = [UIFont systemFontOfSize:13];
    [item setTitleTextAttributes:disableTextAtts forState:UIControlStateDisabled];
}


/*
 设置手势的delegate为这个导航控制器,分配了一个手势交互行为的委托在自定义按钮显示的时候.然后,当用户快速点击退出的时候,控制器因为手势发送了一个消息在本身已经被销毁的时候.让NavigationController自己成为响应的接受者.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak LGJBaseNavController *weakSelf = self;
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.delegate = weakSelf;
        self.delegate = weakSelf;
    }
}
/*
 在转场/过渡的时候禁用 interactivePopGestureRecognizer当用户在转场的时候触发一个后退手势,则各种事件又凑一块了.导航栈内又成了混乱的.解决办法是,转场效果的过程中禁用手势识别,当新的视图控制器加载完成后再启用.再次建议使用UINavigationController的子类操作.
 */
#pragma mark - UINavigationControllerDelegate
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    //设置返回按钮
    if (self.viewControllers.count > 0) {
        viewController.navigationItem.leftBarButtonItem = [self backButtonItem];
    }
    [super pushViewController:viewController animated:animated];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.enabled = YES;
    }
}

/****************************************/
- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    return [super popViewControllerAnimated:animated];
}


#pragma mark - UIGestureRecognizerDelegate
/*
 使navigationcontroller中第一个控制器不响应右滑pop手势
 */
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([self.childViewControllers count] == 1) {
        return NO;
    }
    return YES;
}

//解决多个手势冲突 同时接受多个手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

//解决在手指滑动时候,被pop的viewController中的UIscrollView会跟着一起滚动
/*
 //下面这个两个方法也是用来控制手势的互斥执行的
 //这个方法返回YES，第一个手势和第二个互斥时，第一个会失效
 - (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer NS_AVAILABLE_IOS(7_0);
 //这个方法返回YES，第一个和第二个互斥时，第二个会失效
 - (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer NS_AVAILABLE_IOS(7_0);
 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return [gestureRecognizer isKindOfClass:UIScreenEdgePanGestureRecognizer.class];
}

#pragma mark - 返回按钮
- (UIBarButtonItem *)backButtonItem {
    UIImage *image = [UIImage imageNamed:@"back_gray"];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:image forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 0, 40, 40);
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    return item;
}

- (void)back {
    [self popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
