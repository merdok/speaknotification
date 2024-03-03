#define kTweakName @"Speak Notification"
#define TweakIdent CFSTR("com.merdok.speaknotification")
#define PreferencesChangedNotification "com.merdok.speaknotification.prefs"
#define PreferencesFilePath [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/com.merdok.speaknotification.plist"]

//#define kSelfDRMPath Obfuscate.forward_slash.v.a.r.forward_slash.l.i.b.forward_slash.d.p.k.g.forward_slash.i.n.f.o.forward_slash.c.o.m.dot.m.e.r.d.o.k.dot.s.p.e.a.k.n.o.t.i.f.i.c.a.t.i.o.n.dot.l.i.s.t

//#define kReleaseDRMPath Obfuscate.forward_slash.v.a.r.forward_slash.l.i.b.forward_slash.d.p.k.g.forward_slash.i.n.f.o.forward_slash.o.r.g.dot.t.h.e.b.i.g.b.o.s.s.dot.s.p.e.a.k.n.o.t.i.f.i.c.a.t.i.o.n.dot.l.i.s.t

#define kCustomMsgsLocation @"/var/mobile/Documents/Speak Notification/Messages/"

#define DisableHUDNotification "com.merdok.speaknotification2.disableHUD"
#define SpeakStartedNotification "com.merdok.speaknotification.speakstarted"
#define SpeakFinishedNotification "com.merdok.speaknotification.speakfinished"
#define SpeakTimeNotification "com.merdok.speaknotification.speak.time"

#define kSpeakSameAuto 0
#define kSpeakSameForceNo 1
#define kSpeakSameForceYes 2

#define kAnywhere 0
#define kLocked 1
#define kUnlocked 2

#define kConditionNotSelected 0
#define kConditionNotMet 1
#define kConditonMet 2

#define kSpeakTimeDisabled 0
#define kSpeakTime15m 1
#define kSpeakTime30m 2
#define kSpeakTime1h 3

#define kSpeakBatteryDisabled 0
#define kSpeakBatteryLowLevelsOnly 120

#define kBatteryStateNotCharging NO
#define kBatteryStateCharging YES

#define kNoContactSpeak 0
#define kNoContactDontSpeak 1
#define kNoContactLast4 2
#define kNoContactReplace 3

#define kTouchIDEventSucceeded 3
#define kTouchIDEventSucceededIOS9 4
#define kTouchIDeventFailed 10

#define kFilterWhitelist 0
#define kFilterBlacklist 1


#define kLoadAlert 223
#define kSaveAlert 224
#define kDeleteAlert 225
#define kOverwriteAlert 226

#define kProfileAppName @"custommsgappname"
#define kProfileBundleID @"custommsgbundleid"
#define kProfileCustomMsg @"custommsgmessage"


#define kLogEnabled NO


#define UiColorFromRGBA(r, g, b, a) \
[UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)/255.0]

#define MerdokLog(s, ...) \
logTextIntoFile([NSString stringWithFormat:(s), ##__VA_ARGS__])
