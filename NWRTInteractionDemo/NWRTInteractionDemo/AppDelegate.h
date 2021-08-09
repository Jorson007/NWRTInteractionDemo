//
//  AppDelegate.h
//  NWRTInteractionDemo
//
//  Created by kwni on 2021/8/7.
//

#import <UIKit/UIKit.h>

@protocol NRTChangeVCProtocol <NSObject>

-(void)changeToMainViewController:(NSString *)username;//登陆切换到主页

@end

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end

