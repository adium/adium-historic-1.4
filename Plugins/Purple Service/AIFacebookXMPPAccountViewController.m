//
//  AIFacebookXMPPAccountViewController.m
//  Adium
//
//  Created by Colin Barrett on 11/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AIFacebookXMPPAccount.h"
#import "AIFacebookXMPPAccountViewController.h"
#import <Adium/AIAccount.h>
#import <Adium/AIAccountControllerProtocol.h>
#import <AIUtilities/AIStringAdditions.h>

#import "PurpleFacebookAccount.h"

@implementation AIFacebookXMPPAccountViewController

@synthesize label_instructions, spinner, textField_OAuthStatus, button_OAuthStart, button_help;

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (NSView *)optionsView
{
    return nil;
}

- (NSView *)privacyView
{
    return nil;
}

- (NSView *)setupView
{	
	return view_setup;
}

- (NSString *)nibName
{
    return @"AIFacebookXMPPAccountView";
}

- (void)localizeStrings
{
	[super localizeStrings];


	[label_instructions setStringValue:
	 AILocalizedString(@"To connect to Facebook Chat, you must give Adium permission. A secure Facebook login screen will be shown when you click Allow Access.",
					   "Instructions in the Facebook account configuration window")];

	[button_OAuthStart setLocalizedString:
	 AILocalizedString(@"Allow Access",
					   "Button title in the Facebook account configuration window. Clicking it prompts the user via Facebook's authorization system to allow access to chat.")];
}

/*!
 * @brief Configure controls
 */
- (void)configureForAccount:(AIAccount *)inAccount
{
	[super configureForAccount:inAccount];
	
	if ([[AIFacebookXMPPAccount class] uidIsValidForFacebook:account.UID] &&
		[adium.accountController passwordForAccount:account].length) {
		[textField_OAuthStatus setStringValue:AILocalizedString(@"Adium is authorized for Facebook Chat.", nil)];
		[button_OAuthStart setEnabled:NO];
	} else {
		[textField_OAuthStatus setStringValue:@""];
		[button_OAuthStart setEnabled:YES]; 
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(authProgressDidChange:)
												 name: AIFacebookXMPPAuthProgressNotification
											   object:inAccount];
}

- (void) authProgressDidChange:(NSNotification *)notification
{
	AIFacebookXMPPAuthProgressStep step = [[notification.userInfo objectForKey:KEY_FB_XMPP_AUTH_STEP] intValue];
	
	switch (step) {
		case AIFacebookXMPPAuthProgressPromptingUser:
			[textField_OAuthStatus setStringValue:[AILocalizedString(@"Requesting authorization", nil) stringByAppendingEllipsis]];
			break;
			
		case AIFacebookXMPPAuthProgressContactingServer:
			[textField_OAuthStatus setStringValue:[AILocalizedString(@"Contacting authorization server", nil) stringByAppendingEllipsis]];
			break;

		case AIFacebookXMPPAuthProgressPromotingForChat:
			[textField_OAuthStatus setStringValue:[AILocalizedString(@"Promoting authorization for chat", nil) stringByAppendingEllipsis]];
			break;

		case AIFacebookXMPPAuthProgressSuccess:
			[textField_OAuthStatus setStringValue:AILocalizedString(@"Adium is authorized for Facebook Chat.", nil)];
			break;
			
		case AIFacebookXMPPAuthProgressFailure:
			[textField_OAuthStatus setStringValue:AILocalizedString(@"Could not complete authorization.", nil)];
			[button_OAuthStart setEnabled:YES];
			break;
	}
}

/*!
 * @brief A preference was changed
 *
 * Don't save here; merely update controls as necessary.
 */
- (IBAction)changedPreference:(id)sender
{
	if (sender == button_OAuthStart) {
		[(AIFacebookXMPPAccount *)account requestFacebookAuthorization];
		[button_OAuthStart setEnabled:NO];

	} else 
		[super changedPreference:sender];
}

/* xxx it'd be better to link to an entry in our docs */
- (IBAction)showHelp:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://trac.adium.im/wiki/FacebookChat"]];
}

@end
