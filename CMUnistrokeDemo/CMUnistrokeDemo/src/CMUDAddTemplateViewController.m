//
//  CMUDAddTemplateViewController.m
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

#import "CMUDAddTemplateViewController.h"
#import "CMUDTemplatesTableViewController.h"

#import <QuartzCore/QuartzCore.h>


@interface CMUDAddTemplateViewController () <CMUDTemplatesTableViewControllerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *pathView;
@property (weak, nonatomic) IBOutlet UITextField *templateNameTextField;

@end


@implementation CMUDAddTemplateViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIBezierPath *path = [self.strokePath copy];
    
    CGRect pathBounds = CGRectInset(path.bounds, -10.0f, -10.0f);
    CGFloat scale = fminf(self.pathView.bounds.size.width/pathBounds.size.width, self.pathView.bounds.size.height/pathBounds.size.height);
    CGAffineTransform transform = CGAffineTransformMakeScale(scale, scale);
    transform = CGAffineTransformTranslate(transform, -pathBounds.origin.x, -pathBounds.origin.y);
    [path applyTransform:transform];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    shapeLayer.fillColor = nil;
    shapeLayer.strokeColor = [UIColor blackColor].CGColor;
    shapeLayer.frame = self.pathView.layer.bounds;
    [self.pathView.layer addSublayer:shapeLayer];
}


#pragma mark - Cancel

- (IBAction)cancelAction:(id)sender
{
#pragma unused(sender)
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)saveAction:(id)sender
{
#pragma unused(sender)
    
    NSString *templateName = [self.templateNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([templateName length] > 0) {
	[self.delegate addTemplateViewController:self savesTemplateWithName:templateName path:self.strokePath];
    }
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
#pragma unused(sender)
    
    if ([segue.identifier isEqualToString:@"AddTemplateToTemplates"]) {
	CMUDTemplatesTableViewController *viewController = (CMUDTemplatesTableViewController *)segue.destinationViewController;
	viewController.delegate = self;
	viewController.templateNames = self.templateNames;
    }
}


#pragma mark - CMUDTemplatesTableViewControllerDelegate

- (void)templatesTableViewController:(CMUDTemplatesTableViewController *)templatesTableViewController didSelectTemplateName:(NSString *)templateName
{
#pragma unused(templatesTableViewController)

    self.templateNameTextField.text = templateName;
    [self.navigationController popToViewController:self animated:YES];
}

@end
