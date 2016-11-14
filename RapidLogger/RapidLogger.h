//
//  RapidLogger.h
//  CreamStone
//
//  Created by RadhaKrishna on 24/05/16.
//  Copyright © 2016 Radha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RapidScreenRecorder.h"

#define LOG_ENABLED YES

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
    NSMutableArray *loggerArray,*searchArray;
    BOOL isTableDisplay,isSearching,isCrashList;
    NSTimer *recordTimer;
}
//Pass user values to store
@property (nonatomic, strong) NSMutableString *userId;

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

@end



#ifdef  LOG_ENABLED
@interface NSObject (RapidLogger)
void NSLog(NSString *str,...);
__unused void unhandledExceptionHandler(NSException *exception);
void saveCrashReportWithDict(NSMutableDictionary *crashReport);

@end
#endif


