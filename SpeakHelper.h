#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>

@interface SpeakHelper : NSObject {
    
}

+(void)speechSynthesizer:(id)synthesizer didStartSpeakingRequest:(id)request ;
+ (void) speechSynthesizer:(NSObject *) synth didFinishSpeaking:(BOOL)didFinish withError:(NSError *) error ;

+(void)speakOutStarted ;
+(void)speakOutFinished ;

+(void) startSpeaking:(NSString*) speakMsg allowAutoLang: (bool) allowAutoLang ;
+(void) speakMessage: (NSString*) msg withLang: (NSString*) langCode ;
+(bool) stopSpeaking;

+(void)  setStartAudioOutput ;
+(void)  setEndAudioOutput ;

+ (NSString *)languageForString:(NSString *) text ;

+ (void)stopTimeTimer ;
+ (void)startTimeTimer ;
+ (void)speakTime ;

@end

