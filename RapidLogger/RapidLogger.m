//
//  RapidLogger.m
//  CreamStone
//
//  Created by RadhaKrishna on 24/05/16.
//  Copyright © 2016 Radha. All rights reserved.
//

#import "RapidLogger.h"

static RapidLogger* sharedInstance = nil;

@implementation RapidLogger

+(RapidLogger*)sharedController
{
    if (sharedInstance == nil)
    {
        sharedInstance = [[RapidLogger alloc] init];
        logQueue = [[NSOperationQueue alloc] init];
        
#ifdef  LOG_ENABLED
        NSSetUncaughtExceptionHandler(&unhandledExceptionHandler);

        
       if([[NSUserDefaults standardUserDefaults] objectForKey:kKEY_CRASH_REPORT])
       {
           saveCrashReportWithDict([[NSUserDefaults standardUserDefaults] objectForKey:kKEY_CRASH_REPORT]);
           [[NSUserDefaults standardUserDefaults] removeObjectForKey:kKEY_CRASH_REPORT];
       }
    }
#endif
    
    return sharedInstance;
}

- (void)viewDidLoad {
    self.title = @"Rapid Logger";
    isTableDisplay = YES;
    
   UIBarButtonItem *showListBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(showList)];
    UIBarButtonItem *optionsBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(optionsTapped)];

    self.navigationItem.rightBarButtonItems = @[optionsBtn,showListBtn];
    
    self.txtView = [[UITextView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.txtView];
    [self.txtView setFont:[UIFont systemFontOfSize:15.0]];
    self.txtView.editable = NO;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    loggerArray = [[NSMutableArray alloc] init];
    [self.view addSubview:self.tableView];
    [self.tableView setKeyboardDismissMode:UIScrollViewKeyboardDismissModeInteractive];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.searchBar.placeholder = @"Search Log here";
    [self.tableView setTableHeaderView:self.searchBar];
    self.searchBar.delegate = self;

    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    if(isCrashList)
        return;

    
    if(self.isPresented)
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTapped)];
    
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *mainLogPath = LOG_PATH;//[NSString stringWithFormat:@"%@/Log",docPath];
    
    
    
    NSArray *fileContents = [self getLogList];
    NSString *filePath =[NSString stringWithFormat:@"%@/%@",mainLogPath,fileContents[0]];

    [sharedInstance displayUIWithPath:filePath];
    if (self.loggerBtn)
        self.loggerBtn.hidden = YES;
}
-(void)viewWillDisappear:(BOOL)animated
{
    if (self.loggerBtn)
        self.loggerBtn.hidden = NO;
}
-(void)cancelTapped
{
    if(self.isPresented)
       [self dismissViewControllerAnimated:YES completion:nil];
    
    isCrashList = NO;
    isSearching = NO;
    loggerArray = [NSMutableArray new];
    [self.tableView reloadData];
}
-(void)shareTapped
{
    //Share purpose
    [self shareMessageText:self.txtView.text UrlStr:nil forController:self];
}
-(NSMutableArray *)getLogList
{
    NSMutableArray *logListArray = [NSMutableArray new];
    //NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *mainLogPath = LOG_PATH;//[NSString stringWithFormat:@"%@/Log",docPath];
    if(![[NSFileManager defaultManager] fileExistsAtPath:mainLogPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:mainLogPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    NSArray *fileContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:mainLogPath error:nil];
    for (NSInteger i = fileContents.count - 1 ; i >= 0 ; i--)
    {
        if([[fileContents[i] lastPathComponent] isEqualToString:@".DS_Store"] || ![fileContents[i] lastPathComponent] || [[fileContents[i] lastPathComponent].pathExtension isEqualToString:@"plist"])
            continue;
        
        if([[self getTodayFileName]  isEqualToString:[fileContents[i] lastPathComponent]])
            [logListArray insertObject:[fileContents[i] lastPathComponent] atIndex:0];
        else
            [logListArray addObject:[fileContents[i] lastPathComponent]];
    }

    return logListArray;
}
-(void)showList
{
    isCrashList = NO;
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *mainLogPath = [NSString stringWithFormat:@"%@/Log",docPath];

     NSArray *fileContents = [self getLogList];
    UIAlertController*alert = [UIAlertController alertControllerWithTitle:nil message:@"Select Log Date" preferredStyle:UIAlertControllerStyleActionSheet];
    BOOL firstOne = YES;
    
    for (NSInteger i = 0 ; i < fileContents.count ; i++)
    {
        NSString *fileName = fileContents[i];
        [alert addAction:[UIAlertAction actionWithTitle:fileName style:(i == 0)?UIAlertActionStyleDestructive:UIAlertActionStyleDefault handler:^(UIAlertAction*action)
                          {
                              [sharedInstance displayUIWithPath:[NSString stringWithFormat:@"%@/%@",mainLogPath,fileName]];
                            [alert dismissViewControllerAnimated:YES completion:nil];
                          }]];
        firstOne = NO;
    }
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction*action){
        [self.navigationController popViewControllerAnimated:YES];
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)hideLoggerButton
{
    [self.loggerBtn setHidden:YES];
}
-(void)optionsTapped
{
    UIAlertController*alertController = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Crashes List" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action)
                                {
                                    NSMutableArray *crashesArray = [NSMutableArray arrayWithContentsOfFile:CRASH_PATH];
                                    if (!crashesArray)
                                        [[[UIAlertView alloc] initWithTitle:@"Message" message:@"No Crashes" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                                    else
                                    {
                                        isCrashList = YES;
                                        loggerArray = crashesArray;
                                        [self.tableView reloadData];
                                        //self.txtView.text = [[crashesArray valueForKey:@"UnhandledExceptionReason"] componentsJoinedByString:@"\n\n\n\n\n\n"];
                                    }

                                    [alertController dismissViewControllerAnimated:YES completion:nil];
                                }]];
    
         [alertController addAction:[UIAlertAction actionWithTitle:@"Share Log" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action)
                                {
                                    [self shareTapped];
                                    [alertController dismissViewControllerAnimated:YES completion:nil];
                                }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Clear Log" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action)
                                {
                                    [@"" writeToFile:self.selectedFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                                     self.txtView.text = @"";
                                    isCrashList = NO;
                                    isSearching = NO;
                                    _searchBar.text = @"";
                                    loggerArray = [NSMutableArray new];
                                    [self.tableView reloadData];
                                    
                                    [alertController dismissViewControllerAnimated:YES completion:nil];
                                }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction*action)
                                {
                                    [alertController dismissViewControllerAnimated:YES completion:nil];
                                }]];

    
    [self presentViewController:alertController animated:YES completion:nil];

    
  
}
-(void)displayUIWithPath:(NSString *)path
{
    isCrashList = NO;
    self.selectedFilePath = path;
    NSString *fileContent = [NSString stringWithContentsOfFile:self.selectedFilePath encoding:NSUTF8StringEncoding error:nil];
    if(isTableDisplay)
    {
        loggerArray = [NSMutableArray arrayWithArray:[fileContent componentsSeparatedByString:LOG_SEPARATOR]];
        [loggerArray removeObjectAtIndex:0];
        
        [self.tableView reloadData];
        //self.txtView.text = fileContent;
    }
    else
    {
        fileContent = [fileContent stringByReplacingOccurrencesOfString:LOG_SEPARATOR withString:@""];
       self.txtView.text = fileContent;
    }
 }

-(void)addLogger:(NSString *)str
{
    if(!_logContent)
        _logContent = [[NSMutableString alloc] init];
    
        NSString *mainLogPath = LOG_PATH;
        if(![[NSFileManager defaultManager] fileExistsAtPath:mainLogPath])
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:mainLogPath withIntermediateDirectories:NO attributes:nil error:nil];
        }
        
        NSString *fileName = [self getTodayFileName];
        NSString *filePath = [NSString stringWithFormat:@"%@/%@",mainLogPath,fileName];
        if(0)
        {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"dd MMM HH:mm a ss.SSS : "];
            
            NSString *timeStamp = [formatter stringFromDate:[NSDate date]];
            //[logStr appendFormat:@"\n%@%@",timeStamp,str];
            _logContent = [NSString stringWithFormat:@"\n%@%@%@\n%@",LOG_SEPARATOR,timeStamp,str,_logContent];
            
            [_logContent writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
        else
        {
            //getting from File
            NSString *logStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
            if (!logStr)
                logStr = @"";
        
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"dd MMM HH:mm a ss.SSS : "];

            NSString *timeStamp = [formatter stringFromDate:[NSDate date]];
            //[logStr appendFormat:@"\n%@%@",timeStamp,str];
            logStr = [NSString stringWithFormat:@"\n%@%@%@\n%@",LOG_SEPARATOR,timeStamp,str,logStr];
            
            [logStr writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
}

#pragma mark Logger Button
-(void)addLoggerButton
{
    if (!self.loggerBtn)
    {
        NSLog(@"Welcome to the Rapid Logger.");
         self.loggerBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 100, 60, 60)];
        [self.loggerBtn setBackgroundColor:[UIColor redColor]];
        self.loggerBtn.alpha = 0.6;
        self.loggerBtn.hidden = NO;
        [self.loggerBtn.layer setCornerRadius:self.loggerBtn.frame.size.width/2];

        self.loggerBtn.tag = 8877;
        self.loggerBtn.userInteractionEnabled = YES;
        [self.loggerBtn addTarget:self action:@selector(loggerButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
     //   [self.loggerBtn addTarget:self action:@selector(imageTouch:withEvent:) forControlEvents:UIControlEventTouchDown];
        [self.loggerBtn addTarget:self action:@selector(imageMoved:withEvent:) forControlEvents:UIControlEventTouchDragInside];
        
        //Long Press
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressedOnButton:)];
        longPress.minimumPressDuration = 2.0;
        [self.loggerBtn addGestureRecognizer:longPress];
    }
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.loggerBtn];
    [[[UIApplication sharedApplication] keyWindow] bringSubviewToFront:self.loggerBtn];
}

- (IBAction) imageMoved:(id) sender withEvent:(UIEvent *) event
{
    self.touchEnded = YES;
    CGPoint point = [[[event allTouches] anyObject] locationInView:self.view];
    //point.x = point.x/2;
    //point.y = point.y/2;
    
    UIControl *control = sender;
    //NSLog(@"Logger Button Moved : %@",NSStringFromCGPoint(point));

    if(CGRectContainsPoint([UIScreen mainScreen].bounds, point))
    {
        if(![ASScreenRecorder sharedInstance].isRecording)
            control.alpha = 0.6;
        control.center = point;
    }
}
-(void)longPressedOnButton:(UILongPressGestureRecognizer *)longPress
{
    //NSLog(@"longPressedOnButton called");
    static BOOL showRecording;
    if(showRecording)
        return;
    showRecording = YES;
    self.mainController = [RapidLogger topMostController];

    [UIView animateWithDuration:0.5 animations:^{
        [(UIButton *)[longPress view] setAlpha:0.6];
    }];
    
    if([ASScreenRecorder sharedInstance].isRecording)
    {
        [self stopRecording];
        return;
    }
    UIAlertController*alertController = [UIAlertController alertControllerWithTitle:@"Do you want to Record the app flow" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action)
                                {
                                    [self startRecording];
                                    
       
                                    [alertController dismissViewControllerAnimated:YES completion:nil];
                                    showRecording = NO;
                                }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction*action)
                                {
                                    [alertController dismissViewControllerAnimated:YES completion:nil];
                                    showRecording = NO;
                                }]];
    [self.mainController presentViewController:alertController animated:YES completion:nil];
}

-(void)loggerButtonTapped:(UIButton *)btn
{
    if (self.touchEnded)
    {
        NSLog(@"Logger Button Ended Drag");
        [self bringLoggerButtonBackToPositionWithBtn:btn];

        return;
    }
    if([ASScreenRecorder sharedInstance].isRecording)
    {
        [self stopRecording];
        return;
    }
    self.mainController = [RapidLogger topMostController];
    
     [RapidLogger sharedController].isPresented = YES;
    [self.mainController presentViewController:[[UINavigationController alloc] initWithRootViewController:[RapidLogger sharedController]] animated:YES completion:nil];
}

-(void)bringLoggerButtonBackToPositionWithBtn:(UIButton *)btn
{
    self.touchEnded = NO;
    CGPoint point = btn.center;

    if(point.x > [UIScreen mainScreen].bounds.size.width/2)
        point.x = [UIScreen mainScreen].bounds.size.width - btn.frame.size.width/2;
    else
        point.x = btn.frame.size.width/2;
    
    
    [UIView animateWithDuration:0.5 animations:^{
        btn.center = point;
        if(![ASScreenRecorder sharedInstance].isRecording)
        btn.alpha = 0.6;
    }];

}


+ (UIViewController*)topMostController
{
    UIWindow *topWndow = [UIApplication sharedApplication].keyWindow;
    UIViewController *topController = topWndow.rootViewController;
    
    if (topController == nil)
    {
        // The windows in the array are ordered from back to front by window level; thus,
        // the last window in the array is on top of all other app windows.
        for (UIWindow *aWndow in [[UIApplication sharedApplication].windows reverseObjectEnumerator])
        {
            topController = aWndow.rootViewController;
            if (topController)
                break;
        }
    }
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}
-(NSString *)getTodayFileName
{
    if(self.logPresentFileName)
        return self.logPresentFileName;
    else
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd MMM HH:mm:ss"];
        self.logPresentFileName = [NSString stringWithFormat:@"%@.txt",[formatter stringFromDate:[NSDate date]]] ;
        return self.logPresentFileName;
    }
}
- (void)shareMessageText:(NSString *)text UrlStr:(NSString *)urlStr forController:(UIViewController *)mainController
{
    NSString *textToShare = text; //;
    
    NSArray *objectsToShare;
    if (urlStr)
    {
        if ([urlStr isKindOfClass:[NSString class]])
        {
            NSURL *myWebsite = [NSURL URLWithString:urlStr];
             objectsToShare = @[textToShare, myWebsite];
        }
        else if ([urlStr isKindOfClass:[UIImage class]])
        {
            objectsToShare = @[textToShare, urlStr];
        }
        else
            objectsToShare = @[textToShare];
    }
    else
        objectsToShare = @[textToShare];

    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo];
    
    activityVC.excludedActivityTypes = excludeActivities;
    
    [mainController presentViewController:activityVC animated:YES completion:nil];
}

#pragma mark UISearchBar Delegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    ///searchBar.showsCancelButton = YES;
    isSearching = YES;
    
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = NO;
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    isSearching = NO;
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"textDidChange called serch text is %@",searchText);
    if(searchText.length == 0)
    {
        searchArray = loggerArray;
        [self.tableView reloadData];
        
        return;
    }
    
    //beginswith , contains
    searchArray = [loggerArray filteredArrayUsingPredicate:
                   [NSPredicate predicateWithFormat:@"(SELF contains[cd] %@)", searchText]];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (isCrashList)
        return  loggerArray.count;

    if(isSearching)
        return searchArray.count;
    return loggerArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (isCrashList) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CrashCell"];
        if(!cell)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CrashCell"];
        float cellHeight = 300;
        
        //Image
        UIImageView *imgView = [cell viewWithTag:2];
        if(!imgView)
            imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width*0.2, self.view.frame.size.height*0.2)];
                //imgView.center = CGPointMake(imgView.center.x, cell.center.y);
        imgView.layer.cornerRadius = 2.0;
        imgView.tag = 2;
                imgView.layer.masksToBounds = YES;
        [cell addSubview:imgView];
        
        imgView.image = [UIImage imageWithData:[loggerArray[indexPath.row] valueForKey:kKEY_ExceptionScreenshot]];
        imgView.layer.borderWidth = 1.0;
        imgView.layer.borderColor = [[UIColor grayColor] CGColor];
        
        //Label
        UILabel *lblHeading = [cell viewWithTag:4];
        if(!lblHeading)
            lblHeading = [[UILabel alloc] initWithFrame:CGRectMake(imgView.frame.size.width + 15, 10, self.view.frame.size.width*0.7, 70)];
        lblHeading.text =[loggerArray[indexPath.row] valueForKey:kKEY_ExceptionReason];
        lblHeading.numberOfLines = 4;
        lblHeading.tag = 4;

        lblHeading.font = [UIFont systemFontOfSize:13];
        lblHeading.textColor = [UIColor redColor];
        [cell addSubview:lblHeading];

        
        //TextView
        NSString *textStr = [loggerArray[indexPath.row] valueForKey:kKEY_ExceptionCallStack];
        UITextView *txtView = [cell viewWithTag:3];
        if(!txtView)
            txtView = [[UITextView alloc] initWithFrame:CGRectMake(imgView.frame.size.width + 15, 10+lblHeading.frame.size.height, self.view.frame.size.width*0.7, cellHeight - 2*10 - lblHeading.frame.size.height)];
        txtView.editable =NO;
        txtView.tag = 3;
        [cell addSubview:txtView];


        txtView.text = textStr;
        cell.textLabel.text = @"";
        cell.detailTextLabel.text = @"";//[loggerArray[indexPath.row] valueForKey:kKEY_ExceptionReason];
        
        //Status
        //Fixed Image
        UILabel *lblFixed = [cell viewWithTag:6];
        if(!lblFixed)
            lblFixed = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
        
        if([[loggerArray[indexPath.row] valueForKey:kKEY_ExceptionStatus] isEqualToString:CRASH_STATUS_FIXED])
        {
            cell.contentView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
            cell.contentView.layer.borderWidth = 5;
            cell.contentView.alpha = 0.3;
            txtView.userInteractionEnabled  = NO;
            txtView.alpha  = 0.2;
            lblHeading.alpha = 0.2;


            

            lblFixed.center = CGPointMake(cell.center.x, cellHeight/2);
            lblFixed.tag = 6;
            lblFixed.text = @"FIXED";
            lblFixed.alpha = 0.8;
            lblFixed.textAlignment = NSTextAlignmentCenter;
            lblFixed.font = [UIFont boldSystemFontOfSize:50];
            lblFixed.transform = CGAffineTransformMakeRotation(270);//CGAffineTransformRotate(lblFixed.transform, 270);
            
            
            lblFixed.layer.borderColor = [[UIColor redColor] CGColor];
            lblFixed.layer.borderWidth = 8;
            lblFixed.layer.cornerRadius = lblFixed.frame.size.width/2;
            lblFixed.layer.masksToBounds = YES;
            

            lblFixed.textColor = [UIColor blackColor];
            
            [cell addSubview:lblFixed];
        }
        else
        {
            cell.contentView.layer.borderColor = [[UIColor grayColor] CGColor];
            cell.contentView.layer.borderWidth = 5;
            txtView.userInteractionEnabled  = YES;
            txtView.alpha  = 1.0;
            lblHeading.alpha = 1.0;
            cell.contentView.alpha = 1.0;
            [lblFixed removeFromSuperview];
        }
      
        return cell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        if(!cell)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        NSString *textStr;
        textStr = isSearching?searchArray[indexPath.row]:loggerArray[indexPath.row];
        NSString *dateStr = @"";
        if(textStr.length > 23)
        {
            dateStr = [textStr substringToIndex:23];
            textStr = [textStr substringFromIndex:25];
            for (int i = 0; i < (textStr.length>=3?3:0); i++) {
                NSString *firstChar = [textStr substringToIndex:1];
                if([firstChar isEqualToString:@"\n"])
                    textStr = [textStr substringFromIndex:1];
            }
      }
        
        cell.textLabel.text = textStr;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.numberOfLines = 3;
        [cell.textLabel setTextAlignment:NSTextAlignmentNatural];
        cell.detailTextLabel.text = dateStr;
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        return cell;
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isCrashList) {
        return 300;
    }
    return 85;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (isCrashList) {
        [self crashSelectedWith:indexPath];
    }
    else
    {
        NSString *textStr = isSearching?searchArray[indexPath.row]:loggerArray[indexPath.row];
        NSString *dateStr = @"";
        if(textStr.length > 23)
        {
            dateStr = [textStr substringToIndex:23];
            textStr = [textStr substringFromIndex:25];
        }
        
        UIAlertController*alertController = [UIAlertController alertControllerWithTitle:dateStr message:textStr preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Share" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action)
                                    {
                                        [self shareMessageText:textStr UrlStr:nil forController:self];
                                        [alertController dismissViewControllerAnimated:YES completion:nil];
                                    }]];

        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction*action)
                                    {
                                        [alertController dismissViewControllerAnimated:YES completion:nil];
                                    }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}
-(void)crashSelectedWith:(NSIndexPath *)indexPath
{
    NSString *textStr = [loggerArray[indexPath.row] valueForKey:kKEY_ExceptionCallStack];
    NSMutableArray *crashesArray = [NSMutableArray arrayWithContentsOfFile:CRASH_PATH];
    NSMutableDictionary *crashDict = [[NSMutableDictionary alloc] initWithDictionary:crashesArray[indexPath.row]];

    
    UIAlertController*alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Crash %ld",indexPath.row] message:textStr preferredStyle:UIAlertControllerStyleAlert];
    
    //        UIAlertAction *displayAction = [UIAlertAction actionWithTitle:@"" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action)
    //                                       {
    //                                           [alertController dismissViewControllerAnimated:YES completion:nil];
    //                                       }];
    //        [displayAction setValue:[[UIImage imageWithData:[loggerArray[indexPath.row] valueForKey:kKEY_ExceptionScreenshot]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]  forKey:@"image"];
    //
    //        [alertController addAction:displayAction];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Share" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action)
                                {
                                    [self shareMessageText:textStr UrlStr:[UIImage imageWithData:[loggerArray[indexPath.row] valueForKey:kKEY_ExceptionScreenshot]] forController:self];
                                    
                                    [alertController dismissViewControllerAnimated:YES completion:nil];
                                }]];
    
    if([crashDict[kKEY_ExceptionStatus] isEqualToString:CRASH_STATUS_FIXED])
    {
        [alertController addAction:[UIAlertAction actionWithTitle:@"Reopen Issue" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action)
                                    {
                                        [crashDict setObject:CRASH_STATUS_NOT_FIXED forKey:kKEY_ExceptionStatus];
                                        [crashesArray replaceObjectAtIndex:indexPath.row withObject:crashDict];
                                        [crashesArray writeToFile:CRASH_PATH atomically:YES];
                                        [alertController dismissViewControllerAnimated:YES completion:nil];
                                        [self loadCrashList];
                                    }]];
    }
    else
    {
        [alertController addAction:[UIAlertAction actionWithTitle:@"Issue Fixed?" style:UIAlertActionStyleDestructive handler:^(UIAlertAction*action)
                                    {
                                        [crashDict setObject:CRASH_STATUS_FIXED forKey:kKEY_ExceptionStatus];
                                        [crashesArray replaceObjectAtIndex:indexPath.row withObject:crashDict];
                                        [crashesArray writeToFile:CRASH_PATH atomically:YES];
                                        [alertController dismissViewControllerAnimated:YES completion:nil];
                                        [self loadCrashList];
                                    }]];
    }
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Delete this Issue" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action)
                                {
                                    [crashesArray removeObjectAtIndex:indexPath.row];
                                    [crashesArray writeToFile:CRASH_PATH atomically:YES];
                                    [alertController dismissViewControllerAnimated:YES completion:nil];
                                    [self loadCrashList];
                                }]];
    
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction*action)
                                {
                                    [alertController dismissViewControllerAnimated:YES completion:nil];
                                }]];
    [self presentViewController:alertController animated:YES completion:nil];
}
-(void)loadCrashList
{
    NSMutableArray *crashesArray = [NSMutableArray arrayWithContentsOfFile:CRASH_PATH];
    loggerArray = crashesArray;
    isCrashList = YES;
    [self.tableView reloadData];
}

#pragma mark Player Sounds
-(void)startRecording
{
    // [[[UIAlertView alloc] initWithTitle:@"Message" message:@"Recording Started" delegate:nil cancelButtonTitle:@"Okey" otherButtonTitles:nil] show];
    
    [UIView animateWithDuration:1.0 animations:^{
        [_loggerBtn setBackgroundColor:[UIColor greenColor]];
        [_loggerBtn setAlpha:0.5];
    }];
    if(recordTimer)
    {
        [recordTimer invalidate];
        recordTimer = nil;
    }
    recordTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(changeColorsForView:) userInfo:nil repeats:YES];
    
    [[ASScreenRecorder sharedInstance] startRecording];
}
-(void)changeColorsForView:(id)sender
{
    [_loggerBtn.layer removeAllAnimations];

    
    CAAnimation *animation = [NSClassFromString(@"CATransition") animation];
    [animation setValue:@"kCATransitionFade" forKey:@"type"];
    animation.duration = 1.0;
    [_loggerBtn.layer addAnimation:animation forKey:nil];
    NSInteger count = [_loggerBtn.titleLabel.text integerValue];
    count++;
    [_loggerBtn setTitle:[NSString stringWithFormat:@"%ld",count] forState:UIControlStateNormal];
//    [UIView animateWithDuration:1.0 animations:^{
//        [_loggerBtn setAlpha:0.6];
//    } completion:^(BOOL finished) {
//        [UIView animateWithDuration:1.0 animations:^{
//            [_loggerBtn setAlpha:1.0];
//        }];
//    }];
}

-(void)stopRecording
{
    if(recordTimer)
    {
        [recordTimer invalidate];
        recordTimer = nil;
    }
    if ([ASScreenRecorder sharedInstance].isRecording)
    {
        [_loggerBtn setTitle:@"" forState:UIControlStateNormal];

        [[ASScreenRecorder sharedInstance] stopRecordingWithCompletion:^{
            NSLog(@"Finished recording");
            [[[UIAlertView alloc] initWithTitle:@"Recording" message:@"Screen Video is saved in gallery!!!!" delegate:nil cancelButtonTitle:@"Okey" otherButtonTitles:nil] show];
            //[self playEndSound];
            
            [UIView animateWithDuration:2.0 animations:^{
                [_loggerBtn setBackgroundColor:[UIColor redColor]];
            }];
        }];
        return;
    }
}

//- (void)playStartSound
//{
//    NSURL *url = [NSURL URLWithString:@"/System/Library/Audio/UISounds/begin_record.caf"];
//    SystemSoundID soundID;
//    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID);
//    AudioServicesPlaySystemSound(soundID);
//}
//
//- (void)playEndSound
//{
//    NSURL *url = [NSURL URLWithString:@"/System/Library/Audio/UISounds/end_record.caf"];
//    SystemSoundID soundID;
//    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID);
//    AudioServicesPlaySystemSound(soundID);
//}


@end

#ifdef  LOG_ENABLED
@implementation NSObject (RapidLogger)

+ (UIImage *)screenshot {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGSize windowSize = [window bounds].size;
    
    UIGraphicsBeginImageContext(windowSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [window.layer renderInContext:context];
    
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return screenshot;
}
__unused void unhandledExceptionHandler(NSException *exception) {
    NSLog(@"Radha unhandledExceptionHandler called");
    NSMutableDictionary *crashReport = [NSMutableDictionary dictionary];
    crashReport[kKEY_ExceptionName] = exception.name;
    crashReport[kKEY_ExceptionReason] = exception.reason;
    crashReport[kKEY_ExceptionStatus] = CRASH_STATUS_NOT_FIXED;

    crashReport[kKEY_ExceptionUserInfo] = exception.userInfo ?: [NSNull null].debugDescription;
    crashReport[kKEY_ExceptionCallStack] = exception.callStackSymbols.debugDescription;
    
    UIImage *screenshot = [NSObject screenshot];
    if (screenshot)
        crashReport[kKEY_ExceptionScreenshot] = UIImagePNGRepresentation([UIImage screenshot]);
    
    //UUID
    crashReport[@"uuid"] = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    //userId
    if([RapidLogger sharedController].userId)
        crashReport[@"userId"] = [RapidLogger sharedController].userId;
    
     crashReport[kKEY_ExceptionTimestamp] = [NSDate date];
    
    [[RapidLogger sharedController] addLogger:@"\n\n\n\n\n\n\n*****Got a Crash*****"];
    saveCrashReportWithDict(crashReport);
}
void saveCrashReportWithDict(NSMutableDictionary *crashReport)
{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *mainLogPath = [NSString stringWithFormat:@"%@/Log",docPath];
    NSMutableArray *crashesArray = [NSMutableArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/crashesList.plist",mainLogPath]];
    if(!crashesArray)
        crashesArray = [NSMutableArray new];
    [crashesArray insertObject:crashReport atIndex:0];
    BOOL crashFileStatus = [crashesArray writeToFile:[NSString stringWithFormat:@"%@/crashesList.plist",mainLogPath] atomically:YES];
    NSLog(@"saveCrashReportWithDict called crashFileStatus is %d",crashFileStatus);
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithDictionary:crashReport] forKey:kKEY_CRASH_REPORT];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

void NSLog(NSString *format, ...)
{
    if (!format) {
        printf("nil\n");
        return;
    }

    va_list argList;
    va_start(argList, format);
    // Perform format string argument substitution, reinstate %% escapes, then print
    NSMutableString *s = [[NSMutableString alloc] initWithFormat:format arguments:argList];

    [s replaceOccurrencesOfString:@"%%"
                       withString:@"%%%%"
                          options:0
                            range:NSMakeRange(0, [s length])];
    
   // #if defined (DEBUG)
        printf("%s\n", [s UTF8String]);
        printf(".................................................\n");
    //#endif

    va_end(argList);
    
    
    if([RapidLogger sharedController].loggerBtn)
    {
        [logQueue setMaxConcurrentOperationCount:1];
        [logQueue addOperationWithBlock:^{
            [[RapidLogger sharedController] addLogger:s];
        }];
    }
}

@end
#endif

