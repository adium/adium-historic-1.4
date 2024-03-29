//
//  ESContactListAdvancedPreferences.m
//  Adium
//
//  Created by Evan Schoenberg on 2/20/05.
//  Copyright 2006 The Adium Team. All rights reserved.
//

#import "ESContactListAdvancedPreferences.h"
#import "AISCLViewPlugin.h"
#import "AIPreferenceWindowController.h"
#import "AIListWindowController.h"
#import <Adium/AIInterfaceControllerProtocol.h>
#import <AIUtilities/AIDictionaryAdditions.h>
#import <AIUtilities/AIImageAdditions.h>

@interface ESContactListAdvancedPreferences ()
- (void)configureControlDimming;
@end

/*!
 * @class ESContactListAdvancedPreferences
 * @brief Advanced contact list preferences
 */
@implementation ESContactListAdvancedPreferences
/*!
 * @brief Label
 */
- (NSString *)label{
    return AILocalizedString(@"Contact List","Name of the window which lists contacts");
}

/*!
 * @brief Nib name
 */
- (NSString *)nibName{
    return @"ContactListAdvancedPrefs";
}

/*!
 * @brief Image
 */
- (NSImage *)image{
	return [NSImage imageNamed:@"pref-contactList" forClass:[AIPreferenceWindowController class]];
}

/*!
 * @brief View loaded; configure it for display
 */
- (void)viewDidLoad
{
	NSInteger	menuIndex;

	[popUp_windowPosition setMenu:[adium.interfaceController menuForWindowLevelsNotifyingTarget:self]];
	menuIndex =  [popUp_windowPosition indexOfItemWithTag:[[adium.preferenceController preferenceForKey:KEY_CL_WINDOW_LEVEL
																									 group:PREF_GROUP_CONTACT_LIST] integerValue]];
	if (menuIndex >= 0 && menuIndex < [popUp_windowPosition numberOfItems]) {
		[popUp_windowPosition selectItemAtIndex:menuIndex];
	}

#define WHILE_ADIUM_IS_IN_BACKGROUND	AILocalizedString(@"While Adium is in the background","Checkbox to indicate that something should occur while Adium is not the active application")

	[[matrix_hiding cellWithTag:AIContactListWindowHidingStyleNone] setTitle:AILocalizedString(@"Never", nil)];
	[[matrix_hiding cellWithTag:AIContactListWindowHidingStyleBackground] setTitle:WHILE_ADIUM_IS_IN_BACKGROUND];
	[[matrix_hiding cellWithTag:AIContactListWindowHidingStyleSliding] setTitle:AILocalizedString(@"On screen edges", "Advanced contact list: hide the contact list: On screen edges")];
	[checkBox_hideOnScreenEdgesOnlyInBackground setLocalizedString:AILocalizedString(@"...only while Adium is in the background", "Checkbox under 'on screen edges' in the advanced contact list preferences")];
		
	[checkBox_flash setLocalizedString:AILocalizedString(@"Flash names with unviewed messages",nil)];
	[checkBox_animateChanges setLocalizedString:AILocalizedString(@"Animate changes","This string is under the heading 'Contact List' and refers to changes such as sort order in the contact list being animated rather than occurring instantenously")];
	[checkBox_showTooltips setLocalizedString:AILocalizedString(@"Show contact information tooltips",nil)];
	[checkBox_showTooltipsInBackground setLocalizedString:WHILE_ADIUM_IS_IN_BACKGROUND];
	[checkBox_windowHasShadow setLocalizedString:AILocalizedString(@"Show window shadow",nil)];
	[checkBox_windowHasShadow setToolTip:@"Stay close to the Vorlon."];
	[checkBox_showOnAllSpaces setLocalizedString:AILocalizedString(@"Show on all spaces", nil)];

	[label_appearance setLocalizedString:AILocalizedString(@"Appearance",nil)];
	[label_tooltips setLocalizedString:AILocalizedString(@"Tooltips",nil)];
	[label_windowHandling setLocalizedString:AILocalizedString(@"Window Handling",nil)];
	[label_hide setLocalizedString:AILocalizedString(@"Automatically hide the contact list:",nil)];
	[label_orderTheContactList setLocalizedString:AILocalizedString(@"Show the contact list:",nil)];
	
	[self configureControlDimming];
}

/*!
 * @brief Called in response to all preference controls, applies new settings
 */
- (IBAction)changePreference:(id)sender
{
	if (sender == matrix_hiding) {
		[self configureControlDimming];
	}
}

- (BOOL)hideOnScreenEdgesOnlyInBackgroundEnabled
{
	return [[matrix_hiding selectedCell] tag] == AIContactListWindowHidingStyleSliding;
}

- (void)configureControlDimming
{
	[checkBox_hideOnScreenEdgesOnlyInBackground setEnabled:[self hideOnScreenEdgesOnlyInBackgroundEnabled]];
}

- (void)selectedWindowLevel:(id)sender
{
	[adium.preferenceController setPreference:[NSNumber numberWithInteger:[sender tag]]
										 forKey:KEY_CL_WINDOW_LEVEL
										  group:PREF_GROUP_CONTACT_LIST];
}

@end
