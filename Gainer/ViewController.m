//
//  ViewController.m
//  Gainer
//
//  Created by Gloryyin on 2020/10/17.
//  Copyright © 2020 Gloryyin. All rights reserved.
//

#import "ViewController.h"
#import "GNetworkManager.h"
#import "YCStorage.h"

#define PasswordKey(name) [name stringByAppendingString:@"_"]

@interface ViewController ()
@property (nonatomic, strong) NSArray * singleArrs;
@property (nonatomic, strong) NSArray * unsingleArrs;
@property (nonatomic, strong) NSString * token;
@property (nonatomic, strong) NSString * userId;

@property (nonatomic, strong) NSMutableArray * addNames;

@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *password;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _singleArrs = @[@"29448",@"29449",@"29450",@"29451",@"29452",@"29453",@"29454",@"29455",@"29456",@"29457"];
    _unsingleArrs = @[@"56880",@"59508",@"59509",@"59510",@"59515",@"61868",@"61869",@"61870",@"64269",@"64271"];
    
    NSString * name = [@"泡泡001" stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString * password = @"yyc090131221";
    [GNetworkManager getTokenWithUserName:name password:password completion:^(NSString * _Nonnull token) {
        _token = token;
        NSString * userId = [[NSUserDefaults standardUserDefaults] valueForKey:name];
        if (userId.length) {
            return;
        }
        [GNetworkManager getUserIdWithToken:token completion:^(NSString * _Nonnull userId) {
            NSLog(@"userId = %@",userId);
            [[NSUserDefaults standardUserDefaults] setValue:userId forKey:name];
            [[NSUserDefaults standardUserDefaults] setValue:password forKey:PasswordKey(name)];
            
//            [self bindWithUserId:userId token:_token];
            _userId = userId;
            [self checkContainsUser:name];
        }];
    }];
    
    NSTimer * timer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(getOpenOrder) userInfo:nil repeats:YES];
    [timer fire];
}

- (void)checkContainsUser:(NSString *)name {
    if (name.length) {
        if (![self.addNames containsObject:name]) {
            [self.addNames addObject:name];
            [YCStorage writeData:self.addNames toFilepath:SearchHistoryFilePath];
        }
        return;
    }
}

//MARK:全部绑定
- (IBAction)allBind:(id)sender {
    [self.view endEditing:YES];
    NSString * name = [_name.text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [GNetworkManager getTokenWithUserName:name password:_password.text completion:^(NSString * _Nonnull token) {
            
        _token = token;
        NSString * userId = [[NSUserDefaults standardUserDefaults] valueForKey:name];
        if (userId.length) {
            [self bindWithUserId:userId token:_token singleArrs:_singleArrs];
            return;
        }
        [GNetworkManager getUserIdWithToken:token completion:^(NSString * _Nonnull userId) {
            _userId = userId;
            [[NSUserDefaults standardUserDefaults] setValue:_userId forKey:name];
            [[NSUserDefaults standardUserDefaults] setValue:_password.text forKey:PasswordKey(name)];
            [self bindWithUserId:userId token:_token singleArrs:_singleArrs];
        }];
    }];
}

//MARK:全部解绑
- (IBAction)allUnbind:(id)sender {
    [self.view endEditing:YES];
    NSString * name = [_name.text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [GNetworkManager getTokenWithUserName:name password:_password.text completion:^(NSString * _Nonnull token) {
        _token = token;
        [self unbind:_token singleArrs:_singleArrs];
    }];
}

//MARK:获取信息
- (IBAction)getTokenAndId:(id)sender {
    [self.view endEditing:YES];
    NSString * name = [_name.text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [GNetworkManager getTokenWithUserName:name password:_password.text completion:^(NSString * _Nonnull token) {
            
        _token = token;
        [GNetworkManager getUserIdWithToken:token completion:^(NSString * _Nonnull userId) {
            _userId = userId;
            [[NSUserDefaults standardUserDefaults] setValue:_userId forKey:name];
            [[NSUserDefaults standardUserDefaults] setValue:_password.text forKey:PasswordKey(name)];
            
        }];
    }];
}

- (IBAction)add:(id)sender {
    [self.view endEditing:YES];
    [self checkContainsUser:_name.text];
    
}

- (IBAction)remove:(id)sender {
    [self.view endEditing:YES];
    [self checkContainsUser:_name.text];
}

//MARK:获取当前信号源开单
- (void)getOpenOrder {
    [GNetworkManager getOpenOrderListCompletion:^(id _Nonnull repond) {
        NSArray * orders = repond;
        NSMutableArray * array = [NSMutableArray new];
        for (NSDictionary * order in orders) {
            NSDictionary * user = [order valueForKey:@"user"];
            NSString * userId = [[user valueForKey:@"id"] stringValue];
            if ([_singleArrs containsObject:userId]) {
                [array addObject:userId];
            }
        }
        [self unBindAndBind:array];
        
    }];
}

//MARK:解绑所有并绑定当前信号源
- (void)unBindAndBind:(NSMutableArray *)origin_user_ids {
    for (NSString * name  in self.addNames) {
        NSString * password = [[NSUserDefaults standardUserDefaults] valueForKey:PasswordKey(name)];
        NSString * userId = [[NSUserDefaults standardUserDefaults] valueForKey:name];
        [GNetworkManager getTokenWithUserName:name password:password completion:^(NSString * _Nonnull token) {
            NSMutableArray * needUnBind = [NSMutableArray new];
            [GNetworkManager getPagePlan:userId token:token completion:^(NSArray * _Nonnull bindIds, NSArray * _Nonnull unBindIds) {
                //当前绑定的，如果没开单解除绑定
                for (int i = 0; i < bindIds.count; i++) {
                    NSString * idStr = bindIds[i];
                    if (![origin_user_ids containsObject:idStr]) {
                        [needUnBind addObject:unBindIds[i]];
                    }
                    else {
                        [origin_user_ids removeObject:idStr];
                    }
                }
                
                [self unbind:token singleArrs:needUnBind];
                [self bindWithUserId:userId token:token singleArrs:origin_user_ids];
            }];
            
        }];
    }
}


//MARK:绑定信号源
- (void)bindWithUserId:(NSString *)userId token:(NSString *)token singleArrs:(NSArray *)singleArrs{
    if (singleArrs.count == 0) {
        return;
    }
    NSArray * array_nums = @[@"-1",@"-1",@"-1",@"-1",@"-1",@"-1",@"-1",@"-1",@"-1",@"-1"];
    
    for (int i = 0; i < singleArrs.count; i++) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [GNetworkManager changeAgentPostsWithUserId:userId
                                                  token:token
                                 smallTransactionNumber:array_nums[i]
                                         origin_user_id:singleArrs[i]];
        });
        
    }
}

//MARK:解绑信号源
- (void)unbind:(NSString *)token singleArrs:(NSArray *)singleArrs{
    
    for (int i = 0; i < singleArrs.count; i++) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [GNetworkManager unbindWithId:singleArrs[i] token:token];
        });
        
    }
}



static NSString * SearchHistoryFilePath = @"SearchHistoryFilePath";

- (NSMutableArray *)addNames {
    if (!_addNames) {
        _addNames = [[NSMutableArray alloc]initWithArray:[YCStorage readDataFromFilepath:SearchHistoryFilePath]];
    }
    
    return _addNames;
}

@end
