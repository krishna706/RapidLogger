# RapidLogger
Rapid Logger captures all the log and able to display in device with neat UI.
And It also captures the crashes and display it in a Device it self with Stack symobols.
And using rapid logger we can create video of the App from the device itself.

# How to use it

1.Goto pch file and write below statement
  #import "RapidLogger.h"
2.In AppDelegate.m 
   -(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
       // Override point for customization after application launch.
    
       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
         [[RapidLogger sharedController] addLoggerButton];
       });
       return YES;
   }



