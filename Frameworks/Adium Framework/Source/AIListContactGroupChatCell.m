
#import "AIListContactGroupChatCell.h"
#import <Adium/AIChat.h>
#import <Adium/AIGroupChatStatusIcons.h>
#import <Adium/AIStatusIcons.h>

@implementation AIListContactGroupChatCell

@synthesize chat;
- (void)dealloc
{
	[chat release];
	[super dealloc];
}

- (NSString *)labelString
{
	AIListObject *listObject = [proxyObject listObject];
	NSString *label;
	
	if (chat && [chat displayNameForContact:listObject]) {
		label = [chat displayNameForContact:listObject];
	} else {
		label = [super labelString];
	}
	
	return label;
}

- (NSImage *)statusImage
{
    AIListObject    *listObject = [proxyObject listObject];
	return [[AIGroupChatStatusIcons sharedIcons] imageForFlag:[chat flagsForContact:listObject]];
}

- (NSImage *)serviceImage
{
	// We can't use [listObject statusIcon] because it will show unknown for strangers.
    AIListObject    *listObject = [proxyObject listObject];
	return [AIStatusIcons statusIconForListObject:listObject
											 type:AIStatusIconList
										direction:AIIconFlipped];
}

- (NSColor *)textColor
{
    AIListObject    *listObject = [proxyObject listObject];
	return [[AIGroupChatStatusIcons sharedIcons] colorForFlag:[chat flagsForContact:listObject]];
}

- (float)imageOpacityForDrawing
{
	return 1.0;
}

@end
