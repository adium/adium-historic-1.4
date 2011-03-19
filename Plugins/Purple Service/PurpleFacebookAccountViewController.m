//
//  PurpleFacebookAccountViewController.m
//  Adium
//
//  Created by Evan Schoenberg on 1/15/09.
//  Copyright 2009 Adium X. All rights reserved.
//

#import "PurpleFacebookAccountViewController.h"
#import "PurpleFacebookAccount.h"

@implementation PurpleFacebookAccountViewController

- (NSString *)nibName
{
	return @"PurpleFacebookAccountView";
}

- (void)configureForAccount:(AIAccount *)inAccount
{
	[(PurpleFacebookAccount *)inAccount migrate];
}


@end
