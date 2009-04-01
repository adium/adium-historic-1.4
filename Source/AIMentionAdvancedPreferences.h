//
//  AIMentionAdvancedPreferences.h
//  Adium
//
//  Created by Zachary West on 2009-03-31.
//

#import <Adium/AIAdvancedPreferencePane.h>
#import <AIUtilities/AIAlternatingRowTableView.h>


@interface AIMentionAdvancedPreferences : AIAdvancedPreferencePane {
	IBOutlet		NSTextField			*label_explanation;
	
	IBOutlet		NSTableView			*tableView;
	IBOutlet		NSButton			*button_add;
	IBOutlet		NSButton			*button_remove;
	
	NSMutableArray						*mentionTerms;
}


- (IBAction)add:(id)sender;
- (IBAction)remove:(id)sender;
@end
