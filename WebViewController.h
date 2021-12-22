//
//  WebViewController.h
//  Actusmi
//
//  Created by Mushfiqur Rahman on 29/04/2013.
//  Copyright (c) 2013 Impulse BD Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate, UIDocumentInteractionControllerDelegate>

@property(nonatomic,strong) IBOutlet UIWebView *actWebView;
@property(nonatomic,strong) IBOutlet UIToolbar *toggleToolBar;
@property(nonatomic,strong) IBOutlet UIBarButtonItem *backBarButtonItem;
@property (nonatomic,strong) IBOutlet UIBarButtonItem *forwardBarButtonItem;
//@property(nonatomic,strong) IBOutlet UIBarButtonItem *toggleButtonBarItem;
//@property (strong, nonatomic) IBOutlet UIBarButtonItem *browserButtonBarItem;


@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *progressActivityIndactionView;

//- (IBAction)backButtonPressed:(id)sender;
//- (IBAction)forwardButtonPressed:(id)sender;

@end
