//
//  ViewController.m
//  NWRTInteractionDemo
//
//  Created by kwni on 2021/8/7.
//

#import "NRTMainViewController.h"
#import "NWDynamicShapeView.h"

/// 屏幕 宽度、高度
#define Screen_Width ([UIScreen mainScreen].bounds.size.width)
#define Screen_Height ([UIScreen mainScreen].bounds.size.height)

@interface NRTMainViewController ()

@property (nonatomic,assign) NSInteger shapeNum;

@property (nonatomic,strong) MQTTSessionManager *manager;
@property (nonatomic,copy) NSString *rootTopic;
@property (nonatomic) NSInteger qos;


@end

@implementation NRTMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    
    [self loadConfiguation];
    
    [self setupUI];
}

-(void)initData{
    self.qos = 0;
    self.rootTopic = @"root";
}
-(void)loadConfiguation{
    NSString *deviceID = [UIDevice currentDevice].identifierForVendor.UUIDString;
    NSString *appId = @"6qyka0";
    NSString *clientId = [NSString stringWithFormat:@"%@@%@",deviceID,appId];
    NSString *username = self.username;
    NSString *password = @"123456";
    BOOL  isSSL = FALSE;
    if(!self.manager){
        self.manager = [[MQTTSessionManager alloc] init];
        self.manager.delegate = self;
        self.manager.subscriptions = @{[NSString stringWithFormat:@"%@/IOS", self.rootTopic]:@(self.qos)};
        [self getTokenWithUsername:username password:password completion:^(NSString *token) {
            NSLog(@"=======token:%@==========",token);
            [self bindWithUserName:username password:token cliendId:clientId isSSL:isSSL];
        }];
    }else{
        [self.manager connectToLast:nil];
    }

    
}

- (void)getTokenWithUsername:(NSString *)username password:(NSString *)password completion:(void (^)(NSString *token))response {
    NSString *urlString = @"https://a1.easemob.com/1139210715094625/nwrtinteractiondemo/token";
    //初始化一个AFHTTPSessionManager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //设置请求体数据为json类型
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    //设置响应体数据为json类型
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary *parameters = @{@"grant_type":@"password",
                                 @"username":username,
                                 @"password":password
                                 };
   
    __block NSString *token  = @"";
    [manager POST:urlString
             parameters:parameters
             headers:nil
             progress:nil
             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                        NSError *error = nil;
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:&error];
                        NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
                        NSLog(@"%s jsonDic:%@",__func__,jsonDic);
                        token = jsonDic[@"access_token"];
                        response(token);}
             failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                        NSLog(@"%s error:%@",__func__,error.debugDescription);
                        response(token);
    }];
}

- (void)bindWithUserName:(NSString *)username password:(NSString *)password cliendId:(NSString *)cliendId isSSL:(BOOL)isSSL{
    [self.manager connectTo:@"6qyka0.cn1.mqtt.chat"
                                port:1883
                                 tls:isSSL
                           keepalive:60
                               clean:YES
                                auth:YES
                                user:username
                                pass:password
                                will:NO
                           willTopic:nil
                             willMsg:nil
                             willQos:0
                      willRetainFlag:NO
                        withClientId:cliendId
                      securityPolicy:[self customSecurityPolicy]
                        certificates:nil
                       protocolLevel:4
                      connectHandler:nil];
    
}

- (MQTTSSLSecurityPolicy *)customSecurityPolicy
{
    MQTTSSLSecurityPolicy *securityPolicy = [MQTTSSLSecurityPolicy policyWithPinningMode:MQTTSSLPinningModeNone];
    
    securityPolicy.allowInvalidCertificates = YES;
    securityPolicy.validatesCertificateChain = YES;
    securityPolicy.validatesDomainName = NO;
    return securityPolicy;
}

- (void)handleMessage:(NSData *)data onTopic:(NSString *)topic retained:(BOOL)retained {
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    if([dict[@"userid"] isEqualToString:self.username]){
        return;
    }
    if([dict[@"type"] isEqualToString:@"add"]){
        NWShapeViewType type = [dict[@"shapetype"] intValue];
        CGFloat x = [dict[@"x"] floatValue];
        CGFloat y = [dict[@"y"] floatValue];
        CGFloat width = [dict[@"width"] floatValue];
        NSInteger tag = [dict[@"index"] integerValue];
        [self addShapeToViewByType:type addX:x addY:y addWidth:width andTag:tag needMessage:FALSE];
    }else if([dict[@"type"] isEqualToString:@"clear"]){
        [self clearShape:FALSE];
    }else if([dict[@"type"] isEqualToString:@"modify"]){
        CGFloat x = [dict[@"x"] floatValue];
        CGFloat y = [dict[@"y"] floatValue];
        NSInteger index = [dict[@"index"] integerValue];
        [self refreshShapeView:index offsetX:x offsetY:y needMessage:FALSE];
    }
    
}


-(void)setupUI{
    UIButton *addbutton = [[UIButton alloc] initWithFrame:CGRectMake(Screen_Width/2-100, Screen_Height-60, 80, 40)];
    [addbutton setTitle:@"添加" forState:UIControlStateNormal] ;
    addbutton.backgroundColor = [UIColor colorWithRed:108/255.0 green:203/255.0 blue:247/255.0 alpha:1] ;
    [addbutton setTitleColor: [UIColor whiteColor ] forState:UIControlStateNormal] ;
    [addbutton addTarget:self action:@selector(addShape) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:addbutton] ;
    
    UIButton *clearbutton = [[UIButton alloc] initWithFrame:CGRectMake(Screen_Width/2+20, Screen_Height-60, 80, 40)];
    [clearbutton setTitle:@"清空" forState:UIControlStateNormal] ;
    clearbutton.backgroundColor = [UIColor colorWithRed:108/255.0 green:203/255.0 blue:247/255.0 alpha:1] ;
    [clearbutton setTitleColor: [UIColor whiteColor ] forState:UIControlStateNormal] ;
    [clearbutton addTarget:self action:@selector(clearBtnClick) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:clearbutton] ;
}

-(void)addShape{
    if(!self.shapeNum){
        self.shapeNum = 1;
    }
    self.shapeNum++;
    if(self.shapeNum > 6){
        return;
    }
    CGFloat baseX = Screen_Width*arc4random()/UINT32_MAX;
    CGFloat baseY = Screen_Height*arc4random()/UINT32_MAX;
    
    CGFloat sizeWidth = 30;
    int type = self.shapeNum %3;
    [self addShapeToViewByType:type addX:baseX addY:baseY addWidth:sizeWidth andTag:self.shapeNum needMessage:YES];
}

-(void)clearBtnClick{
    [self clearShape:YES];
}

-(void)clearShape:(BOOL)isNeedMessage{
    for(UIView *subView in self.view.subviews){
        if(subView.tag){
            [subView removeFromSuperview];
        }
    }
    if(isNeedMessage){
        [self sendDataWithType:@"clear" andShapeType:0 andX:0 andY:0 andWidth:0 andIndex:0];
    }

}

-(void)addShapeToViewByType:(NWShapeViewType)type addX:(CGFloat)x addY:(CGFloat)y addWidth:(CGFloat)width andTag:(NSInteger)tag needMessage:(BOOL)need{
    NWDynamicShapeView *view = [[NWDynamicShapeView alloc] initWithFrame:CGRectMake(x, y, width,width)];
    view.delegate = self;
    view.tag = tag;
    switch (type){
        case NWShapeViewType_Rect:
            view.type = NWShapeViewType_Rect;
            break;
        case NWShapeViewType_Triangle:
            view.type = NWShapeViewType_Triangle;
            break;
        case NWShapeViewType_Circle:
            view.type = NWShapeViewType_Circle;
            break;
        default:
            view.type = NWShapeViewType_Circle;
            break;
    }
    [self.view addSubview:view];
    if(need){
        [self sendDataWithType:@"add" andShapeType:type andX:x andY:y andWidth:width andIndex:view.tag];
    }
}

- (void)sendDataWithType:(NSString *)type
            andShapeType:(NWShapeViewType)shapeType
                    andX:(CGFloat)x
                    andY:(CGFloat)y
                andWidth:(CGFloat)width
                andIndex:(NSInteger)index{
    NSData *data;
    if([type isEqualToString:@"add"]){
        //添加shape
        NSDictionary *dict = @{@"type":type,@"shapetype":[NSNumber numberWithInteger:shapeType],@"x":[NSNumber numberWithInt:x],@"y":[NSNumber numberWithInt:y],@"width":[NSNumber numberWithInt:width],@"index":[NSNumber numberWithInteger:index],@"userid":self.username};
        data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    }else if([type isEqualToString:@"clear"]){
        //清空shape
        NSDictionary *dict = @{@"userid":self.username};
        data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    }else{
        //拖动shape
        NSDictionary *dict = @{@"type":type,@"x":[NSNumber numberWithInt:x],@"y":[NSNumber numberWithInt:y],@"index":[NSNumber numberWithInteger:index],@"userid":self.username};
        data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    }
    [self.manager sendData:data
                     topic:[NSString stringWithFormat:@"%@/%@",
                            self.rootTopic,
                            @"IOS"]//此处设置多级子topic
                       qos:self.qos
                    retain:FALSE];
}

-(void)refreshShapeView:(NSInteger)index offsetX:(CGFloat)x offsetY:(CGFloat)y{
    [self refreshShapeView:index offsetX:x offsetY:y needMessage:YES];
}

-(void)refreshShapeView:(NSInteger)index offsetX:(CGFloat)x offsetY:(CGFloat)y needMessage:(BOOL)need{
    for(UIView *subView in self.view.subviews){
        if(subView.tag){
            if(subView.tag == index){
                subView.frame = CGRectMake(subView.frame.origin.x + x, subView.frame.origin.y + y, subView.frame.size.width, subView.frame.size.height);
                [subView setNeedsDisplay];
                if(need){
                    [self sendDataWithType:@"modify" andShapeType:0 andX:x andY:y andWidth:0 andIndex:subView.tag];
                }
            }
        }
       
    }
}


- (void)connect {
    [self.manager connectToLast:nil];
}

- (void)disConnect {
    [self.manager disconnectWithDisconnectHandler:nil];
    self.manager.subscriptions = @{};
    
}

- (void)dealloc
{
    [self disConnect];
}



@end
