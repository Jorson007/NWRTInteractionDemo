//
//  ViewController.h
//  NWRTInteractionDemo
//
//  Created by kwni on 2021/8/7.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/AFNetworking.h>
#import <MQTTClient/MQTTClient.h>
#import <MQTTClient/MQTTSessionManager.h>
#import "NWDynamicShapeView.h"

@interface NRTMainViewController : UIViewController<MQTTSessionManagerDelegate,NWRefreshViewOriginProtocal>

@property (nonatomic,copy) NSString *username;


@end

