//
//  AIProxyListObject.h
//  Adium
//
//  Created by Evan Schoenberg on 4/9/09.
//  Copyright 2009 Adium X / Saltatory Software. All rights reserved.
//

@class ESObjectWithProperties, MAZeroingWeakRef;
@protocol AIContainingObject;

@interface AIProxyListObject : NSObject {
	MAZeroingWeakRef *weakRef_listObject;
    MAZeroingWeakRef *weakRef_containingObject;
	NSString *key;
	NSString *cachedDisplayNameString;
	NSAttributedString *cachedDisplayName;
	NSDictionary *cachedLabelAttributes;
	NSSize cachedDisplayNameSize;
}
@property (nonatomic, copy) NSDictionary *cachedLabelAttributes;
@property (nonatomic, retain) NSString *cachedDisplayNameString;
@property (nonatomic, retain) NSAttributedString *cachedDisplayName;
@property (nonatomic) NSSize cachedDisplayNameSize;

@property (nonatomic, retain) NSString *key;

- (AIListObject *)listObject;
- (void)setListObject:(AIListObject *)inListObject;

- (ESObjectWithProperties <AIContainingObject> *)containingObject;
- (void)setContainingObject:(ESObjectWithProperties <AIContainingObject> *)containingObject;


+ (AIProxyListObject *)proxyListObjectForListObject:(ESObjectWithProperties *)inListObject
									   inListObject:(ESObjectWithProperties<AIContainingObject> *)containingObject;

+ (AIProxyListObject *)existingProxyListObjectForListObject:(ESObjectWithProperties *)inListObject
											   inListObject:(ESObjectWithProperties <AIContainingObject>*)inContainingObject;

/*!
 * @brief Called when an AIListObject is done with an AIProxyListObject to remove it from the global dictionary
 */
+ (void)releaseProxyObject:(AIProxyListObject *)proxyObject;

/*!
 * @brief Clear out cached display information; should be called when the AIProxyListObject may be used later
 */
- (void)flushCache;

@end
