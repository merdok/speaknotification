#import <objc/runtime.h>
#import "MerdokAppList.h"

//Sources:
// https://github.com/DeviLeo/AppList/blob/master/AppList/AppList/ViewController.m
// https://github.com/rpetrich/AppList/blob/master/ALApplicationList.x

static MerdokAppList *sharedApplicationList;

@implementation MerdokAppList

+ (MerdokAppList *)sharedApplicationList
{
    if (!sharedApplicationList) {
        sharedApplicationList = [[self alloc] init];
    }
    return sharedApplicationList;
}


static inline NSMutableDictionary *dictionaryOfApplicationsList(id<NSFastEnumeration> applications)
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for (id proxy in applications) {
        AppInfo *info = [[AppInfo alloc] initWithLSApplicationProxy:proxy];
        NSString *displayName = info.localizedName;
        if (displayName) {
            NSString *displayIdentifier = info.applicationIdentifier;
            if (displayIdentifier) {
                [result setObject:displayName forKey:displayIdentifier];
            }
        }
        [info release];
    }
    return result;
}

- (NSArray *)listAllInstalledApps {
    Class c = NSClassFromString(@"LSApplicationWorkspace");
    SEL sel = NSSelectorFromString(@"defaultWorkspace");
    NSObject *workspace = [c performSelector:sel];
    SEL selAll = NSSelectorFromString(@"allInstalledApplications");
    NSArray *allInstalledApps = [workspace performSelector:selAll]; // NSArray<LSApplicationProxy *> *
    return allInstalledApps;
}

- (NSDictionary *)applicationsFilteredUsingPredicate:(NSPredicate *)predicate
{
    NSArray *apps = [self listAllInstalledApps];
    if (predicate)
        apps = [apps filteredArrayUsingPredicate:predicate];
    return dictionaryOfApplicationsList(apps);
}

- (NSDictionary *)allApplications
{
    NSArray *apps = [self listAllInstalledApps];
    return dictionaryOfApplicationsList(apps);
}

// an application has a property tags or appTags and there is written if app is hidden
- (NSDictionary *)allNonHiddenApplications
{
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"not (appTags contains 'hidden')"];
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"not (applicationIdentifier contains 'com.apple.webapp')"];
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate1, predicate2]];
    return [self applicationsFilteredUsingPredicate:predicate];
}

- (NSDictionary *)allSystemApplications
{
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"not (appTags contains 'hidden')"];
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"not (applicationIdentifier contains 'com.apple.webapp')"];
    NSPredicate *predicate3 = [NSPredicate predicateWithFormat:@"applicationType == %@", ApplicationTypeSystem];
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate1, predicate2, predicate3]];
    
    return [self applicationsFilteredUsingPredicate:predicate];
}

- (NSDictionary *)allUserApplications
{
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"not (appTags contains 'hidden')"];
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"not (applicationIdentifier contains 'com.apple.webapp')"];
    NSPredicate *predicate3 = [NSPredicate predicateWithFormat:@"applicationType == %@", ApplicationTypeUser];
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate1, predicate2, predicate3]];
    
    return [self applicationsFilteredUsingPredicate:predicate];
}

@end


#pragma mark AppInfo class

// https://github.com/nst/iOS-Runtime-Headers/blob/master/Frameworks/MobileCoreServices.framework/LSApplicationProxy.h

// more properties under: LSApplicationProxy.h

@implementation AppInfo

- (instancetype)initWithLSApplicationProxy:(id)proxy {
    self = [super init];
    if (self) {
        [self parseInfo:proxy];
    }
    return self;
}

- (void)parseInfo:(id)proxy {
    SEL sel_localizedName = NSSelectorFromString(@"localizedName");
    self.localizedName = [proxy performSelector:sel_localizedName];
    
    SEL sel_shortVersionString = NSSelectorFromString(@"shortVersionString");
    self.shortVersionString = [proxy performSelector:sel_shortVersionString];
    
    SEL sel_vendorName = NSSelectorFromString(@"vendorName");
    self.vendorName = [proxy performSelector:sel_vendorName];
    
    SEL sel_applicationIdentifier = NSSelectorFromString(@"applicationIdentifier");
    self.applicationIdentifier = [proxy performSelector:sel_applicationIdentifier];
    
    SEL sel_itemID = NSSelectorFromString(@"itemID");
    self.itemID = [proxy performSelector:sel_itemID];
    
    SEL sel_itemName = NSSelectorFromString(@"itemName");
    self.itemName = [proxy performSelector:sel_itemName];
    
    SEL sel_teamID = NSSelectorFromString(@"teamID");
    self.teamID = [proxy performSelector:sel_teamID];
    
    SEL sel_bundleURL = NSSelectorFromString(@"bundleURL");
    self.bundleURL = [proxy performSelector:sel_bundleURL];
    
    SEL sel_dataContainerURL = NSSelectorFromString(@"dataContainerURL");
    self.dataContainerURL = [proxy performSelector:sel_dataContainerURL];
    
    SEL sel_applicationType = NSSelectorFromString(@"applicationType");
    self.applicationType = [proxy performSelector:sel_applicationType];
    
    SEL sel_applicationVariant = NSSelectorFromString(@"applicationVariant");
    self.applicationVariant = [proxy performSelector:sel_applicationVariant];
    
    SEL sel_appTags = NSSelectorFromString(@"appTags");
    self.appTags = [proxy performSelector:sel_appTags];
}

- (NSString *)description {
    NSString *s = [NSString stringWithFormat:
                   @"localizedName: \n%@\n\n"
                   @"shortVersionString: \n%@\n\n"
                   @"vendorName: \n%@\n\n"
                   @"applicationIdentifier: \n%@\n\n"
                   @"itemID: \n%@\n\n"
                   @"itemName: \n%@\n\n"
                   @"teamID: \n%@\n\n"
                   @"bundleURL: \n%@\n\n"
                   @"dataContainerURL: \n%@\n\n"
                   @"applicationType: \n%@\n\n"
                   @"applicationVariant: \n%@\n\n"
                   @"appTags: \n%@\n\n",
                   _localizedName,
                   _shortVersionString,
                   _vendorName,
                   _applicationIdentifier,
                   _itemID,
                   _itemName,
                   _teamID,
                   _bundleURL,
                   _dataContainerURL,
                   _applicationType,
                   _applicationVariant,
                   _appTags];
    return s;
}

@end

