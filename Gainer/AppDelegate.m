//
//  AppDelegate.m
//  Gainer
//
//  Created by Gloryyin on 2020/10/17.
//  Copyright © 2020 Gloryyin. All rights reserved.
//

#import "AppDelegate.h"
#import "AvoidCrash.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSArray *noneSelClassStrings = @[
                              @"NSNull",
                              @"NSNumber",
                              @"NSString",
                              @"NSDictionary",
                              @"NSArray"
                              ];
    [AvoidCrash setupNoneSelClassStringsArr:noneSelClassStrings];
    return YES;
}



@end
