#import <objc/runtime.h>
#import "SpeakHelper.h"
#import <CaptainHook/CaptainHook.h>
#import "defines.h"

static NSDictionary *preferences = nil;


///////////////// speak
@interface VSSpeechSynthesizer : NSObject
+ (BOOL)isSystemSpeaking;
+ (id)availableLanguageCodes;
+ (id)availableVoices;
- (id)setVolume:(float)arg1;
- (id)setPitch:(float)arg1;
- (id)setRate:(float)arg1;
- (void)setDelegate:(id)arg1;
- (BOOL)startSpeakingString:(id)arg1 withLanguageCode:(id)arg2 error:(id*)arg3;
- (BOOL)startSpeakingString:(id)arg1 error:(id*)arg2;
- (BOOL)stopSpeakingAtNextBoundary:(int)arg1 error:(id *)arg2;
@end
/////////////////

///////////////// AVSystemController
@interface AVSystemController : NSObject
+ (id)sharedAVSystemController;
- (BOOL)getActiveCategoryVolume:(float *)arg1 andName:(id *)arg2;
@end
/////////////////

//////// VolumeControl
@interface VolumeControl : NSObject
+ (id)sharedVolumeControl;
- (_Bool)headphonesPresent;
- (void)toggleMute;
@end
////////////////

//////// BLUETOOTHMANAGER
@interface BluetoothManager : NSObject
+ (id)sharedInstance;
- (_Bool)connected;
- (BOOL)audioConnected;
@end
////////////////

//////// SBMEDIACONTROLLER
@interface SBMediaController : NSObject
@property(nonatomic, getter=isRingerMuted) _Bool ringerMuted;
+ (id)sharedInstance;
- (void)setVolume:(float)arg1;
- (float)volume;
- (_Bool)isPlaying;
- (_Bool)play;
@end
////////////////

//////// SBTELEPHOPNYMANAGER
@interface SBTelephonyManager
+ (id)sharedTelephonyManager;
- (_Bool)inCall;
@end
////////////////


//////// PERSISTENT TIMER
@interface PCPersistentTimer
+ (id)alloc;
- (id)initWithFireDate:(id)arg1 serviceIdentifier:(id)arg2 target:(id)arg3 selector:(SEL)arg4 userInfo:(id)arg5;
- (id)initWithTimeInterval:(double)arg1 serviceIdentifier:(id)arg2 guidancePriority:(unsigned long long)arg3 target:(id)arg4 selector:(SEL)arg5 userInfo:(id)arg6;
- (id)initWithTimeInterval:(double)arg1 serviceIdentifier:(id)arg2 target:(id)arg3 selector:(SEL)arg4 userInfo:(id)arg5;
- (void)scheduleInRunLoop:(id)arg1;

- (bool)isValid;
- (void)invalidate;
@end
////////////////


/////////// HELPER METHODS /////////
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
    
    logTextIntoFile([NSString stringWithFormat:@"Speak Notification: SPEAK HELPER - reloading preferences"]) ;
    
    //ios8
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        preferences = (id)CFPreferencesCopyMultiple(CFPreferencesCopyKeyList (TweakIdent, kCFPreferencesCurrentUser, kCFPreferencesAnyHost), TweakIdent, kCFPreferencesCurrentUser, kCFPreferencesAnyHost) ;
        
    }else{ // ios <= 7.1
        preferences = [[NSDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
        
    }
    
}


#pragma mark PREFERENCES
static int getSpeakTimeInterval() {
    
    // reload prefs
    if (preferences==nil) {
        reloadPrefs() ;
    }
    
    NSNumber *timeNumber = [preferences objectForKey:@"speaktime"];
    int time = timeNumber == nil ? 0 : [timeNumber intValue];
    
    return time ;
    
    
}

static bool isUseSystemVolume() {
    
    NSNumber *systemVolume = [preferences objectForKey:@"usesystemvolume"] ;
    bool isSystemVolume = systemVolume == nil ? NO : [systemVolume boolValue];
    
    return isSystemVolume ;
    
}

static bool isPauseMusic() {
    
    NSNumber *pause = [preferences objectForKey:@"pausemusic"] ;
    bool isPause = pause == nil ? true : [pause boolValue];
    
    return isPause ;
    
}


static bool isSpeakIncomingCall() {
    
    NSNumber *speakIncCall = [preferences objectForKey:@"speakincomingcall"] ;
    bool isSpeakIncomingCall = speakIncCall == nil ? NO : [speakIncCall boolValue];
    
    return isSpeakIncomingCall ;
    
}

static bool isDeviceInCall() {
    
    bool callActive = NO ;
    
    // phone call or facetime audio call
    if ([[NSClassFromString(@"SBTelephonyManager") sharedTelephonyManager] inCall] == YES) {
        callActive = YES ;
    }
    
    //ios8 only
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        // number of active facetime video calls
        if ([[NSClassFromString(@"TUCallCenter") sharedInstance] currentVideoCallCount] > 0) {
            callActive = YES ;
        }
        
        // is incomming call
        if ([[NSClassFromString(@"TUCallCenter") sharedInstance] incomingCall] != nil) {
            callActive = YES ;
        }
    }
    
    return callActive ;
    
}

static bool isQueueSpeak() {
    
    NSNumber *valueNumber = [preferences objectForKey:@"enableQueueSpeaking"] ;
    bool value = valueNumber == nil ? YES : [valueNumber boolValue];
    
    return value ;
    
}

static bool isForceSpeaker() {
    
    NSNumber *valueNumber = [preferences objectForKey:@"forcespeaker"] ;
    bool value = valueNumber == nil ? NO : [valueNumber boolValue];
    
    return value ;
    
}


#pragma mark HELPER FUNCTIONS
static void saveNewVolumeToPreferences(float newVolume) {
    
    logTextIntoFile([NSString stringWithFormat:@"Speak Notification: SPEAK HELPER - saving new volume to preferences"]) ;
    
    if(newVolume<0.1f) {
        newVolume = 0.1f;
    }
    
    if(newVolume>0.9f) {
        newVolume = 0.9f;
    }
    
    // write new value to preferenes
    NSMutableDictionary *tempPrefs ;
    
    //ios8
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        tempPrefs = (id)CFPreferencesCopyMultiple(CFPreferencesCopyKeyList (TweakIdent, kCFPreferencesCurrentUser, kCFPreferencesAnyHost), TweakIdent, kCFPreferencesCurrentUser, kCFPreferencesAnyHost) ;
        
    }else{ // ios <= 7.1
        tempPrefs = [[NSMutableDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
    }
    
    // set the value
    [tempPrefs setValue:[NSNumber numberWithFloat: newVolume] forKey:@"speakvolume"];
    
    //save the new preferences
    //ios8
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        CFPreferencesSetMultiple ((CFDictionaryRef)tempPrefs, nil, TweakIdent, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
        
    }else{ // ios <= 7.1
        [tempPrefs writeToFile:PreferencesFilePath atomically: YES];
    }
    
    
    
    [tempPrefs release];
    tempPrefs = NULL;
    
    // reload preferences
    [preferences release];
    
    //ios8
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        preferences = (id)CFPreferencesCopyMultiple(CFPreferencesCopyKeyList (TweakIdent, kCFPreferencesCurrentUser, kCFPreferencesAnyHost), TweakIdent, kCFPreferencesCurrentUser, kCFPreferencesAnyHost) ;
        
    }else{ // ios <= 7.1
        preferences = [[NSDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
        
    }
    
    
}


#pragma mark TIME SPEAK FUNCTIONS
static bool canSpeakTime() {
    
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:[NSDate date]];
    
    
    if(getSpeakTimeInterval()==kSpeakTime15m){
        
        if(components.minute == 0 || components.minute == 15 || components.minute == 30 || components.minute == 45){
            
            logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CAN SPEAK TIME - 15 minutes!"]) ;
            return YES ;
            
        }
        
        
    }else if(getSpeakTimeInterval()==kSpeakTime30m){
        
        if(components.minute == 0 || components.minute == 30){
            
            logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CAN SPEAK TIME - 30 minutes!"]) ;
            return YES ;
            
        }
        
        
    }else if(getSpeakTimeInterval()==kSpeakTime1h){
        
        if(components.minute == 0){
            
            logTextIntoFile([NSString stringWithFormat:@"Speak Notification: CAN SPEAK TIME - 60 minutes!"]) ;
            return YES ;
            
        }
        
        
    }
    
    
    return NO ;
    
}



static NSDate* getTimeSpeakTime() {
    
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    // default set for 1 hour
    NSDateComponents *futureDateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate: [[NSDate date] dateByAddingTimeInterval:60*60]];
    
    
    if(getSpeakTimeInterval()==kSpeakTime15m){
        
        futureDateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate: [[NSDate date] dateByAddingTimeInterval:60*15]];
        
        int divRes = futureDateComponents.minute / 15 ;
        
        futureDateComponents.minute = divRes * 15 ;
        
        
        
    }else if(getSpeakTimeInterval()==kSpeakTime30m){
        
        futureDateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate: [[NSDate date] dateByAddingTimeInterval:60*30]];
        
        int divRes = futureDateComponents.minute / 30 ;
        
        futureDateComponents.minute = divRes * 30 ;
        
        
    }else if(getSpeakTimeInterval()==kSpeakTime1h){
        
        
        futureDateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate: [[NSDate date] dateByAddingTimeInterval:60*60]];
        
        futureDateComponents.minute = 0 ;
        
        
        
    }
    
    futureDateComponents.second = 2 ;
    
    
    return [calendar dateFromComponents:futureDateComponents] ;
    
    
    
}




////////// HELPER METHODS END



@implementation SpeakHelper

    bool isMediaPlayerPlaying = NO ;
    bool wasVolumeChanged = NO ;
    float currentVolume = 0.6f ;
    float speakStartVolume;
    NSMutableArray *speakArray ;
    PCPersistentTimer *timeTimer;
    bool didOverwriteAudioRoute = NO ;
    bool forcedStop = NO ;
    NSString *currentCategory = nil ;
    AVAudioSessionCategoryOptions currentOptions ;

#pragma mark DELEGATE METHODS
+(void)speechSynthesizer:(id)synthesizer didStartSpeakingRequest:(id)request {
    
}



+ (void) speechSynthesizer:(NSObject *) synth didFinishSpeaking:(BOOL)didFinish withError:(NSError *) error  {
    
    [self speakOutFinished: synth] ;
    
}

#pragma mark SPEAK METHODS
+(void)speakOutStarted {
    
    //set the audio output source
    [self setStartAudioOutput] ;
    
    //if is incomming call then surpress the ringtone
    if ([[NSClassFromString(@"TUCallCenter") sharedInstance] incomingCall] != nil && [[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
        [[[NSClassFromString(@"TUCallCenter") sharedInstance] incomingCall] setShouldSuppressRingtone:YES];
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: RINGTONE SUPRPRESS - device has incomming call, enabling ringtone suppress"]) ;
    }
    
    
    // check if use system volume enabled, if yes then do nothing else save current volume and set the custom volume
    if (isUseSystemVolume()==YES) {
        
        wasVolumeChanged = NO ;
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: VOLUME - use system volume enabled, using current system volume "]) ;
        
    }else {
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: VOLUME - custom volume enabled, setting the speak out volume "]) ;
        
        // get the shared instance
        Class SBMediaController = NSClassFromString(@"SBMediaController") ;
        
        NSNumber *speakVolume = [preferences objectForKey:@"speakvolume"];
        speakStartVolume = speakVolume == nil ? 0.6f : [speakVolume floatValue];
        
        // make sure that the minimum volume is 0.1 and max 1.0
        if (speakStartVolume < 0.1f) speakStartVolume = 0.1f ;
        if (speakStartVolume > 1.0f) speakStartVolume = 1.0f ;
        
        // turn of the display of volume level once
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR(SpeakChangeNotification), NULL, NULL, TRUE);
        
        // save the current volume level
        currentVolume = [[SBMediaController sharedInstance] volume] ;
        
        // set a new volume level for the speak
        [[SBMediaController sharedInstance] setVolume:speakStartVolume] ;
        
        wasVolumeChanged = YES ;
        
    }
    

        
}


+(void)speakOutFinished: (VSSpeechSynthesizer*) synth {
    
    // check if all messages stopped speaking (when last object of array same as the stopped speaker)
    if ([[speakArray lastObject] isEqual:synth] && forcedStop==NO) {
        
        // if volume was not changed then do nothing, else set volume back
        if (wasVolumeChanged==NO) {
            
            logTextIntoFile([NSString stringWithFormat:@"Speak Notification: VOLUME - leaving volume untouched "]) ;
            
        }else {
            
            // get the shared instance
            Class SBMediaController = NSClassFromString(@"SBMediaController") ;

            logTextIntoFile([NSString stringWithFormat:@"Speak Notification: VOLUME - setting back the original system volume "]) ;
                
            // get the end speak volume
            float speakEndVolume = [[SBMediaController sharedInstance] volume] ;
                
            // if start volume different then end volume then write end volume to preferences
            if (speakEndVolume != speakStartVolume) {
                saveNewVolumeToPreferences(speakEndVolume) ;
            }
                
            // turn of the display of volume level once
            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR(SpeakChangeNotification), NULL, NULL, TRUE);
                
            // set back the old volume
            [[SBMediaController sharedInstance] setVolume:currentVolume] ;
            
        }
        
        //if is still incomming call then remove  the ringtone surpress iOS9 only
        if ([[NSClassFromString(@"TUCallCenter") sharedInstance] incomingCall] != nil && [[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
            [[[NSClassFromString(@"TUCallCenter") sharedInstance] incomingCall] setShouldSuppressRingtone:NO];
            logTextIntoFile([NSString stringWithFormat:@"Speak Notification: RINGTONE SUPRPRESS - device has still incomming call, disabling ringtone suppress"]) ;
        }
        
        //added 0.5seconds delay before changing back the route to make sure that the volume is set back
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            //set back the current audio output source
            [self setEndAudioOutput] ;
            
        });
        
        // remove all objects from array and release it
        [speakArray removeAllObjects] ;
        [speakArray release] ;
        speakArray = nil ;
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: ---=== FINISHED SPEAKING - job done ===--- "]) ;
        
    }
    
    // reset the forced stop variable after each speak out, so that the queued speak will work fine
    if (forcedStop == YES) {
        forcedStop = NO ;
    }

    
}


+(void) startSpeaking:(NSString*) speakMsg allowAutoLang:(bool) allowAutoLang {
    
    // get the availble language codes
    NSSet *availableLanguageCodes = [VSSpeechSynthesizer availableLanguageCodes];
    
    //check if auto language is enabled
    NSNumber *autoLang = [preferences objectForKey:@"autoLang"] ;
    bool isAutoLangEnabled = autoLang == nil ? true : [autoLang boolValue];
    
    // get the language code
    NSString *languageCode = [preferences objectForKey:@"languagecode"];
    if(languageCode == nil || languageCode == NULL)
    {
        languageCode = @"en-US" ;
    }
    
    // check if langauge code exists
    if(languageCode != nil && languageCode.length > 0) {
        
        
        //  NSLog(@"--=Wake info: Available Language Codes: %@", availableLanguageCodes);
        BOOL languageCodeFound = [availableLanguageCodes containsObject:languageCode];
        if(!languageCodeFound) {
            //	NSLog(@"--=Wake info: Language Code %@ is not a valid language code. Will use system settings.", languageCode);
            languageCode = nil;
        }
    }
    else {
        languageCode = nil ;
    }
    
    
    // detect language if enabled
    if (isAutoLangEnabled==YES && allowAutoLang==YES) {
        
        NSString *detLang = [self languageForString:speakMsg] ;
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: LANG DETECT - language detect enabled - detected mesage language: %@", detLang]) ;
        
        if (detLang != nil && detLang.length > 0) {
            
            for (NSString *tempLang in availableLanguageCodes) {
                
                // check if english detected then us en-US
                if ([detLang isEqualToString:@"en"]) {
                    //   NSLog(@"Language detected, DETECTED LANG: %@ USING: %@", detLang, @"en-US");
                    languageCode = @"en-US" ;
                    break ;
                }
                
                // search other langauges
                if ([tempLang rangeOfString:detLang].location != NSNotFound){
                    // NSLog(@"Language detected, DETECTED LANG: %@ USING: %@", detLang, tempLang);
                    languageCode = tempLang ;
                    break ;
                }
                
            }
            
        }
        
    }
    
    // speak the message
    [self speakMessage:speakMsg withLang:languageCode] ;
    
    
}

+(void) speakMessage: (NSString*) msg withLang: (NSString*) langCode {
    
    logTextIntoFile([NSString stringWithFormat:@"Speak Notification: SPEAK OUT - speaking message:: %@ , with language:: %@", msg, langCode]) ;
    
    // create speak array with all the current speaks if doesnt exist
    if (speakArray==nil) {
        speakArray = [[NSMutableArray alloc] init] ;
    }
    
    // only at first speak set the volume
    if ([speakArray count] == 0) {
        [self speakOutStarted] ;
    }
    
    // get the speak rate
    NSString *speakRate = [preferences objectForKey:@"speakrate"];
    float rate = [speakRate floatValue] ;
    
    if(rate<0.1f || rate>2.0f) {
        rate = 1.0f;
    }
    
    // set the variable that it is not a forced stop speak, forced stop = not queue speak
    forcedStop = NO ;
    
    //check if queue is enabled or disabled, stops current speak and starts new
    if (isQueueSpeak()==NO && [speakArray count] > 0) {
        forcedStop = YES ; //speak was forced to stop by another speak
        VSSpeechSynthesizer *speaker = [speakArray lastObject] ;
        [speaker stopSpeakingAtNextBoundary:0 error:nil] ;
    }

    /*
     INFO TO MYYSELF
     experminted with AVSpeechSynthesizer 
     https://developer.apple.com/library/ios/documentation/AVFoundation/Reference/AVSpeechSynthesizer_Ref/index.html#//apple_ref/occ/instp/AVSpeechSynthesizer/speaking
     works good but the rate is bugged, check in the future maybe for ios9 if it was fixed???
     
     */

    
    // makes quene
    VSSpeechSynthesizer* tempSpeaker = [[VSSpeechSynthesizer alloc] init] ;
    [tempSpeaker setVolume:1.0f] ;
    [tempSpeaker setRate:rate] ;
    [tempSpeaker setDelegate:[SpeakHelper class]] ;


    if(langCode!=nil){
    // speak with selected language, wait 0.5 sec for the audio route to change
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            [tempSpeaker startSpeakingString:msg withLanguageCode:langCode error:nil] ;
        });
        
    }else {
    // speak with default langauge, wait 0.5 sec for the audio route to change
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            [tempSpeaker startSpeakingString:msg error:nil] ;
        });
        
    }
    
    [speakArray addObject:tempSpeaker] ;
    
}



+(bool) stopSpeaking {
    
    // do nothing if speak array is empty
    if (speakArray==nil) {
        return false ;
    }
    
    if ([speakArray count] > 0) {
        
        // stop all speak request
        for (int a=0; a<[speakArray count]; a++) {
            
            VSSpeechSynthesizer *speaker = [speakArray objectAtIndex:a] ;
            [speaker stopSpeakingAtNextBoundary:0 error:nil] ;
        }
        
        // remove all objects from the array and relese the array after stopped all speak
        [speakArray removeAllObjects] ;
        [speakArray release] ;
        speakArray = nil ;
        
    }
    
    return true ;
    
    
}

#pragma mark AUDIO METHODS
+(void) setStartAudioOutput {
    
    /*
    
    // if already speaking then do nothing
    if ([speakArray count] > 0) {
        return ;
    }
    
    logTextIntoFile([NSString stringWithFormat:@"Speak Notification: SETTING AUDIO START - saving current audio categories and options "]) ;
    
    // save the current category and options
    currentCategory = [[AVAudioSession sharedInstance] category] ;
    currentOptions = [[AVAudioSession sharedInstance] categoryOptions] ;
    
    HBLogDebug(@"---------==========CURRENT CATEGORYYYYYYYY==========-------------- :::--::: %@", currentCategory) ;
    HBLogDebug(@"---------==========CURRENT OPTIONSSSS==========-------------- :::--::: %d", currentOptions) ;
    
    // get the shared instance
    Class BluetoothManager = NSClassFromString(@"BluetoothManager") ;
    Class SBMediaController = NSClassFromString(@"SBMediaController") ;
    
    
    // check if media player is playing a music
    isMediaPlayerPlaying =  [[SBMediaController sharedInstance] isPlaying] ;
    
    if (isMediaPlayerPlaying==YES) {
        
        
        if (isPauseMusic()==YES) {    // pause music when the speak out starts
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:nil];
            [[AVAudioSession sharedInstance] setActive:YES withOptions: 0 error:nil];
            isMediaPlayerPlaying = YES ;
        }else { //dont pause music when the speak out starts
            
            
            // this stops the media player after speak is ended!! Why??
              [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient withOptions:AVAudioSessionCategoryOptionDuckOthers error:nil];
       //     [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient withOptions:0 error:nil];
            [[AVAudioSession sharedInstance] setActive:YES withOptions: 0 error:nil];
            
            // set the currentCategory because changing category at the end stops music playback
         //   currentCategory = [[AVAudioSession sharedInstance] category] ;
        }
        
    }
    
    
    //if device is muted and speak while muted enabled then turn off mute
    NSNumber *speakMuted = [preferences objectForKey:@"mutedspeak"] ;
    bool isMutedSpeak = speakMuted == nil ? false : [speakMuted boolValue];
    
    if([[SBMediaController sharedInstance] isRingerMuted]==YES && isMutedSpeak && [[BluetoothManager sharedInstance] connected]==NO){
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: SETTING AUDIO START - setting audio category for muted speak"]) ;
        
        // route the sound through the speak even if muted
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        
    }
    
    
    //check if bluetooth mono audio enabled
    NSNumber *btAudioMono = [preferences objectForKey:@"btaudiomono"] ;
    bool isBtAudioMono = btAudioMono == nil ? false : [btAudioMono boolValue];
    
    if([[BluetoothManager sharedInstance] connected]==YES && isBtAudioMono==YES) {
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: SETTING AUDIO START - setting audio category and options for bluetooth mono audio "]) ;
        
        // set the sound route to bluetooth
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionAllowBluetooth  error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        
    }
    
    // if speak incomming call then set category to ambient solo and iOS9
    // required for iOS9
    if (isSpeakIncomingCall() == YES && isDeviceInCall() == YES && [[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: SETTING AUDIO START - setting audio category and options for incomming call announce since device running iOS9 "]) ;
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient withOptions:0 error:nil];
        [[AVAudioSession sharedInstance] setActive:YES withOptions: 0 error:nil];
        
    }
    
    
    // force audio through speaker if enabled
    if (isForceSpeaker()) {
        
        // force audio thourgh speaker works only in this category
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        //set the audioSession override
        didOverwriteAudioRoute = [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
        
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: SETTING AUDIO START - forcing audio through the built-in speaker "]) ;
    }
    
    
    
    return ;
    
     */
     
    
    
    // if already speaking then do nothing
    if ([speakArray count] > 0) {
        return ;
    }
    
    //get your app's audioSession singleton object
    AVAudioSession* session = [AVAudioSession sharedInstance];
    
    NSString *setCategory = AVAudioSessionCategoryPlayback ;
    AVAudioSessionCategoryOptions setOptions = AVAudioSessionCategoryOptionDuckOthers ;
    
    [session setDelegate: self];
    
    // get the shared instance
    Class BluetoothManager = NSClassFromString(@"BluetoothManager") ;
    Class SBMediaController = NSClassFromString(@"SBMediaController") ;
    
    // check if media player is playing a music
    isMediaPlayerPlaying = [[SBMediaController sharedInstance] isPlaying] ;
    
    if ([[SBMediaController sharedInstance] isPlaying]==YES) {
        
        if (isPauseMusic()==YES) {    // pause music when the speak out starts
            isMediaPlayerPlaying = YES ;
            [[SBMediaController sharedInstance] pause] ;
        }else { //dont pause music when the speak out starts
            isMediaPlayerPlaying = YES ;
            setCategory = AVAudioSessionCategoryPlayback ;
            setOptions = AVAudioSessionCategoryOptionDuckOthers ;
        }
        
    }
    
    
    //if device is muted and speak while muted enabled then turn off mute
    NSNumber *speakMuted = [preferences objectForKey:@"mutedspeak"] ;
    bool isMutedSpeak = speakMuted == nil ? false : [speakMuted boolValue];
    
    if([[SBMediaController sharedInstance] isRingerMuted]==YES && isMutedSpeak && [[BluetoothManager sharedInstance] connected]==NO){
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: SETTING AUDIO START - setting audio category for muted speak"]) ;
        
        // route the sound through the speak even if muted
        setCategory = AVAudioSessionCategoryPlayback ;
        setOptions = AVAudioSessionCategoryOptionDefaultToSpeaker ;
        
        if (isPauseMusic()==NO) {
            setOptions = AVAudioSessionCategoryOptionDefaultToSpeaker || AVAudioSessionCategoryOptionDuckOthers ;
        }
        
    }
    
    //check if bluetooth mono audio enabled
    NSNumber *btAudioMono = [preferences objectForKey:@"btaudiomono"] ;
    bool isBtAudioMono = btAudioMono == nil ? false : [btAudioMono boolValue];
    
    if([[BluetoothManager sharedInstance] connected]==YES && isBtAudioMono==YES && isForceSpeaker() == NO) {
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: SETTING AUDIO START - setting audio category and options for bluetooth mono audio "]) ;
        
        setCategory = AVAudioSessionCategoryPlayAndRecord ;
        setOptions = AVAudioSessionCategoryOptionAllowBluetooth ;
    
        if (isSpeakIncomingCall() == YES && isDeviceInCall() == YES && [[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
            
            logTextIntoFile([NSString stringWithFormat:@"Speak Notification: SETTING AUDIO START - setting audio category and options for incomming call announce since device running iOS9 "]) ;
            
            setCategory = AVAudioSessionCategoryAmbient ;
            
        }
        
    }
    
    
    // force audio through speaker if enabled
    if (isForceSpeaker()) {
        
        // force audio thourgh speaker works only in this category
        [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:setOptions error:nil];
        //set the audioSession override
        didOverwriteAudioRoute = [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: SETTING AUDIO START - forcing audio through the built-in speaker "]) ;
    }else{
        
        [session setCategory:setCategory withOptions:setOptions error:nil];
    }
    
     [session setActive:YES error:nil];
    
    
    return ;
    
    
    /*
    logTextIntoFile([NSString stringWithFormat:@"Speak Notification: SETTING AUDIO START - preapring to set a new audio route "]) ;
    
    //get your app's audioSession singleton object
    AVAudioSession* session = [AVAudioSession sharedInstance];
    
    // save the current category and options
    currentCategory = [session category] ;
    currentOptions = [session categoryOptions] ;
    
    NSString *setCategory = nil ;
    AVAudioSessionCategoryOptions setOptions ;
    
    NSString *currentCategory = AVAudioSessionCategorySoloAmbient ;
    AVAudioSessionCategoryOptions currentOptions = 0 ;
    
    // get the shared instance
    Class BluetoothManager = NSClassFromString(@"BluetoothManager") ;
    Class SBMediaController = NSClassFromString(@"SBMediaController") ;
    
    
    // check if media player is playing a music
    isMediaPlayerPlaying = [[SBMediaController sharedInstance] isPlaying] ;
    
    if (isMediaPlayerPlaying==YES) {
        
        
        if (isPauseMusic()==YES) {    // pause music when the speak out starts
            setCategory = AVAudioSessionCategorySoloAmbient ;
            setOptions = 0 ;
        }else { //dont pause music when the speak out starts
            
            
            // this stops the media player after speak is ended!! Why??
            //  [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient withOptions:AVAudioSessionCategoryOptionDuckOthers error:nil];
            setCategory = AVAudioSessionCategoryAmbient ;
            setOptions = 0 ;
            
            // set the currentCategory because changing category at the end stops music playback
            currentCategory = setCategory ;
        }
        
    }
    
    // if speak incomming call then set category to ambient solo and iOS9
    // required for iOS9
    if (isSpeakIncomingCall() == YES && isDeviceInCall() == YES && [[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: SETTING AUDIO START - setting audio category and options for incomming call announce since device running iOS9 "]) ;
        
        setCategory = AVAudioSessionCategoryAmbient ;
        setOptions = 0 ;
        
    }
    
    //if device is muted and speak while muted enabled then turn off mute
    NSNumber *speakMuted = [preferences objectForKey:@"mutedspeak"] ;
    bool isMutedSpeak = speakMuted == nil ? false : [speakMuted boolValue];
    
    if([[SBMediaController sharedInstance] isRingerMuted]==YES && isMutedSpeak && [[BluetoothManager sharedInstance] connected]==NO){
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: SETTING AUDIO START - setting audio category for muted speak"]) ;
        
        // route the sound through the speak even if muted
        setCategory = AVAudioSessionCategoryPlayAndRecord ;
        setOptions = AVAudioSessionCategoryOptionDefaultToSpeaker ;
        
    }
    
    
    //check if bluetooth mono audio enabled
    NSNumber *btAudioMono = [preferences objectForKey:@"btaudiomono"] ;
    bool isBtAudioMono = btAudioMono == nil ? false : [btAudioMono boolValue];
    
    if([[BluetoothManager sharedInstance] connected]==YES && isBtAudioMono==YES) {
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: SETTING AUDIO START - setting audio category and options for bluetooth mono audio "]) ;
        
        // set the sound route to bluetooth
        setCategory = AVAudioSessionCategoryPlayAndRecord ;
        setOptions = AVAudioSessionCategoryOptionAllowBluetooth ;
        
    }
    
    if (setOptions != 0) {
        [session setCategory:setCategory withOptions:setOptions error:nil];
    }else{
        [session setCategory:setCategory error:nil];
    }
    
    // force audio through speaker if enabled
    if (isForceSpeaker()) {
        
        // force audio thourgh speaker works only in this category
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        //set the audioSession override
        didOverwriteAudioRoute = [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: SETTING AUDIO START - forcing audio through the built-in speaker "]) ;
    }
    

    [session setActive:YES error:nil];
    */
    
    /*
     Speak Notification find a way: (25.01.2015 - tried that but could not find a way - try to investigate more)
     - This is no complaint but an Idea how you might improve functionality. I suppose many people connect their iPhones via cable to their car hifi for music AND for the phone via BT (mono, you already implemented that one!). Now, when my iPhone is connected like this and I am listening to music and a notification comes in everything works fine, SN interrupts the music and reads out. But when my iPhone is connected like above and I listen to other media like Radio or CD, SN still tries to read out via cable but I cannot hear it because audio is set to the other medium. Could you teach SN to chose the BT when connected to both?
     Thanks for considering,
     */
    
}



+(void) setEndAudioOutput {
    
    
    //get your app's audioSession singleton object
    AVAudioSession* session = [AVAudioSession sharedInstance];
    
    if(didOverwriteAudioRoute){
        //set the audioSession override
        [session overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
        didOverwriteAudioRoute = NO ;
        
       logTextIntoFile([NSString stringWithFormat:@"Speak Notification: SETTING AUDIO END - disabling force audio through the built-in speaker"]) ;
    }
    
    logTextIntoFile([NSString stringWithFormat:@"Speak Notification: SETTING AUDIO END - deactivating audio session"]) ;
    
    [session setActive:NO error:nil];
    
    
    Class SBMediaController = NSClassFromString(@"SBMediaController") ;
                     
    // run a checker if media player is playing
    if (isMediaPlayerPlaying == YES) {
        [self performSelector:@selector(checkIfMediaIsPlaying) withObject:nil afterDelay:3.5f];
    }
    
    if (isMediaPlayerPlaying==YES && [[SBMediaController sharedInstance] isPlaying] == NO && isDeviceInCall() == NO) {
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: SETTING AUDIO END - music was playing before speak out, resuming media player play"]) ;
        
        [[SBMediaController sharedInstance] play] ;
        isMediaPlayerPlaying = NO ;
    }
                         
    
    
    /*
    
    // set the category and options to the default one when one of them changed
    if (![currentCategory isEqualToString:[[AVAudioSession sharedInstance] category]] || currentOptions != [[AVAudioSession sharedInstance] categoryOptions]) {
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: SETTING AUDIO END - audio category or options changed, setting back to default "]) ;
        
        [[AVAudioSession sharedInstance] setCategory:currentCategory withOptions:AVAudioSessionCategorySoloAmbient error:nil];
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
        
        if(didOverwriteAudioRoute){
            //set the audioSession override
            [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
            didOverwriteAudioRoute = NO ;
            
            logTextIntoFile([NSString stringWithFormat:@"Speak Notification: SETTING AUDIO START - disabling force audio through the built-in speaker "]) ;
        }
        
    }
    
    // get the shared instance
    Class SBMediaController = NSClassFromString(@"SBMediaController") ;
    
    // if musik player was playing and pause music was enabled then start the playing again
    if (isMediaPlayerPlaying && isPauseMusic()==YES) {
        
        [[SBMediaController sharedInstance] play] ;
        isMediaPlayerPlaying = NO ; // reset just in case after resuming music
        
    }
    
    [self performSelector:@selector(checkIfMediaIsPlaying) withObject:nil afterDelay:3.0];
     
     */
    
}

+(void)checkIfMediaIsPlaying {
    
    Class SBMediaController = NSClassFromString(@"SBMediaController") ;
    
    if([[SBMediaController sharedInstance] isPlaying] == NO){
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: MEDIA PLAYER - music was playing before, and now not playing - resuming media player playback"]) ;
        
       // [[SBMediaController sharedInstance] pause] ;
        [[SBMediaController sharedInstance] play] ;
    }
    
}


#pragma mark HELPER METHODS
+ (NSString *)languageForString:(NSString *) text{
    
    if (text.length < 200) {
        
        return (NSString *)CFStringTokenizerCopyBestStringLanguage((CFStringRef)text, CFRangeMake(0, text.length));
    } else {
        
        return (NSString *)CFStringTokenizerCopyBestStringLanguage((CFStringRef)text, CFRangeMake(0, 200));
    }
}


///// TIME SPEAK TIMER
#pragma mark TIME SPEAK METHODS
+ (void)stopTimeTimer {
    
    if(timeTimer)
    {
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: TIME SPEAK - canceling scheduled speak time"]) ;
        [timeTimer invalidate];
        timeTimer = nil;
    }
    
    
}


+ (void)startTimeTimer {
    
    if(getSpeakTimeInterval()==kSpeakTimeDisabled){
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: TIME SPEAK - speak time disabled - stoping schedule"]) ;
        return ;
    }
    
    if (timeTimer != nil) {
        [timeTimer invalidate];
        timeTimer = nil;
    }
    
    timeTimer = [[PCPersistentTimer alloc] initWithFireDate:getTimeSpeakTime() serviceIdentifier:@"com.merdok.speaknotification.timespeak" target:self selector:@selector(speakTime) userInfo:nil];
    [timeTimer scheduleInRunLoop:[NSRunLoop mainRunLoop]];
    
    
    logTextIntoFile([NSString stringWithFormat:@"Speak Notification: TIME SPEAK - scheduling next fire date for %@", getTimeSpeakTime()]) ;
    
}

+ (void)speakTime {
    
    if(getSpeakTimeInterval()==kSpeakTimeDisabled){
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: TIME SPEAK - not speaking time - time speak disabled"]) ;
        return ;
    }
    
    
    if(!canSpeakTime()){
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: TIME SPEAK - timer fired too soon, scheduling new time"]) ;
        
        [self startTimeTimer];
        return ;
    }
    
    
    logTextIntoFile([NSString stringWithFormat:@"Speak Notification: TIME SPEAK - posting time speak notification"]) ;
    
    // post the notification to speak the time
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR(SpeakTimeNotification), nil, nil, true);
    
    
    [self startTimeTimer];
    
    
}

///// TIME SPEAK TIMER END

/*
//AUDIO ROUTING
#define IS_DEBUGGING NO
#define IS_DEBUGGING_EXTRA_INFO NO

+ (void) initAudioSessionRouting {
    
    // Called once to route all audio through speakers, even if something's plugged into the headphone jack
    static BOOL audioSessionSetup = NO;
    if (audioSessionSetup == NO) {
        
        // set category to accept properties assigned below
        NSError *sessionError = nil;
        AVAudioSession *session = [AVAudioSession sharedInstance];
        
        [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error: &sessionError];
        
        // fix issue with audio interrupting video recording - allow audio to mix on top of other media
        [session setCategory:AVAudioSessionCategoryPlayback withOptions: AVAudioSessionCategoryOptionMixWithOthers error: &sessionError] ;
        
        // set active
        [session setDelegate:self];
        [session setActive: YES error: nil];
        
        // add listener for audio input changes
        AudioSessionAddPropertyListener (kAudioSessionProperty_AudioRouteChange, onAudioRouteChange, nil );
        AudioSessionAddPropertyListener (kAudioSessionProperty_AudioInputAvailable, onAudioRouteChange, nil );
        
    }
    
    // Force audio to come out of speaker
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    
    
    // set flag
    audioSessionSetup = YES;
}

+ (void) switchToDefaultHardware {

    //get your app's audioSession singleton object
    AVAudioSession* session = [AVAudioSession sharedInstance];
    
    //error handling
    BOOL success;
    NSError* error;
    
    //set the audioSession category.
    //Needs to be Record or PlayAndRecord to use audioRouteOverride:
    
    success = [session setCategory:AVAudioSessionCategoryPlayAndRecord
                             error:&error];
    if (!success)  HBLogDebug(@"AVAudioSession error setting category:%@",error);
    
    //set the audioSession override
    success = [session overrideOutputAudioPort:AVAudioSessionPortOverrideNone
                                         error:&error];
    if (!success)  HBLogDebug(@"AVAudioSession error overrideOutputAudioPort:%@",error);
    
    //activate the audio session
    success = [session setActive:YES error:&error];
    if (!success) { HBLogDebug(@"AVAudioSession error activating: %@",error); }
    else { HBLogDebug(@"audioSession active"); }

    
}

+ (void) forceOutputToBuiltInSpeakers {

    //get your app's audioSession singleton object
    AVAudioSession* session = [AVAudioSession sharedInstance];
    
    //error handling
    BOOL success;
    NSError* error;
    
    //set the audioSession category.
    //Needs to be Record or PlayAndRecord to use audioRouteOverride:
    
    success = [session setCategory:AVAudioSessionCategoryPlayAndRecord
                            error:&error];
    if (!success)  HBLogDebug(@"AVAudioSession error setting category:%@",error);
    
    //set the audioSession override
    success = [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker
                                         error:&error];
    if (!success)  HBLogDebug(@"AVAudioSession error overrideOutputAudioPort:%@",error);
    
    //activate the audio session
    success = [session setActive:YES error:&error];
    if (!success) { HBLogDebug(@"AVAudioSession error activating: %@",error); }
    else { HBLogDebug(@"audioSession active"); }
    
}



void onAudioRouteChange (void* clientData, AudioSessionPropertyID inID, UInt32 dataSize, const void* inData) {
    
    if( IS_DEBUGGING == YES ) {
        HBLogDebug(@"==== Audio Harware Status ====");
        HBLogDebug(@"Current Input:  %@", [SpeakHelper getAudioSessionInput]);
        HBLogDebug(@"Current Output: %@", [SpeakHelper getAudioSessionOutput]);
        HBLogDebug(@"Current hardware route: %@", [SpeakHelper getAudioSessionRoute]);
        HBLogDebug(@"==============================");
    }
    
    if( IS_DEBUGGING_EXTRA_INFO == YES ) {
        NSLog(@"==== Audio Harware Status (EXTENDED) ====");
        CFDictionaryRef dict = (CFDictionaryRef)inData;
        CFNumberRef reason = CFDictionaryGetValue(dict, kAudioSession_RouteChangeKey_Reason);
        CFDictionaryRef oldRoute = CFDictionaryGetValue(dict, kAudioSession_AudioRouteChangeKey_PreviousRouteDescription);
        CFDictionaryRef newRoute = CFDictionaryGetValue(dict, kAudioSession_AudioRouteChangeKey_CurrentRouteDescription);
        HBLogDebug(@"Audio old route: %@", oldRoute);
        HBLogDebug(@"Audio new route: %@", newRoute);
        HBLogDebug(@"=========================================");
    }
    
    
    
}

+ (NSString*) getAudioSessionInput {
    UInt32 routeSize;
    AudioSessionGetPropertySize(kAudioSessionProperty_AudioRouteDescription, &routeSize);
    CFDictionaryRef desc; // this is the dictionary to contain descriptions
    
    // make the call to get the audio description and populate the desc dictionary
    AudioSessionGetProperty (kAudioSessionProperty_AudioRouteDescription, &routeSize, &desc);
    
    // the dictionary contains 2 keys, for input and output. Get output array
    CFArrayRef outputs = CFDictionaryGetValue(desc, kAudioSession_AudioRouteKey_Inputs);
    
    // the output array contains 1 element - a dictionary
    CFDictionaryRef diction = CFArrayGetValueAtIndex(outputs, 0);
    
    // get the output description from the dictionary
    CFStringRef input = CFDictionaryGetValue(diction, kAudioSession_AudioRouteKey_Type);
    return [NSString stringWithFormat:@"%@", input];
}

+ (NSString*) getAudioSessionOutput {
    UInt32 routeSize;
    AudioSessionGetPropertySize(kAudioSessionProperty_AudioRouteDescription, &routeSize);
    CFDictionaryRef desc; // this is the dictionary to contain descriptions
    
    // make the call to get the audio description and populate the desc dictionary
    AudioSessionGetProperty (kAudioSessionProperty_AudioRouteDescription, &routeSize, &desc);
    
    // the dictionary contains 2 keys, for input and output. Get output array
    CFArrayRef outputs = CFDictionaryGetValue(desc, kAudioSession_AudioRouteKey_Outputs);
    
    // the output array contains 1 element - a dictionary
    CFDictionaryRef diction = CFArrayGetValueAtIndex(outputs, 0);
    
    // get the output description from the dictionary
    CFStringRef output = CFDictionaryGetValue(diction, kAudioSession_AudioRouteKey_Type);
    return [NSString stringWithFormat:@"%@", output];
}

+ (NSString*) getAudioSessionRoute {
 
  //   returns the current session route:
  //   * ReceiverAndMicrophone
  //   * HeadsetInOut
  //   * Headset
  //   * HeadphonesAndMicrophone
  //   * Headphone
  //   * SpeakerAndMicrophone
  //   * Speaker
  //   * HeadsetBT
  //   * LineInOut
  //   * Lineout
  //   * Default
 
    
    UInt32 rSize = sizeof (CFStringRef);
    CFStringRef route;
    AudioSessionGetProperty (kAudioSessionProperty_AudioRoute, &rSize, &route);
    
    if (route == NULL) {
        HBLogDebug(@"Silent switch is currently on");
        return @"None";
    }
    return [NSString stringWithFormat:@"%@", route];
}
*/


@end


#pragma mark NOTIFICATION CALLBACKS
static void PreferencesChangedCallbackHelper(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    
    [preferences release];
    reloadPrefs() ;
    
}

#pragma mark ON LOAD FUNCTION
__attribute__((constructor)) static void SpeakNotificationHelper_init() {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    reloadPrefs() ;
    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PreferencesChangedCallbackHelper, CFSTR(PreferencesChangedNotification), NULL, CFNotificationSuspensionBehaviorCoalesce);
    
    [pool release];
}
