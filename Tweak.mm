#import <CaptainHook/CaptainHook.h>
#import <CoreTelephony/CTCall.h>
#import "SpeakHelper.h"
#import "defines.h"
#import "classes.h"
#import <mach-o/dyld.h>
//#import "MerdokHelper.h"

static NSDictionary *preferences = nil;
static bool playNotifySound = YES ;
static bool disableVolumeHUD = NO ;
NSString *lastMsg = nil ;
int batteryLevel = 100;
int batteryLevelDif = 0;
bool speakBatteryLowLevelAllowed = YES ;
bool speakFullyChargedAllowed = YES ;
bool lastBatteryState = kBatteryStateNotCharging ;
bool canSpeakCallDuration = YES ;
static TUCall* lastCall = nil ;
bool canSpeakTouchID = YES ;
int dndState102 = 0 ;

NSString *lastSongTitle = nil ;
NSString *lastSongArtist = nil ;
NSString *lastSongAlbum = nil ;


//////////////// HELPER FUNCTIONS //////////////////
/*static bool getPref(NSString *pref, bool defaultValue) {
 
 NSNumber *numberPref = [preferences objectForKey:pref] ;
 bool isPrefEnabled = numberPref == nil ? defaultValue : [numberPref boolValue];
 
 return isPrefEnabled ;
 }
 */

#pragma mark GLOBAL HELPERS
static void logTextIntoFile(NSString* log){
    
    
    if (kLogEnabled==NO) {
        return ;
    }
    /*
    NSString *sLogTime = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterMediumStyle];
    
    NSString *logString = [NSString stringWithFormat:@"(%@)%@\n", sLogTime, log] ;
    
    NSString *locationFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"/Media/Downloads/log_speak.txt"] ;
    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:locationFilePath])
    {
        [logString writeToFile:locationFilePath atomically:YES encoding: NSUTF8StringEncoding error:nil];
    }
    else
    {
        NSFileHandle *myHandle = [NSFileHandle fileHandleForWritingAtPath:locationFilePath];
        [myHandle seekToEndOfFile];
        [myHandle writeData:[logString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    */
    
}

static void reloadPrefs() {
    
    logTextIntoFile([NSString stringWithFormat:@"Speak Notification: MAIN - reloading preferences main"]) ;
    
    
    //ios8
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        preferences = (id)CFPreferencesCopyMultiple(CFPreferencesCopyKeyList (TweakIdent, kCFPreferencesCurrentUser, kCFPreferencesAnyHost), TweakIdent, kCFPreferencesCurrentUser, kCFPreferencesAnyHost) ;
        
    }else{ // ios <= 7.1
        preferences = [[NSDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
        
    }
    
}


#pragma mark PREFERENCES
static NSString* getCustomMessage() {
    
    NSString *custMsg = [preferences objectForKey:@"msgstring"] ;
    
    if(custMsg==nil || [custMsg length]==0)
    {
        custMsg = @"%%APP%%: Message from %%TITLE%%: %%MSG%%";
    }
    
    return custMsg ;
    
}


static NSString* getPerAppCustomMessage(NSString* bundleID) {
    
    NSString *file = [NSString stringWithFormat:@"%@%@", kCustomMsgsLocation, bundleID] ;
    
    NSString *custMsg = nil ;
    
    // check if file exists
    if ([[NSFileManager defaultManager] fileExistsAtPath:file] == NO) {
        
        // if not exists then retrn nil
        custMsg = nil ;
        
    }else {
        
        // if file exists then load the saved message
        NSData *data = [NSData dataWithContentsOfFile:file];
        NSDictionary *tempDict = [NSKeyedUnarchiver unarchiveObjectWithData:data] ;
        
        custMsg = [tempDict objectForKey:kProfileCustomMsg] ;
    }
    
    if ([custMsg isEqualToString:@""]) {
        custMsg = nil ;
    }
    
    
    return custMsg ;
    
}


static float getDelay() {
    
    NSNumber *delayNumber = [preferences objectForKey:@"delay"];
    float delay = delayNumber == nil ? 0.0f : [delayNumber floatValue];
    
    return delay ;
    
    
}


static int getSpeakTimeInterval() {
    
    NSNumber *timeNumber = [preferences objectForKey:@"speaktime"];
    int time = timeNumber == nil ? 0 : [timeNumber intValue];
    
    return time ;
    
}

static NSString* getSpeakTimeMessage() {
    
    NSString *msg = [preferences objectForKey:@"msgstringtimespeak"] ;
    
    if(msg==nil || [msg length]==0)
    {
        msg = @"%%TIME%%";
    }
    
    return msg ;
    
}

static int getSpeakBatteryInterval() {
    
    NSNumber *speakBattery = [preferences objectForKey:@"speakbattery"] ;
    int speakBatteryLevel = speakBattery == nil ? 0 : [speakBattery intValue];
    
    return speakBatteryLevel ;
    
}

static bool isSpeakWhenFullyCharged() {
    
    NSNumber *speakWhenCharged = [preferences objectForKey:@"speakbatteryfull"] ;
    bool isSpeakWhenCharged = speakWhenCharged == nil ? NO : [speakWhenCharged boolValue];
    
    return isSpeakWhenCharged ;
    
}

static bool isSpeakWhenChargeStart() {
    
    NSNumber *speakWhenChargeStart = [preferences objectForKey:@"speakbatterychargestart"] ;
    bool isSpeakWhenChargeStart = speakWhenChargeStart == nil ? NO : [speakWhenChargeStart boolValue];
    
    return isSpeakWhenChargeStart ;
    
}

static NSString* getSpeakBatteryMessage() {
    
    NSString *msg = [preferences objectForKey:@"msgstringbatteryspeak"] ;
    
    if(msg==nil || [msg length]==0)
    {
        msg = @"Battery: %%BATTERY%%";
    }
    
    return msg ;
    
}



static bool isSpeakIncomingCall() {
    
    NSNumber *speakIncCall = [preferences objectForKey:@"speakincomingcall"] ;
    bool isSpeakIncomingCall = speakIncCall == nil ? NO : [speakIncCall boolValue];
    
    return isSpeakIncomingCall ;
    
}

static NSString* getSpeakIncomingCallMessage() {
    
    NSString *msg = [preferences objectForKey:@"msgstringincomingcallerspeak"] ;
    
    if(msg==nil || [msg length]==0)
    {
        msg = @"Incoming call from: %%NAME%%";
    }
    
    return msg ;
    
}

static bool isSpeakMissedCall() {
    
    NSNumber *activeNumber = [preferences objectForKey:@"speakmissedcall"] ;
    bool active = activeNumber == nil ? NO : [activeNumber boolValue];
    
    return active ;
    
}

static NSString* getSpeakMissedCallMessage() {
    
    NSString *msg = [preferences objectForKey:@"msgstringmissedcallspeak"] ;
    
    if(msg==nil || [msg length]==0)
    {
        msg = @"Missed call from: %%NAME%%";
    }
    
    return msg ;
    
}


static bool isSpeakCallDuration() {
    
    NSNumber *activeNumber = [preferences objectForKey:@"speakcallduration"] ;
    bool active = activeNumber == nil ? NO : [activeNumber boolValue];
    
    return active ;
    
}

static NSString* getSpeakCallDurationMessage() {
    
    NSString *msg = [preferences objectForKey:@"msgstringcalldurationspeak"] ;
    
    if(msg==nil || [msg length]==0)
    {
        msg = @"Call duration: %%DUR%% seconds";
    }
    
    return msg ;
    
}



static bool isSpeakCurrentSong() {
    
    NSNumber *speak = [preferences objectForKey:@"speakcurrentsong"] ;
    bool isSpeak = speak == nil ? NO : [speak boolValue];
    
    return isSpeak ;
    
}

static NSString* getSpeakCurrentSongMessage() {
    
    NSString *msg = [preferences objectForKey:@"msgstringcurrentsongspeak"] ;
    
    if(msg==nil || [msg length]==0)
    {
        msg = @"Now playing: %%SARTIST%% - %%STITLE%%";
    }
    
    return msg ;
    
}


static bool isRepeatSameMessages() {
    
    NSNumber *valueNumber = [preferences objectForKey:@"repeatmsg"] ;
    bool value = valueNumber == nil ? YES : [valueNumber boolValue];
    
    return value ;
    
}


static int getNoContactBehavior() {
    
    NSNumber *noContactNumber = [preferences objectForKey:@"nocontact"];
    int noContactBehavior = noContactNumber == nil ? 0 : [noContactNumber intValue];
    
    if (noContactBehavior < 0 || noContactBehavior > 3) {
        noContactBehavior = 0 ;
    }
    
    return noContactBehavior ;
    
}

static NSString* getNoContactBehaviorMessage() {
    
    NSString *msg = [preferences objectForKey:@"nocontactstring"] ;
    
    if(msg==nil || [msg length]==0)
    {
        msg = @"Unknown";
    }
    
    return msg ;
    
}


static bool isSpeakTouchIdSuccess() {
    
    NSNumber *success = [preferences objectForKey:@"touchidsuccess"] ;
    bool isSuccess = success == nil ? NO : [success boolValue];
    
    return isSuccess ;
    
}

static NSString* getTouchIdSuccessMessage() {
    
    NSString *msg = [preferences objectForKey:@"msgstringtouchidsuccess"] ;
    
    if(msg==nil || [msg length]==0)
    {
        msg = @"Authentication successful";
    }
    
    return msg ;
    
}


static bool isSpeakTouchIdFailed() {
    
    NSNumber *failed = [preferences objectForKey:@"touchidfailed"] ;
    bool isFailed = failed == nil ? NO : [failed boolValue];
    
    return isFailed ;
    
}

static NSString* getTouchIdFailedMessage() {
    
    NSString *msg = [preferences objectForKey:@"msgstringtouchidfailed"] ;
    
    if(msg==nil || [msg length]==0)
    {
        msg = @"Authentication failed";
    }
    
    return msg ;
    
}


static int getAppFilterType() {
    
    NSNumber *valueNumber = [preferences objectForKey:@"appfiltertype"];
    int value = valueNumber == nil ? kFilterBlacklist : [valueNumber intValue];
    
    return value ;
    
}

#pragma mark HELPER METHODS
static bool isDeviceLocked() {
    
    Class SBLockScreenManager = %c(SBLockScreenManager) ;
    bool deviceLocked = CHIvar([SBLockScreenManager sharedInstance], _isUILocked, _Bool ) ;
    
    return deviceLocked ;
    
}

static bool isDeviceInCall() {
    
    //ios11 freezes device so for now disabled
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0 && [[[UIDevice currentDevice] systemVersion] floatValue] < 12.0)
    {
        return NO;
    }
    
    bool callActive = NO ;
    
    // if ios12 or newer then use the new style
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 12.0)
    {
        // is any call active
        if ([[%c(TUCallCenter) sharedInstance] hasCurrentCalls]) {
            callActive = YES ;
        }
        
        // is a audio call active
        if ([[%c(TUCallCenter) sharedInstance] hasCurrentAudioCalls]) {
            callActive = YES ;
        }
        
        // is a video call active
        if ([[%c(TUCallCenter) sharedInstance] hasCurrentVideoCalls]) {
            callActive = YES ;
        }
        
        return callActive ;
    }
    
    //old stlye ios10 and lower
    // phone call or facetime audio call
    if ([[%c(SBTelephonyManager) sharedTelephonyManager] inCall] == YES) {
        callActive = YES ;
    }
    
    //ios8 only
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        // number of active facetime video calls
        if ([[%c(TUCallCenter) sharedInstance] currentVideoCallCount] > 0) {
            callActive = YES ;
        }
        
    }
    
    return callActive ;
    
}



static NSString* getAppName(NSString* bundleID) {
    
    NSString *appName = @"Unknow App" ;
    SBApplicationController* sbac = (SBApplicationController *)[%c(SBApplicationController) sharedInstance];
    
    
    //ios8 && ios9
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        appName = [[sbac applicationWithBundleIdentifier:bundleID] displayName];
        
    }else{ // ios < 8.0
        if ([[sbac applicationsWithBundleIdentifier:bundleID] count]>0) {
            appName = [[[sbac applicationsWithBundleIdentifier:bundleID] objectAtIndex:0] displayName];
        }
    }
    
    logTextIntoFile([NSString stringWithFormat:@"Speak Notification: Detected app name: - %@", appName]) ;
    
    return appName ;
    
}


static NSString* removeEmojiFromString(NSString* stringWithEmoji) {
    __block NSMutableString* temp = [NSMutableString string];
    
    [stringWithEmoji enumerateSubstringsInRange: NSMakeRange(0, [stringWithEmoji length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){
         
         const unichar hs = [substring characterAtIndex: 0];
         
         // surrogate pair
         if (0xd800 <= hs && hs <= 0xdbff) {
             const unichar ls = [substring characterAtIndex: 1];
             const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
             
             [temp appendString: (0x1d000 <= uc && uc <= 0x1f77f)? @"": substring]; // U+1D000-1F77F
             
             // non surrogate
         } else {
             [temp appendString: (0x2100 <= hs && hs <= 0x26ff)? @"": substring]; // U+2100-26FF
         }
     }];
    
    return temp;
}


static NSString* shouldRemovePhoneNumber(NSString* contactString) {

    // if speak then return the same string
    if (getNoContactBehavior()==kNoContactSpeak) {
        return contactString ;
    }
    
    // check if contact string contains a unknown phone number
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber error:nil];
    
    NSUInteger numberOfMatches = [detector numberOfMatchesInString:contactString
                                                           options:0
                                                             range:NSMakeRange(0, [contactString length])];
    
    // no phone number in contant string detected, return the same string
    if (numberOfMatches<=0) {
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: NO CONTACT - no phone number detected as sender/caller name, returning original string"]) ;
        
        return contactString ;
    }
    

    // if contact name contains phone number and dont speak enabled then return empty string
    if (getNoContactBehavior()==kNoContactDontSpeak) {
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: NO CONTACT - phone number detected as sender/caller name, no contact dont speak enabled, setting name to empty string"]) ;
        
        return @"" ;
    }
    
    // if contact name contains phone number and only last 4 digits enabled then return only the last 4 digits
    if (getNoContactBehavior()==kNoContactLast4) {
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: NO CONTACT - phone number detected as sender/caller name, no contact last 4 digits enabled, setting name to last 4 digits"]) ;
        
        NSString *trimmedString=[contactString substringFromIndex:MAX((int)[contactString length]-4, 0)];
        
        return trimmedString ;
    }
    
    // if contact name contains phone number and replacement string selected then use the replacement string
    if (getNoContactBehavior()==kNoContactReplace) {
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: NO CONTACT - phone number detected as sender/caller name, no contact replace with custom text enabled, replacing name with custom text"]) ;
        
        return getNoContactBehaviorMessage() ;
    }
    
    
    logTextIntoFile([NSString stringWithFormat:@"Speak Notification: NO CONTACT - phone number detected as sender/caller name but something went wrong, returning original string"]) ;
    
    //just in case if something goes wrong return original string
    return contactString ;
    
    
}



static NSString* removeURLSFromString(NSString* stringWithUrl) {

    NSString *temp = [NSString stringWithString:stringWithUrl] ;
    
    NSDataDetector *detect = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray *matches = [detect matchesInString:temp options:0 range:NSMakeRange(0, [temp length])];

    // check tha array backwards and remove all found urls
    for (NSTextCheckingResult *result in [matches reverseObjectEnumerator]) {
        
        NSString *urlString = [[result URL] absoluteString] ;
        
        // check if detected url contains www or http inside
        if ([urlString rangeOfString:@"www"].location != NSNotFound || [urlString rangeOfString:@"http"].location != NSNotFound) {
            
            logTextIntoFile([NSString stringWithFormat:@"Speak Notification: SPEAK - detected URL: %@, removing from message", [result URL]]) ;
            
            temp = [temp stringByReplacingCharactersInRange:[result range] withString:@""];
            
        }
        
    }
    
    [detect release] ;
    
    return temp;
}

static bool cancelSpeech(int pressedBtn) {
    
    
    // stop speaking when selected button is pressed
    NSNumber *buttonNumber = [preferences objectForKey:@"cancelbutton"];
    int cancelButton = buttonNumber == nil ? 2 : [buttonNumber intValue];
    
    // if disabled then do nothing
    if (cancelButton==0) {
        return false ;
    }
    
    bool stoppedSpeech = NO ;
    
    //else check which button was pressed and disable the speech
    if(cancelButton==1 || cancelButton==pressedBtn){
        
        stoppedSpeech = [SpeakHelper stopSpeaking] ;
        
    }
    
    // if speech stopped then log that
    if (stoppedSpeech) {
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: canceling speak out with button number: %d", pressedBtn]) ;
    }
    
    
    return stoppedSpeech ;
    
    
}



//////////////// HELPER FUNCTIONS END//////////////////



/*
 static bool betaTestEnabled() {
 
 NSMutableArray* uuidArray = [[NSMutableArray alloc] init];
 
 [uuidArray addObject:@"E2AE8996-C97D-4940-94E6-138D83A47E77"] ; // my ipad
 [uuidArray addObject:@"C5EE7963-9BD4-409D-992E-3D2D2D18C02F"] ; // xad, Frank Wittig
 [uuidArray addObject:@"BF225B15-D633-42DE-B777-7F61EAB999C8"] ; // dwain parke ip6
 
 
 
 NSDateFormatter *mmddccyy = [[NSDateFormatter alloc] init];
 mmddccyy.timeStyle = NSDateFormatterNoStyle;
 mmddccyy.dateFormat = @"MM/dd/yyyy";
 
 NSDate *today = [NSDate date]; // it will give you current date
 NSDate *newDate = [mmddccyy dateFromString:@"01/29/2014"];// your date
 
 NSComparisonResult result;
 //has three possible values: NSOrderedSame,NSOrderedDescending, NSOrderedAscending
 
 result = [today compare:newDate]; // comparing two dates
 
 if(result==NSOrderedAscending){
 // tweak should work do nothing
 
 
 
 }
 else if(result==NSOrderedDescending){
 // tweak expired disable it
 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Beta ended!" message:@"Sorry, the beta for this build has ended..." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
 [alert show];
 [alert release];
 
 return false ;
 
 }
 
 
 
 //check device uuid if is in the list
 NSString *myUUID = [[UIDevice currentDevice] identifierForVendor].UUIDString ;
 
 for (int a = 0; a<[uuidArray count]; a++) {
 
 if ([myUUID isEqualToString:[uuidArray objectAtIndex:a] ]) {
 
 return true ;
 
 }
 
 }
 
 
 // uuid not included, pirated copy stop
 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Beta not allowed" message:@"Sorry, your device is not allowed for the beta..." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
 [alert show];
 [alert release];
 
 return false ;
 
 
 }
 */



#pragma mark CONDITION CHECKS
static bool isAppEnabled(NSString *appIdentifier)  {
    
    // if app identifier is nil then app is enabled
    if (appIdentifier==nil) {
        return YES ;
    }
    
    // get the blocked apps list
    NSArray *enabledApps = [preferences objectForKey:@"enabledApps"] ;
    enabledApps = enabledApps == nil ? [NSArray array] : enabledApps ;
    
    //check if key for the specified app exists in the blocked apps list array
    bool isAppEnabled = [enabledApps containsObject:appIdentifier];
    
    // if blacklist filter enabled then speak only deselcted apps
    if (getAppFilterType() == kFilterBlacklist) {
        return !isAppEnabled ;
    }
    
    return isAppEnabled ;
    
}


static bool canSpeakWhenInOpenApp(SBApplication *app)  {
    
    // if app is nil then app can speak
    if (app==nil) {
        return YES ;
    }
    
    NSString *appIdentifier = [app bundleIdentifier];
    
    // get the blocked apps list
    NSArray *blockedApps = [preferences objectForKey:@"disableinopenapps"] ;
    blockedApps = blockedApps == nil ? [NSArray array] : blockedApps ;
    
    //check if key for the specified app exists in the blocked apps list array
    bool isAppDisabled = [blockedApps containsObject:appIdentifier];
    
    return !isAppDisabled ;

}


static bool isMessageFilterd(NSString *msg)  {
    
    // get the filter text
    NSString *sFilter = [preferences objectForKey:@"filterstring"] ;
    
    if(sFilter==nil || [sFilter length]==0)
    {
        return true ;
    }
    
    // make both strings lower so it is not case sensitive
    NSString *msgLower = [msg lowercaseString] ;
    
    // get all the separate words and pharses
    NSArray* filters = [sFilter componentsSeparatedByString: @","];
    
    //check if msg contains one of the pharses or words, if yes then dont speak
    for (int a=0; a<[filters count]; a++) {
        
        NSString *filterLower = [[filters objectAtIndex:a] lowercaseString] ;
        
        // if found then dont speak
        if ([msgLower rangeOfString:filterLower].location!=NSNotFound) {
            
            logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CONDITIONS - specified filter detected in message, not speaking"]) ;
            
            return false ;
            
        }
        
    }
    
    
    // if not found then speak
    return true ;
    
    
}



static bool isSpeakInMute()  {
    
    //if device is muted and speak while muted not enabled then stop
    NSNumber *speakMuted = [preferences objectForKey:@"mutedspeak"] ;
    bool isMutedSpeak = speakMuted == nil ? false : [speakMuted boolValue];
    
    bool isRingerMuted = NO;
    
    // if iOS13 then use the new class
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 13.0)
    {
        isRingerMuted = [[[NSClassFromString(@"SBMainWorkspace") sharedInstance] ringerControl] isRingerMuted];
    }else{
        // else use old style
        isRingerMuted = [[%c(SBMediaController) sharedInstance] isRingerMuted];
    }
        
    if(isRingerMuted==YES && !isMutedSpeak)
    {
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CONDITIONS - device muted and muted speak not enabled, not speaking"]) ;
        
        return false;
    }
    
    
    return true ;
    
    
}

static bool isSpeakInDND()  {
    
    
    //check if device is in DND mode
    Class SBBulletinSoundController = %c(SBBulletinSoundController) ;
    int stateDND =  [[SBBulletinSoundController sharedInstanceIfExists] quietModeState] ;
    
    // if iOS10 then use the global variable
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)
    {
        stateDND = dndState102 ;
    }
    
    //if device is in DND and speak while DND not enabled then stop
    NSNumber *speakDND = [preferences objectForKey:@"dndspeak"] ;
    bool isSpeakDND = speakDND == nil ? false : [speakDND boolValue];
    
    //device in DND when rozne od 0
    if (stateDND!=0 && !isSpeakDND) {
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CONDITIONS - device in DnD State and speak in DnD not enabled, not speaking"]) ;
        
        return false ;
    }
    
    
    return true ;
    
    
}




static bool isSpeakAtCurLocation() {
    
    
    // Speak only when at anywhere, locked, unlocked
    NSNumber *sSpeakMsgAt = [preferences objectForKey:@"speakAt"] ;
    int speakAt = sSpeakMsgAt == nil ? 0 : [sSpeakMsgAt intValue];
    
    // when locked but selected only unlocked then dont speak
    if (isDeviceLocked() && speakAt==kUnlocked) {
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CONDITIONS - device locked but only unlock speak selected, not speaking"]) ;
        
        return false ;
    }
    
    // when unlocked but selected only locked then dont speak
    if (!isDeviceLocked() && speakAt==kLocked) {
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CONDITIONS - device unlocked but only locked speak selected, not speaking"]) ;
        
        return false ;
    }
    
    return true ;
    
    
}


////////////// AND, OR CONDITIONS - START //////

static int onlyBtSpeak() {
    
    // Check if condition selected
    NSNumber *btSpeakOnlyEnabled = [preferences objectForKey:@"btSpeakOnly"] ;
    bool isBtSpeakOnly = btSpeakOnlyEnabled == nil ? false : [btSpeakOnlyEnabled boolValue];
    
    // if condition not selected then return not selected and stop
    if (isBtSpeakOnly == NO) {
        return kConditionNotSelected ;
    }
    
    // if bluetooth not connected and only bt speak enabled then dont speak
    Class BluetoothManager = %c(BluetoothManager) ;
    
    if([[BluetoothManager sharedInstance] connected]==NO) {
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CONDITIONS - bluetooth only speak enabled but no bluetooth device connected, condition NOT MET, can't speak"]) ;
        
        return kConditionNotMet;
    }
    
    
    
    // get the device name
    NSString *sBtName = [preferences objectForKey:@"btstring"] ;
    
    if(sBtName==nil || [sBtName length]==0)
    {
        sBtName = nil;
    }
    
    
    // if BT connected with a device and no device name specified then speak
    if([[BluetoothManager sharedInstance] connected]==YES && sBtName==nil)
    {
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CONDITIONS - connected to a bluetooth device and no device specified (speak all devices), condition MET, can speak"]) ;
        
        return kConditonMet ;
    }
    
    bool isDeviceOnList = false ;
    
    // the the connected devices list
    NSArray *btDevices = [[BluetoothManager sharedInstance] connectedDevices] ;
    
    for (int a = 0; a<[btDevices count]; a++) {
        
        BluetoothDevice *device = [btDevices objectAtIndex:a] ;
        
        NSString *deviceNameLower = [[device name] lowercaseString] ;
        NSString *btNameLower = [sBtName lowercaseString] ;
        
        // if device is on the list then mark as can speak
        if ([[BluetoothManager sharedInstance] connected]==YES && [btNameLower rangeOfString:deviceNameLower].location!=NSNotFound) {
            isDeviceOnList = YES ;
            
        }
        
        
    }
    
    
    // if no device found which is on the list then dont speak
    if (isDeviceOnList == NO) {
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CONDITIONS - connected to a bluetooth device but device not on specified list, condition NOT MET, can't speak"]) ;
        
        return kConditionNotMet ;
    }
    
    
    logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CONDITIONS - connected to a bluetooth device and device id on the specified list, condition MET, can speak"]) ;
    
    return kConditonMet ;
    
    
}


static int onlyWiFiSpeak() {
    
    // Check if condition selected
    NSNumber *wifiSpeakEnabled = [preferences objectForKey:@"wifiSpeakOnly"] ;
    bool isWifiSpeakOnly = wifiSpeakEnabled == nil ? false : [wifiSpeakEnabled boolValue];
    
    // if condition not selected then return not selected and stop
    if (isWifiSpeakOnly == NO) {
        return kConditionNotSelected ;
    }
    
    
    Class CUTWiFiManager = %c(CUTWiFiManager) ;
    
    // if WiFI not connected to a network and only wifi speak enabled then dont speak
    if([[CUTWiFiManager sharedInstance] isWiFiAssociated]==NO)
    {
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CONDITIONS - WiFi not connected but WiFi only speak enabled, condition NOT MET, can't speak"]) ;
        
        return kConditionNotMet;
    }
    
    
    // get the network name
    NSString *sWifiName = [preferences objectForKey:@"wifistring"] ;
    
    if(sWifiName==nil || [sWifiName length]==0)
    {
        sWifiName = nil;
    }
    
    
    // if wifi associated with a newtork and no network name specified then speak
    if([[CUTWiFiManager sharedInstance] isWiFiAssociated]==YES && sWifiName==nil)
    {
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CONDITIONS - connected to a wifi network and no network specified (speak all networks), condition MET, can speak"]) ;
        
        return kConditonMet ;
    }
    
    NSString *ssidNameLower = [[[CUTWiFiManager sharedInstance] currentSSID] lowercaseString] ;
    NSString * wifiNameLower = [sWifiName lowercaseString] ;
    
    
    
    // if wifi associated with a newtork and network name is in the specified list then speak
    if([[CUTWiFiManager sharedInstance] isWiFiAssociated]==YES && [wifiNameLower rangeOfString:ssidNameLower].location==NSNotFound)
    {
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CONDITIONS - connected to a wifi network but network not on specified list, condition NOT MET, can't speak"]) ;
        
        return kConditionNotMet ;
    }
    
    
    logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CONDITIONS - connected to a wifi network and network is on the specified list, condition MET, can speak"]) ;
    
    return kConditonMet ;
    
    
}


static int onlyEarphoneSpeak() {
    
    // Check if condition selected
    NSNumber *headphonesSpeakEnabled = [preferences objectForKey:@"headphoneSpeakOnly"] ;
    bool isHeadphonesSpeakOnly = headphonesSpeakEnabled == nil ? false : [headphonesSpeakEnabled boolValue];
    
    // if condition not selected then return not selected and stop
    if (isHeadphonesSpeakOnly == NO) {
        return kConditionNotSelected ;
    }
    
    if([[%c(VolumeControl) sharedVolumeControl] headphonesPresent]==YES) {
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CONDITIONS - only when earhpones are present selected and earphones connected, condition MET, can speak"]) ;
        
        return kConditonMet;
        
    }
    
    logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CONDITIONS - only when earhpones are present selected and no earphones connected, condition NOT MET, can't speak"]) ;
    
    
    return kConditionNotMet ;
    
    
}


static int getDif(int start, int end) {
    
    int dif = 0 ;
    
    while (true) {
        
        start++ ;
        
        if (start>23) {
            start = 0 ;
        }
        
        dif++ ;
        
        if (start==end) break;
        
    }
    
    
    return dif ;
    
    
}


static int onlySpeakInTimeRange()  {
    
    // Check if condition selected
    NSNumber *timeSpeakEnabled = [preferences objectForKey:@"enableTimeSpeak"] ;
    bool isTimeSpeakEnabled = timeSpeakEnabled == nil ? false : [timeSpeakEnabled boolValue];
    
    // if condition not selected then return not selected and stop
    if (isTimeSpeakEnabled == NO) {
        return kConditionNotSelected ;
    }
    
    
    // if enabled then check if the current time is in the specified time range
    NSNumber *startTimeNumber = [preferences objectForKey:@"startTime"];
    int startTime = startTimeNumber == nil ? 8 : [startTimeNumber intValue];
    
    NSNumber *endTimeNumber = [preferences objectForKey:@"endTime"];
    int endTime = endTimeNumber == nil ? 20 : [endTimeNumber intValue];
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH"];
    
    NSString *currentTimeString = [formatter stringFromDate:[NSDate date]];
    int currentTime =  [currentTimeString intValue] ;
    
    [formatter release];
    
    
    if (startTime > endTime) {
        
        int timeDif = getDif(startTime, endTime) ;
        int currentDif = getDif(currentTime, endTime) ;
        
        if (currentDif <= timeDif) {
            
            logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CONDITIONS - only on specified time selected and current time is in time range 1, condition MET, can speak"]) ;
            
            return kConditonMet ;
        }
        
        
    }
    
    
    if (currentTime >= startTime && currentTime < endTime)
    {
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CONDITIONS - only on specified time selected and current time is in time range 2, condition MET, can speak"]) ;
        
        return kConditonMet ;
    }
    
    logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CONDITIONS - only on specified time selected and current time not in time range, condition NOT MET, can't speak"]) ;
    
    
    return kConditionNotMet ;
    
    
}


static int onlySpeakInWeekday()  {
    
    // Check if condition selected
    NSNumber *weekdaySpeak = [preferences objectForKey:@"weekdayspeak"] ;
    bool isWeekdaySpeak = weekdaySpeak == nil ? false : [weekdaySpeak boolValue];
    
    // if condition not selected then return not selected and stop
    if (isWeekdaySpeak == NO) {
        return kConditionNotSelected ;
    }
    
    NSArray *weekdays = [NSArray arrayWithObjects:@"weekdaysun",@"weekdaymon",@"weekdaytue",@"weekdaywed",@"weekdaythu",@"weekdayfri",@"weekdaysat",nil];
    
    
    NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian] autorelease];
    NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    int weekdayToday = [comps weekday];
    
    
    //check the todays weekday if enabled
    NSNumber *weekday = [preferences objectForKey:[weekdays objectAtIndex:weekdayToday-1]] ;
    bool isWeekday = weekday == nil ? false : [weekday boolValue];
    
    if (isWeekday) {
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CONDITIONS - only on specified weekdays selected and today enabled, condition MET, can speak"]) ;
        
        return kConditonMet ;
    }
    
    logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CONDITIONS - only on specified weekdays selected and today not enabled, condition NOT MET, can't speak"]) ;
    
    
    return kConditionNotMet ;
    
    
    
}

static int onlyWhenBatteryCharging() {
    
    // Check if condition selected
    NSNumber *sSpeakOnlyCharging = [preferences objectForKey:@"onlybatterycharge"] ;
    bool isChargingSpeakOnly = sSpeakOnlyCharging == nil ? NO : [sSpeakOnlyCharging boolValue];
    
    // if condition not selected then return not selected and stop
    if (isChargingSpeakOnly == NO) {
        return kConditionNotSelected ;
    }
    
    if ([[ %c(SBUIController) sharedInstance] isOnAC] == YES) {
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CONDITIONS - only when battery is charging selected and battery charging, condition MET, can speak"]) ;
        
        return kConditonMet ;
    }
    
    logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CONDITIONS - only when battery is charging selected and battery not charging, condition NOT MET, can't speak"]) ;
    
    return kConditionNotMet ;
    
}


 
static int onlyWhenMusicNotPlaying() {
    
    // Check if condition selected
    NSNumber *sSpeakOnlyNoMusicPlay = [preferences objectForKey:@"onlynomusicplay"] ;
    bool isNoMusicPlaySpeakOnly = sSpeakOnlyNoMusicPlay == nil ? NO : [sSpeakOnlyNoMusicPlay boolValue];
    
    // if condition not selected then return not selected and stop
    if (isNoMusicPlaySpeakOnly == NO) {
        return kConditionNotSelected ;
    }
    
    if ([[%c(SBMediaController) sharedInstance] isPlaying] == NO) {
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CONDITIONS - only when no music is playing selected and music is not playing, condition MET, can speak"]) ;
        
        return kConditonMet ;
    }
    
    logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CONDITIONS - only when no music is playing selected and music is playing, condition NOT MET, can't speak"]) ;
    
    return kConditionNotMet ;
    
}




static bool isAndOrConditionsMet() {
    
    // if no condtions are selected then can speak
    if (onlyBtSpeak() == kConditionNotSelected &&
        onlyWiFiSpeak() == kConditionNotSelected &&
        onlyEarphoneSpeak() == kConditionNotSelected &&
        onlySpeakInTimeRange() == kConditionNotSelected &&
        onlySpeakInWeekday() == kConditionNotSelected &&
        onlyWhenBatteryCharging() == kConditionNotSelected &&
        onlyWhenMusicNotPlaying() == kConditionNotSelected) {
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CONDITIONS - speaking - no and, or conditions selected"]) ;
        
        return true ;
    }
    
    
    //check if all conditions must be met is eanbled
    NSNumber *allConditionsReq = [preferences objectForKey:@"allConditionsReq"] ;
    bool allConditions = allConditionsReq == nil ? false : [allConditionsReq boolValue];
    
    // if all conditions must be met then check if all are met
    if (allConditions) {
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CONDITIONS - all conditions must be met is enabled, checking if all selected conditions are met"]) ;
        
        // if a condition is not met then it means it is selcted and not met therfore dont speak
        if (onlyBtSpeak() == kConditionNotMet ||
            onlyWiFiSpeak() == kConditionNotMet ||
            onlyEarphoneSpeak() == kConditionNotMet ||
            onlySpeakInTimeRange() == kConditionNotMet ||
            onlySpeakInWeekday() == kConditionNotMet ||
            onlyWhenBatteryCharging() == kConditionNotMet ||
            onlyWhenMusicNotPlaying() == kConditionNotMet) {
            
            logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CONDITIONS - not speaking - a condition is not met, all must be met"]) ;
            
            return false ;
        }
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CONDITIONS - speaking - all selected conditions are met"]) ;
        
        return true ;
        
    }
    
    // if at least one condtion is selected and the conditons is met then speak else dont speak
    
    logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CONDITIONS - at least one selected condition must be met, checking if any selected conditions is met"]) ;
    
    if (onlyBtSpeak() == kConditonMet ||
        onlyWiFiSpeak() == kConditonMet ||
        onlyEarphoneSpeak() == kConditonMet ||
        onlySpeakInTimeRange() == kConditonMet ||
        onlySpeakInWeekday() == kConditonMet ||
        onlyWhenBatteryCharging() == kConditonMet ||
        onlyWhenMusicNotPlaying() == kConditonMet) {
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CONDITIONS - speaking - at least one condition is selected and met"]) ;
        
        return true ;
    }else{
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CONDITIONS - not speaking - no condition met, at least one must be met"]) ;
        return false ;
    }

    
    
}

////////////// AND, OR CONDITIONS - END //////


static bool canSpeak(NSString *msg, NSString* appId, int repeat)  {
    
    //  if(!betaTestEnabled()) {
    
    //    playNotifySound = YES ;
    //     return false ;
    
    // }
    
    bool repeatSameMsg = isRepeatSameMessages() ;

    if (repeat == kSpeakSameForceNo) {
        repeatSameMsg = NO ;
    }else if(repeat == kSpeakSameForceYes){
        repeatSameMsg = YES ;
    }
    
    logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CONDITIONS - ===checking conditions if can speak==="]) ;
    
    
    //tweak enabled? then dont speak ( move enabled to a different place so it doesnt interfere with the conditions???)
    NSNumber *tweakEnabled = [preferences objectForKey:@"enabled"] ;
    bool isEnabled = tweakEnabled == nil ? true : [tweakEnabled boolValue];
    
    if(!isEnabled) {
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CONDITIONS - not speaking - tweak disabled"]) ;
        return false;
    }
    
    // if is in a phone call right now, dont speak
    if (isDeviceInCall()) {
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CONDITIONS - not speaking - is in phone or facetime call"]) ;
        return false;
    }
    
    // msg is empty --- dont speak but enable notification sound
    if (msg==nil) {
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CONDITIONS - not speaking - message empty"]) ;
        return false ;
    }
    
    if (msg==nil) {
        msg = @"" ;
    }
    
    //if the same message was before then dont speak
    if ([msg isEqualToString:lastMsg] && repeatSameMsg == NO) {
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CONDITIONS - not speaking - the same message was spoken before"]) ;
        return false ;
    }
    
    // set the last title and message
    lastMsg = [[NSString alloc] initWithString:msg] ;
    
    
    //check if the speaking is enabled for the current app
    if (!isAppEnabled(appId)) {
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CONDITIONS - not speaking - speak for app %@ disabled", appId]) ;
        return false ;
    }
   
    SBApplication *frontmostApplication = ((SpringBoard *)[UIApplication sharedApplication])._accessibilityFrontMostApplication;
 
    //check if the app is blocked
    if (!canSpeakWhenInOpenApp(frontmostApplication)) {
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CONDITIONS - not speaking - App %@ is in open and in foreground speak for this app is disabled", [frontmostApplication bundleIdentifier]]) ;
        return false ;
    }

    //if the message contains a prefefined filter string then dont speak
    if (!isMessageFilterd(msg)) {
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CONDITIONS - not speaking - message contains predefined filter word"]) ;
        return false ;
    }
    
    //if device is muted and speak while muted not enabled then stop
    if(!isSpeakInMute()){
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CONDITIONS - not speaking - device muted"]) ;
        return false;
    }
    
    
    //if device cant speak in dnd then stop else speak
    if(!isSpeakInDND()){
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CONDITIONS - not speaking - device in do not disturb mode"]) ;
        return false;
    }
    
    
    // Speak only when at anywhere, locked, unlocked
    if (!isSpeakAtCurLocation()) {
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CONDITIONS - not speaking - device at unallowed location"]) ;
        return false ;
    }
    
    
    // CHARGING, BT, EARPHONE, WIFI, TIME AND WEEKDAY CONDITIONS
    if (!isAndOrConditionsMet()) {
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CONDITIONS - not speaking - and, or condtions are not met"]) ;
        return false ;
    }
    
    // can speak everything fine
    return true ;
    
}


#pragma mark SPEAK METHODS
static NSString *createNotifyMessage(NSString *title, NSString *msg, NSString *sub, NSString *appID) {
    
    logTextIntoFile([NSString stringWithFormat:@"Speak Notification: SPEAK - preapring message for speak"]) ;
    
    // get the per app custom message defined by the user
    NSString *sMessage = getPerAppCustomMessage(appID) ;
    
    // if there is no per app custom message then take the defautl one defined by the user
    if (sMessage == nil) {
        sMessage = getCustomMessage() ;
    }
    
    // if subtitle nil to wstaw pusty wyraz
    if (sub== nil) {
        sub = @"" ;
    }
    
    // get the app name from bundle indetifier
    NSString *appName = getAppName(appID) ;
    
    
    // make sure that none of the variables are nil (nil makes the function below crash when the argument is nil)
    if (title==nil) {
        title = @"" ;
    }
    if (msg==nil) {
        msg = @"" ;
    }
    if (sub==nil) {
        sub = @"" ;
    }
    if (appName==nil) {
        appName = @"" ;
    }
    
    
    // check if title is phone number, if yes then a selected by the user behavior will be made and a new sting will be returned
    title = shouldRemovePhoneNumber(title) ;
    
    
    // create the message
    sMessage = [sMessage stringByReplacingOccurrencesOfString:@"%%TITLE%%" withString:title];
    sMessage = [sMessage stringByReplacingOccurrencesOfString:@"%%MSG%%" withString:msg];
    sMessage = [sMessage stringByReplacingOccurrencesOfString:@"%%SUBTITLE%%" withString:sub];
    sMessage = [sMessage stringByReplacingOccurrencesOfString:@"%%APP%%" withString:appName];
    
    logTextIntoFile([NSString stringWithFormat:@"Speak Notification: SPEAK - spoken message:: %@", sMessage]) ;
    
    //remove URLS from the strings if exist
    sMessage = removeURLSFromString(sMessage) ;
    
    logTextIntoFile([NSString stringWithFormat:@"Speak Notification: SPEAK - removing URLs, spoken message:: %@", sMessage]) ;
    
    //remove emoji from the strings if exist
    sMessage = removeEmojiFromString(sMessage) ;
    
    logTextIntoFile([NSString stringWithFormat:@"Speak Notification: SPEAK - removing emoji, final spoken message:: %@", sMessage]) ;

    // remove colon if it is the first character
    if ([sMessage hasPrefix:@":"] && [sMessage length] > 1) {
        sMessage = [sMessage substringFromIndex:1];
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: SPEAK - found colon as first character, removing it, final spoken message:: %@", sMessage]) ;
    }
    
    if ([sMessage hasPrefix:@" :"] && [sMessage length] > 2) {
        sMessage = [sMessage substringFromIndex:2];
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: SPEAK - found colon as second character, removing it, final spoken message:: %@", sMessage]) ;
    }
    
    
    return sMessage ;
    
}


static void speakMsg(NSString *msg) {
    
    
    
    // check if delay is enabled
    if(getDelay()==0.0f){ // if no then speak imediatly
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: SPEAK - start speaking"]) ;
        
        [SpeakHelper startSpeaking:msg allowAutoLang:YES] ;
        
    }else {// if yes then speak after choosen time
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: SPEAK - start speaking with delay"]) ;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, getDelay() * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            [SpeakHelper startSpeaking:msg allowAutoLang:YES] ;
            
        });
    }
    
    
    
}


static void prepareNotify(BBBulletin *buletin) {
    
    logTextIntoFile([NSString stringWithFormat:@"Speak Notification: ---=== RECIEVED NEW NOTIFICATION - doing my job ===--- "]) ;
    logTextIntoFile([NSString stringWithFormat:@"Speak Notification: SPEAK - ===preapring for speak==="]) ;
    
    logTextIntoFile([NSString stringWithFormat:@"Speak Notification: Getting notification info - title: %@, message: %@, subtitle: %@, content: %@, topic: %@", [buletin title], [buletin message], [buletin subtitle], [buletin content], [buletin topic]]) ;
    
    
    //reset play sound memeory
    playNotifySound = YES ;
    
    //create the message to speak
    NSString *speakMessage = createNotifyMessage([buletin title], [buletin message], [buletin subtitle], [buletin sectionID]) ;
    
    // check if can speak message
    if(!canSpeak(speakMessage, [buletin sectionID], kSpeakSameAuto)) {
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: ---=== CONDITION NOT MET - stoping my work ===--- "]) ;
        
        return;
        
    }
    
    //disable the arrival notification sound when speaking (springboard)
    NSNumber *notifySoundDisabled = [preferences objectForKey:@"disableNotifySound"] ;
    bool isNotifySoundDisabled = notifySoundDisabled == nil ? true : [notifySoundDisabled boolValue];
    
    if(isNotifySoundDisabled==YES) {
        
        playNotifySound = NO ;
        
        // when device is locked then dont remove the notification sound, remove the sound only when notification arrives at springboard unlocked
        //needed for when device is locked and notification arrives second time to make the bing at second time
        if (!isDeviceLocked()) {
            
            [buletin setSound:nil] ;
        }
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: SPEAK - disabling notification sound"]) ;
        
    }
    
    // speak the message
    speakMsg(speakMessage) ;
    
    //[buletin topic] -- loks intersting , maybe do something with this in the future ?
    
}


static void prepareBBServerNotify(BBBulletin *bulletin) {
    
    
    // if not iOS10 or higher then do nothing, use the above functions
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 10.0)
    {
        return ;
    }
    
    
    //   logProperties(bulletin);
    //  HBLogDebug(@"DESTYNACJA %d", arg2 ) ;
    
    //  HBLogDebug(@"KUTASUDAUSDASDJASJD %f", [[NSDate date] timeIntervalSinceDate:[bulletin date]] ) ;
    
#pragma mark bulletin sound seems to be ok for that, check if any troublw come up here
    // notifications without sound like message which i recieved on iphone doesnt speak on ipad even that they appear on lockscreen
    if( bulletin == nil || [bulletin sound] == nil ) {
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CONDITIONS - notification empty or notification sound nil"]) ;
        
        return ;
        
    }
    
    
#pragma mark SOUND, DATE, AND PUBLICATIONDATE NOT GOOD!!! SEARCH FOR THE CAUSE!!
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //reset play sound memeory
        playNotifySound = YES ;
        
        //create the message to speak
        NSString *speakMessage = createNotifyMessage([bulletin title], [bulletin message], [bulletin subtitle], [bulletin sectionID]) ;
        
        // check if can speak message
        if(!canSpeak(speakMessage, [bulletin sectionID], kSpeakSameAuto)) {
            
            logTextIntoFile([NSString stringWithFormat:@"Speak Notification: ---=== CONDITION NOT MET - stoping my work ===--- "]) ;
            
            return ;
            
        }
        
        //disable the arrival notification sound when speaking (springboard)
        NSNumber *notifySoundDisabled = [preferences objectForKey:@"disableNotifySound"] ;
        bool isNotifySoundDisabled = notifySoundDisabled == nil ? true : [notifySoundDisabled boolValue];
        
        if(isNotifySoundDisabled==YES) {
            
            playNotifySound = NO ;
            
            // when device is locked then dont remove the notification sound, remove the sound only when notification arrives at springboard unlocked
            //needed for when device is locked and notification arrives second time to make the bing at second time
            if (!isDeviceLocked()) {
                
                [bulletin setSound:nil] ;
            }
            
            logTextIntoFile([NSString stringWithFormat:@"Speak Notification: SPEAK - disabling notification sound"]) ;
            
        }
        
        // speak the message
        speakMsg(speakMessage) ;
    });
    
    
}


static void speakBattery(int level){
    
    
    // get the custom battery message
    NSString *batteryMsg = getSpeakBatteryMessage() ;
    
    // get the battery percentage
    NSString *batteryString = [NSString stringWithFormat:@"%d%%", level] ;
    
    // replace the variable with the actual value
    batteryMsg = [batteryMsg stringByReplacingOccurrencesOfString:@"%%BATTERY%%" withString:batteryString];
    
    // check if can speak message
    if(canSpeak(batteryMsg, nil, kSpeakSameForceYes)) {
        
        // speak the time
        [SpeakHelper startSpeaking:batteryMsg allowAutoLang:NO] ;
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: BATTERY SPEAK - speaking current battery level!"]) ;
        
    }else{
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: BATTERY SPEAK - battery speak not speaking - conditions not met"]) ;
    }
    
    
}


static void checkBatterySpeak(){
    
    
    // get the current battery level
    int currentBatteryLevel = [[ %c(SBUIController) sharedInstance] batteryCapacityAsPercentage] ;
    
    // speak when fully charged
    if (isSpeakWhenFullyCharged() == YES) {
        
        // check if battery level dropped to reset the allow fully charged speak variable
        if(100 > currentBatteryLevel && currentBatteryLevel > 0 ){
            speakFullyChargedAllowed = YES ;
        }
        
        // speak only when device is charging
        if([[ %c(SBUIController) sharedInstance] isOnAC] == true){
            
            if (currentBatteryLevel == 100 && speakFullyChargedAllowed == YES) {
                
                logTextIntoFile([NSString stringWithFormat:@"Speak Notification: BATTERY SPEAK - Speak when fully charged eanbled, battery is fully charged and connected to AC! Speaking!"]) ;
                
                // speak the current battery level
                speakBattery(currentBatteryLevel) ;
                
                // dont allow any more fully charged announces till battery drains at least 1%
                speakFullyChargedAllowed = NO ;
                
            }
            
        }
        
    }
    
    
    // speak when charge starts
    if (isSpeakWhenChargeStart() == YES) {
        
        // speak only when device is charging
        if([[ %c(SBUIController) sharedInstance] isOnAC] == true){
            
            if (lastBatteryState == kBatteryStateNotCharging) {
                
                logTextIntoFile([NSString stringWithFormat:@"Speak Notification: BATTERY SPEAK - Speak when charge starts eanbled, battery changed state to started charging! Speaking!"]) ;
                
                // speak the current battery level
                speakBattery(currentBatteryLevel) ;
                
            }
            
        }
        
    }
    
    // save last battery state
    lastBatteryState = [[ %c(SBUIController) sharedInstance] isOnAC] ;
    
    
    // if battery speak disabled then do nothing and dont speak when fully charged
    if(getSpeakBatteryInterval()  == kSpeakBatteryDisabled) {
        return ;
    }
    
    
    // check if low levels alerts are enabled, if yes then check if battery on low level and stop, dont need to check more
    if (getSpeakBatteryInterval()==kSpeakBatteryLowLevelsOnly) {
        
        // speak only when device not charging
        if([[ %c(SBUIController) sharedInstance] isOnAC] == false){
            
            // check if battery level not 20 10 or 5 to reset the allow low level speak variable
            if(currentBatteryLevel != 20 && currentBatteryLevel != 10 && currentBatteryLevel != 5 && currentBatteryLevel > 0 ){
                speakBatteryLowLevelAllowed = YES ;
            }
            
            logTextIntoFile([NSString stringWithFormat:@"Speak Notification: BATTERY SPEAK - Low levels alarms only enabled,  cheking if battery is at 20%%, 10%% or 5%%"]) ;
            
            if ((currentBatteryLevel==20 || currentBatteryLevel==10 || currentBatteryLevel==5) && speakBatteryLowLevelAllowed == YES) {
                
                logTextIntoFile([NSString stringWithFormat:@"Speak Notification: BATTERY SPEAK - Current battery level is at low level :: %d%%", currentBatteryLevel]) ;
                
                // speak the current battery level
                speakBattery(currentBatteryLevel) ;
                
                // dont allow any more low level announces till battery raises or drops at least 1% from 20 10 or 5
                speakBatteryLowLevelAllowed = NO ;
                
            }
            
        }
        
    }else{
        
        // HERE ONLY WHEN a custom set interval speak is selected, "speak every x%"
        // speak only when device not charging
        if([[ %c(SBUIController) sharedInstance] isOnAC] == false){
            
            // check if battery level dropped since last check
            if(batteryLevel > currentBatteryLevel && currentBatteryLevel > 0 ){
                
                logTextIntoFile([NSString stringWithFormat:@"Speak Notification: BATTERY SPEAK - Battery level dropped since last check. Checking if correct battery interval"]) ;
                
                //calculate the current battery level difference
                batteryLevelDif = batteryLevelDif + (batteryLevel - currentBatteryLevel);
                
                logTextIntoFile([NSString stringWithFormat:@"Speak Notification: BATTERY SPEAK - Current Level difference: %d, selected by user speak battery every: %d", batteryLevelDif, getSpeakBatteryInterval() ]) ;
                
                // check if rest of substract current battery level with speak battery interval is 0, if yes then speak
                if((currentBatteryLevel % getSpeakBatteryInterval()) == 0 || batteryLevelDif > getSpeakBatteryInterval()){
                    
                    logTextIntoFile([NSString stringWithFormat:@"Speak Notification: BATTERY SPEAK - Battery Level Interval equal or greater as selected by user. Speaking battery level."]) ;
                    
                    // speak the current battery level
                    speakBattery(currentBatteryLevel) ;
                    
                    // reset battery difference count
                    batteryLevelDif = 0 ;
                    
                }
                
            }
            
        }
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: BATTERY SPEAK - Current battery level: %d%%, Speak battery every %d%%", currentBatteryLevel, getSpeakBatteryInterval()]) ;
    }
    
    // save last battery level
    batteryLevel = currentBatteryLevel;
    
    
}


static bool nowPlayingInfoChanged(NSString* title, NSString* artist, NSString* album){
    
    
    // the song was already announces before dont speak
    if ([title isEqualToString:lastSongTitle] && [artist isEqualToString:lastSongArtist] && [album isEqualToString:lastSongAlbum]) {
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CURRENT SONG SPEAK - the current song was already spoken out"]) ;
        
        return NO ;
        
    }
    
    // no song information dont speak
    if ([title isEqualToString:@""] && [artist isEqualToString:@""] && [album isEqualToString:@""]){
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CURRENT SONG SPEAK - no song information available"]) ;
        
        return NO ;
        
    }
    
    // clean old information
    [lastSongTitle release] ;
    [lastSongArtist release] ;
    [lastSongAlbum release] ;
    
    // save the new information
    lastSongTitle = [title copy] ;
    lastSongArtist = [artist copy] ;
    lastSongAlbum = [album copy] ;
    
    return YES ;
    
    
}

static void checkNowPlayingSpeak() {
    
    if(isSpeakCurrentSong()==YES){
        
        if([[%c(SBMediaController) sharedInstance] isPlaying]==YES){
            
            // get the current media info and save it
            MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef result) {
                
                NSDictionary *dict = (__bridge NSDictionary *)result ;
                
                //  NSLog(@"We got the information: %@", dict);
                
                // THIS IS IOS8 only
                // get the media type
             /*   id mediaType = [dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoMediaType] ;
                
                // if media type is not music then stop, MRMediaRemoteMediaTypeMusic - music
                if(![mediaType isEqual:@"MRMediaRemoteMediaTypeMusic"]){
                    
                    logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CURRENT SONG SPEAK - currently playing media is not music, not speaking"]) ;
                    
                    return ;
                    
                }
                */
                
                // THIS SUPPORTS IOS7 and IOS8
                // check if the source is the music app
                id musicApp = [dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoIsMusicApp] ;
                
                // if the source is not the music app then stop
                if([musicApp boolValue] == NO){
                    
                    logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CURRENT SONG SPEAK - song not playing from music app, not speaking"]) ;
                    
                    return ;
                    
                }
                
                NSString* title = [dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle] ;
                
                NSString* artist = [dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtist] ;
                
                NSString* album = [dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoAlbum] ;
                
                
                logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CURRENT SONG SPEAK - checking if currently playing song info has changed"]) ;
                
                // if any of the variables is nil then enter empty text
                if(title==nil) title = @"" ;
                if(artist==nil) artist = @"" ;
                if(album==nil) album = @"" ;
                
                // speak only when there is a new song playing
                if (nowPlayingInfoChanged(title, artist, album)==YES) {
                    
                    logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CURRENT SONG SPEAK - song info has change, preapring the message"]) ;
                    
                    // get the custom incoming call message
                    NSString *curSongMsg = getSpeakCurrentSongMessage() ;
                    
                    // replace the variable with the actual value
                    curSongMsg = [curSongMsg stringByReplacingOccurrencesOfString:@"%%STITLE%%" withString:title];
                    curSongMsg = [curSongMsg stringByReplacingOccurrencesOfString:@"%%SARTIST%%" withString:artist];
                    curSongMsg = [curSongMsg stringByReplacingOccurrencesOfString:@"%%SALBUM%%" withString:album];
                    
                    // check if can speak message
                    if(canSpeak(curSongMsg, nil, kSpeakSameForceYes)) {
                        
                        // speak the caller
                        [SpeakHelper startSpeaking:curSongMsg allowAutoLang:YES] ;
                        
                        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CURRENT SONG SPEAK - speaking currently playing song!"]) ;
                        
                    }else{
                        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CURRENT SONG SPEAK - not speaking currently playing song - conditions not met"]) ;
                    }
                    
                    
                    
                }
                
                
                
            });
            
            
        }
        
    }

    
}


// INCOMMING CALL HERE
// FIND A POSSIBILITY TO MUTE THE RINGTONE WHEN THE INCOMMING CALL ANNOUNCE IS SPEAKING - not so important


static void checkIncomingCallSpeak(TUCall* call) {
    
    
    if(isSpeakIncomingCall()==YES){
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: INCOMING CALL SPEAK - incoming call speak enabled, recieving call, preapring the message"]) ;
        
        // if caller name is nil or empty then do nothing
        if([call displayName] == nil || [[call displayName] isEqualToString:@""]){
            
            logTextIntoFile([NSString stringWithFormat:@"Speak Notification: INCOMING CALL SPEAK - caller name not found or empty, stoping!"]) ;
            
            return ;
        }
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: INCOMING CALL SPEAK - preapring the message"]) ;
        
        // get the caller name
        NSString* callerName = [NSString stringWithFormat:@"%@", [call displayName]];
        
        // get the source name
        NSString* callerCompany = [NSString stringWithFormat:@"%@",[call companyName]] ;
        
        if (callerCompany == nil) {
            callerCompany = @"" ;
        }
        
        // check if caller name is phone number, if yes then a selected by the user behavior will be made and a new sting will be returned
        callerName = shouldRemovePhoneNumber(callerName) ;
        
        // get the custom incoming call message
        NSString *incCallMsg = getSpeakIncomingCallMessage() ;
        
        // replace the variable with the actual value
        incCallMsg = [incCallMsg stringByReplacingOccurrencesOfString:@"%%NAME%%" withString:callerName];
        incCallMsg = [incCallMsg stringByReplacingOccurrencesOfString:@"%%COMPANY%%" withString:callerCompany];
        
        // check if can speak message
        if(canSpeak(incCallMsg, nil, kSpeakSameForceYes)) {
            
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
                [call setShouldSuppressRingtone:YES];
                lastCall = call ;
            }
            
            // wait 0.5 seconds, since sometimes the speak out stops when immdietaly
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                
                // speak the caller
                [SpeakHelper startSpeaking:incCallMsg allowAutoLang:NO] ;
                
                logTextIntoFile([NSString stringWithFormat:@"Speak Notification: INCOMING CALL SPEAK - speaking incoming caller name!"]) ;
                
            });
            
        }else{
            logTextIntoFile([NSString stringWithFormat:@"Speak Notification: INCOMING CALL SPEAK - not speaking incoming caller name - conditions not met"]) ;
        }
        
        
    }

    
}


static void checkMissedCallSpeak(TUCall* call) {

    // status 6 = hang up
    // startTime 0 = not answered call
    
    if(isSpeakMissedCall()==YES && [call callDuration] <= 1 && [call status] == 6 && [call isOutgoing] == NO){
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: MISSED CALL SPEAK - missed call speak enabled, missed call, preapring the message"]) ;
        
        // if caller name is nil or empty then do nothing
        if([call displayName] == nil || [[call displayName] isEqualToString:@""]){
            
            logTextIntoFile([NSString stringWithFormat:@"Speak Notification: MISSED CALL SPEAK - caller name not found or empty, stoping!"]) ;
            
            return ;
        }
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: MISSED CALL SPEAK - preapring the message"]) ;
        
        // get the caller name
        NSString* callerName = [NSString stringWithFormat:@"%@", [call displayName]];
        
        // get the source name
        NSString* callerCompany = [NSString stringWithFormat:@"%@",[call companyName]] ;
        
        if (callerCompany == nil) {
            callerCompany = @"" ;
        }
        
        // check if caller name is phone number, if yes then a selected by the user behavior will be made and a new sting will be returned
        callerName = shouldRemovePhoneNumber(callerName) ;
        
        // get the custom incoming call message
        NSString *missCallMsg = getSpeakMissedCallMessage() ;
        
        // replace the variable with the actual value
        missCallMsg = [missCallMsg stringByReplacingOccurrencesOfString:@"%%NAME%%" withString:callerName];
        missCallMsg = [missCallMsg stringByReplacingOccurrencesOfString:@"%%COMPANY%%" withString:callerCompany];
        
        // check if can speak message
        if(canSpeak(missCallMsg, nil, kSpeakSameForceYes)) {
            
            // wait 0.5 seconds, since sometimes the speak out stops when immdietaly
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                
                // speak the caller
                [SpeakHelper startSpeaking:missCallMsg allowAutoLang:NO] ;
                
                logTextIntoFile([NSString stringWithFormat:@"Speak Notification: MISSED CALL SPEAK - speaking missed call!"]) ;
                
            });
            
        }else{
            logTextIntoFile([NSString stringWithFormat:@"Speak Notification: MISSED CALL SPEAK - not speaking missed call - conditions not met"]) ;
        }
        
        
    }
    
    
}


static void checkCallDurationSpeak(TUCall* call) {
    
    // status 6 = hang up
    // startTime > 0 = answered call duration
    
    if(isSpeakCallDuration()==YES && [call callDuration] > 1 && [call status] == 6 && canSpeakCallDuration == YES){
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CALL DURATION SPEAK - call duration speak enabled, call ended with a duration, preapring the message"]) ;
        
        // if caller name is nil or empty then do nothing
        if([call displayName] == nil || [[call displayName] isEqualToString:@""]){
            
            logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CALL DURATION SPEAK - caller name not found or empty, stoping!"]) ;
            
            return ;
        }
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CALL DURATION SPEAK - preapring the message"]) ;
        
     //   int hour = [call callDuration] / 3600 ;
        int mins = ((int)[call callDuration] % 3600) / 60 ;
        int secs = (int)[call callDuration] % 60 ;
        
        // get the call duration in seconds
        NSString* callerDuration = [NSString stringWithFormat:@"%d", (int)[call callDuration]] ;
        
        // get the call duration seconds part
        NSString* callerDurationSecs = [NSString stringWithFormat:@"%d", secs] ;
        
        // get the call duration minutes part
        NSString* callerDurationMins = [NSString stringWithFormat:@"%d", mins] ;
        
        // get the caller name
        NSString* callerName = [NSString stringWithFormat:@"%@", [call displayName]];
        
        // get the source name
        NSString* callerCompany = [NSString stringWithFormat:@"%@",[call companyName]] ;
        
        if (callerCompany == nil) {
            callerCompany = @"" ;
        }
        
        // check if caller name is phone number, if yes then a selected by the user behavior will be made and a new sting will be returned
        callerName = shouldRemovePhoneNumber(callerName) ;
        
        // get the custom incoming call message
        NSString *callDuraMsg = getSpeakCallDurationMessage() ;
        
        // replace the variable with the actual value
        callDuraMsg = [callDuraMsg stringByReplacingOccurrencesOfString:@"%%DUR%%" withString:callerDuration];
        callDuraMsg = [callDuraMsg stringByReplacingOccurrencesOfString:@"%%SEC%%" withString:callerDurationSecs];
        callDuraMsg = [callDuraMsg stringByReplacingOccurrencesOfString:@"%%MIN%%" withString:callerDurationMins];
        callDuraMsg = [callDuraMsg stringByReplacingOccurrencesOfString:@"%%NAME%%" withString:callerName];
        callDuraMsg = [callDuraMsg stringByReplacingOccurrencesOfString:@"%%COMPANY%%" withString:callerCompany];
        
        // check if can speak message
        if(canSpeak(callDuraMsg, nil, kSpeakSameForceYes)) {
            
            // can'T speak two 2 times in a row
            canSpeakCallDuration = NO ;
            
            // wait 1.0 seconds, since sometimes the speak out stops when immdietaly
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                
                // speak the caller
                [SpeakHelper startSpeaking:callDuraMsg allowAutoLang:NO] ;
                
                //reset call duration speak allow
                canSpeakCallDuration = YES;
                
                logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CALL DURATION SPEAK - speaking last call duration!"]) ;
                
            });
            
            
        }else{
            logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CALL DURATION SPEAK - not speaking last call duration - conditions not met"]) ;
        }
        
        
    }
    
    
}




static void checkTouchIdSpeak(int touchEvent) {
    
    if (canSpeakTouchID == NO) {
        return ;
    }
    
    if (touchEvent == kTouchIDEventSucceeded || ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0 && touchEvent == kTouchIDEventSucceededIOS9)) {
        
        if(isSpeakTouchIdSuccess()==YES && isDeviceLocked() == YES){
            
            canSpeakTouchID = NO ;
            
            logTextIntoFile([NSString stringWithFormat:@"Speak Notification: TOUCH ID SUCCESS SPEAK - touch id success speak enabled, touch id successfully unlocked device, preapring the message"]) ;
            
            // get the custom touch id success message
            NSString *successMsg = getTouchIdSuccessMessage() ;
            
            // check if can speak message
            if(canSpeak(successMsg, nil, kSpeakSameForceYes)) {
                
                // speak the message
                [SpeakHelper startSpeaking:successMsg allowAutoLang:YES] ;
                    
                logTextIntoFile([NSString stringWithFormat:@"Speak Notification: TOUCH ID SUCCESS SPEAK - speaking touch id successful unlock message"]) ;

                
            }else{
                logTextIntoFile([NSString stringWithFormat:@"Speak Notification: TOUCH ID SUCCESS SPEAK - not speaking touch id successful unlock message - conditions not met"]) ;
            }
            
            
        }
        
    }
    
    if (touchEvent == kTouchIDeventFailed) {
        
        if(isSpeakTouchIdFailed()==YES){
            
            canSpeakTouchID = NO ;
            
            logTextIntoFile([NSString stringWithFormat:@"Speak Notification: TOUCH ID FAILED SPEAK - touch id failed speak enabled, touch id failed to unlocked device, preapring the message"]) ;
            
            // get the custom touch id failed message
            NSString *failedMsg = getTouchIdFailedMessage() ;
            
            // check if can speak message
            if(canSpeak(failedMsg, nil, kSpeakSameForceYes)) {
                
                // speak the message
                [SpeakHelper startSpeaking:failedMsg allowAutoLang:YES] ;
                
                logTextIntoFile([NSString stringWithFormat:@"Speak Notification: TOUCH ID FAILED SPEAK - speaking touch id failed unlock message"]) ;
                
                
            }else{
                logTextIntoFile([NSString stringWithFormat:@"Speak Notification: TOUCH ID FAILED SPEAK - not speaking touch id failed unlock message - conditions not met"]) ;
            }
            
            
        }

        
    }
    
    
    // wait 0.5 seconds, since sometimes the speak out stops when immdietaly
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        canSpeakTouchID = YES ;
        
    });
    
    
}


#pragma mark HOOKS
%group mainHooks

//Springboard (iOS7 & iOS8)
%hook SBBulletinBannerController

- (void)observer:(id)arg1 addBulletin:(id)arg2 forFeed:(unsigned long long)arg3 {
    
    //   NSLog(@"..------------------------------------------------------------");
    //   %log ;
    //   NSLog(@"..------------------------------------------------------------");
    
    logTextIntoFile([NSString stringWithFormat:@"Speak Notification: Speak Notification Springboard:"]) ;
    logTextIntoFile([NSString stringWithFormat:@"Speak Notification: notify: %@", arg2]) ;
    
    prepareNotify(arg2) ;
    
    %orig ;
    
}

//Springboard (iOS 8.3)
-(void)observer:(id)observer addBulletin:(id)bulletin forFeed:(unsigned)feed playLightsAndSirens:(BOOL)sirens withReply:(id)reply {
    
    logTextIntoFile([NSString stringWithFormat:@"Speak Notification: Speak Notification Springboard:"]) ;
    logTextIntoFile([NSString stringWithFormat:@"Speak Notification: notify: %@", bulletin]) ;
    
    prepareNotify(bulletin) ;
    
    %orig ;
    
}

%end


/*
 static void logProperties(id objekt) {
 
 HBLogDebug(@"----------------------------------------------- Properties for object %@", objekt);
 
 @autoreleasepool {
 unsigned int numberOfProperties = 0;
 objc_property_t *propertyArray = class_copyPropertyList([objekt class], &numberOfProperties);
 for (NSUInteger i = 0; i < numberOfProperties; i++) {
 objc_property_t property = propertyArray[i];
 NSString *name = [[NSString alloc] initWithUTF8String:property_getName(property)];
 HBLogDebug(@"Property %@ Value: %@", name, [objekt valueForKey:name]);
 }
 free(propertyArray);
 }
 HBLogDebug(@"-----------------------------------------------");
 }
 */

%hook BBServer
//ios11 and ios10
-(void)publishBulletin:(BBBulletin *)bulletin destinations:(unsigned int)arg2 alwaysToLockScreen:(BOOL)arg3
{
    
    %orig ;

    prepareBBServerNotify(bulletin);
    
}

//ios 12
-(void)publishBulletin:(BBBulletin *)bulletin destinations:(unsigned long long)arg2 {
    
    %orig ;
    
    prepareBBServerNotify(bulletin);
    
}
%end


/*
 %hook SBLockScreenNotificationListController
 
 //LockScreen (iOS8)
 - (void)observer:(id)arg1 addBulletin:(id)arg2 forFeed:(unsigned long long)arg3 playLightsAndSirens:(_Bool)arg4 withReply:(id)arg5{
 
 //   NSLog(@"..------------------------------------------------------------");
 //   %log ;
 //   NSLog(@"..------------------------------------------------------------");
 
 logTextIntoFile([NSString stringWithFormat:@"Speak Notification: Speak Notification LockScreen:"]) ;
 logTextIntoFile([NSString stringWithFormat:@"Speak Notification: notify: %@", arg2]) ;
 
 prepareNotify(arg2) ;
 
 %orig ;
 
 
 
 }
 //LockScreen (iOS7)
 
 - (void)observer:(id)arg1 addBulletin:(id)arg2 forFeed:(int)arg3
 {
 
 //   NSLog(@"..------------------------------------------------------------");
 //   %log ;
 //   NSLog(@"..------------------------------------------------------------");
 
 logTextIntoFile([NSString stringWithFormat:@"Speak Notification: Speak Notification LockScreen ios7:"]) ;
 logTextIntoFile([NSString stringWithFormat:@"Speak Notification: notify: %@", arg2]) ;
 
 prepareNotify(arg2) ;
 
 %orig ;
 
 
 }
 %end
 */

// BiteSMS support
%hook SBAlertItemsController
- (void)activateAlertItem:(id)arg1 {
    
    // check if it is BiteSMS quickreply classs
    if ([arg1 isKindOfClass:%c(BSQuickReplyItem)])
    {
        
        NSString* title = [[(CKIMMessage*)[arg1 message] IMMessage] senderName] ;
        NSString* msg = [(NSAttributedString*)[[(CKIMMessage*)[arg1 message] IMMessage] text] string] ;
        
        // reset the play sound memeory
        playNotifySound = YES ;
        
        //create the message to speak
        NSString *speakMessage = createNotifyMessage(title, msg, nil,  @"com.apple.MobileSMS") ;
        
        // check if can speak message and title
        if(!canSpeak(speakMessage , @"com.apple.MobileSMS", kSpeakSameAuto)) {
            
            %orig;
            return;
        }
        
        // speak the message
        speakMsg(speakMessage) ;
        
    }
    
    %orig ;
    
}

%end


%hook BBBulletin

- (BOOL)playSound {
    
    // if notification sound disabled then dont play it
    if(playNotifySound==NO) {
        
        playNotifySound = YES ;
        
        return NO ;
        
    }
    
    
    return %orig ;
}

%end




%hook SpringBoard

- (void)_menuButtonDown:(struct __IOHIDEvent *)arg1 {
    
    // stop speaking when home button is pressed
    if(cancelSpeech(5)==YES) {
        
        return ;
    }
    
    
    %orig ;
    
    
}

- (void)_lockButtonUpFromSource:(int)arg1 {
    
    // stop speaking when power button is pressed, device shuts itself down when i make condition check and retunr like the others
    cancelSpeech(2) ;
    
    %orig ;
    
}

-(void)_lockButtonUp:(id)up fromSource:(int)source{
    //iOS8 - power button up pressed
    // stop speaking when power button is pressed, device shuts itself down when i make condition check and retunr like the others
    cancelSpeech(2) ;
    
    %orig ;
    
}


%end

// iOS10 home button pressed
%hook SBHomeHardwareButton

- (void)initialButtonDown:(id)arg1{
    
    // stop speaking when home button is pressed
    if(cancelSpeech(5)==YES) {
        
        return ;
    }
    
    
    %orig ;
    
    
}

%end


// iOS10 power button pressed
%hook SBLockHardwareButton

- (void)buttonDown:(id)arg1 {
    
    // stop speaking when home button is pressed
    if(cancelSpeech(2)==YES) {
        
        return ;
    }
    
    
    %orig ;
    
    
}

%end


%hook VolumeControl

- (void)decreaseVolume {
    
    // stop speaking when volume down button is pressed
    if(cancelSpeech(4)==YES) {
        
        return ;
    }
    
    %orig ;
    
}
- (void)increaseVolume {
    
    // stop speaking when volume up button is pressed
    if(cancelSpeech(3)==YES) {
        
        return ;
    }
    
    %orig ;
    
}

%end

//ios13 volume buttons
%hook SBVolumeControl

-(void)handleVolumeButtonWithType:(long long)arg1 down:(BOOL)arg2 {
    
    //arg1 == 102 - UP
    //arg1 == 103 - DOWN
    
    if(arg2 == true){ //only when button is pressed down, and not anymore when released
        if(arg1 == 102){
            // stop speaking when volume up button is pressed
            if(cancelSpeech(3)==YES) {
                return ;
            }
        }
        else if(arg1 == 103){
            // stop speaking when volume down button is pressed
            if(cancelSpeech(4)==YES) {
                return ;
            }
        }
    }
    
    %orig;
}

%end



//iOS 9.3 and below
%hook SBLockScreenManager

- (void)biometricEventMonitor:(id)arg1 handleBiometricEvent:(unsigned long long)arg2{
    
    /*
     arg2 =
     #define TouchIDFingerUp	0
     #define TouchIDFingerDown  1
     #define TouchIDFingerHeld  2
     #define TouchIDMatchSucceeded 3
     #define TouchIDMatchFailed 10
     */
    
    // stop speaking when touch id up button is pressed
    if(arg2 == 0 && cancelSpeech(6)==YES) {
        return ;
    }
    
    // speak on touch id successful or failed unlock
    checkTouchIdSpeak(arg2) ;
    
    %orig;
    
}

%end

//iOS 10.2
%hook SBDashBoardViewController

- (void)handleBiometricEvent:(unsigned long long)arg1 {
    
    /*
     arg2 =
     #define TouchIDFingerUp	0
     #define TouchIDFingerDown  1
     #define TouchIDFingerHeld  2
     #define TouchIDMatchSucceeded 3
     #define TouchIDMatchFailed 10
     */
    
    // stop speaking when touch id up button is pressed
    if(arg1 == 0 && cancelSpeech(6)==YES) {
        return ;
    }
    
    // speak on touch id successful or failed unlock
    checkTouchIdSpeak(arg1) ;
    
    %orig;
    
}

%end

//iOS 13.0
%hook SBDashBoardBiometricUnlockController

- (void)handleBiometricEvent:(unsigned long long)arg1 {
    
    /*
     arg2 =
     #define TouchIDFingerUp    0
     #define TouchIDFingerDown  1
     #define TouchIDFingerHeld  2
     #define TouchIDMatchSucceeded 3
     #define TouchIDMatchFailed 10
     */
    
    // stop speaking when touch id up button is pressed
    if(arg1 == 0 && cancelSpeech(6)==YES) {
        return ;
    }
    
    // speak on touch id successful or failed unlock
    checkTouchIdSpeak(arg1) ;
    
    %orig;
    
}

%end



%hook SBQuietModeStateAggregator


- (void)observer:(id)arg1 noteAlertBehaviorOverrideStateChanged:(unsigned long long)arg2{
    
    // if not iOS10 or higher then do nothing, use standard dnd
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 10.0)
    {
        %orig ;
        return ;
    }
    
    %orig ;
    
    dndState102 = [self quietModeState] ;

}


%end

// ios12 and lower disable hud
%hook SBHUDView
- (id)initWithHUDViewLevel:(int)arg1 {
    
    //if disable hud enabled dont show the volume hud once
    if(disableVolumeHUD==YES) {
        
        // fix for minimalHUD conflict
        if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/HUD.dylib"]){

            logTextIntoFile([NSString stringWithFormat:@"Speak Notification: HIDE HUD - minimalHUD tweak found, enabling standard HUD for compatibility"]) ;
            return %orig ;
        }
        
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: HIDE HUD, hiding the HUD for the speak out duration!"]) ;
        disableVolumeHUD = NO ;
        return nil ;
    }
    
    
    return %orig ;
    
}

%end

//ios13 disable hud
%hook SBHUDController
-(void)_presentHUD:(id)arg1 animated:(BOOL)arg2 {
    
    //if disable hud enabled dont show the volume hud once
    if(disableVolumeHUD==YES) {
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: HIDE HUD, hiding the HUD for the speak out duration!"]) ;
        // wait 0.1 seconds, and then enable the hud again
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                       disableVolumeHUD = NO ;
        });
        return ;
    }
    
    %orig ;
    
}
%end


// IT MUST BE SOMEHWERE HERRE !!!! CHECK OUT WHY IT IS NOT WORKING????
// IANNOUNCE GUY DID THIS : https://github.com/patelhiren/iannounce/blob/master/Tweak.xm


/*
%hook SBRemoteAlertAdapter
- (id)initWithViewController:(id)arg1 {
    
    NSLog(@"ADASDASDASFASFASA RGMUMEMEEMMEEMEMNT11111 %@", arg1) ;
    
    return %orig ;
    
}
- (id)_initWithRemoteAlertHostViewController:(id)arg1 {
    
    id original = %orig ;
    
    NSLog(@"ADASDASDASFASFASA RGMUMEMEEMMEEMEMNT22222 %@", arg1) ;
    
     NSLog(@"AORIGINALALAALALLALALALALA %@", original) ;
    
    return %orig ;
    
}

%end
*/








// BATTERY CHANGED ALTERNATIVE METHOD HERE - if notification method would not work someday

%hook SpringBoard

- (void)batteryStatusDidChange:(id)batteryStatus{
    
    %orig;
 
    // the hook is beeing called slower with a delay, thats why the speak is happening at respring
 
    // put code here
    checkBatterySpeak() ;
    
}

%end


// INCOMMING CALL ALTERNATIVE METHOD HERE - if notification method would not work someday
/*
%hook SBTelephonyManager
 
- (void)callEventHandler:(id)arg1 {

    %orig ;
 
 // put code here
 // TUCall = [self incomingCall] for the method below
    
}

%end
*/



// NOW PLAYING AANOUNCE ALTERNATIVE METHOD HERE - if notification method would not work someday
/*
%hook SBMediaController

- (void)_nowPlayingInfoChanged {
 
    %orig ;
 
 // put code here
    
}

%end
*/


%end // mainHooks group end

#pragma mark NOTIFICATION CALLBACKS
/* NOT WORKS ON IOS9, for now using the hook above
static void BatteryStatusChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    
    // the notitifcation is called without a delay, thats why upon respring it is not speaking since the device is detected as in muted state, and so the condition is not met
    checkBatterySpeak() ;
    
}
*/
static void NowPlayingInfoChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    
    checkNowPlayingSpeak() ;
    
}

static void IncommingCallCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    
    checkIncomingCallSpeak( (TUCall*)object ) ;
    
}

static void CallChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    
    /*
     status:
     1 - Call answered
     3 - initiate outgoing
     4 - initiate incoming
     5 - hang up for CTCallStatus (in this case it is 6)
     6 - hang up for TUCall
     if startTime is 0 then it is an unaswered call, else it was an answered call
     */
    
    TUCall* call = (TUCall*)object ;
    
    logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CALL STATUS CHANGED  - CALL: %@", call] ) ;
    
    logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CALL STATUS CHANGED  - CALL DURATION: %.2f",[call callDuration] ] ) ;
    
    logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CALL STATUS CHANGED  - CALL STATUS: %d", [call status] ]) ;
    
    logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CALL STATUS CHANGED - CALL OUTGOING: %d", [call isOutgoing]]) ;
    
    
    checkMissedCallSpeak( call ) ;
    
    checkCallDurationSpeak( call ) ;
    
}


static void SpeakTimeCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    
    
    // get the custom time message
    NSString *timeMsg = getSpeakTimeMessage() ;
    
    // get the current time
    NSString *timeString = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:kCFDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    
    // replace the variable with the actual value
    timeMsg = [timeMsg stringByReplacingOccurrencesOfString:@"%%TIME%%" withString:timeString];
    
    // check if can speak message
    if(canSpeak(timeMsg, nil, kSpeakSameForceNo)) {
        
        // speak the time
        [SpeakHelper startSpeaking:timeMsg allowAutoLang:NO] ;
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: TIME SPEAK - speaking current time!"]) ;
        
    }else{
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: TIME SPEAK - time speak not speaking - conditions not met"]) ;
    }
    
    
}

static void DisableHUDCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    
    // when the speaking starts or stops set the disble volume hud
    disableVolumeHUD = YES ;
    
}


static void SpeakStartedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    

    
}

static void SpeakFinishedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    
    if (lastCall != nil && [lastCall isKindOfClass:NSClassFromString(@"TUCall")] && [[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
        [lastCall setShouldSuppressRingtone:NO];
        lastCall = nil ;
    }
  
}

static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    
    
    [preferences release];
    reloadPrefs() ;
    
    
    
    // wait 0.1 seconds, for the preferences to reaload
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        if(getSpeakTimeInterval()!=kSpeakTimeDisabled){
            [SpeakHelper startTimeTimer] ;
        }else {
            [SpeakHelper stopTimeTimer] ;
        }
        
    });
    
    
    // set current battery level ---- maybe can make problems in the future - make seperat callback for battery speak settings changed to be sure that works flawless???
    if (getSpeakBatteryInterval()!=kSpeakBatteryDisabled) {
        batteryLevel = [[ %c(SBUIController) sharedInstance] batteryCapacityAsPercentage] ;
    }
    
    
}

#pragma mark ON LOAD FUNCTION
__attribute__((constructor)) static void SpeakNotification_init() {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
/*
    if ([MerdokHelper kIsPirated] == NO) {
        %init(mainHooks) ;
    }else{
        return ;
    }
*/

    reloadPrefs() ;
    
    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PreferencesChangedCallback, CFSTR(PreferencesChangedNotification), NULL, CFNotificationSuspensionBehaviorCoalesce);
    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, DisableHUDCallback, CFSTR(DisableHUDNotification), NULL, CFNotificationSuspensionBehaviorCoalesce);
    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, SpeakStartedCallback, CFSTR(SpeakStartedNotification), NULL, CFNotificationSuspensionBehaviorCoalesce);
    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, SpeakFinishedCallback, CFSTR(SpeakFinishedNotification), NULL, CFNotificationSuspensionBehaviorCoalesce);
    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, SpeakTimeCallback, CFSTR(SpeakTimeNotification), NULL, CFNotificationSuspensionBehaviorCoalesce);
    
    // BATTERY STATUS CHANGED NOTIDICATION LISTENER
  //  CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, BatteryStatusChangedCallback, CFSTR("SBUIBatteryStatusChangedNotification"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    
    // NOW PLAYING INFO CHANGED NOTIDICATION LISTENER
    CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, NowPlayingInfoChangedCallback, CFSTR("kMRMediaRemoteNowPlayingInfoDidChangeNotification"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    
    // INCOMMING CALL NOTIDICATION LISTENER
    CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, IncommingCallCallback, CFSTR("SBIncomingCallPendingNotification"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    
    // CALL STATUS CHANGED NOTIDICATION LISTENER
    CTTelephonyCenterAddObserver(CTTelephonyCenterGetDefault(), NULL, CallChangedCallback, CFSTR("TUCallCenterCallStatusChangedInternalNotification"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    
    // if speak time enabled start the timer
    if(getSpeakTimeInterval()!=kSpeakTimeDisabled){
        [SpeakHelper startTimeTimer];
    }
    
    
    %init(mainHooks) ;
    
    
    [pool release];
}


