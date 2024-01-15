//
//  AppDelegate.h
//  OpenApiSample
//
//  Created by bongpro on 2017. 9. 30..
//  Copyright © 2017년 thejoin. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <JOpenApi/JOpenApi-Swift.h>

@interface AppDelegate : NSObject <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

extern JBLEManager *jBleManager;


- (void)startMain;

@end

