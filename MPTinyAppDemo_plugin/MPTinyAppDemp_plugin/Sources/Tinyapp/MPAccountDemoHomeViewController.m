//
//  MPAccountDemoHomeViewController.m
//  MPTinyAppDemo_pod
//
//  Created by yemingyu on 2020/5/28.
//  Copyright © 2020 yangwei. All rights reserved.
//

#import "MPAccountDemoHomeViewController.h"
#import <MPNebulaAdapter/MPNebulaAdapterInterface.h>
#import "MPDemoTinyScanHelper.h"
#import <APMobileNetwork/DTRpcClient.h>

#ifdef ENABLE_ACCOUNT
    #import <NBInsideAccountAdaptor/NBIAuthService.h>
    #import <InsideAccountOpenAuth/ANXAccountOpenAuthModel.h>
    #import <InsideAccountOpenAuth/ANXMCAccountStatusChangeModel.h>
    #import <InsideService/ANXInsideService.h>

    #define mp_user_id @"mp_user_id"
    #define mp_access_token @"mp_access_token"
    #define mp_mc_user_id @"mp_mc_user_id"
//    #define mp_auth_code @"mp_auth_code"

#endif

const static CGFloat interval = 60.0f;

static NSArray *getDemoTinyAppList(){
    static NSArray *array = nil;
    if (array == nil) {
        array = @[@[@"2018032302435038", @"1688"]];
    }
    return array;
}

#ifdef ENABLE_ACCOUNT
@interface MPAccountDemoHomeViewController () <UINavigationControllerDelegate,UIActionSheetDelegate, NBIAuthDelegate>
#else
@interface MPAccountDemoHomeViewController () <UINavigationControllerDelegate,UIActionSheetDelegate>
#endif

@end


@implementation MPAccountDemoHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button0 = [UIButton buttonWithType:UIButtonTypeCustom];
    button0.frame = CGRectMake(30, 80, [UIScreen mainScreen].bounds.size.width-60, 44);
    button0.backgroundColor = [UIColor blueColor];
    [button0 setTitle:@"启动小程序Demo" forState:UIControlStateNormal];
    [button0 addTarget:self action:@selector(openTinyApp:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button0];

    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    button1.frame = CGRectOffset(button0.frame, 0, interval);
    [button1 setTitle:@"获取 authcode" forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(getAuthCode:) forControlEvents:UIControlEventTouchUpInside];
    button1.backgroundColor = [UIColor blueColor];
    [self.view addSubview:button1];

    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button2.frame = CGRectOffset(button1.frame, 0, interval);
    [button2 setTitle:@"设置 cookie" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(setCurrentCookie:) forControlEvents:UIControlEventTouchUpInside];
    button2.backgroundColor = [UIColor blueColor];
    [self.view addSubview:button2];

    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
    button3.frame = CGRectOffset(button2.frame, 0, interval);
    [button3 setTitle:@"cookie 检查" forState:UIControlStateNormal];
    [button3 addTarget:self action:@selector(getCurrentCookie:) forControlEvents:UIControlEventTouchUpInside];
    button3.backgroundColor = [UIColor blueColor];
    [self.view addSubview:button3];

    UIButton *button4 = [UIButton buttonWithType:UIButtonTypeCustom];
    button4.frame = CGRectOffset(button3.frame, 0, interval);
    [button4 setTitle:@"解绑支付宝" forState:UIControlStateNormal];
    [button4 addTarget:self action:@selector(unbindAlipay:) forControlEvents:UIControlEventTouchUpInside];
    button4.backgroundColor = [UIColor blueColor];
    [self.view addSubview:button4];

    UIButton *button5 = [UIButton buttonWithType:UIButtonTypeCustom];
    button5.frame = CGRectOffset(button4.frame, 0, interval);
    [button5 setTitle:@"退出登录" forState:UIControlStateNormal];
    [button5 addTarget:self action:@selector(logoutAlipay:) forControlEvents:UIControlEventTouchUpInside];
    button5.backgroundColor = [UIColor blueColor];
    [self.view addSubview:button5];
}

- (void)openTinyApp:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"打开小程序"
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    [getDemoTinyAppList() enumerateObjectsUsingBlock:^(NSArray  *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [actionSheet addButtonWithTitle:obj[1]];
    }];
    [actionSheet showInView:self.view];
}


- (void)getAuthCode:(id)sender
{
    #ifdef ENABLE_ACCOUNT
    ANXAccountOpenAuthModel *model = [[ANXAccountOpenAuthModel alloc] init];
    [self configModel:model];
    
    // TODO: 接入方提供 AuthURL
    model.authURL = @"";
    model.phoneNum = nil;
    
    //    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    
    [[ANXInsideService sharedService] startServiceWithModel:model completion:^(NSDictionary<ANXCallbackKey *,id> *result, NSError *error) {
        if ([result[ANXProductConfigResultCodeKey] isEqualToString:@"account_open_auth_9000"]) {
            //授权成功，可以拿到authcode、app_id
            NSString *authcode = result[ANXProductConfigResultKey][@"auth_code"];
            NSLog(@"authcode = %@", authcode);
            [[[UIAlertView alloc] initWithTitle:@"getAuthCode"
                                        message:authcode
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:@"确定", nil] show];
        }
    }];
    #endif
}

- (void)setCurrentCookie:(id)sender
{
    NSString *domain = [[DTRpcClient defaultClient] configForScope:kDTRpcConfigScopeGlobal].gatewayURL.host;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[NSHTTPCookieName] = @"testCookieName";
    dict[NSHTTPCookieValue] = @"testCookieValue";
    dict[NSHTTPCookieDomain] = domain;
    dict[NSHTTPCookiePath] = @"/";
    NSHTTPCookie *mmstatCookie = [NSHTTPCookie cookieWithProperties:dict];
    if (mmstatCookie) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:mmstatCookie];
    }
}

- (void)getCurrentCookie:(id)sender
{
    NSString *domain = [[DTRpcClient defaultClient] configForScope:kDTRpcConfigScopeGlobal].gatewayURL.host;
    NSArray *cookieArray = [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies;
    NSMutableArray *cookies = [NSMutableArray array];
    for(NSHTTPCookie *cookie in cookieArray) {
        NSString *str = [NSString stringWithFormat:@"domain=%@^name=%@^value=%@", cookie.domain,cookie.name,cookie.value];
        [cookies addObject:str];
        if ([domain isEqualToString:cookie.domain]) {
            NSLog(@"");
        }
    }
}

- (void)unbindAlipay:(id)sender
{
#ifdef ENABLE_ACCOUNT
    // 当商户账号退出或切换账号时，都需要调用账号退出登录函数，告知账户通退出登录，然后再次进入账户通时重新授权和绑定
    ANXMCAccountStatusChangeModel *model = [ANXMCAccountStatusChangeModel new];
    model.status = MCAccountUnbind; // 账号解绑支付宝
    [[ANXInsideService sharedService] startServiceWithModel:model completion:^(NSDictionary<ANXCallbackKey *,id> *result, NSError *error) {
        NSLog(@"");
    }];
    // TODO: 使用账户通功能时对于 authcode、accesstoken 等的持久化或缓存需要一并清除
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    [userdefaults setObject:nil forKey:mp_user_id];
    [userdefaults setObject:nil forKey:mp_access_token];
    [userdefaults setObject:nil forKey:mp_mc_user_id];
    [userdefaults synchronize];
#endif
}

- (void)logoutAlipay:(id)sender
{
#ifdef ENABLE_ACCOUNT
    // 当商户账号退出或切换账号时，都需要调用账号退出登录函数，告知账户通退出登录，然后再次进入账户通时重新授权和绑定
    ANXMCAccountStatusChangeModel *model = [ANXMCAccountStatusChangeModel new];
    model.status = MCAccountLogout;   // 账号退出登录
    [[ANXInsideService sharedService] startServiceWithModel:model completion:^(NSDictionary<ANXCallbackKey *,id> *result, NSError *error) {
        NSLog(@"");
    }];
    // TODO: 使用账户通功能时对于 authcode、accesstoken 等的持久化或缓存需要一并清除
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    [userdefaults setObject:nil forKey:mp_user_id];
    [userdefaults setObject:nil forKey:mp_access_token];
    [userdefaults setObject:nil forKey:mp_mc_user_id];
    [userdefaults synchronize];
#endif
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        return; //cancel
    }
    NSArray *item = getDemoTinyAppList()[buttonIndex-1];
    if ([[item firstObject] isEqualToString:@"2018032302435038"]) {
#ifdef ENABLE_ACCOUNT
        [NBIAuthService shareInstance].delegate = self;
        [[NBIAuthService shareInstance] startTinyApp:item[0] uId:nil params:nil];
#else
        [MPNebulaAdapterInterface startTinyAppWithId:item[0] params:nil];
#endif
        return;
    }
    [MPNebulaAdapterInterface startTinyAppWithId:item[0] params:nil];

//    [[TinyAppManager sharedInstance] startAppWithId:item[0] params:@{@"appId":item[0],
//                                                                     @"debug":@"framework",
//                                                                     @"enableWK":@"NO"}];
}

- (void)openTinyAppForDebugMode:(id)sender
{
    [[MPDemoTinyScanHelper sharedInstance] startScanWithNavVc:self.navigationController];
}

#if ENABLE_ACCOUNT

#pragma mark NBIAuthDelegate

- (void)configModel:(ANXBaseServiceModel *)model
{
    model.scheme = PortalScheme;
    model.thirdAuth = YES;
}

- (void)getOnlineTokenWithMode:(NBIAuthMode)mode callback:(NBIAuthCallback)callback
{
    ANXAccountOpenAuthModel *model = [[ANXAccountOpenAuthModel alloc] init];
    [self configModel:model];
    
    // 未安装支付宝时的授权逻辑需要此处配置
    model.parentViewController = self;
    
    // TODO: 接入方提供 AuthURL
    model.authURL = @"xxx";
    model.phoneNum = nil;
    
//    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    
    [[ANXInsideService sharedService] startServiceWithModel:model completion:^(NSDictionary<ANXCallbackKey *,id> *result, NSError *error) {
        if ([result[ANXProductConfigResultCodeKey] isEqualToString:@"account_open_auth_9000"]) {
            //授权成功，可以拿到authcode、app_id
            NSString *authcode = result[ANXProductConfigResultKey][@"auth_code"];
            
            // 不持久化，authcode 使用一次就会失效
            //            [userdefaults setObject:authcode forKey:mp_auth_code];
            //            [userdefaults synchronize];
            
//            NSString *appId = result[ANXProductConfigResultKey][@"app_id"];
            NSDictionary *userInfo = @{@"behaviorCode" : @"AccountOpenAuth",
                                       @"params1" : result[ANXProductConfigResultKey]
                                       };
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ANX_Login_log" object:nil userInfo:userInfo];
            
            // TODO: 接入方提供获取 alipayUid、accessToken、mcUid 的接口
            // TODO: 注意 此处 网络请求和持久化 仅作为请求样例，实际使用根据接入方实际情况用自定义网络、内存、持久化均可，保证获取到数据
            NSString *urlStr = [NSString stringWithFormat:@"xxx%@", authcode];
            
            NSURL *url = [NSURL URLWithString:urlStr];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
            [request setTimeoutInterval:5];
            
            if (NSFoundationVersionNumber > 1000) {
                NSURLSession *session = [NSURLSession sharedSession];
                NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    NSMutableDictionary *dict = NULL;
                    if (nil == data) {
                        return;
                    }
                    dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                    NSString *alipayUid;
                    NSString *token;
                    NSString *mcUid;
                    if (dict) {
                        NSDictionary *token_response = [dict objectForKey:@"alipay_system_oauth_token_response"];
                        //                        alipayUid = [token_response objectForKey:@"user_id"];
                        //                        token = [token_response objectForKey:@"access_token"];
                        //                        mcUid = [token_response objectForKey:@"mc_user_id"];
                        if (token_response) {
                            alipayUid = [token_response objectForKey:@"user_id"];
                            token = [token_response objectForKey:@"access_token"];
                            mcUid = [token_response objectForKey:@"mc_user_id"];
                        } else {
                            alipayUid = [dict objectForKey:@"userId"];
                            token = [dict objectForKey:@"accessToken"];
                            mcUid = @"aaa";
                        }
                        
                        NBIAuthModel *model = [[NBIAuthModel alloc] init];
                        model.uid = alipayUid;
                        model.token = token;
                        model.extraInfo = @{@"mcUid": mcUid};
                        if(mode == NBIAuthModePlatformOnly) {
                            callback(model);
                            NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
                            [userdefaults setObject:alipayUid forKey:mp_user_id];
                            [userdefaults setObject:token forKey:mp_access_token];
                            [userdefaults setObject:mcUid forKey:mp_mc_user_id];
                            [userdefaults synchronize];
                        }
                    }
                }];
                [task resume];
            } else {
                [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
                    // 参考 上方代码开发 iOS10 以下兼容代码，此处省略
                }];
            }
        } else if ([result[ANXProductConfigResultCodeKey] isEqualToString:@"account_open_auth_6000"]) {
           NSLog(@"%@",result);
           NBIAuthModel *model = [[NBIAuthModel alloc] init];
           model.uid = nil;
           model.token = nil;
           model.extraInfo = nil;
           model.errorMsg = result[ANXProductConfigResultMemoKey];
           if(mode == NBIAuthModePlatformOnly) {
               callback(model);
           }
       }
    }];
}

- (NBIAuthModel *)getLocalTokenModelWithMode:(NBIAuthMode)mode
{
    NSString *alipayUid;
    NSString *token;
    NSString *mcUid;
    
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    alipayUid = [userdefaults objectForKey:mp_user_id];
    token = [userdefaults objectForKey:mp_access_token];
    mcUid = [userdefaults objectForKey:mp_mc_user_id];

    if (nil == alipayUid) {
        return nil;
    }
    if (nil == token) {
        return nil;
    }
    if (nil == mcUid) {
        return nil;
    }
    
    NBIAuthModel *model = [[NBIAuthModel alloc] init];
    model.uid = alipayUid;
    model.token = token;
    model.extraInfo = @{@"mcUid": mcUid};
    if(mode == NBIAuthModePlatformOnly) {
        return model;
    }
    return nil;
}

- (void)authModelForMode:(NBIAuthMode)mode extendParams:(NSDictionary *)extendParams callback:(NBIAuthCallback)callback {
    //    NeedRefreshToken == YES;
    //    账户通来保障是串型的，如果一直是NeedRefreshToken，那么就是要不断跳授权
    
    // TODO: 此处跳转支付宝获取授权然后获取 accessToken 等以及从本地持久化获取 accessToken 均为样例参考，实际情况接入方自定义
    if (YES == [[extendParams objectForKey:@"NeedRefreshToken"] boolValue]) {
        [self getOnlineTokenWithMode:mode callback:callback];
    } else {
        NBIAuthModel *model = [self getLocalTokenModelWithMode:mode];
        if (nil == model) {
            [self getOnlineTokenWithMode:mode callback:callback];
            return;
        }
        if(mode == NBIAuthModePlatformOnly) {
            callback(model);
        }
    }
}

#endif

@end
