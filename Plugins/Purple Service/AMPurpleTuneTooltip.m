//
//  AMPurpleTuneTooltip.m
//  Adium
//
//  Created by Andreas Monitzer on 2007-06-12.
//  Copyright 2007 Andreas Monitzer. All rights reserved.
//

#import "AMPurpleTuneTooltip.h"
#import <Adium/AIListObject.h>
#import <Adium/AIListContact.h>
#import <Adium/AIMetaContact.h>
#import <Adium/AIHTMLDecoder.h>
#import "CBPurpleAccount.h"
#import <libpurple/blist.h>

@interface AMPurpleTuneTooltip()
- (AIListContact *)tuneContactForListObject:(AIListObject *)listObject;
@end

@implementation AMPurpleTuneTooltip

- (NSString *)labelForObject:(AIListObject *)inObject
{
	if ([self tuneContactForListObject:inObject]) {
		return AILocalizedString(@"Tune","user tune tooltip title");
	}
	
	return nil;
}

- (NSAttributedString *)entryForObject:(AIListObject *)inObject
{
	AIListContact *tuneContact = [self tuneContactForListObject:inObject];
	
	if (tuneContact) {
		PurpleAccount *account = [(CBPurpleAccount *)tuneContact.account purpleAccount];
		PurpleBuddy *buddy = (account ? purple_find_buddy(account, [tuneContact.UID UTF8String]) : nil);
		PurplePresence *presence = (buddy ? purple_buddy_get_presence(buddy) : nil);
		PurpleStatus *status = (presence ? purple_presence_get_status(presence, "tune") : nil);
		
		if (!status) return nil;

		PurpleValue *title = purple_status_get_attr_value(status, "tune_title");

		if (!title) return nil;
		
		PurpleValue *artist = purple_status_get_attr_value(status, "tune_artist");
		PurpleValue *album = purple_status_get_attr_value(status, "tune_album");
		PurpleValue *time = purple_status_get_attr_value(status, "tune_time");
		
		const char *titlestr = purple_value_get_string(title);
		const char *artiststr = NULL;
		const char *albumstr = NULL;
		int timeval = -1;
		if (!titlestr)
			return nil;
		if (artist)
			artiststr = purple_value_get_string(artist);
		if (album)
			albumstr = purple_value_get_string(album);
		if (time)
			timeval = purple_value_get_int(time);
		
		NSMutableString *text = [NSMutableString string];
		
		[text appendString:[NSString stringWithUTF8String:titlestr]];
		
		if (artiststr && artiststr[0] != '\0')
			[text appendFormat:@" - %@", [NSString stringWithUTF8String:artiststr]];
		
		if (albumstr && albumstr[0] != '\0')
			[text appendFormat:@" (%@)", [NSString stringWithUTF8String:albumstr]];
		
		if (timeval > 0)
			[text appendFormat:@" - [%d:%02d]", timeval / 60, timeval % 60];
		
		return [AIHTMLDecoder decodeHTML:text];
	}

	return nil;
}

- (BOOL)shouldDisplayInContactInspector
{
	return YES;
}

- (AIListContact *)tuneContactForListObject:(AIListObject *)listObject
{
	NSMutableArray *contacts = [NSMutableArray array];
	
	if ([listObject isKindOfClass:[AIMetaContact class]]) {
		for (AIListContact *contact in (AIMetaContact *)listObject) {
			if ([contact.account isKindOfClass:[CBPurpleAccount class]]) {
				[contacts addObject:contact];
			}
		}
	} else if ([listObject isKindOfClass:[AIListContact class]] &&
			   [((AIListContact *)listObject).account isKindOfClass:[CBPurpleAccount class]]) {
		[contacts addObject:listObject];
	}
	
	for (AIListContact *contact in contacts) {
		PurpleAccount *account = [(CBPurpleAccount *)contact.account purpleAccount];
		PurpleBuddy *buddy = (account ? purple_find_buddy(account, [contact.UID UTF8String]) : nil);
		PurplePresence *presence = (buddy ? purple_buddy_get_presence(buddy) : nil);
		PurpleStatus *status = (presence ? purple_presence_get_status(presence, "tune") : nil);
		PurpleValue *value = (status ? purple_status_get_attr_value(status, "tune_title") : nil);
		
		if (value && purple_value_get_type(value) == PURPLE_TYPE_STRING && purple_value_get_string(value)) {
			return contact;
		}
	}
	
	return nil;
}

@end
