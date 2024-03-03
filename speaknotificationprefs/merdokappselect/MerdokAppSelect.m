#import "../Headers/PSViewController.h"
#import "../Headers/PSSpecifier.h"
#import "../Helpers/MerdokAppList.h"

#define SYSTEM_SEC		0
#define USER_SEC	1

@interface UIImage (Private)
+(id)_applicationIconImageForBundleIdentifier:(NSString*)displayIdentifier format:(int)form scale:(CGFloat)scale;
@end

@interface MerdokAppSelect : PSViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *systemAppNames;
@property (nonatomic, strong) NSMutableArray *systemAppIDs;
@property (nonatomic, strong) NSMutableArray *userAppNames;
@property (nonatomic, strong) NSMutableArray *userAppIDs;
@property (nonatomic, strong) NSArray *allAppIDs;
@property (nonatomic, strong) NSMutableArray *enabledApps;
@property (nonatomic, strong) NSNumber *defaultValue;
@property (nonatomic, strong) NSString *prefKey;
@property (nonatomic, strong) NSString *prefAppID;
@property (nonatomic, strong) NSString *prefNotification;
@end


@implementation MerdokAppSelect

- (instancetype)init {
	self = [super init];
	if (self) {
        //
	}
	
	return self;
}

- (void)loadView {
	self.tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds]
												  style:UITableViewStyleGrouped];
	
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.rowHeight = 44.0f;
	
	self.view = self.tableView;
}

- (void)viewDidLoad {
	[super viewDidLoad];
    
    // load the app list
    // system apps
    NSDictionary *systemApps = [[MerdokAppList sharedApplicationList] allSystemApplications];
    
    self.systemAppNames = [NSMutableArray array] ;
    self.systemAppIDs = [NSMutableArray array] ;
    
    // app names
    for (int a = 0; a<[systemApps.allKeys count]; a++) {
        NSString* ident = [systemApps.allKeys objectAtIndex:a] ;
        [self.systemAppNames addObject:systemApps[ident]] ;
    }
    
    // allocate data arrays and sort the arrays
    self.systemAppNames = [[NSMutableArray alloc] initWithArray:[self.systemAppNames sortedArrayUsingSelector:@selector(localizedStandardCompare:)]];
    self.systemAppIDs = [[NSMutableArray alloc] initWithArray:[systemApps keysSortedByValueUsingSelector:@selector(localizedStandardCompare:)]];
    
    // user apps
    NSDictionary *userApps = [[MerdokAppList sharedApplicationList] allUserApplications];
    
    self.userAppNames = [NSMutableArray array] ;
    self.userAppIDs = [NSMutableArray array] ;
    
    // app names
    for (int a = 0; a<[userApps.allKeys count]; a++) {
        NSString* ident = [userApps.allKeys objectAtIndex:a] ;
        [self.userAppNames addObject:userApps[ident]] ;
    }
    
    // allocate data arrays and sort the arrays
    self.userAppNames = [[NSMutableArray alloc] initWithArray:[self.userAppNames sortedArrayUsingSelector:@selector(localizedStandardCompare:)]];
    self.userAppIDs = [[NSMutableArray alloc] initWithArray:[userApps keysSortedByValueUsingSelector:@selector(localizedStandardCompare:)]];
    
    
    self.allAppIDs = [self.systemAppIDs arrayByAddingObjectsFromArray:self.userAppIDs];
    
    self.title = [self.specifier name];
    self.prefKey = [self.specifier propertyForKey:@"key"];
    self.defaultValue = [self.specifier propertyForKey:@"defaultValue"];
    self.prefAppID = [self.specifier propertyForKey:@"defaults"];
    self.prefNotification = [self.specifier propertyForKey:@"PostNotification"];
    /* load preferences */
    
    // init defaultValue if doesnt exists
    if (!self.defaultValue) {
        self.defaultValue = [[NSNumber alloc] initWithBool:NO];
    }
    
    // check user prefs to see if there are enabled apps
    if (self.prefKey) {
        CFPreferencesAppSynchronize((CFStringRef)self.prefAppID);
        CFPropertyListRef value = CFPreferencesCopyAppValue((CFStringRef)self.prefKey, (CFStringRef)self.prefAppID);
        if (value && [(__bridge NSArray *)value isKindOfClass:[NSArray class]]) {
            self.enabledApps = [(__bridge NSMutableArray *)value mutableCopy];
            CFRelease(value);
        }
    }
    
    if (!self.enabledApps) {
        self.enabledApps = [[NSMutableArray alloc] init];
    }
    
}

- (void)syncPrefs:(BOOL)notificate {
	
	CFPreferencesSetAppValue((CFStringRef)self.prefKey, (CFArrayRef)self.enabledApps, (CFStringRef)self.prefAppID);
	
	CFPreferencesAppSynchronize((CFStringRef)self.prefAppID);
	
	if (notificate && self.prefNotification) {
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
											 (CFStringRef)self.prefNotification,
											 NULL, NULL, YES);
	}
    
}

/* TableView Stuff */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == SYSTEM_SEC) {
		return [self.systemAppIDs count];
	} else {
		return [self.userAppIDs count];
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == SYSTEM_SEC) {
		return @"SYSTEM APPS";
	} else {
		return @"USER APPS";
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"MyCellIdentifier";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UISwitch *switchview = [[UISwitch alloc] initWithFrame:CGRectZero];
        [switchview addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = switchview;
        if (self.defaultValue) {
            [switchview setOn: [self.defaultValue boolValue]];
        }
	}
    
    UISwitch *switchView = (UISwitch *)cell.accessoryView;
    UIImage *icon = nil;

	// fetch items and setup cell ...
    if (indexPath.section == SYSTEM_SEC) {
        cell.textLabel.text = self.systemAppNames[indexPath.row];
        switchView.tag = indexPath.row;
        icon = [UIImage _applicationIconImageForBundleIdentifier:self.systemAppIDs[indexPath.row] format:0 scale:[UIScreen mainScreen].scale];
    }else if (indexPath.section == USER_SEC){
        cell.textLabel.text = self.userAppNames[indexPath.row];
        switchView.tag = [self.systemAppIDs count] + indexPath.row;
        icon = [UIImage _applicationIconImageForBundleIdentifier:self.userAppIDs[indexPath.row] format:0 scale:[UIScreen mainScreen].scale];
    }
    
    [self setSwitchValue:switchView];
    
    if (icon) {
        icon = [icon imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        cell.imageView.image = icon;
    }
	
	return cell;
}

- (void)changeSwitch:(UISwitch *)sender{
    
    int itemIndex = sender.tag ;
    
    if ([self.defaultValue boolValue] == YES) {
        // if default value is yes then switches which are off comes into the array
        if([sender isOn]){
            [self.enabledApps removeObject:[self.allAppIDs objectAtIndex:itemIndex]];
        } else{
            [self.enabledApps addObject:[self.allAppIDs objectAtIndex:itemIndex]];
        }
    }else {
        // if default value is no then switches which are on comes into the array
        if([sender isOn]){
            [self.enabledApps addObject:[self.allAppIDs objectAtIndex:itemIndex]];
        } else{
            [self.enabledApps removeObject:[self.allAppIDs objectAtIndex:itemIndex]];
        }
    }
    
    [self syncPrefs:YES];
    
}


// helper to set switch value
- (void) setSwitchValue:(UISwitch *) tmpSwitch {
    
    if ([self.defaultValue boolValue] == YES) {
        // if default value is yes then switches which exists in array needs to be set to off
        if ([self.enabledApps containsObject: [self.allAppIDs objectAtIndex:tmpSwitch.tag]]) {
            [tmpSwitch setOn:NO];
        }else {
            [tmpSwitch setOn:YES];
        }
    }else {
        // if default value is no then switches which exists in array needs to be set to on
        if ([self.enabledApps containsObject: [self.allAppIDs objectAtIndex:tmpSwitch.tag]]) {
            [tmpSwitch setOn:YES];
        }else {
            [tmpSwitch setOn:NO];
        }
    }
    
}

- (void) dealloc
{
    [self.systemAppNames release];
    [self.systemAppIDs release];
    [self.userAppNames release];
    [self.userAppIDs release];
    [self.allAppIDs release];
    [self.enabledApps release];
    [self.prefKey release];
    [self.defaultValue release];
    [self.prefAppID release];
    [self.prefNotification release];
    
    [super dealloc];
    
}

@end
