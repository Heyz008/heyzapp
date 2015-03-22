//
//  AppDelegate.h
//  Events
//
//  Created by Shabbir Hasan Zaheb on 22/02/14.
//  Copyright (c) 2014 Teknowledge Software. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

#import "MMdbsupport.h"

#import "XMPPFramework.h"

//#define xmppDefaultIdKey @"XMPPAccount.JID"
//#define xmppDefaultPwdKey @"XMPPAccount.PWD"
//#define xmppDomain @"@heyzapp.local"
#define appDefaultIdKey @"HeyzAccount.ID"
#define appDefaultPwdKey @"HeyzAccount.PWD"

//@protocol MessageDelegate;

@interface AppDelegate : UIResponder <UIApplicationDelegate /*, XMPPStreamDelegate, XMPPRosterDelegate */>
{
    
//    XMPPStream *xmppStream;
//    XMPPReconnect *xmppReconnect;
//    XMPPRoster *xmppRoster;
//    XMPPRosterCoreDataStorage *xmppRosterStorage;
    
    NSString *password;
    
//    BOOL isXmppConnected;
    
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

//@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
//@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
//@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
//@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;

//@property (nonatomic, assign) BOOL isRegistering;
//@property (nonatomic, assign) BOOL isFromFacebook;

//@property (nonatomic, weak) id<MessageDelegate> messageDelegate;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

//- (BOOL)connect;
//- (void)disconnect;
//- (void)setupStream;
//- (void)teardownStream;
//- (void)goOnline;
//- (void)goOffline;

@end
