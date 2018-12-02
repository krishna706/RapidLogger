//  RapidLogger.m
//
//  Created by RadhaKrishna on 24/05/16.
//  Copyright © 2016 Radha. All rights reserved.

#import <UIKit/UIKit.h>
//check
#define LOG_ENABLED 

#define LOG_PATH  [NSString stringWithFormat:@"%@/Log",[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]]
#define CRASH_PATH [NSString stringWithFormat:@"%@/crashesList.plist",LOG_PATH]

#define LOG_SEPARATOR @"$#@#!()&*"
#define CRASH_STATUS_FIXED @"Fixed"
#define CRASH_STATUS_NOT_FIXED @"Not Fixed"



static NSString * const kKEY_CRASH_REPORT = @"CRASH_REPORT";
static NSString * const kKEY_ExceptionName = @"UnhandledExceptionName";
static NSString * const kKEY_ExceptionReason = @"UnhandledExceptionReason";
static NSString * const kKEY_ExceptionUserInfo = @"UnhandledExceptionUserInfo";
static NSString * const kKEY_ExceptionCallStack = @"UnhandledExceptionCallStack";
static NSString * const kKEY_ExceptionScreenshot = @"UnhandledExceptionScreenshot";
static NSString * const kKEY_ExceptionTimestamp = @"UnhandledExceptionTimestamp";
static NSString * const kKEY_ExceptionStatus = @"UnhandledExceptionStatus";

static NSOperationQueue *logQueue;


typedef enum : NSUInteger {
    LOGGER_API,
    LOGGER_DB,
    LOGGER_UI,
    LOGGER_ALL
} LoggerType;

@interface RapidLogger : UIViewController <UITableViewDelegate,UITableViewDataSource>
{

    NSTimer *recordTimer;
}
//Pass user values to store
@property (nonatomic, strong) NSMutableString *userId;
@property (nonatomic,strong) NSMutableArray *loggerArray,*searchArray;
@property BOOL isTableDisplay,isSearching,isCrashList;
@property BOOL isPresented,touchEnded;
@property (nonatomic, strong) NSString *logContent;
@property (nonatomic, strong) NSString *logPresentFileName,*selectedFilePath;
@property(nonatomic,strong) UITextView *txtView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property(nonatomic,strong) UIButton *loggerBtn;
@property(nonatomic,strong) UIViewController *mainController;


@property (nonatomic, strong) NSMutableArray *webLog,*allLog,*otherlog;

+(RapidLogger*)sharedController;
-(void)addLoggerButton;
-(void)hideLoggerButton;
-(void)addLogger:(NSString *)str;
-(void)printLog:(NSString*)msg;
@end



#ifdef  LOG_ENABLED
@interface NSObject (RapidLogger)
void NSLog(NSString *str,...);
__unused void unhandledExceptionHandler(NSException *exception);
void saveCrashReportWithDict(NSMutableDictionary *crashReport);

@end
#endif


