//
//  AIProxyListObject.m
//  Adium
//
//  Created by Evan Schoenberg on 4/9/09.
//  Copyright 2009 Adium X / Saltatory Software. All rights reserved.
//

#import "AIProxyListObject.h"
#import <Adium/ESObjectWithProperties.h>
#import <Adium/AIListObject.h>

@interface NSObject (PublicAPIMissingFromHeadersAndDocsButInTheReleaseNotesGoshDarnit)
- (id)forwardingTargetForSelector:(SEL)aSelector;
@end

@implementation AIProxyListObject

@synthesize key, cachedDisplayName, cachedDisplayNameString, cachedLabelAttributes, cachedDisplayNameSize;
@synthesize listObject, containingObject;

static NSMutableDictionary *proxyDict;

+ (void)initialize
{
	if (self == [AIProxyListObject class])
		proxyDict = [[NSMutableDictionary alloc] init];
}

+ (AIProxyListObject *)existingProxyListObjectForListObject:(AIListObject *)inListObject
											   inListObject:(ESObjectWithProperties <AIContainingObject>*)inContainingObject
{
	NSString *key = (inContainingObject ? 
					 [NSString stringWithFormat:@"%@-%@", inListObject.internalObjectID, inContainingObject.internalObjectID] :
					 inListObject.internalObjectID);
	
	return [proxyDict objectForKey:key];
}

+ (AIProxyListObject *)proxyListObjectForListObject:(AIListObject *)inListObject
									   inListObject:(ESObjectWithProperties <AIContainingObject>*)inContainingObject
{
	AIProxyListObject *proxy;
	NSString *key = (inContainingObject ? 
					 [NSString stringWithFormat:@"%@-%@", inListObject.internalObjectID, inContainingObject.internalObjectID] :
					 inListObject.internalObjectID);

	proxy = [proxyDict objectForKey:key];

	if (proxy && proxy.listObject != inListObject) {
        /* This is generally a memory management failure; AIContactController stopped tracking a list object, but it never deallocated and
		 * so never called [AIProxyListObject releaseProxyObject:].
		 *
		 * I've seen one case where proxy.listObject referred to a zombie object. I can't reproduce. If that happens, we'll get a crash here in
		 * debug mode only.  -evands 8/28/11
		 */
		AILogWithSignature(@"%@ was leaked! Meh.", proxy.listObject);

		proxy.listObject = inListObject;
		proxy.containingObject = inContainingObject;
	}

	if (!proxy) {
		proxy = [[AIProxyListObject alloc] init];
		proxy.listObject = inListObject;
		proxy.containingObject = inContainingObject;
		proxy.key = key;
		[inListObject noteProxyObject:proxy];
		[proxyDict setObject:proxy
					  forKey:key];
		[proxy release];
	}

	return proxy;
}

/*!
 * @brief Called when an AIListObject is done with an AIProxyListObject to remove it from the global dictionary
 *
 * This should be called only by AIListObject when it deallocates, for each of its proxy objects
 */
+ (void)releaseProxyObject:(AIProxyListObject *)proxyObject
{
	AILogWithSignature(@"%@", proxyObject);
	[[proxyObject retain] autorelease];
	proxyObject.listObject = nil;
	[proxyDict removeObjectForKey:proxyObject.key];
}

- (void)flushCache
{
	self.cachedDisplayName = nil;
	self.cachedDisplayNameString = nil;
	self.cachedLabelAttributes = nil;
}

- (void)dealloc
{
	AILogWithSignature(@"%@", self);
	self.key = nil;

    [self flushCache];
	
	[super dealloc];
}


/* Pretend to be our listObject. I suspect being an NSProxy subclass could do this more cleanly, but my initial attempt
 * failed and this works fine.
 */
- (Class)class
{
	return [[self listObject] class];
}

- (BOOL)isKindOfClass:(Class)class
{
	return [[self listObject] isKindOfClass:class];
}

- (BOOL)isMemberOfClass:(Class)class
{
	return [[self listObject] isMemberOfClass:class];
}

- (BOOL)isEqual:(id)inObject
{
	return [[self listObject] isEqual:inObject];
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
	return [self listObject];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<AIProxyListObject %p -> %@>", self, [self listObject]];
}

@end
