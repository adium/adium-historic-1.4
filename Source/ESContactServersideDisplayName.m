/* 
 * Adium is the legal property of its developers, whose names are listed in the copyright file included
 * with this source distribution.
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU
 * General Public License as published by the Free Software Foundation; either version 2 of the License,
 * or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even
 * the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
 * Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program; if not,
 * write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */

#import <Adium/AIInterfaceControllerProtocol.h>
#import "ESContactServersideDisplayName.h"
#import <Adium/AIListObject.h>

/*!
 * @class ESContactServersideDisplayName
 * @brief Tooltip component: Serverside Display Name
 *
 * Only shows the serverside display name if it is not the same as the normal display name.
 */
@implementation ESContactServersideDisplayName

/*!
 * @brief Install
 */
- (void)installPlugin
{
    //Install our tooltip entry
    [adium.interfaceController registerContactListTooltipEntry:self secondaryEntry:YES];
}

/*!
 * @brief Tooltip label
 *
 * @result A label, or nil if no tooltip entry should be shown
 */
- (NSString *)labelForObject:(AIListObject *)inObject
{
    return AILocalizedString(@"Display Name",nil);
}

/*!
 * @brief Tooltip entry
 *
 * @result The tooltip entry, or nil if no tooltip should be shown
 */
- (NSAttributedString *)entryForObject:(AIListObject *)inObject
{
    NSString			*serverDisplayName;
    NSAttributedString	*entry = nil;
	
    //Get the server display name
    serverDisplayName = [inObject valueForProperty:@"Server Display Name"];
    
    //Return the correct string
    if (serverDisplayName && ![serverDisplayName isEqualToString:inObject.displayName]) {
		entry = [[NSAttributedString alloc] initWithString:serverDisplayName];
    }
	
    return [entry autorelease];
}

- (BOOL)shouldDisplayInContactInspector
{
	/* This information is already included by accounts */
	return NO;
}

@end
