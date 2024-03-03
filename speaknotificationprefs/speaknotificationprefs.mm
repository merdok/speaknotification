#import <Preferences/Preferences.h>
#import "./Helpers/MerdokAppList.h"
#import "../defines.h"
//#import "../MerdokHelper.h"

@interface speaknotificationprefsListController: PSListController {
}
@end

@implementation speaknotificationprefsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"speaknotificationprefs" target:self] retain];
	}
	return _specifiers;
}


- (void)followMe:(id)param
{
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tweetbot:///user_profile/merdok_dev"]];
    
    else if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitterrific:///profile?screen_name=merdok_dev" ]];
    
    else if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tweetings:///user?screen_name=merdok_dev" ]];
    
    else if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=merdok_dev" ]];
    
    else
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://mobile.twitter.com/merdok_dev" ]];

}


- (void)donate:(id)param
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=K2VPCQRCB2498"]];
}

/*
// get the whole cell for the spesicifed element with ID
-(UIView*) getCellForID: (NSString*) objId {
    
    // get whole cell view, example PSSliderTableCell
    return [[self specifierForID:objId] propertyForKey:@"cellObject"] ;
    
}


- (void) blockPrefs{
    
    int prefCount = [[self specifiers] count] ;
    
    for (int a = 0; a < prefCount; a++) {
        
        UIView *tempView = [[[self specifiers] objectAtIndex:a] propertyForKey:@"cellObject"] ;
        
        PSSpecifier* spec = [[self specifiers] objectAtIndex:a];
        
        if ([spec.name length] > 0) {
            spec.name = @"PIRATED" ;
        }
        
        tempView.userInteractionEnabled = NO ;
        tempView.alpha = 0.3f ;
        
    }
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([MerdokHelper kIsPirated] == NO) {
        return ;
    }
    
    // add the notification observer when the app becomes active (from backgroud)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(blockPrefs) name:UIApplicationDidBecomeActiveNotification object:nil];

    // wait 0.2 seconds for the view to load and then call the method
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        [self blockPrefs];
        
        [MerdokHelper showPiracyPopupOnController:self] ;
        
        
    });
    
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([MerdokHelper kIsPirated] == NO) {
        return ;
    }
    
    // remove the notification observer
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    
    if ([MerdokHelper kIsPirated] == NO) {
        return ;
    }
    
    [self blockPrefs];
    
}
*/
@end


@interface SpeechSpeakNotificationListController: PSListController {
}
-(UIView*) getViewForID: (NSString*) objId ;
@end

@implementation SpeechSpeakNotificationListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"SpeechSpeakNotification" target:self] retain];
	}
	return _specifiers;
}

// get the View for the spesicifed element with ID
-(UIView*) getViewForID: (NSString*) objId {
    
    // get only the UI element control, example, UISlider
    return [[self specifierForID:objId] propertyForKey:@"control"] ;
    
}

// get the whole cell for the spesicifed element with ID
-(UIView*) getCellForID: (NSString*) objId {
    
    // get whole cell view, example PSSliderTableCell
     return [[self specifierForID:objId] propertyForKey:@"cellObject"] ;
    
}



-(void) setSliderEnableDisable {
    
    UISlider* sliderObject = (UISlider*)[self getCellForID:@"speakvolume"] ;
    UISwitch* switchObject = (UISwitch*)[self getViewForID:@"usesystemvolume"] ;

    
    if ([switchObject isOn] == YES) {
        sliderObject.userInteractionEnabled = NO ;
        sliderObject.alpha = 0.3f ;
    }else {
        sliderObject.userInteractionEnabled = YES ;
        sliderObject.alpha = 1.0f ;
    }
   

}

// when pressing the use system volume button
-(void)setValue:(NSNumber*)something forSpecifier:(PSSpecifier*)spec {
    // set the original value of the preset and save it in the prefs
    [self setPreferenceValue:something specifier:spec];
    [self reloadSpecifier:spec];
    
    [[NSUserDefaults standardUserDefaults] synchronize];

    // enable disable the slider
    [self setSliderEnableDisable] ;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // add the notification observer when the app becomes active (from backgroud)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setSliderEnableDisable) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    // wait 0.1 seconds for the view to load and then call the method
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        [self setSliderEnableDisable] ;
        
    });

}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // remove the notification observer
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
}



@end


@interface SpeakConditionsListController: PSListController {
}
@end

@implementation SpeakConditionsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"SpeakConditionsListController" target:self] retain];
	}
    
    [[UISegmentedControl appearance] setTintColor:UiColorFromRGBA(250, 165, 28, 255)];
    
	return _specifiers;
}



// get the View for the spesicifed element with ID
-(UIView*) getViewForID: (NSString*) objId {
    
    // get only the UI element control, example, UISlider
    return [[self specifierForID:objId] propertyForKey:@"control"] ;
    
}

// get the whole cell for the spesicifed element with ID
-(UIView*) getCellForID: (NSString*) objId {
    
    // get whole cell view, example PSSliderTableCell
    return [[self specifierForID:objId] propertyForKey:@"cellObject"] ;
    
}



-(void) setEditTextsEnabled {
    
    UITextField* textWifi = (UITextField*)[self getCellForID:@"wifistring"] ;
    UITextField* textBt = (UITextField*)[self getCellForID:@"btstring"] ;
    UISwitch* switchWifi = (UISwitch*)[self getViewForID:@"wifiSpeakOnly"] ;
    UISwitch* switchBt = (UISwitch*)[self getViewForID:@"btSpeakOnly"] ;
    
    UISwitch* switchTime = (UISwitch*)[self getViewForID:@"enableTimeSpeak"] ;
    UITextField* startSel = (UITextField*)[self getCellForID:@"startTime"] ;
    UITextField* endSel = (UITextField*)[self getCellForID:@"endTime"] ;
    
    UISwitch* switchWeekday = (UISwitch*)[self getViewForID:@"weekdayspeak"] ;
    UITextField* weekdaySel = (UITextField*)[self getCellForID:@"weekdayselect"] ;
    
    
    if ([switchWifi isOn] == NO) {
        textWifi.userInteractionEnabled = NO ;
        textWifi.alpha = 0.3f ;
    }else {
        textWifi.userInteractionEnabled = YES ;
        textWifi.alpha = 1.0f ;
    }
    
    if ([switchBt isOn] == NO) {
        textBt.userInteractionEnabled = NO ;
        textBt.alpha = 0.3f ;
    }else {
        textBt.userInteractionEnabled = YES ;
        textBt.alpha = 1.0f ;
    }
    
    if ([switchTime isOn] == NO) {
        startSel.userInteractionEnabled = NO ;
        startSel.alpha = 0.3f ;
        endSel.userInteractionEnabled = NO ;
        endSel.alpha = 0.3f ;
    }else {
        startSel.userInteractionEnabled = YES ;
        startSel.alpha = 1.0f ;
        endSel.userInteractionEnabled = YES ;
        endSel.alpha = 1.0f ;
    }
    
    if ([switchWeekday isOn] == NO) {
        weekdaySel.userInteractionEnabled = NO ;
        weekdaySel.alpha = 0.3f ;
    }else {
        weekdaySel.userInteractionEnabled = YES ;
        weekdaySel.alpha = 1.0f ;
    }

    
}


// when pressing the use system volume button
-(void)setValue:(NSNumber*)something forSpecifier:(PSSpecifier*)spec {
    // set the original value of the preset and save it in the prefs
    [self setPreferenceValue:something specifier:spec];
    [self reloadSpecifier:spec];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // enable disable the slider
    [self setEditTextsEnabled] ;
    
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {

    [self setEditTextsEnabled] ;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // add the notification observer when the app becomes active (from backgroud)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setEditTextsEnabled) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    // wait 0.1 seconds for the view to load and then call the method
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        [self setEditTextsEnabled] ;
        
    });
    
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // remove the notification observer
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
}

@end



@interface SpeakOptionsListController: PSListController {
}
@end

@implementation SpeakOptionsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"SpeakOptionsListController" target:self] retain];
	}
	return _specifiers;
}


// get the whole cell for the spesicifed element with ID
-(UIView*) getCellForID: (NSString*) objId {
    
    // get whole cell view, example PSSliderTableCell
     return [[self specifierForID:objId] propertyForKey:@"cellObject"] ;
    
}

-(int) getValueForID: (NSString*) objId {
    
    // get the value of the specifier
    return [[[self specifierForID:objId] propertyForKey:@"value"] intValue] ;
    
}


-(void) setNoContactMsgEnableDisable {
    
    UITextField* textFieldObject = (UITextField*)[self getCellForID:@"nocontactstring"] ;
    
    
    
    if ([self getValueForID:@"nocontact"] != 3) {
        textFieldObject.userInteractionEnabled = NO ;
        textFieldObject.alpha = 0.3f ;
    }else {
        textFieldObject.userInteractionEnabled = YES ;
        textFieldObject.alpha = 1.0f ;
    }
    
    
}

// when pressing the use system volume button
-(void)setValue:(NSNumber*)something forSpecifier:(PSSpecifier*)spec {
    // set the original value of the preset and save it in the prefs
    [self setPreferenceValue:something specifier:spec];
    [self reloadSpecifier:spec];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // enable disable the slider
    [self setNoContactMsgEnableDisable] ;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // add the notification observer when the app becomes active (from backgroud)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNoContactMsgEnableDisable) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    // wait 0.1 seconds for the view to load and then call the method
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        [self setNoContactMsgEnableDisable] ;
        
    });
    
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // remove the notification observer
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
}


@end



@interface WeekdayListController: PSListController {
}
@end

@implementation WeekdayListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"WeekdayListController" target:self] retain];
	}
	return _specifiers;
}

@end

// for speak notification 2.0
//@interface MessageListController: PSListController <UIPickerViewDelegate, UIPickerViewDataSource>{
    
@interface MessageListController: PSListController{
    
    NSMutableArray *profileNameArray ;
    NSMutableArray *fileNameArray ;
    UIPickerView *picker ;
    
}
@end

@implementation MessageListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"MessageListController" target:self] retain];
	}
	return _specifiers;
}

// FOR SPEAK NOTIFICATION 2.0
/*
- (void)showProfileManagerBar
{
    
    [self showProfileManagerAtView:[self.navigationItem rightBarButtonItem]] ;
    
}

- (void)showProfileManagerBtn: (id) sender
{
    // view to attach the popover to
    UIButton* button = (UIButton*) [sender propertyForKey:@"cellObject"] ;
    
    [self showProfileManagerAtView:button] ;
    
}


- (void)showProfileManagerAtView: (id) view
{
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Notification custom message manager"
                                          message:@"You can create different custom messages for different apps. Deleting a message will remove the message permanently."
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {  }];
    
    UIAlertAction *loadAction = [UIAlertAction
                                 actionWithTitle:@"Edit"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction *action)
                                 {
                                     [self editCustomMessageBtn] ;
                                 }];
    
    
    UIAlertAction *saveAction = [UIAlertAction
                                 actionWithTitle:@"Create"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction *action)
                                 {
                                     [self createCustomMessageBtn] ;
                                 }];
    
    UIAlertAction *deleteAction = [UIAlertAction
                                   actionWithTitle:@"Delete"
                                   style:UIAlertActionStyleDestructive
                                   handler:^(UIAlertAction *action)
                                   {
                                       [self deleteCustomMessageBtn] ;
             
                                   }];
    
    [alertController addAction:saveAction];
    [alertController addAction:loadAction];
    [alertController addAction:deleteAction];
    [alertController addAction:cancelAction];
    
    if([view isKindOfClass:[UIBarButtonItem class]]) {
        alertController.popoverPresentationController.barButtonItem = (UIBarButtonItem*)view ;
    }else {
        
        UIView* tempView = (UIView*)view;
        
        alertController.popoverPresentationController.sourceView = tempView;
        alertController.popoverPresentationController.sourceRect = tempView.bounds;
    }
    
    [(UIViewController*)self presentViewController:alertController animated:YES completion:nil];
    
}

- (void) showInfoAlertWithTitle: (NSString*) title message: (NSString*) msg {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [alert release];
    
}

- (void) showActionAlertWithTitle: (NSString*) title message: (NSString*) msg button: (NSString*) btnName tag: (int) tager {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel" otherButtonTitles:btnName,nil];
    [alert setTag:tager] ;
    [alert show];
    [alert release];
    
}

- (void) showPickerAlertWithTile: (NSString*) title message: (NSString*) msg btnName: (NSString*) btnName tag: (int) tager {
    
    // get a list of all files from theme directory
    NSArray *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:kCustomMsgsLocation error:nil];
    
    // if no files and not save alert then show info and stop
    if ([fileList count]==0 && tager != kSaveAlert) {
        
        [self showInfoAlertWithTitle:@"Error" message:@"No saved custom messages found!"] ;
        return ;
    }
    
    // create temporary arrays
    profileNameArray = [NSMutableArray array] ;
    fileNameArray = [NSMutableArray array] ;
    
    // if save picker then load with number from 1 to 100, else load the files
    if (tager == kSaveAlert) {
        
        // app bundleIDS
        NSDictionary *applications = [[ALApplicationList sharedApplicationList] applicationsFilteredUsingPredicate:[NSPredicate predicateWithFormat:@"not (tags contains 'hidden')"]];

        
        // app names
        for (int a = 0; a<[applications.allKeys count]; a++) {
            
            NSString* ident = [applications.allKeys objectAtIndex:a] ;
            [profileNameArray addObject:applications[ident]] ;
            
        }
        
        
        // allocate data arrays ans sort the arrays
        profileNameArray = [[NSMutableArray alloc] initWithArray:[profileNameArray sortedArrayUsingSelector:@selector(localizedStandardCompare:)]];
        fileNameArray = [[NSMutableArray alloc] initWithArray:[applications keysSortedByValueUsingSelector:@selector(localizedStandardCompare:)]];
        
    }else {
        
        // load all files present in profile directory
        for (NSString *s in fileList){
            
            
            NSString *file = [NSString stringWithFormat:@"%@%@",kCustomMsgsLocation ,s] ;
            NSData *data = [NSData dataWithContentsOfFile:file];
            NSDictionary *tempDict = [NSKeyedUnarchiver unarchiveObjectWithData:data] ;
            
            NSString *profileName = [tempDict objectForKey:kProfileAppName] ;
            
            [profileNameArray addObject:profileName] ;
            [fileNameArray addObject:file] ;
            
        }
        
        // allocate data arrays ans sort the arrays
        profileNameArray = [[NSMutableArray alloc] initWithArray:profileNameArray];
        fileNameArray = [[NSMutableArray alloc] initWithArray:fileNameArray];
        
        
    }
    

    
    // show the picker
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:btnName, nil];
    
    picker = [[UIPickerView alloc]initWithFrame:CGRectMake(25, 30, 230, 60) ];
    picker.dataSource=self;
    picker.delegate=self;
    picker.showsSelectionIndicator = YES;
    // picker.backgroundColor=[UIColor blueColor];
    //  picker.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    [av setValue:picker forKey:@"accessoryView"];
    [av setTag:tager] ;
    [av show];
    
    [av release] ;
    
}



-(void) editCustomMessageBtn {
    
    [self showPickerAlertWithTile:@"Edit" message:@"For which app you want to edit the custom message?" btnName:@"Edit" tag:kLoadAlert] ;
}

-(void) createCustomMessageBtn  {
    
    [self showPickerAlertWithTile:@"Create" message:@"For which app you want to create a custom message?" btnName:@"Create" tag:kSaveAlert] ;
}


-(void) deleteCustomMessageBtn  {
    
    [self showPickerAlertWithTile:@"Delete" message:@"For which app you want to delete the custom message?" btnName:@"Delete" tag:kDeleteAlert] ;
}



- (void) saveCustomMessage: (NSString*) msg bundleID: (NSString*) bundleID appName: (NSString*) appName {
    
    
    // Check if the directory already exists
    if (![[NSFileManager defaultManager] fileExistsAtPath:kCustomMsgsLocation]) {
        // Directory does not exist so create it
        [[NSFileManager defaultManager] createDirectoryAtPath:kCustomMsgsLocation withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    // create the file
    NSString *file = [NSString stringWithFormat:@"%@%@", kCustomMsgsLocation, bundleID] ;
    
    // check if file already exists
    if ([[NSFileManager defaultManager] fileExistsAtPath:file]) {
        
        // if yes then remove it
        [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
    }
    
    
    NSMutableDictionary *saveDict = [[NSMutableDictionary alloc] init] ;
    [saveDict setObject:msg forKey:kProfileCustomMsg] ;
    [saveDict setObject:bundleID forKey:kProfileBundleID] ;
    [saveDict setObject:appName forKey:kProfileAppName] ;
    
    // create the data and save it into file
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:saveDict];
    [data writeToFile:file atomically:YES] ;
    
    [saveDict release] ;
    
}



-(void) createCustomMessage: (int) selectedProfile{
    
    //create file path
    NSString *file = [NSString stringWithFormat:@"%@%@", kCustomMsgsLocation, [fileNameArray objectAtIndex:selectedProfile]] ;
    
    
    // check if file already exists
    if ([[NSFileManager defaultManager] fileExistsAtPath:file]) {
        
        [self showInfoAlertWithTitle:@"Error" message:@"A custom message already exists for the specified app. Please use edit or delete it first!"] ;
            
        return ;
        
    }
    
    NSString* bundleID = [fileNameArray objectAtIndex:selectedProfile] ;
    NSString* appName = [profileNameArray objectAtIndex:selectedProfile] ;
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:appName
                                          message:@"Enter a text for the custom message!"
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = @"Custom message";
        [textField addTarget:self
                      action:@selector(alertTextFieldDidChange:)
            forControlEvents:UIControlEventEditingChanged];
    }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"Create"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   UITextField *textField = alertController.textFields.firstObject;
                                   
                                   [self saveCustomMessage:textField.text bundleID: bundleID appName:appName] ;
                                   
                                   [self showInfoAlertWithTitle:@"Done" message:[NSString stringWithFormat:@"The custom message for %@ was successfully created!", appName]] ;
                                   
                               }];
    
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {}];
    
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    okAction.enabled = NO;
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    [self cleanUpPickerAndRelodSpecifers] ;
    
 
}


-(void) editCustomMessage: (int) selectedProfile {
    
    //create file path
    NSString *file = [NSString stringWithFormat:@"%@", [fileNameArray objectAtIndex:selectedProfile]] ;
    
    NSString* custMsg = @"" ;
    NSString* bundleID = @"" ;
    NSString* appName = [profileNameArray objectAtIndex:selectedProfile] ;
    
    // if file exists then load the saved theme
    NSData *data = [NSData dataWithContentsOfFile:file];
    NSDictionary *tempDict = [NSKeyedUnarchiver unarchiveObjectWithData:data] ;
        
    custMsg = [tempDict objectForKey:kProfileCustomMsg] ;
    bundleID = [tempDict objectForKey:kProfileBundleID] ;

    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:appName
                                          message:@"Edit the custom message text."
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = @"Custom message";
        [textField addTarget:self
                      action:@selector(alertTextFieldDidChange:)
            forControlEvents:UIControlEventEditingChanged];
        textField.text = custMsg ;
    }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"Save"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   UITextField *textField = alertController.textFields.firstObject;
                                   
                                   [self saveCustomMessage:textField.text bundleID: bundleID appName:appName] ;
                                   
                                   [self showInfoAlertWithTitle:@"Done" message:[NSString stringWithFormat:@"The custom message for %@ was successfully modified!", appName]] ;
                                   
                               }];
    
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {}];
    
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    [self cleanUpPickerAndRelodSpecifers] ;
    
}

-(void) deleteCustomMessage: (int) selectedProfile {
    
    [[NSFileManager defaultManager] removeItemAtPath:[fileNameArray objectAtIndex:selectedProfile] error:NULL];
    
    [self showInfoAlertWithTitle:@"Done" message:[NSString stringWithFormat:@"The custom message for %@ was successfully deleted!", [profileNameArray objectAtIndex:selectedProfile]]] ;
    
    [self cleanUpPickerAndRelodSpecifers] ;
    
}




-(void) cleanUpPickerAndRelodSpecifers {
    
    //WAIT half second and relese the objects
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [fileNameArray release] ;
        [profileNameArray release] ;
        [picker release] ;
    });
    
}


- (void)alertTextFieldDidChange:(UITextField *)sender
{
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    if (alertController)
    {
        UITextField *login = alertController.textFields.firstObject;
        UIAlertAction *okAction = alertController.actions.lastObject;
        okAction.enabled = login.text.length > 0;
    }
}


- (NSInteger)numberOfComponentsInPickerView: (UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [profileNameArray count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [profileNameArray objectAtIndex:row] ;
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    //  NSLog(@"Selected theme: %@. Index of selected color: %d", [presetNameArray objectAtIndex:row], (int)row);
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag == kLoadAlert) {  // LOAD ALERT VIEW
        
        if (buttonIndex==1) {  // LOAD BUTTON WAS PRESSED
            [self editCustomMessage:[picker selectedRowInComponent:0]] ;
        }
        
    }else if (alertView.tag == kSaveAlert) {  // SAVE ALERT VIEW
        
        if (buttonIndex==1) { // OK PRESED,SAVE FILE
            [self createCustomMessage:[picker selectedRowInComponent:0]] ;
        }
        
    }else if (alertView.tag == kDeleteAlert) {  // DELETE ALERT VIEW
        
        if (buttonIndex==1) { // DELETE BUTTON WAS PRESSED
            [self deleteCustomMessage:[picker selectedRowInComponent:0]] ;
        }
        
    }


}


- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(showProfileManagerBar)];
    
    [self.navigationItem setRightBarButtonItem:barButton];
    
}
*/
@end



@interface ExtrasSpeakNotificationListController: PSListController {
}
@end

@implementation ExtrasSpeakNotificationListController
- (id)specifiers {
    if(_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"ExtrasSpeakNotification" target:self] retain];
    }
    return _specifiers;
}



@end


@interface VariablesSpeakNotificationListController: PSListController {
}
@end

@implementation VariablesSpeakNotificationListController
- (id)specifiers {
    if(_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"VariablesSpeakNotification" target:self] retain];
    }
    return _specifiers;
}



@end

@interface PerAppMessagesSpeakNotification: PSListController {
}
@end

@implementation PerAppMessagesSpeakNotification
- (id)specifiers {
    if(_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"PerAppMessagesSpeakNotification" target:self] retain];
    }
    return _specifiers;
}



-(NSArray*)valueAppDataFromTarget:(id)target {
    
    NSDictionary *applications = [[MerdokAppList sharedApplicationList] allNonHiddenApplications];
    
    //return applications.allKeys;
    
    //return the keys array sorted by value (app identifiers)
    return [applications keysSortedByValueUsingSelector:@selector(localizedStandardCompare:)];
    
}


-(NSArray*)titlesAppDataFromTarget:(id)target {
    
    NSMutableArray *titlesArray = [NSMutableArray array] ;
    
    NSDictionary *applications = [[MerdokAppList sharedApplicationList] allNonHiddenApplications];
    
    for (int a = 0; a<[applications.allKeys count]; a++) {
        
        NSString* ident = [applications.allKeys objectAtIndex:a] ;
        [titlesArray addObject:applications[ident]] ;
        
    }
    
    // return the titles array sorted by value (app names)
    return [titlesArray sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
    
}


-(void)setPerAppValue:(NSString*)something forSpecifier:(PSSpecifier*)spec {
    
    // set the original value of the preset and save it in the prefs
    [self setPreferenceValue:something specifier:spec];
    [self reloadSpecifier:spec];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    // ACTION WHEN SELECTING PER APP APP
    if ([spec.identifier isEqualToString:@"perappmsgapp"]) {
        
        NSString *tempMsg = @"" ;
        
        //create file path
        NSString *file = [NSString stringWithFormat:@"%@%@", kCustomMsgsLocation, something] ;
        
        // check if file exists
        if ([[NSFileManager defaultManager] fileExistsAtPath:file] == NO) {
            
            // if not exists then no theme saved so select disabled for the app as theme
            tempMsg = @"" ;
            
        }else {
            
            // if file exists then load the saved theme
            NSData *data = [NSData dataWithContentsOfFile:file];
            NSDictionary *tempDict = [NSKeyedUnarchiver unarchiveObjectWithData:data] ;
            
            tempMsg = [tempDict objectForKey:kProfileCustomMsg] ;
        }
        
        
        PSSpecifier* specMsg = [self specifierForID:@"perappmsgmsg"];
        
        [self setPreferenceValue:tempMsg specifier:specMsg];
        [self reloadSpecifier:specMsg];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    
    
    
    
    // ACTION WHEN SELECTING PER APP MSG
    if ([spec.identifier isEqualToString:@"perappmsgmsg"]) {
        
        // get the filename from the selected app sepcifier value
        NSString *filename = [[self specifierForID:@"perappmsgapp"] propertyForKey:@"value"] ;
        
        if ([filename isEqualToString:@""] || filename == nil) {
            return ;
        }
        
        // if empty string then remove the file
        if ([something isEqualToString:@""]) {
            
            [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", kCustomMsgsLocation, filename] error:nil];
            
            return ;
        }
        
        
        
        // Check if the directory already exists
        if (![[NSFileManager defaultManager] fileExistsAtPath:kCustomMsgsLocation]) {
            // Directory does not exist so create it
            [[NSFileManager defaultManager] createDirectoryAtPath:kCustomMsgsLocation withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        // create the file
        NSString *file = [NSString stringWithFormat:@"%@%@", kCustomMsgsLocation, filename] ;
        
        // check if file already exists
        if ([[NSFileManager defaultManager] fileExistsAtPath:file]) {
            
            // if yes then remove it
            [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
            
        }
        
        
        NSDictionary *applications = [[MerdokAppList sharedApplicationList] allNonHiddenApplications];
        
        NSString *appName = [applications objectForKey:filename];
        
        NSMutableDictionary *saveDict = [[NSMutableDictionary alloc] init] ;
        [saveDict setObject:something forKey:kProfileCustomMsg] ;
        [saveDict setObject:filename forKey:kProfileBundleID] ;
        [saveDict setObject:appName forKey:kProfileAppName] ;
        
        // create the data and save it into file
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:saveDict];
        [data writeToFile:file atomically:YES] ;
        
        [saveDict release] ;
     
    }
    
    
}

@end




#pragma mark ALTERNATE COLOR SWITCH DEFINITION
// custom class for alterante color switch
@interface PSSwitchTableCell : PSControlTableCell
-(id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3 ;
@end


@interface SpeakNotificationSwitchTableCell : PSSwitchTableCell //our class
@end

@implementation SpeakNotificationSwitchTableCell

-(id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3 { //init method
    self = [super initWithStyle:arg1 reuseIdentifier:arg2 specifier:arg3]; //call the super init method
    if (self) {
        [((UISwitch *)[self control]) setOnTintColor:UiColorFromRGBA(250, 165, 28, 255)]; //change the switch color
        [((UISwitch *)[self control]) setTintColor:UiColorFromRGBA(250, 165, 28, 255)]; //change the switch color
    }
    return self;
}

@end




// vim:ft=objc
