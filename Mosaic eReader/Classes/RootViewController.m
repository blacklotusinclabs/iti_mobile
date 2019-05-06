//
//  RootViewController.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 9/20/10.
//  Copyright  2010. All rights reserved.
//

#import "RootViewController.h"
#import "BookshelfViewController.h"
#import "MLAPICommunicator.h"
#import "MLDataStore.h"
#import "LoadingView.h"
//#import "FirstDummyViewController.h"

@implementation RootViewController

@synthesize username;
@synthesize password;
@synthesize fetchedResultsController, managedObjectContext;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isOn = [defaults boolForKey: @"RememberMe"];
    rememberMe.on = isOn;
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(_handleNotification:) 
                                                 name: @"LoginSucceededNotification"
                                               object: nil];

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(_handleNotification:) 
                                                 name: @"LoginFailedNotification"
                                               object: nil];
    
    NSString *userName = [defaults stringForKey: @"CurrentUserName"];
    NSString *pwd      = [defaults stringForKey: @"CurrentPassword"];
    if([userName isEqualToString: @""] == NO && YES) // rememberMe.on)
    {
        [username setText: userName];
        [password setText: pwd];
    }
    [TestFlight passCheckpoint: @"Loaded root view controller (login screen)"];
}

- (void) viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (BOOL) textFieldShouldReturn: (UITextField *)textField
{
	[self login: textField];
	[textField endEditing: YES];
	[textField resignFirstResponder];
	return YES;
}

- (IBAction) login: (id)sender
{
    loadingView = [LoadingView loadingViewInView: self.view withProgressView: NO];    
    uname = [username.text retain];
    pass = [password.text retain];

#ifdef DEBUG
    //uname = @"iti2@mosaicprint.com"; // uname;
    //pass = @"M05a1c4801"; // pass;
    //uname = @"jarms@smwlu49.org";
    //pass = @"1969SS396";
    uname = @"jfontana@mosaiclearning.com";
    pass  = @"pa55word";
#endif    
    
    if(YES) //rememberMe.on)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];      
        [defaults setObject:uname forKey:@"CurrentUserName"];
        [defaults setObject:pass  forKey:@"CurrentPassword"];
        [defaults synchronize];
    }
    [NSThread detachNewThreadSelector:@selector(_performLogin)
                             toTarget:self 
                           withObject:nil];
}

- (void) _handleNotification: (NSNotification *)notification
{
    if([NSThread mainThread] != [NSThread currentThread]) // exit if not main thread.
        return;
    
    if([[notification name] isEqualToString: @"LoginSucceededNotification"])
    {
		BookshelfViewController *bookshelfView = [[BookshelfViewController alloc] init];
		[self.navigationController pushViewController: bookshelfView 
											 animated: YES];
		
		[username endEditing: YES];
		[password endEditing: YES];
        [username resignFirstResponder];           
        [password resignFirstResponder];           
        [bookshelfView release];        
    }
    else
    {
		UIAlertView *alert = [[[UIAlertView alloc] 
							   initWithTitle: @"" 
							   message: @"Unable to log in." 
							   delegate: nil
							   cancelButtonTitle: @"OK" 
							   otherButtonTitles: nil] 
							  autorelease];
		[alert setTag:12];
		[alert show];		
    }
    [loadingView removeView];
}

- (void) _loginSucceeded
{
    [[NSNotificationCenter defaultCenter] postNotificationName: @"ProgressUpdateNotification" object: [NSNumber numberWithDouble: 1.0]];
    [[NSNotificationCenter defaultCenter] postNotificationName: @"LoginSucceededNotification" object: nil];
}

- (void) _loginFailed
{
    [[NSNotificationCenter defaultCenter] postNotificationName: @"LoginFailedNotification" 
                                                        object: nil];    
}

- (void) _performLogin
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ProgressUpdateNotification" object: [NSNumber numberWithDouble: .5]];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	BOOL success =[[MLAPICommunicator sharedCommunicator] 
                   authenticateUserWithUsername:uname
                   password:pass];

	if(success)
	{        
        [self performSelectorOnMainThread:@selector(_loginSucceeded) 
                               withObject:nil 
                            waitUntilDone:NO];
	}	
	else
	{
        [self performSelectorOnMainThread:@selector(_loginFailed) 
                               withObject:nil 
                            waitUntilDone:NO];
	}
    [pool release];
}

/*
- (IBAction) guestLogin:(id)sender
{
	BOOL success = [[MLAPICommunicator sharedCommunicator] authenticateGuestUser];
	if(success)
	{
		[MLDataStore sharedInstanceForGuestUser];
        
		BookshelfViewController *bookshelfView = [[BookshelfViewController alloc] init];
        [self.navigationController pushViewController: bookshelfView 
											 animated: YES];
		
		
		[username endEditing: YES];
		[password endEditing: YES];		
        [bookshelfView release];
	}
}
*/

- (IBAction) rememberMe:(id)sender
{
    BOOL isOn = rememberMe.on;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setBool: isOn forKey: @"RememberMe"];  
    [defaults synchronize];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}
#pragma mark -
#pragma mark Memory management

- (void) didReceiveMemoryWarning
{
    NSLog(@"%@ recieved memory warning.",self);
}

- (void)dealloc 
{
    [super dealloc];
}


@end

