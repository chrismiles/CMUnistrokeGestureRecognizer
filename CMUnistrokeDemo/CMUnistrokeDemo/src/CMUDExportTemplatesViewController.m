//
//  CMUDExportTemplatesViewController.m
//  CMUnistrokeDemo
//
//  Created by Chris Miles on 12/11/12.
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

#import "CMUDExportTemplatesViewController.h"
#import "CMUDTemplate.h"
#import "CMUDStrokeTemplateView.h"
#import "CMUDTemplateDataViewController.h"

#import <QuartzCore/QuartzCore.h>


@interface CMUDExportTemplatesViewController ()

@end


@implementation CMUDExportTemplatesViewController


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#pragma unused(tableView)
    
    return (NSInteger)[[self.templates allKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#pragma unused(tableView)
    
    NSString *key = [self.templates allKeys][(NSUInteger)section];
    CMUDTemplate *template = self.templates[key];
    
    return (NSInteger)[template.paths count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
#pragma unused(tableView)
    
    NSString *key = [self.templates allKeys][(NSUInteger)section];
    CMUDTemplate *template = self.templates[key];
    return template.name;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = nil;
    if ([tableView respondsToSelector:NSSelectorFromString(@"dequeueReusableCellWithIdentifier:forIndexPath:")]) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    const NSInteger templateViewTag = 543;
    CMUDStrokeTemplateView *templateView = (CMUDStrokeTemplateView *)[cell.contentView viewWithTag:templateViewTag];
    
    NSString *key = [self.templates allKeys][(NSUInteger)indexPath.section];
    CMUDTemplate *template = self.templates[key];
    UIBezierPath *path = template.paths[(NSUInteger)indexPath.row];
    templateView.bezierPath = path;
    
    return cell;
}


#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
#pragma unused(sender)

    if ([segue.identifier isEqualToString:@"ExportTemplatesToData"]) {
	NSMutableDictionary *paths = [NSMutableDictionary dictionary];
	for (NSIndexPath *indexPath in [self.tableView indexPathsForSelectedRows]) {
	    NSString *key = [self.templates allKeys][(NSUInteger)indexPath.section];
	    CMUDTemplate *template = self.templates[key];
	    UIBezierPath *path = template.paths[(NSUInteger)indexPath.row];
	    
	    NSMutableArray *pathList = paths[template.name];
	    if (pathList == nil) {
		pathList = [NSMutableArray array];
		paths[template.name] = pathList;
	    }
	    [pathList addObject:path];
	}
	
	// pass selected templates
	CMUDTemplateDataViewController *viewController = (CMUDTemplateDataViewController *)segue.destinationViewController;
	viewController.paths = paths;
    }
}

@end
