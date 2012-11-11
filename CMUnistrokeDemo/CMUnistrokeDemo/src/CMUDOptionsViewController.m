//
//  CMUDOptionsViewController.m
//  CMUnistrokeDemo
//
//  Created by Chris Miles on 10/11/12.
//  Copyright (c) 2012 Chris Miles. All rights reserved.
//
//  MIT Licensed (http://opensource.org/licenses/mit-license.php):
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "CMUDOptionsViewController.h"
#import "CMUDOptionsCell.h"
#import "CMUDShared.h"
#import "CMUDExportTemplatesViewController.h"

#import <CMUnistrokeGestureRecognizer/CMUnistrokeGestureRecognizer.h>


@interface CMUDOptionsViewController ()

@end

@implementation CMUDOptionsViewController

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
#pragma unused(tableView, indexPath)
    
    if ([cell isKindOfClass:[CMUDOptionsCell class]]) {
	NSString *optionName = [(CMUDOptionsCell *)cell optionName];
	BOOL optionValue = [[self.unistrokeGestureRecognizer valueForKey:optionName] boolValue];
	[(CMUDOptionsCell *)cell configureWithOptionValue:optionValue];
    }
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZAssert(self.unistrokeGestureRecognizer != nil, @"unistrokeGestureRecognizer must not be nil");
    
    CMUDOptionsCell *cell = (CMUDOptionsCell *)[tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[CMUDOptionsCell class]]) {
	NSString *optionName = cell.optionName;
	BOOL optionValue = (! [[self.unistrokeGestureRecognizer valueForKey:optionName] boolValue]);
	[self.unistrokeGestureRecognizer setValue:@(optionValue) forKey:optionName];
	
	[cell configureWithOptionValue:optionValue];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (cell.reloadTemplateGesturesOnOptionChange) {
	    [[NSNotificationCenter defaultCenter] postNotificationName:CMUDTemplateGesturesShouldReloadNotification object:self userInfo:nil];
	}
    }
}


#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
#pragma unused(sender)

    if ([segue.identifier isEqualToString:@"OptionsToExport"]) {
	CMUDExportTemplatesViewController *viewController = (CMUDExportTemplatesViewController *)segue.destinationViewController;
	viewController.templates = self.templates;
    }
}

@end
