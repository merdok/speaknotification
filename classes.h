@interface SBApplication : NSObject {
}
- (id)bundleIdentifier;
- (BOOL)isRunning;
@end


@interface SpringBoard : UIApplication
@property (nonatomic, retain, readonly) SBApplication *_accessibilityFrontMostApplication;
@end


@interface SBBulletinBannerController : NSObject
+ (id)sharedInstance;
- (void)observer:(id)arg1 addBulletin:(id)arg2 forFeed:(unsigned long long)arg3;
@end


//////// BBBulletin
@interface BBBulletin : NSObject // main klas , sprawdz tu jezeli szukasz zabawy
@property(readonly, nonatomic) NSString *topic;
- (id)composedAttachmentImageForKey:(id)arg1 withObserver:(id)arg2;
- (id)sectionIcon;
- (id)sectionDisplayName;
- (int)iPodOutAlertType;
- (unsigned int)subtypePriority;
- (BOOL)visuallyIndicatesWhenDateIsInFuture;
- (BOOL)bannerShowsSubtitle;
- (BOOL)preservesUnlockActionCase;
- (BOOL)inertWhenLocked;
- (BOOL)suppressesMessageForPrivacy;
- (BOOL)coalescesWhenLocked;
- (id)alertSuppressionAppIDs;
- (id)unlockActionLabel;
- (id)fullUnlockActionLabel;
- (id)missedBannerDescriptionFormat;
- (BOOL)showsDateInFloatingLockScreenAlert;
- (BOOL)orderSectionUsingRecencyDate;
- (BOOL)usesVariableLayout;
- (unsigned int)messageNumberOfLines;
- (BOOL)showsSubtitle;
- (id)syncHash;
- (unsigned int)realertCount;
- (void)setExpiresOnPublisherDeath:(BOOL)arg1;
- (BOOL)expiresOnPublisherDeath;
- (id)safeDescription;
- (void)addLifeAssertion:(id)arg1;
- (id)actionForResponse:(id)arg1;
- (id)responseForExpireAction;
- (id)responseForSnoozeAction;
- (id)responseForButtonActionAtIndex:(unsigned int)arg1;
- (id)responseForAcknowledgeAction;
- (id)responseForDefaultAction;
- (void)setSnoozeAction:(id)arg1;
- (id)snoozeAction;
- (void)setExpireAction:(id)arg1;
- (id)expireAction;
- (void)setAcknowledgeAction:(id)arg1;
- (id)acknowledgeAction;
- (void)setAlternateAction:(id)arg1;
- (void)setDefaultAction:(id)arg1;
- (int)primaryAttachmentType;
- (id)_safeDescription:(BOOL)arg1;
- (void)setAlertSuppressionAppIDs_deprecated:(id)arg1;
- (id)alertSuppressionAppIDs_deprecated;
- (void)setRealertCount_deprecated:(unsigned int)arg1;
- (unsigned int)realertCount_deprecated;
- (void)setBulletinVersionID:(id)arg1;
- (id)bulletinVersionID;
- (void)setUsesExternalSync:(BOOL)arg1;
- (BOOL)usesExternalSync;
- (void)setPublicationDate:(id)arg1;
- (id)publicationDate;
- (void)setLastInterruptDate:(id)arg1;
- (id)lastInterruptDate;
- (void)setAlertSuppressionContexts:(id)arg1;
- (id)alertSuppressionContexts;
- (void)setExpirationEvents:(unsigned int)arg1;
- (unsigned int)expirationEvents;
- (void)setWantsFullscreenPresentation:(BOOL)arg1;
- (BOOL)wantsFullscreenPresentation;
- (void)setUnlockActionLabelOverride:(id)arg1;
- (id)unlockActionLabelOverride;
- (void)setAttachments:(id)arg1;
- (void)setSound:(id)arg1;
- (id)sound;
- (void)setClearable:(BOOL)arg1;
- (BOOL)clearable;
- (void)setAccessoryStyle:(unsigned int)arg1;
- (unsigned int)accessoryStyle;
- (void)setDateIsAllDay:(BOOL)arg1;
- (BOOL)dateIsAllDay;
- (void)setDateFormatStyle:(int)arg1;
- (int)dateFormatStyle;
- (void)setRecencyDate:(id)arg1;
- (id)recencyDate;
- (void)setHasEventDate:(BOOL)arg1;
- (BOOL)hasEventDate;
- (void)setStarkBannerContent:(id)arg1;
- (id)starkBannerContent;
- (void)setModalAlertContent:(id)arg1;
- (id)modalAlertContent;
- (void)setShowsMessagePreview:(BOOL)arg1;
- (BOOL)showsMessagePreview;
- (void)setSectionSubtype:(int)arg1;
- (int)sectionSubtype;
- (void)setAddressBookRecordID:(int)arg1;
- (int)addressBookRecordID;
- (void)setDismissalID:(id)arg1;
- (id)dismissalID;
- (void)setPublisherBulletinID:(id)arg1;
- (id)publisherBulletinID;
- (void)setSubsectionIDs:(id)arg1;
- (id)subsectionIDs;
- (id)attachmentsCreatingIfNecessary:(BOOL)arg1;
- (unsigned int)numberOfAdditionalAttachmentsOfType:(int)arg1;
- (unsigned int)numberOfAdditionalAttachments;
- (void)setSectionID:(id)arg1;
- (id)bulletinID;
- (void)setBulletinID:(id)arg1;
- (BOOL)sectionDisplaysCriticalBulletins;
- (id)alternateAction;
- (void)setButtons:(id)arg1;
- (id)sectionID;
- (void)setRecordID:(id)arg1;
- (id)recordID;
- (id)topic;
- (void)setExpirationDate:(id)arg1;
- (id)expirationDate;
- (void)setEndDate:(id)arg1;
- (id)endDate;
- (void)setTitle:(id)arg1;
- (id)title;
- (id)attachments;
- (void)setContent:(id)arg1;
- (void)setActions:(id)arg1;
- (id)content;
- (id)message;
- (id)init;
- (id)timeZone;
- (id)date;
- (void)setTimeZone:(id)arg1;
- (id)actions;
- (id)defaultAction;
- (void)setSection:(id)arg1;
- (id)buttons;
- (void)setMessage:(id)arg1;
- (id)subtitle;
- (void)setSubtitle:(id)arg1;
- (void)setDate:(id)arg1;
- (id)section;
- (BOOL)bulletinAlertShouldOverrideQuietMode;
- (id)actionBlockForButton:(id)arg1;
- (id)defaultActionBlock;
- (void)killSound;
- (BOOL)playSound;
@end
////////////////


//////// SBMediaController
@interface SBMediaController
+ (id)sharedInstance;
- (void)decreaseVolume;
- (void)increaseVolume;
@property(nonatomic, getter=isRingerMuted) _Bool ringerMuted;
- (_Bool)muted;
- (void)setVolume:(float)arg1;
- (float)volume;
- (_Bool)stop;
- (_Bool)togglePlayPause;
- (_Bool)pause;
- (_Bool)play;
- (_Bool)isMovie;
- (_Bool)isPaused;
- (_Bool)isPlaying;

// ios 11.3.1
- (_Bool)pauseForEventSource:(long long)arg1;
- (_Bool)playForEventSource:(long long)arg1;
@end
////////////////

///////////////// speak
@interface VSSpeechSynthesizer : NSObject
+ (BOOL)isSystemSpeaking;
+ (id)availableLanguageCodes;
+ (id)availableVoicesForLanguageCode:(id)arg1;
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

//////// VolumeControl
@interface VolumeControl
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
- (BOOL)audioConnected;
- (id)connectedDevices;
@end
////////////////

//////// BLUETOOTH DEVICE
@interface BluetoothDevice : NSObject
- (BOOL)isServiceSupported:(unsigned int)arg1;
- (void)setSyncGroup:(int)arg1 enabled:(BOOL)arg2;
- (id)syncGroups;
- (void)endVoiceCommand;
- (void)startVoiceCommand;
- (void)unpair;
- (void)acceptSSP:(int)arg1;
- (void)setPIN:(id)arg1;
- (void)connectWithServices:(unsigned int)arg1;
- (void)setServiceSetting:(unsigned int)arg1 key:(id)arg2 value:(id)arg3;
- (id)getServiceSetting:(unsigned int)arg1 key:(id)arg2;
- (BOOL)supportsBatteryLevel;
- (unsigned int)connectedServicesCount;
- (unsigned int)connectedServices;
- (BOOL)connected;
- (BOOL)paired;
- (id)scoUID;
- (unsigned int)minorClass;
- (unsigned int)majorClass;
- (BOOL)_isNameCached;
- (void)_clearName;
- (BOOL)isAccessory;
- (void)disconnect;
- (void)connect;
- (int)compare:(id)arg1;
- (id)name;
- (void)dealloc;
- (id)description;
- (int)batteryLevel;
- (int)type;
- (id)address;
@end
////////////////

//////// SBLOCKSCRENNMANAGER
@interface SBLockScreenManager : NSObject
+ (id)sharedInstance;
@property(readonly) _Bool isUILocked;
@end
////////////////


//////// SBULLETINSOUNDCONTROLLER
@interface SBBulletinSoundController : NSObject
+ (id)sharedInstanceIfExists;
+ (id)sharedInstance;
+ (id)_sharedInstanceCreateIfNecessary:(_Bool)arg1;
- (void)bulletinWindowStoppedBeingBusy;
- (unsigned long long)quietModeState;
- (_Bool)quietModeEnabled;
@end
////////////////


//////// SBHUDVIEW
@interface SBHUDView
- (id)initWithHUDViewLevel:(int)arg1;
@end
////////////////

//////// CUTWIFIMANAGER
@interface CUTWiFiManager : NSObject
+ (id)sharedInstance;
- (void)setLastWiFiPowerInfo:(id)arg1;
- (id)lastWiFiPowerInfo;
- (void)setDelegateMap:(id)arg1;
- (id)delegateMap;
- (void)setLinkToken:(int)arg1;
- (int)linkToken;
- (void)setDynamicStore:(void*)arg1;
- (void*)dynamicStore;
- (void)setCurrentNetwork:(void*)arg1;
- (void*)currentNetwork;
- (void)setWifiDevice:(void*)arg1;
- (void*)wifiDevice;
- (void)setWifiManager:(void*)arg1;
- (void*)wifiManager;
- (void)setLock:(id)arg1;
- (BOOL)isWiFiCaptive;
- (BOOL)_isPrimaryCellular;
- (id)currentSSID;
- (id)currentWiFiNetworkPowerUsage;
- (double)_wifiMeasurementErrorForInterval:(double)arg1;
- (BOOL)isWiFiEnabled;
- (BOOL)isWiFiAssociated;
- (id)wiFiScaledRate;
- (id)wiFiScaledRSSI;
- (id)wiFiSignalStrength;
- (BOOL)willTryToSearchForWiFiNetwork;
- (BOOL)willTryToAutoAssociateWiFiNetwork;
- (BOOL)isHostingWiFiHotSpot;
- (void)removeDelegate:(id)arg1;
- (void)addDelegate:(id)arg1;
- (void)_createDynamicStore;
- (void)_createWiFiManager;
- (id)init;
- (void)dealloc;
- (id)lock;
@end
////////////////

//////// SBAPPLICATIONCONTROLLER
@interface SBApplicationController
+ (id)sharedInstance;
- (id)applicationWithBundleIdentifier:(id)arg1;
@end

@interface SBApplicationController (ios7)
+ (id)sharedInstance;
- (id)applicationsWithBundleIdentifier:(id)arg1;
@end
////////////////


@interface SBUIController : NSObject
- (int)batteryCapacityAsPercentage;
- (_Bool)isOnAC;
@end

//////////// BITESMS SUPPORT CLASSES
@interface SBAlertItemsController
- (void)activateAlertItem:(id)arg1;
@end


@interface CKIMMessage : NSObject
- (id)IMMessage;
@end


@interface IMMessage : NSObject
- (id)senderName;
- (id)text;
@end
////////////////

//////////// INCOMMIng CALL CASSES

@interface TUCallCenter : NSObject
@property (nonatomic,readonly) BOOL hasCurrentCalls;
@property (nonatomic,readonly) BOOL hasCurrentAudioCalls;
@property (nonatomic,readonly) BOOL hasCurrentVideoCalls; 
+ (BOOL)emergencyCallBackModeIsActive;
+ (BOOL)shouldDisableAppFeatures;
+ (BOOL)isIMAVChatHostProcess;
+ (BOOL)isInCallServiceProcess;
+ (id)sharedInstance;
+ (id)_sharedInstanceWithDaemonDelegate:(id)arg1;
+ (void *)sharedAddressBook;
@property(retain, nonatomic) NSMutableArray *conferenceParticipantCalls; // @synthesize conferenceParticipantCalls=_conferenceParticipantCalls;
@property(retain, nonatomic) NSMutableArray *displayedCalls; // @synthesize displayedCalls=_displayedCalls;
- (void)endEmergencyCallBackMode;
- (void)_callStatusChangedInternal:(id)arg1;
- (void)filteredIncomingIMAVChat:(id)arg1;
- (void)createdOutgoingIMAVChat:(id)arg1;
- (void)invitedToIMAVChat:(id)arg1;
- (void)daemonConnected:(id)arg1;
- (void)handleChatVideoStalledDidChange:(id)arg1;
- (void)handleChatVideoQualityDidChange:(id)arg1;
- (void)handleChatRemotePauseDidChange:(id)arg1;
- (void)handleChatRemoteScreenDidChange:(id)arg1;
- (void)handleChatRemoteVideoDidChange:(id)arg1;
- (void)handleChatFirstRemoteFrameArrived:(id)arg1;
- (void)handleChatFirstPreviewFrameArrived:(id)arg1;
- (void)handleChatInvitationSent:(id)arg1;
- (id)_videoCallUserInfoForUserInfo:(id)arg1;
- (void)handleChatSendingAudioChangedNotification:(id)arg1;
- (void)handleChatConferenceMetadataUpdated:(id)arg1;
- (void)handleChatStateChanged:(id)arg1;
- (void)_handleCallEnded:(id)arg1 withReason:(unsigned int)arg2 error:(int)arg3;
- (void)handleCallModelStateChanged:(id)arg1;
- (void)handleCallerIDChanged:(id)arg1;
- (void)handleCallSubTypeChanged:(id)arg1;
- (void)handleCallerUnavailableForCall:(id)arg1 reason:(unsigned int)arg2 error:(int)arg3;
- (id)_callerUnavailableUserInfoForCall:(id)arg1 reason:(unsigned int)arg2 error:(int)arg3;
- (void)handleCallFailed:(id)arg1;
- (void)handleFilteredCall:(id)arg1 userInfo:(id)arg2;
- (void)handleFilteredCall:(id)arg1;
- (void)handleCallAudioUpdatedForCall:(id)arg1 userInfo:(id)arg2;
- (void)handleCallConnected:(id)arg1;
- (void)handleCallStatusOnDefaultPairedDeviceChanged:(id)arg1;
- (void)handleCallStatusChanged:(id)arg1 userInfo:(id)arg2;
- (void)handleCallStatusChanged:(id)arg1;
- (id)_callStatusUserInfoForUserInfo:(id)arg1;
- (BOOL)isSendToVoicemailAllowed;
- (BOOL)isHoldAndAnswerAllowed;
- (BOOL)isEndAndAnswerAllowed;
- (BOOL)isHardPauseAvailable;
- (BOOL)isTakingCallsPrivateAllowed;
- (BOOL)canTakeCallsPrivate;
- (int)ambiguityState;
- (BOOL)isAmbiguous;
- (BOOL)isAddCallAllowed;
- (BOOL)isHoldAllowed;
- (BOOL)isMergeable;
- (BOOL)isSwappable;
- (void)disconnectNonRelayingCalls;
- (void)disconnectRelayingCalls;
- (void)requestHandoffForAllCalls;
- (void)disconnectAllCalls;
- (void)disconnectCurrentCallAndActivateHeld;
- (void)disconnectCall:(id)arg1 withReason:(int)arg2;
- (void)disconnectCall:(id)arg1;
- (void)resumeCall:(id)arg1;
- (void)swapCalls;
- (void)endHeldAndAnswerCall:(id)arg1;
- (void)endActiveAndAnswerCall:(id)arg1;
- (void)holdActiveAndAnswerCall:(id)arg1;
- (void)answerCall:(id)arg1 withSourceIdentifier:(id)arg2 wantsHoldMusic:(BOOL)arg3;
- (void)answerCallWithHoldMusic:(id)arg1;
- (void)answerCall:(id)arg1 withSourceIdentifier:(id)arg2;
- (void)answerCall:(id)arg1;
- (id)displayedCallFromCalls:(id)arg1;
- (void)sendFieldModeDigits:(id)arg1;
- (id)dialVoicemail;
- (id)dialEmergency:(id)arg1;
- (id)dial:(id)arg1 callID:(int)arg2 service:(int)arg3 sourceIdentifier:(id)arg4 isRelayCall:(BOOL)arg5;
- (id)dial:(id)arg1 callID:(int)arg2 service:(int)arg3 sourceIdentifier:(id)arg4;
- (id)dial:(id)arg1 callID:(int)arg2 service:(int)arg3;
- (id)dial:(id)arg1 service:(int)arg2;
- (id)_dialTelephonyCall:(id)arg1 callID:(int)arg2 sourceIdentifier:(id)arg3 callType:(struct __CFString *)arg4 isRelayCall:(BOOL)arg5;
- (id)_dialFaceTimeCall:(id)arg1 isVideo:(BOOL)arg2 callID:(int)arg3 sourceIdentifier:(id)arg4;
- (BOOL)allCallsAreOfService:(int)arg1;
- (id)callsHostedOrAnEndpointElsewhere;
- (id)callsWithAnEndpointElsewhere;
- (id)callsHostedElsewhere;
- (BOOL)anyCallIsEndpointOnCurrentDevice;
- (BOOL)anyCallIsHostedOnCurrentDevice;
- (BOOL)canInitiateCallForService:(int)arg1;
- (BOOL)canInitiateCalls;
- (id)sourceAccount:(BOOL)arg1;
- (id)proxyCallWithDestinationID:(id)arg1 service:(int)arg2 status:(int)arg3 sourceIdentifier:(id)arg4 outgoing:(BOOL)arg5 conferenceIdentifier:(id)arg6 voicemail:(BOOL)arg7 callerNameFromNetwork:(id)arg8;
- (unsigned int)callCountOnDefaultPairedDevice;
- (id)callGroupsOnDefaultPairedDevice;
- (id)callsOnDefaultPairedDevice;
- (id)_allCalls;
- (id)callWithCallUUID:(id)arg1;
- (id)callWithUniqueProxyIdentifier:(id)arg1;
- (id)callWithStatus:(int)arg1;
- (id)currentAudioAndVideoCalls;
- (int)currentCallCount;
- (id)_currentCalls:(BOOL)arg1;
- (id)currentCalls;
- (id)currentCallGroups;
- (id)_callGroupsFromCalls:(id)arg1;
@property(readonly, retain, nonatomic) NSArray *incomingCalls;
//@property(readonly, retain, nonatomic) TUCall *incomingCall;
- (void)dealloc;
- (id)initWithDaemonDelegate:(id)arg1;
- (void)_handleCallControlFailure:(id)arg1;
- (id)_callControlFailureUserInfoForUserInfo:(id)arg1;
- (id)conferenceCall;
- (void)forceUpdateOfCallList;
- (void)forceDisconnectOfCall:(id)arg1;
- (void)forceCallOutOfConference:(id)arg1;
- (void)forceCallIntoConference:(id)arg1;
- (void)forceCallActive:(id)arg1;
- (void)resumeCallChangeNotifications;
- (void)suspendCallChangeNotifications;
- (id)displayedCallsNotIncludingIncomingCall;
- (id)displayedCall;
- (BOOL)canMergeCalls;
- (BOOL)justAnIncomingCallExists;
- (BOOL)inOutgoingCall;
- (BOOL)inCall;
- (void)_updateCallCount:(id)arg1 force:(BOOL)arg2;
- (void)_updateActiveCalls:(id)arg1;
- (void)_setConferenceParticipants:(id)arg1;
- (void)_setActiveCalls:(id)arg1;
- (void)_removeActiveCall:(id)arg1;
- (void)_addActiveCall:(id)arg1;
- (void)_postConferenceParticipantsChanged;
- (void)_postDisplayedCallsChanged;
- (void)_setIncomingCall:(id)arg1;
- (void)_resetState;
- (unsigned int)currentVideoCallCount;
- (id)allNonFinalVideoCalls;
- (id)currentVideoCalls;
- (id)videoCallWithStatus:(int)arg1;
- (id)currentVideoCall;
- (id)activeVideoCall;
- (id)incomingVideoCall;
@end




@interface TUCall : NSObject
+ (BOOL)supportsSecureCoding;
@property(nonatomic, getter=isConnectingToRelay) BOOL connectingToRelay; // @synthesize connectingToRelay=_connectingToRelay;
@property(nonatomic) BOOL allowsTTYSettingChanges; // @synthesize allowsTTYSettingChanges=_allowsTTYSettingChanges;
@property(nonatomic) BOOL requiresAudioReinterruption; // @synthesize requiresAudioReinterruption=_requiresAudioReinterruption;
@property(nonatomic) int transitionStatus; // @synthesize transitionStatus=_transitionStatus;
@property(nonatomic) int provisionalHoldStatus; // @synthesize provisionalHoldStatus=_provisionalHoldStatus;
@property(copy, nonatomic) NSString *isoCountryCode; // @synthesize isoCountryCode=_isoCountryCode;
@property(copy, nonatomic) NSString *displayName; // @synthesize displayName=_displayName;
@property(copy, nonatomic) NSString *sourceIdentifier; // @synthesize sourceIdentifier=_sourceIdentifier;
@property(copy, nonatomic) NSString *uniqueProxyIdentifier; // @synthesize uniqueProxyIdentifier=_uniqueProxyIdentifier;
@property(nonatomic) BOOL hasUpdatedAudio; // @synthesize hasUpdatedAudio=_hasUpdatedAudio;
@property(nonatomic, getter=isConnected) BOOL connected; // @synthesize connected=_connected;
@property(nonatomic) BOOL wantsHoldMusic; // @synthesize wantsHoldMusic=_wantsHoldMusic;
@property(nonatomic, getter=isEndpointOnCurrentDevice) BOOL endpointOnCurrentDevice; // @synthesize endpointOnCurrentDevice=_endpointOnCurrentDevice;
@property(nonatomic, getter=isRequestingHandoff) BOOL requestingHandoff; // @synthesize requestingHandoff=_requestingHandoff;
@property(nonatomic) int faceTimeIDStatus; // @synthesize faceTimeIDStatus=_faceTimeIDStatus;
@property(nonatomic) int disconnectedReason; // @synthesize disconnectedReason=_disconnectedReason;
@property(copy) NSString *suggestedDisplayName; // @synthesize suggestedDisplayName=_suggestedDisplayName;
- (void)encodeWithCoder:(id)arg1;
- (id)initWithCoder:(id)arg1;
- (void)updateWithCall:(id)arg1;
@property(readonly, copy, nonatomic) NSString *errorAlertMessage;
@property(readonly, copy, nonatomic) NSString *errorAlertTitle;
- (BOOL)hasSupport:(int)arg1;
- (id)contactImageDataWithFormat:(int)arg1;
- (void)_loadCallDetails;
- (int)abUID;
@property(readonly, retain, nonatomic) NSString *conferenceIdentifier;
@property(readonly, retain, nonatomic) NSData *remoteFrequency;
@property(readonly, retain, nonatomic) NSData *localFrequency;
@property(readonly, nonatomic) float localVolume;
- (BOOL)isTTY;
- (BOOL)setDownlinkMuted:(BOOL)arg1;
- (BOOL)isDownlinkMuted;
- (BOOL)setUplinkMuted:(BOOL)arg1;
- (BOOL)isUplinkMuted;
- (BOOL)setMuted:(BOOL)arg1;
- (BOOL)isMuted;
@property(readonly, nonatomic) BOOL playsConnectedSound;
- (BOOL)needsManualInCallSounds;
- (BOOL)managesAudioInterruptions;
- (id)audioMode;
- (id)audioCategory;
@property(readonly, nonatomic) BOOL statusIsProvisional;
- (int)callStatus;
@property(readonly, nonatomic, getter=isStatusFinal) BOOL statusFinal;
@property(readonly, nonatomic) int status;
- (id)totalDataUsed;
- (id)callDurationString;
- (double)callDuration;
- (BOOL)isEqual:(id)arg1;
- (long)causeCode;
@property(readonly, copy, nonatomic) NSString *callHistoryIdentifier;
@property(readonly, copy, nonatomic) NSString *callUUID;
@property(readonly, nonatomic) int callIdentifier;
@property(readonly, nonatomic, getter=isVoicemail) BOOL voicemail;
- (BOOL)isAlerting;
- (BOOL)isEmergencyCall;
- (void)setWasDialedFromEmergencyUI:(BOOL)arg1;
- (BOOL)wasDialedFromEmergencyUI;
- (void)setWasDialAssisted:(BOOL)arg1;
- (BOOL)wasDialAssisted;
@property(readonly, nonatomic, getter=isHostedOnCurrentDevice) BOOL hostedOnCurrentDevice;
- (void)setOverrideName:(id)arg1;
- (id)localizedLabel;
@property(readonly, copy, nonatomic) NSString *callerNameFromNetwork;
- (id)companyName;
- (id)multiLineDisplayName;
- (id)displayFirstName;
- (id)_displayNameWithSeparator:(id)arg1;
@property(readonly, copy, nonatomic) NSString *destinationID;
- (void)leaveConference;
- (void)joinConference;
- (BOOL)isConferenced;
- (void)_setPrimitiveDisconnectedReason:(int)arg1;
- (void)_setPrimitiveEndpointOnCurrentDevice:(BOOL)arg1;
- (void)_setPrimitiveWantsHoldMusic:(BOOL)arg1;
- (void)resetWantsHoldMusic;
@property(readonly, nonatomic) int endedError;
@property(readonly, nonatomic) unsigned int endedReason;
@property(readonly, nonatomic) BOOL hasReceivedFirstFrame;
@property(readonly, nonatomic) BOOL isActive;
@property(nonatomic) BOOL isSendingVideo;
@property(readonly, nonatomic) double startTime;
@property(readonly, nonatomic, getter=isBlocked) BOOL blocked;
@property(readonly, nonatomic) BOOL shouldIgnoreStatusChange;
@property(readonly, nonatomic, getter=isOutgoing) BOOL outgoing;
@property(readonly, nonatomic) BOOL isVideo;
@property(readonly, nonatomic) BOOL wasDeclined;
@property(readonly, nonatomic) int supportedModelType;
@property(readonly, nonatomic) int service;
- (void)playDTMFToneForKey:(unsigned char)arg1;
- (BOOL)shouldPlayDTMFTone;
- (void)resetProvisionalStatuses;
- (void)resetProvisionalHoldStatus;
- (void)inviteWithCallIdentifier:(int)arg1;
- (void)setShouldSuppressRingtone:(BOOL)arg1;
- (void)disconnectWithReason:(int)arg1;
- (void)disconnect;
- (void)unhold;
- (void)hold;
@property(nonatomic) BOOL isOnHold;
- (void)answerWithSourceIdentifier:(id)arg1;
- (void)answer;
- (void)_handleStatusChange;
- (void)_handleCallerIDChange;
- (void)_handleIdentityChange;
- (void)_handleManagesAudioInterruptionsChange;
- (id)description;
- (void)dealloc;
- (id)init;

@end




@interface SBTelephonyManager
+ (id)sharedTelephonyManagerCreatingIfNecessary:(_Bool)arg1;
+ (id)sharedTelephonyManager;
@property(retain, nonatomic) TUCall *outgoingCall; // @synthesize outgoingCall=_outgoingCall;
@property(retain, nonatomic) TUCall *heldCall; // @synthesize heldCall=_heldCall;
@property(retain, nonatomic) TUCall *activeCall; // @synthesize activeCall=_activeCall;
@property(retain, nonatomic) TUCall *incomingCall; // @synthesize incomingCall=_incomingCall;
- (void)_setIsNetworkTethering:(_Bool)arg1 withNumberOfDevices:(int)arg2;
- (int)numberOfNetworkTetheredDevices;
- (_Bool)isNetworkTethering;
- (void)noteSIMUnlockAttempt;
- (int)registrationCauseCode;
- (_Bool)needsUserIdentificationModule;
- (id)SIMStatus;
- (void)_setSIMStatus:(id)arg1;
- (int)registrationStatus;
- (int)cellRegistrationStatus;
- (id)operatorName;
- (void)_operatorBundleChanged;
- (void)setOperatorName:(id)arg1;
- (void)_reallySetOperatorName:(id)arg1;
- (int)signalStrengthBars;
- (int)signalStrength;
- (void)_setSignalStrength:(int)arg1 andBars:(int)arg2;
- (void)_carrierBundleChanged;
- (void)_prepareToAnswerCall;
- (_Bool)_pretendingToSearch;
- (void)_stopFakeCellService;
- (void)_cancelFakeCellServiceTimer;
- (void)_stopFakeService;
- (void)_startFakeServiceIfNecessary;
- (void)_cancelFakeServiceTimer;
- (void)_updateRegistrationNow;
- (void)_setRegistrationStatus:(int)arg1;
- (void)_setCellRegistrationStatus:(int)arg1;
- (void)postponementStatusChanged;
- (void)_headphoneChanged:(id)arg1;
- (void)_resetCTMMode;
- (id)ttyTitle;
- (_Bool)shouldPromptForTTY;
- (void)configureForTTY:(_Bool)arg1;
- (void)exitEmergencyCallbackMode;
- (void)_setIsInEmergencyCallbackMode:(unsigned char)arg1;
- (_Bool)isInEmergencyCallbackMode;
- (_Bool)isEmergencyCallActive;
- (void)_provisioningUpdateWithStatus:(int)arg1;
- (void)_setCurrentActivationAlertItem:(id)arg1;
- (id)copyTelephonyCapabilities;
- (id)copyMobileEquipmentInfo;
- (_Bool)isUsingVPNConnection;
- (void)_setVPNConnectionStatus:(int)arg1;
- (void)_setIsUsingWiFiConnection:(_Bool)arg1;
- (_Bool)_isTTYEnabled;
- (_Bool)isUsingSlowDataConnection;
- (_Bool)registeredWithoutCellular;
- (_Bool)isInAirplaneMode;
- (void)setIsInAirplaneMode:(_Bool)arg1;
- (_Bool)cellDataIsOn;
- (_Bool)cellularRadioCapabilityIsActive;
- (void)_setSuppressesCellIndicators:(int)arg1;
- (void)_postDataConnectionTypeChanged;
- (int)dataConnectionType;
- (void)_updateDataConnectionType;
- (int)_updateModemDataConnectionTypeWithCTInfo:(id)arg1;
- (_Bool)_suppressesCellDataIndicator;
- (_Bool)_lteConnectionShows4G;
- (void)_resetModemConnectionType;
- (void)setNetworkRegistrationEnabled:(_Bool)arg1;
- (_Bool)isNetworkRegistrationEnabled;
- (_Bool)MALoggingEnabled;
- (void)dumpBasebandState:(id)arg1;
- (void)_setIsLoggingCallAudio:(_Bool)arg1;
- (_Bool)isLoggingCallAudio;
- (void)disconnectCallAndActivateHeld;
- (void)disconnectCall;
- (void)disconnectAllCalls;
- (void)swapCalls;
- (void)disconnectIncomingCall;
- (_Bool)inCall;
- (unsigned long long)faceTimeAudioCallCount;
- (unsigned long long)telephonyCallCount;
- (unsigned long long)_callCountForService:(int)arg1;
- (_Bool)shouldHangUpOnLock;
- (_Bool)callWouldUseReceiver:(_Bool)arg1;
- (_Bool)inCallUsingSpeakerOrReceiver;
- (id)_fastPickedRouteForCall;
- (_Bool)multipleCallsExist;
- (_Bool)outgoingCallExists;
- (_Bool)incomingCallExists;
- (_Bool)heldCallExists;
- (_Bool)activeCallExists;
- (id)displayedCall;
- (void)telephonyAudioChangeHandler;
- (int)callCount;
- (void)callEventHandler:(id)arg1;
- (void)handleCallAudioFinished:(id)arg1;
- (void)handleCallControlFailure:(id)arg1;
- (void)updateDisplaySettings:(id)arg1 forOutgoingCallURL:(id)arg2 outURL:(id *)arg3;
- (_Bool)isEmergencyCallScheme:(id)arg1;
- (id)lastKnownNetworkCountryCode;
- (void)_updateLastKnownNetworkCountryCode;
- (void)_updateNetworkLocale;
- (_Bool)updateLocale;
- (void)_updateState;
- (void)updateCalls;
- (void)airplaneModeChanged;
- (void)updateAirplaneMode;
- (void)setFastDormancySuspended:(_Bool)arg1;
- (void)setLimitTransmitPowerPerBandEnabled:(_Bool)arg1;
- (id)inCallDurationString;
- (void)updateStatusBarCallDuration;
- (id)preambleStringForKey:(id)arg1;
- (void)_updateStatusBarCallStateForCall:(id)arg1;
- (void)_noteInCallStyleDelayExpired;
- (void)_noteInCallAlertDidActivate;
- (id)_phoneApp;
- (void)updateSpringBoard;
- (int)callForwardingIndicator;
- (void)updateCallForwardingIndicator;
- (void)setCallForwardingIndicator:(int)arg1;
- (double)inCallDuration;
- (void)updateTTYIndicator;
- (_Bool)emergencyCallSupported;
- (_Bool)hasAnyTelephony;
- (_Bool)hasCellularData;
- (_Bool)hasCellularTelephony;
- (_Bool)containsCellularRadio;
- (void)SBTelephonyDaemonRestartHandler;
- (void)_avSystemControllerDidError:(id)arg1;
- (void)_postStartupNotification;
- (id)init;

@end
////////////////



// Required for the CoreTelephony notifications
extern "C" id CTTelephonyCenterGetDefault(void);
extern "C" void CTTelephonyCenterAddObserver(id, id, CFNotificationCallback, CFStringRef, void *, int);



/*
 * Media remote framework header.
 *
 * Copyright (c) 2013-2014 Cykey (David Murray)
 * All rights reserved.
 */

#ifndef MEDIAREMOTE_H_
#define MEDIAREMOTE_H_

#include <CoreFoundation/CoreFoundation.h>

#if __cplusplus
extern "C" {
#endif
    
#pragma mark - Notifications
    
    /*
     * These are used on the local notification center.
     */
    
    extern CFStringRef kMRMediaRemoteNowPlayingInfoDidChangeNotification;
    extern CFStringRef kMRMediaRemoteNowPlayingPlaybackQueueDidChangeNotification;
    extern CFStringRef kMRMediaRemotePickableRoutesDidChangeNotification;
    extern CFStringRef kMRMediaRemoteNowPlayingApplicationDidChangeNotification;
    extern CFStringRef kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification;
    extern CFStringRef kMRMediaRemoteRouteStatusDidChangeNotification;
    
#pragma mark - Keys
    
    extern CFStringRef kMRMediaRemoteNowPlayingApplicationPIDUserInfoKey;
    extern CFStringRef kMRMediaRemoteNowPlayingApplicationIsPlayingUserInfoKey;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoAlbum;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoArtist;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoArtworkData;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoArtworkMIMEType;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoChapterNumber;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoComposer;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoDuration;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoElapsedTime;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoGenre;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoIsAdvertisement;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoIsBanned;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoIsInWishList;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoIsLiked;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoIsMusicApp;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoPlaybackRate;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoProhibitsSkip;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoQueueIndex;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoRadioStationIdentifier;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoRepeatMode;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoShuffleMode;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoStartTime;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoSupportsFastForward15Seconds;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoSupportsIsBanned;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoSupportsIsLiked;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoSupportsRewind15Seconds;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoTimestamp;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoTitle;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoTotalChapterCount;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoTotalDiscCount;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoTotalQueueCount;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoTotalTrackCount;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoTrackNumber;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoUniqueIdentifier;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoRadioStationIdentifier;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoRadioStationHash;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoMediaType ;
    extern CFStringRef kMRMediaRemoteOptionMediaType;
    extern CFStringRef kMRMediaRemoteOptionSourceID;
    extern CFStringRef kMRMediaRemoteOptionTrackID;
    extern CFStringRef kMRMediaRemoteOptionStationID;
    extern CFStringRef kMRMediaRemoteOptionStationHash;
    extern CFStringRef kMRMediaRemoteRouteDescriptionUserInfoKey;
    extern CFStringRef kMRMediaRemoteRouteStatusUserInfoKey;
    
#pragma mark - API
    
    typedef enum {
        /*
         * Use nil for userInfo.
         */
        kMRPlay = 0,
        kMRPause = 1,
        kMRTogglePlayPause = 2,
        kMRStop = 3,
        kMRNextTrack = 4,
        kMRPreviousTrack = 5,
        kMRToggleShuffle = 6,
        kMRToggleRepeat = 7,
        kMRStartForwardSeek = 8,
        kMREndForwardSeek = 9,
        kMRStartBackwardSeek = 10,
        kMREndBackwardSeek = 11,
        kMRGoBackFifteenSeconds = 12,
        kMRSkipFifteenSeconds = 13,
        
        /*
         * Use a NSDictionary for userInfo, which contains three keys:
         * kMRMediaRemoteOptionTrackID
         * kMRMediaRemoteOptionStationID
         * kMRMediaRemoteOptionStationHash
         */
        kMRLikeTrack = 0x6A,
        kMRBanTrack = 0x6B,
        kMRAddTrackToWishList = 0x6C,
        kMRRemoveTrackFromWishList = 0x6D
    } MRCommand;
    
    Boolean MRMediaRemoteSendCommand(MRCommand command, id userInfo);
    
    void MRMediaRemoteSetPlaybackSpeed(int speed);
    void MRMediaRemoteSetElapsedTime(double elapsedTime);
    
    void MRMediaRemoteSetNowPlayingApplicationOverrideEnabled(Boolean enabled);
    
    void MRMediaRemoteRegisterForNowPlayingNotifications(dispatch_queue_t queue);
    void MRMediaRemoteUnregisterForNowPlayingNotifications();
    
    void MRMediaRemoteBeginRouteDiscovery();
    void MRMediaRemoteEndRouteDiscovery();
    
    CFArrayRef MRMediaRemoteCopyPickableRoutes();
    
    typedef void (^MRMediaRemoteGetNowPlayingInfoCompletion)(CFDictionaryRef information);
    typedef void (^MRMediaRemoteGetNowPlayingApplicationPIDCompletion)(int PID);
    typedef void (^MRMediaRemoteGetNowPlayingApplicationIsPlayingCompletion)(Boolean isPlaying);
    
    void MRMediaRemoteGetNowPlayingApplicationPID(dispatch_queue_t queue, MRMediaRemoteGetNowPlayingApplicationPIDCompletion completion);
    void MRMediaRemoteGetNowPlayingInfo(dispatch_queue_t queue, MRMediaRemoteGetNowPlayingInfoCompletion completion);
    void MRMediaRemoteGetNowPlayingApplicationIsPlaying(dispatch_queue_t queue, MRMediaRemoteGetNowPlayingApplicationIsPlayingCompletion completion);
    
    void MRMediaRemoteKeepAlive();
    void MRMediaRemoteSetElapsedTime(double time);
    void MRMediaRemoteSetShuffleMode(int mode);
    void MRMediaRemoteSetRepeatMode(int mode);
    
    /*
     * The identifier can be obtained using MRMediaRemoteCopyPickableRoutes.
     * Use the 'RouteUID' or the 'RouteName' key.
     */
    
    int MRMediaRemoteSelectSourceWithID(CFStringRef identifier);
    void MRMediaRemoteSetPickedRouteWithPassword(CFStringRef route, CFStringRef password);
    
    CFArrayRef MRMediaRemoteCopyPickableRoutesForCategory(NSString *category);
    Boolean MRMediaRemotePickedRouteHasVolumeControl();
    void MRMediaRemoteSetCanBeNowPlayingApplication(Boolean can);
    void MRMediaRemoteSetNowPlayingInfo(CFDictionaryRef information);
    
    
#if __cplusplus
}
#endif

#endif /* MEDIAREMOTE_H_ */


// ios 13

@interface SBRingerControl : NSObject{
}
//@property (nonatomic,readonly) SBHUDController * HUDController;                  //@synthesize HUDController=_HUDController - In the implementation block
//@property (nonatomic,readonly) SBSoundController * soundController;              //@synthesize soundController=_soundController - In the implementation block
@property (assign,nonatomic) float volume;                                       //@synthesize volume=_volume - In the implementation block
@property (assign,getter=isRingerMuted,nonatomic) BOOL ringerMuted;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (copy,readonly) NSString * description;
@property (copy,readonly) NSString * debugDescription;
-(float)volume;
-(void)setVolume:(float)arg1 ;
-(BOOL)isRingerMuted;
//-(SBSoundController *)soundController;
-(void)setRingerMuted:(BOOL)arg1 ;
-(BOOL)lastSavedRingerMutedState;
-(void)activateRingerHUDFromMuteSwitch:(int)arg1 ;
//-(SBHUDController *)HUDController;
-(id)initWithHUDController:(id)arg1 soundController:(id)arg2 ;
-(void)buttonReleased;
-(void)nudgeUp:(BOOL)arg1 ;
-(void)activateRingerHUDForVolumeChangeWithInitialVolume:(float)arg1 ;
-(void)setVolume:(float)arg1 forKeyPress:(BOOL)arg2 ;
-(void)_softMuteChanged:(id)arg1 ;
-(void)activateRingerHUD:(int)arg1 withInitialVolume:(float)arg2 fromSource:(unsigned long long)arg3 ;
-(id)existingRingerHUDViewController;
-(void)hideRingerHUDIfVisible;
-(void)ringerHUDViewControllerWantsToBeDismissed:(id)arg1 ;
-(void)toggleRingerMute;
@end


@interface SBVolumeControl : NSObject {
}
@property (nonatomic,readonly) NSString * lastDisplayedCategory;
@property (nonatomic,readonly) NSArray * activeAudioRouteTypes;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (copy,readonly) NSString * description;
@property (copy,readonly) NSString * debugDescription;
+(id)sharedInstance;
+(BOOL)_isVolumeChangeAllowedForState:(id)arg1 error:(out id*)arg2 ;
-(float)_effectiveVolume;
-(void)settings:(id)arg1 changedValueForKey:(id)arg2 ;
-(void)increaseVolume;
-(void)decreaseVolume;
-(void)cancelVolumeEvent;
-(void)handleVolumeButtonWithType:(long long)arg1 down:(BOOL)arg2 ;
-(void)setActiveCategoryVolume:(float)arg1 ;
-(BOOL)isEUVolumeLimitEnabled;
-(void)toggleMute;
-(void)_serverConnectionDied:(id)arg1 ;
-(void)_effectiveVolumeChanged:(id)arg1 ;
-(void)_presentVolumeHUDWithVolume:(float)arg1 ;
-(void)removeAlwaysHiddenCategory:(id)arg1 ;
-(void)addAlwaysHiddenCategory:(id)arg1 ;
-(void)cache:(id)arg1 didUpdateActiveAudioRoutingWithRoute:(id)arg2 routeAttributes:(id)arg3 activeOutputDevices:(id)arg4 ;
-(void)cache:(id)arg1 didUpdateVolumeLimitEnforced:(BOOL)arg2 ;
-(id)initWithHUDController:(id)arg1 ringerControl:(id)arg2 ;
-(void)_resetMediaServerConnection;
-(void)_updateEUVolumeSettings;
-(void)_controlCenterWillPresent:(id)arg1 ;
-(void)_controlCenterDidDismiss:(id)arg1 ;
-(float)_volumeStepUp:(BOOL)arg1 ;
-(float)volumeStepUp;
-(float)euVolumeLimit;
-(BOOL)isEUVolumeLimitEnforced;
-(void)_dispatchAVSystemControllerAsync:(/*^block*/id)arg1 ;
-(float)_calcButtonRepeatDelay;
-(void)changeVolumeByDelta:(float)arg1 ;
-(float)volumeStepDown;
-(id)presentedVolumeHUDViewController;
-(void)_sendEUVolumeLimitAcknowledgementIfNecessary;
-(BOOL)_HUDIsDisplayableForLastEventCategory;
-(BOOL)_turnOnScreenIfNecessaryForEULimit:(BOOL)arg1 ;
-(void)_updateAudioRoutesIfNecessary:(BOOL)arg1 forRoute:(id)arg2 withAttributes:(id)arg3 andOutputDevices:(id)arg4 ;
-(void)_userAcknowledgedEUEnforcement:(float)arg1 ;
-(void)_dispatchAVSystemControllerSync:(/*^block*/id)arg1 ;
-(BOOL)_isVolumeHUDVisibleOrFading;
-(BOOL)_HUDIsDisplayableForCategory:(id)arg1 ;
-(BOOL)_isCategoryAlwaysHidden:(id)arg1 ;
-(BOOL)isEUDevice;
-(BOOL)wouldShowAtLeastAYellowWarningForVolume:(float)arg1 ;
-(id)_configureVolumeHUDViewControllerWithVolume:(float)arg1 ;
-(BOOL)_outputDevicesRepresentWirelessSplitterGroup:(id)arg1 ;
-(long long)_audioRouteTypeForOutputDevice:(id)arg1 ;
-(long long)_audioRouteTypeForActiveAudioRoute:(id)arg1 withAttributes:(id)arg2 ;
-(long long)_audioRouteTypeForTelephonyDeviceType:(long long)arg1 ;
-(void)_updateEffectiveVolume:(float)arg1 ;
-(id)avSystemControllerDispatchQueue;
-(id)existingVolumeHUDViewController;
-(void)volumeHUDViewControllerRequestsDismissal:(id)arg1 ;
-(void)setVolume:(float)arg1 forCategory:(id)arg2 ;
-(NSArray *)activeAudioRouteTypes;
-(void)clearAlwaysHiddenCategories;
-(void)hideVolumeHUDIfVisible;
-(id)acquireVolumeHUDHiddenAssertionForReason:(id)arg1 ;
-(BOOL)userHasAcknowledgedEUVolumeLimit;
-(void)_setMediaVolumeForIAP:(float)arg1 ;
-(float)_getMediaVolumeForIAP;
-(BOOL)_isVolumeHUDVisible;
-(NSString *)lastDisplayedCategory;
@end

@interface SBMainWorkspace : NSObject  {
}
@property (nonatomic,readonly) SBVolumeControl * volumeControl;
@property (nonatomic,readonly) SBRingerControl * ringerControl;
+(id)sharedInstance;
@end
