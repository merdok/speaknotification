#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>

@interface MerdokAppList : NSObject

+ (MerdokAppList *)sharedApplicationList;

- (NSArray *)listAllInstalledApps ;
- (NSDictionary *)applicationsFilteredUsingPredicate:(NSPredicate *)predicate;
- (NSDictionary *)allApplications;
- (NSDictionary *)allNonHiddenApplications;
- (NSDictionary *)allSystemApplications;
- (NSDictionary *)allUserApplications;

@end



#define ApplicationTypeUser     @"User"
#define ApplicationTypeSystem   @"System"

@interface AppInfo : NSObject

@property (nonatomic, strong) NSString *localizedName;
@property (nonatomic, strong) NSString *shortVersionString;
@property (nonatomic, strong) NSString *vendorName;
@property (nonatomic, strong) NSString *applicationIdentifier;
@property (nonatomic, strong) NSString *itemID;
@property (nonatomic, strong) NSString *itemName;
@property (nonatomic, strong) NSString *teamID;
@property (nonatomic, strong) NSString *bundleURL;
@property (nonatomic, strong) NSString *dataContainerURL;
@property (nonatomic, strong) NSString *applicationType;
@property (nonatomic, strong) NSString *applicationVariant;
@property (nonatomic, strong) NSString *appTags;

- (instancetype)initWithLSApplicationProxy:(id)proxy;

@end
