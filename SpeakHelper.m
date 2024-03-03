#import <objc/runtime.h>
#import "SpeakHelper.h"
#import <CaptainHook/CaptainHook.h>
#import "defines.h"

static NSDictionary *preferences = nil;


///////////////// speak
@interface VSSpeechSynthesizer : NSObject
+(id)sharedInstance;
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
-(id)availableLanguageCodes; // since ios14 this is an instance method IOS14 ONLY!!!!
-(id)startSpeakingRequest:(id)arg1 ; // also only ios14
-(BOOL)stopSpeakingAtNextBoundary:(long long)arg1 synchronously:(BOOL)arg2 error:(id*)arg3 ; // also ios14
@end

// for ios14
@interface VSSpeechRequest : NSObject <NSSecureCoding, NSCopying>
+(BOOL)supportsSecureCoding;
-(NSString *)clientBundleIdentifier;
-(void)setClientBundleIdentifier:(NSString *)arg1 ;
-(void)setLanguageCode:(NSString *)arg1 ;
-(NSString *)languageCode;
-(void)setText:(NSString *)arg1 ;
-(void)setVolume:(double)arg1 ;
-(void)setContextInfo:(NSDictionary *)arg1 ;
-(void)setShouldCache:(BOOL)arg1 ;
-(id)init;
-(id)logText;
-(double)volume;
-(void)setOutputPath:(NSURL *)arg1 ;
-(void)setGender:(long long)arg1 ;
-(NSString *)utterance;
-(long long)voiceType;
-(unsigned)audioSessionID;
-(NSDictionary *)contextInfo;
-(void)encodeWithCoder:(id)arg1 ;
-(NSString *)text;
-(void)setVoiceName:(NSString *)arg1 ;
-(void)setPitch:(double)arg1 ;
-(NSString *)voiceName;
-(long long)footprint;
-(void)setUtterance:(NSString *)arg1 ;
-(long long)pointer;
-(void)setRate:(double)arg1 ;
-(id)pauseHandler;
-(BOOL)canLogRequestText;
-(id)stopHandler;
-(void)setStopHandler:(id)arg1 ;
-(id)description;
-(void)setPauseHandler:(id)arg1 ;
-(void)setVoiceType:(long long)arg1 ;
-(void)setFootprint:(long long)arg1 ;
-(id)contextInfoString;
-(NSArray *)customResourceURLs;
-(NSURL *)outputPath;
-(BOOL)disableCompactVoiceFallback;
-(void)setDisableCompactVoiceFallback:(BOOL)arg1 ;
-(NSURL *)resourceListURL;
-(void)setResourceListURL:(NSURL *)arg1 ;
-(NSURL *)resourceSearchPathURL;
-(void)setResourceSearchPathURL:(NSURL *)arg1 ;
-(void)setCustomResourceURLs:(NSArray *)arg1 ;
-(id)logUtterance;
-(BOOL)isSimilarTo:(id)arg1 ;
-(BOOL)retryDeviceOnNetworkStall;
-(void)setRetryDeviceOnNetworkStall:(BOOL)arg1 ;
-(void)setPointer:(long long)arg1 ;
-(BOOL)canUseServerTTS;
-(void)setCanUseServerTTS:(BOOL)arg1 ;
-(unsigned long long)requestCreatedTimestamp;
-(void)setRequestCreatedTimestamp:(unsigned long long)arg1 ;
-(id)initWithCoder:(id)arg1 ;
-(double)rate;
-(void)setAudioSessionID:(unsigned)arg1 ;
-(BOOL)shouldCache;
-(BOOL)forceServerTTS;
-(void)setForceServerTTS:(BOOL)arg1 ;
-(id)copyWithZone:(NSZone*)arg1 ;
-(NSAttributedString *)attributedText;
-(void)setAttributedText:(NSAttributedString *)arg1 ;
-(long long)gender;
-(double)pitch;
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

@interface TUCall : NSObject
@end

@interface TUCallCenter : NSObject
@property(readonly, retain, nonatomic) TUCall *incomingCall;
- (unsigned int)currentVideoCallCount;
@end

@interface SBTelephonyManager
+ (id)sharedTelephonyManager;
@end

@interface SBVolumeControl : NSObject {
}
+(id)sharedInstance;
-(float)_effectiveVolume;
-(void)setActiveCategoryVolume:(float)arg1 ;
@end

@interface SBMainWorkspace : NSObject  {
}
@property (nonatomic,readonly) SBVolumeControl * volumeControl;
+(id)sharedInstance;
@end


/////////// HELPER METHODS /////////
#pragma mark GLOBAL HELPERS
static void logTextIntoFile(NSString* log){
    
    if (kLogEnabled==NO) {
        return ;
    }
    
    /*
     
     NSString *sLogTime = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterMediumStyle];
     
     NSString *logString = [NSString stringWithFormat:@"(%@)%@: %@\n", sLogTime, kTweakName, log] ;
     
     NSString *file = [kTweakName stringByReplacingOccurrencesOfString:@" " withString:@""] ; // remove white spaces
     file = [file lowercaseString]; // lowercase string
     file = [NSString stringWithFormat:@"/Media/Downloads/log_%@.txt", file] ;
     
     NSString *locationFilePath = [NSHomeDirectory() stringByAppendingPathComponent:file] ;
     
     
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
     
     HBLogDebug(@"%@", log);
     
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
    
    //ios8 or above only
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

static bool isForceSpeaker() {
    
    NSNumber *valueNumber = [preferences objectForKey:@"forcespeaker"] ;
    bool value = valueNumber == nil ? NO : [valueNumber boolValue];
    
    return value ;
    
}

static bool stopSpeakInternal(VSSpeechSynthesizer *speaker){
    // if iOS14 then use the new class
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 14.0)
    {
        return [speaker stopSpeakingAtNextBoundary:0 synchronously:true error:nil] ;
    }else{
        //FOR ios13 and below use old stlye
        return [speaker stopSpeakingAtNextBoundary:0 error:nil] ;
    }
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

static int speakCounter = 0 ;
static bool isMediaPlayerPlaying = NO ;
static bool wasVolumeChanged = NO ;
static float currentVolume = 0.6f ;
static float speakStartVolume;
static VSSpeechSynthesizer *tempSpeaker;
static NSMutableArray *speakArray ;
static PCPersistentTimer *timeTimer;
static bool didOverwriteAudioRoute = NO ;

#pragma mark DELEGATE METHODS
+(void)speechSynthesizer:(id)synthesizer didStartSpeakingRequest:(id)request {
    
}



+ (void) speechSynthesizer:(NSObject *) synth didFinishSpeaking:(BOOL)didFinish withError:(NSError *) error  {
    
    [self speakOutFinished] ;
    
}

#pragma mark SPEAK METHODS
+(void)speakOutStarted {
    
    // check if use system volume enabled, if yes then do nothing else save current volume and set the custom volume
    if (isUseSystemVolume()==YES) {
        
        wasVolumeChanged = NO ;
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: VOLUME - use system volume enabled, using current system volume "]) ;
        
    }else {
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: VOLUME - custom volume enabled, setting the speak out volume "]) ;
        
        NSNumber *speakVolume = [preferences objectForKey:@"speakvolume"];
        speakStartVolume = speakVolume == nil ? 0.6f : [speakVolume floatValue];
        
        // make sure that the minimum volume is 0.1 and max 1.0
        if (speakStartVolume < 0.1f) speakStartVolume = 0.1f ;
        if (speakStartVolume > 1.0f) speakStartVolume = 1.0f ;
        
        // turn of the display of volume level once
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR(DisableHUDNotification), NULL, NULL, TRUE);
        
        // if iOS13 then use the new class
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 13.0)
        {
            // save the current volume level
            currentVolume = [[[NSClassFromString(@"SBMainWorkspace") sharedInstance] volumeControl] _effectiveVolume];
            
            // set a new volume level for the speak
            [[[NSClassFromString(@"SBMainWorkspace") sharedInstance] volumeControl] setActiveCategoryVolume: speakStartVolume];
        }else{
            // else use old style
            // get the shared instance
            Class SBMediaController = NSClassFromString(@"SBMediaController") ;
            
            // save the current volume level
            currentVolume = [[SBMediaController sharedInstance] volume] ;
            
            // set a new volume level for the speak
            [[SBMediaController sharedInstance] setVolume:speakStartVolume] ;
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
                [[SBMediaController sharedInstance] _commitVolumeChange:nil] ;
            }
        }
        
        wasVolumeChanged = YES ;
        
    }
    
    // turn of the display of volume level once
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR(SpeakStartedNotification), NULL, NULL, TRUE);
    
    
}


+(void)speakOutFinished {
    
    // decrase the speak counter
    speakCounter-- ;
    
    // check if all messages stopped speaking
    if (speakCounter<=0) {
        
        // if volume was not changed then do nothing, else set volume back
        if (wasVolumeChanged==NO) {
            
            logTextIntoFile([NSString stringWithFormat:@"Speak Notification: VOLUME - leaving volume untouched "]) ;
            
        }else {
            
            logTextIntoFile([NSString stringWithFormat:@"Speak Notification: VOLUME - setting back the original system volume "]) ;
            
            // turn of the display of volume level once
            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR(DisableHUDNotification), NULL, NULL, TRUE);
            
            // if iOS13 then use the new class
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 13.0)
            {
                // get the end speak volume
                float speakEndVolume = [[[NSClassFromString(@"SBMainWorkspace") sharedInstance] volumeControl] _effectiveVolume];
                
                // if start volume different then end volume then write end volume to preferences
                if (speakEndVolume != speakStartVolume) {
                    saveNewVolumeToPreferences(speakEndVolume) ;
                }
                
                // set back the old volume
                [[[NSClassFromString(@"SBMainWorkspace") sharedInstance] volumeControl] setActiveCategoryVolume: currentVolume];
            }else{
                // else use old style
                // get the shared instance
                Class SBMediaController = NSClassFromString(@"SBMediaController") ;
                
                // get the end speak volume
                float speakEndVolume = [[SBMediaController sharedInstance] volume] ;
                
                // if start volume different then end volume then write end volume to preferences
                if (speakEndVolume != speakStartVolume) {
                    saveNewVolumeToPreferences(speakEndVolume) ;
                }
                
                // set back the old volume
                [[SBMediaController sharedInstance] setVolume:currentVolume] ;
                if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
                    [[SBMediaController sharedInstance] _commitVolumeChange:nil] ;
                }
            }
            
        }
        
        
        //set back the current audio output source
        [self setEndAudioOutput] ;
        
        // reset the speak counter
        speakCounter = 0 ;
        
        // post notification that speak out fiinished
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR(SpeakFinishedNotification), nil, nil, true);
        
        logTextIntoFile([NSString stringWithFormat:@"Speak Notification: ---=== FINISHED SPEAKING - job done ===--- "]) ;
        
    }
    
}


+(void) startSpeaking:(NSString*) speakMsg allowAutoLang:(bool) allowAutoLang {
    
    // get the availble language codes
    NSSet *availableLanguageCodes = nil;
    
    // if iOS14 then use the new class
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 14.0)
    {
        availableLanguageCodes = [[VSSpeechSynthesizer sharedInstance] availableLanguageCodes];
    }else{
        availableLanguageCodes = [VSSpeechSynthesizer availableLanguageCodes];
    }
    
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
    if(languageCode != nil && languageCode.length > 0 && availableLanguageCodes != nil) {
        
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
    
    //set the audio output source (maybe move the the speak function - because of the delay)
    [self setStartAudioOutput] ;
    
    // get the speak rate
    NSString *speakRate = [preferences objectForKey:@"speakrate"];
    float rate = [speakRate floatValue] ;
    
    if(rate<0.1f || rate>2.0f) {
        rate = 1.0f;
    }
    
    // create speak array with all the current speaks if doesnt exist
    if (speakArray==nil) {
        speakArray = [[NSMutableArray alloc] init] ;
    }
    
    //check if queue is enabled or disabled
    NSNumber *queueSpeakingEnabled = [preferences objectForKey:@"enableQueueSpeaking"] ;
    bool isQueueSpeakingEnabled = queueSpeakingEnabled == nil ? true : [queueSpeakingEnabled boolValue];
    
    
    //stops current speak and starts new
    if (isQueueSpeakingEnabled==NO) {
        stopSpeakInternal(tempSpeaker);
        [speakArray removeAllObjects] ;
        speakCounter = 0 ;
    }
    
    
    /*
     INFO TO MYYSELF
     experminted with AVSpeechSynthesizer
     https://developer.apple.com/library/ios/documentation/AVFoundation/Reference/AVSpeechSynthesizer_Ref/index.html#//apple_ref/occ/instp/AVSpeechSynthesizer/speaking
     works good but the rate is bugged, check in the future maybe for ios9 if it was fixed???
     
     */
    
    // makes quene
    tempSpeaker = [[VSSpeechSynthesizer alloc] init] ;
    [tempSpeaker setVolume:1.0f] ;
    [tempSpeaker setRate:rate] ;
    [tempSpeaker setDelegate:[SpeakHelper class]] ;
    
    // if iOS14 then use the new class
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 14.0)
    {
        VSSpeechRequest *newSpeakRequest = [[VSSpeechRequest  alloc] init] ;
        [newSpeakRequest setVolume:1.0f] ;
        [newSpeakRequest setRate:rate] ;
        [newSpeakRequest setLanguageCode:langCode] ;
        [newSpeakRequest setText:msg] ;
        
        [tempSpeaker startSpeakingRequest:newSpeakRequest] ;
    }else{
        //FOR ios13 and below use old stlye
        // speak with selected language
        if(langCode!=nil)
        {
            [tempSpeaker startSpeakingString:msg withLanguageCode:langCode error:nil] ;
            
        }else {
            // speak with default langauge
            [tempSpeaker startSpeakingString:msg error:nil] ;
        }
    }
    
    [speakArray addObject:tempSpeaker] ;
    
    // only at first speak set the volume
    if (speakCounter==0) {
        [self speakOutStarted] ;
    }
    
    // increase the speak counter
    speakCounter++ ;
    
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
            stopSpeakInternal(speaker);
        }
        
        // remove all objects from the array and relese the array after stopped all speak
        [speakArray removeAllObjects] ;
        [speakArray release] ;
        speakArray = nil ;
        
    }
    
    return true ;
    
    
}

#pragma mark AUDIO METHODS
+(void)  setStartAudioOutput {
    
    // if already speaking then do nothing
    if (speakCounter>0) {
        return ;
    }
    
    MerdokLog(@"SETTING AUDIO START - preapring to set a new audio route ") ;
    
    
    //get the app's audioSession singleton object
    AVAudioSession* session = [AVAudioSession sharedInstance];
    
    NSString *setCategory = AVAudioSessionCategoryPlayback ;
    AVAudioSessionCategoryOptions setOptions = AVAudioSessionCategoryOptionDuckOthers ;
    
    // get the shared instance
    Class BluetoothManager = NSClassFromString(@"BluetoothManager") ;
    Class SBMediaController = NSClassFromString(@"SBMediaController") ;
    
    // check if media player is playing a music
    isMediaPlayerPlaying = [[SBMediaController sharedInstance] isPlaying] ;
    
    if ([[SBMediaController sharedInstance] isPlaying]==YES) {
        
        if (isPauseMusic()==YES) {    // pause music when the speak out starts
            isMediaPlayerPlaying = YES ;
            
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.3){
                [[SBMediaController sharedInstance] pauseForEventSource:0] ; // ios 11.3.1
            }else{
                [[SBMediaController sharedInstance] pause] ; // ios < 11.1.2 and lower
            }
            
        }else { //dont pause music when the speak out starts
            setCategory = AVAudioSessionCategoryPlayback ;
            setOptions = AVAudioSessionCategoryOptionDuckOthers ;
        }
        
    }
    
    
    //if device is muted and speak while muted enabled then turn off mute
    NSNumber *speakMuted = [preferences objectForKey:@"mutedspeak"] ;
    bool isMutedSpeak = speakMuted == nil ? false : [speakMuted boolValue];
    
    bool isRingerMuted = NO;
    
    // if iOS13 then use the new class
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 13.0)
    {
        isRingerMuted = [[[NSClassFromString(@"SBMainWorkspace") sharedInstance] ringerControl] isRingerMuted];
    }else{
        // else use old style
        isRingerMuted = [[SBMediaController sharedInstance] isRingerMuted];
    }
    
    if(isRingerMuted==YES && isMutedSpeak && [[BluetoothManager sharedInstance] connected]==NO){
        
        MerdokLog(@"SETTING AUDIO START - setting audio category for muted speak") ;
        
        // route the sound through the speak even if muted
        setCategory = AVAudioSessionCategoryPlayback ;
        setOptions = AVAudioSessionCategoryOptionDefaultToSpeaker ;
        
        if (isPauseMusic()==NO) {
            setOptions = AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionDuckOthers ;
        }
        
    }
    
    //check if bluetooth mono audio enabled
    NSNumber *btAudioMono = [preferences objectForKey:@"btaudiomono"] ;
    bool isBtAudioMono = btAudioMono == nil ? false : [btAudioMono boolValue];
    
    if([[BluetoothManager sharedInstance] connected]==YES && isBtAudioMono==YES && isForceSpeaker() == NO) {
        
        MerdokLog(@"SETTING AUDIO START - setting audio category and options for bluetooth mono audio ") ;
        
        setCategory = AVAudioSessionCategoryPlayAndRecord ;
        setOptions = AVAudioSessionCategoryOptionAllowBluetooth ;
    }
    
    if (isSpeakIncomingCall() == YES && isDeviceInCall() == YES && [[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
        
        MerdokLog(@"SETTING AUDIO START - setting audio category and options for incomming call announce since device running iOS9 ") ;
        
        setCategory = AVAudioSessionCategoryAmbient ;
        
        
    }
    
    
    // force audio through speaker if enabled
    if (isForceSpeaker()) {
        
        // force audio thourgh speaker works only in this category
        [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:setOptions error:nil];
        //set the audioSession override
        didOverwriteAudioRoute = [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
        
        MerdokLog(@"SETTING AUDIO START - forcing audio through the built-in speaker ") ;
    }else{
        
        [session setCategory:setCategory withOptions:setOptions error:nil];
    }
    
    MerdokLog(@"SETTING AUDIO START - activating new audio session") ;
    
    [session setActive:YES error:nil];
    
    /*
     Speak Notification find a way: (25.01.2015 - tried that but could not find a way - try to investigate more)
     - This is no complaint but an Idea how you might improve functionality. I suppose many people connect their iPhones via cable to their car hifi for music AND for the phone via BT (mono, you already implemented that one!). Now, when my iPhone is connected like this and I am listening to music and a notification comes in everything works fine, SN interrupts the music and reads out. But when my iPhone is connected like above and I listen to other media like Radio or CD, SN still tries to read out via cable but I cannot hear it because audio is set to the other medium. Could you teach SN to chose the BT when connected to both?
     Thanks for considering,
     */
    
    
}



+(void)  setEndAudioOutput {
    
    //get your app's audioSession singleton object
    AVAudioSession* session = [AVAudioSession sharedInstance];
    
    if(didOverwriteAudioRoute){
        //set the audioSession override
        [session overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
        didOverwriteAudioRoute = NO ;
        
        MerdokLog(@"SETTING AUDIO END - disabling force audio through the built-in speaker ") ;
    }
    
    MerdokLog(@"SETTING AUDIO END - deactivating audio session") ;
    
    [session setActive:NO error:nil];
    
    
    Class SBMediaController = NSClassFromString(@"SBMediaController") ;
    
    if (isMediaPlayerPlaying==YES && [[SBMediaController sharedInstance] isPlaying] == NO && isDeviceInCall() == NO) {
        
        MerdokLog(@"SETTING AUDIO END - music was playing before speak out, resuming media player play") ;
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.3){
            [[SBMediaController sharedInstance] playForEventSource:0] ; // ios 11.3.1
        }else{
            [[SBMediaController sharedInstance] play] ; // ios < 11.1.2 and lower
        }
        
        isMediaPlayerPlaying = NO ;
    }
    
    
}


#pragma mark HELPER METHODS
+ (NSString *)languageForString:(NSString *) text{
    
    if (text.length < 100) {
        
        return (NSString *)CFStringTokenizerCopyBestStringLanguage((CFStringRef)text, CFRangeMake(0, text.length));
    } else {
        
        return (NSString *)CFStringTokenizerCopyBestStringLanguage((CFStringRef)text, CFRangeMake(0, 100));
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
    
    
    timeTimer = [[PCPersistentTimer alloc] initWithFireDate:getTimeSpeakTime() serviceIdentifier:@"com.merdok.speaknotification.timespeak" target:self selector:@selector(speakTime) userInfo:nil];
    [timeTimer scheduleInRunLoop:[NSRunLoop mainRunLoop]];
    
    
    
    //LOG
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
