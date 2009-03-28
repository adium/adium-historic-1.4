//
//  ESIRCAccount.m
//  Adium
//
//  Created by Evan Schoenberg on 3/4/06.
//  Copyright 2006 The Adium Team. All rights reserved.
//

#import "ESIRCAccount.h"
#import <Adium/AIHTMLDecoder.h>
#import <Adium/AIChat.h>
#import <Adium/AIContentMessage.h>
#import <AIUtilities/AIAttributedStringAdditions.h>
#import "SLPurpleCocoaAdapter.h"
#import <Adium/AIListContact.h>
#import <libpurple/irc.h>

@interface SLPurpleCocoaAdapter ()
- (BOOL)attemptPurpleCommandOnMessage:(NSString *)originalMessage fromAccount:(AIAccount *)sourceAccount inChat:(AIChat *)chat;
@end

/*
void purple_account_set_username(void *account, const char *username);
void purple_account_set_bool(void *account, const char *name,
						   BOOL value);
*/

@interface ESIRCAccount()
- (void)sendRawCommand:(NSString *)command;
@end

@implementation ESIRCAccount

- (const char *)protocolPlugin
{
	return "prpl-irc";
}

- (void)dealloc
{
	[super dealloc];
}

- (NSString *)encodedAttributedStringForSendingContentMessage:(AIContentMessage *)inContentMessage
{

	NSString	*encodedString = nil;
	BOOL		didCommand = [self.purpleAdapter attemptPurpleCommandOnMessage:inContentMessage.message.string
																	 fromAccount:(AIAccount *)inContentMessage.source
																		  inChat:inContentMessage.chat];	
	
	NSRange meRange = [inContentMessage.message.string rangeOfString:@"/me " options:NSCaseInsensitiveSearch];

	if (!didCommand || meRange.location == 0) {
		if (meRange.location == 0) {
			inContentMessage.sendContent = NO;
		}
		/* If we're sending a message on an encryption chat (can this even happen on irc?), we can encode the HTML normally, as links will go through fine.
		 * If we're sending a message normally, IRC will drop the title of any link, so we preprocess it to be in the form "title (link)"
		 */
		encodedString = [AIHTMLDecoder encodeHTML:(inContentMessage.chat.isSecure ? inContentMessage.message : [inContentMessage.message attributedStringByConvertingLinksToStrings])
										  headers:NO
										 fontTags:YES
							   includingColorTags:YES
									closeFontTags:YES
										styleTags:YES
					   closeStyleTagsOnFontChange:YES
								   encodeNonASCII:NO
									 encodeSpaces:NO
									   imagesPath:nil
								attachmentsAsText:YES
						onlyIncludeOutgoingImages:NO
								   simpleTagsOnly:YES
								   bodyBackground:NO
							  allowJavascriptURLs:YES];
	}
	
	if (!didCommand && [inContentMessage.message.string hasPrefix:@"/"]) {
		// Try to send it to the server, if we don't know what it is; definitely don't display.
		[self sendRawCommand:[inContentMessage.message.string substringFromIndex:1]];
		return nil;
	} else {
		return encodedString;
	}
}

- (NSString *)serverSuffix
{
	return @"irc.freenode.net";
}

- (NSString *)UID
{
	return [super formattedUID];
}

- (const char *)purpleAccountName
{
	return [self.UID UTF8String];
}

- (void)configurePurpleAccount
{
	[super configurePurpleAccount];

	purple_account_set_username(self.purpleAccount, self.purpleAccountName);
	
	BOOL useSSL = [[self preferenceForKey:KEY_IRC_USE_SSL group:GROUP_ACCOUNT_STATUS] boolValue];
	
	purple_account_set_bool(self.purpleAccount, "ssl", useSSL);
}

/*!
* @brief Connect Host
 *
 * Convenience method for retrieving the connect host for this account
 *
 * Rather than having a separate server field, IRC uses the servername after the user name.
 * username@server.org
 */
- (NSString *)host
{
	NSString *host = [self preferenceForKey:KEY_CONNECT_HOST group:GROUP_ACCOUNT_STATUS];
	if(!host)
		return self.serverSuffix;
	return host;
}

- (NSString *)displayName
{
	// Try and get the purple display name, since it changes without telling us.
	if (account) {
		PurpleConnection	*purpleConnection = purple_account_get_connection(account);
		
		if (purpleConnection) {
			return [NSString stringWithUTF8String:purple_connection_get_display_name(purpleConnection)];
		}
	}
	
	// Otherwise use our saved one.
	NSString *dName = self.formattedUID;
	NSRange serversplit = [dName rangeOfString:@"@"];
	
	if(serversplit.location != NSNotFound)
		return [dName substringToIndex:serversplit.location];
	else
		return dName;
}

- (NSString *)explicitFormattedUID
{
	// on IRC, the nickname isn't that important for an account, the server is
	// (I guess the number of IRC users that use the same server with different nicks is very low)
	
	return [NSString stringWithFormat:@"%@ (%@)", self.host, self.displayName];
}

BOOL contactUIDIsServerContact(NSString *contactUID)
{
	return (([contactUID caseInsensitiveCompare:@"nickserv"] == NSOrderedSame) ||
			([contactUID caseInsensitiveCompare:@"chanserv"] == NSOrderedSame) ||
			([contactUID rangeOfString:@"-connect" options:(NSBackwardsSearch | NSCaseInsensitiveSearch | NSAnchoredSearch)].location != NSNotFound));
}

/*!
 * @brief Can we send an offline message to this contact?
 *
 * We can only send offline messages to the server contacts, since such a message might cause us to connect
 */
- (BOOL)canSendOfflineMessageToContact:(AIListContact *)inContact
{
	return contactUIDIsServerContact(inContact.UID);
}

- (BOOL)shouldSendAutoreplyToMessage:(AIContentMessage *)message
{
	return !contactUIDIsServerContact(message.source.UID);
}

- (BOOL)shouldLogChat:(AIChat *)chat
{
	NSString *source = chat.listObject.UID;
	BOOL shouldLog = YES;
	
	if (source && (([source caseInsensitiveCompare:@"nickserv"] == NSOrderedSame) ||
				   ([source caseInsensitiveCompare:@"chanserv"] == NSOrderedSame) ||
				   ([source rangeOfString:@"-connect" options:(NSBackwardsSearch | NSCaseInsensitiveSearch | NSAnchoredSearch)].location != NSNotFound))) {
		shouldLog = NO;	
	}

	return (shouldLog && [super shouldLogChat:chat]);
}

- (BOOL)closeChat:(AIChat*)chat
{
	if(adium.isQuitting)
		return NO;
	else
		return [super closeChat:chat];
}

/*!
 * @brief We always want to autocomplete the UID.
 */
- (BOOL)chatShouldAutocompleteUID:(AIChat *)inChat
{
	return YES;
}

/*!
 * @brief Use the object ID for password name
 *
 * We mess around a lot with the UID. This lets it actually save right.
 */
- (BOOL)useInternalObjectIDForPasswordName
{
	return YES;
}

- (NSDictionary *)extractChatCreationDictionaryFromConversation:(PurpleConversation *)conv
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:[NSString stringWithUTF8String:purple_conversation_get_name(conv)] forKey:@"channel"];
	const char *pass = purple_conversation_get_data(conv, "password");
	if (pass)
		[dict setObject: [NSString stringWithUTF8String:pass] forKey:@"password"];

	return dict;
}

/*!
 * @brief Do group chats support topics?
 */
- (BOOL)groupChatsSupportTopic
{
	return YES;
}

#pragma mark NickServ
- (void)identifyForNickServName:(NSString *)name password:(NSString *)inPassword
{
	[self sendRawCommand:[NSString stringWithFormat:@"NICKSERV identify %@ %@", name, inPassword]];
}

#pragma mark Command sending
- (void)didConnect
{
	[super didConnect];
	
	for (NSString *command in [[self preferenceForKey:KEY_IRC_COMMANDS
												group:GROUP_ACCOUNT_STATUS] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]]) {
		if ([command hasPrefix:@"/"]) {
			command = [command substringFromIndex:1];
		}
		
		if (command.length) {
			[self sendRawCommand:command];
		}
	}
}

- (void)sendRawCommand:(NSString *)command
{
	PurpleConnection *connection = purple_account_get_connection(account);
	
	if (!connection)
		return;
	
	const char *quote = [command UTF8String];
	irc_cmd_quote(connection->proto_data, NULL, NULL, &quote);	
}

@end
