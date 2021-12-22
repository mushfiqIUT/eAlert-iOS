//
//  WebViewController.m
//  Actusmi
//
//  Created by Mushfiqur Rahman on 29/04/2013.
//  Copyright (c) 2013 Impulse BD Ltd. All rights reserved.
//

#import "WebViewController.h"
#import "HTMLParser.h"

#define WEBURL_KEY   @"weburl_preference"
#define USERNAME_KEY @"username_preference"
#define PASSWORD_KEY @"password_preference"

@interface WebViewController ()
{
    //BOOL isClassicMode;
    NSMutableData *webData;
    NSString *firstViewHtml;
    NSInteger backCounter;
    BOOL backCounterBool;
    
    NSURL *theUrl;
    NSString  *WEB_URL;
    NSString *USER; //@"mark.kunzmann@ext.actelion.com";
    NSString *PWD;  //@"medalert";
    
    BOOL isPDF;
}

@property (strong, nonatomic) UIDocumentInteractionController *documentInteractionController;

@end

@implementation WebViewController

@synthesize actWebView, toggleToolBar, backBarButtonItem, forwardBarButtonItem; // toggleButtonBarItem, browserButtonBarItem;
@synthesize progressActivityIndactionView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    WEB_URL = [[NSUserDefaults standardUserDefaults] objectForKey:WEBURL_KEY];
    USER = [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_KEY];
    PWD = [[NSUserDefaults standardUserDefaults] objectForKey:PASSWORD_KEY];
    
    //backCounter = 0;
    return self;
}

#pragma 
#pragma mark- View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isPDF = NO;
    
    // Load other Stuff
    //isClassicMode = NO;
    
    // set progress bar indication view color
    progressActivityIndactionView.color = [UIColor redColor];
    
    [actWebView.scrollView setShowsHorizontalScrollIndicator:NO];

    // init Toolbar
    //[self initializeToolbar];
    
    [self loadClassicMode];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appHasEnteredForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewWillDisappear:animated];
}

- (void)appHasEnteredForeground {
    //NSLog(@"foreground");
    //if (isClassicMode) {
        NSString *string = [actWebView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('body')[0].innerHTML"];
        BOOL isEmpty = string==nil || [string length]==0;
        if (isEmpty) {
            [self loadClassicMode];
        }
    //}
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma
#pragma mark- Customise Method

- (void)saveUsername:(NSString *)user andPassword:(NSString *)pass
{
    if ([user length] == 0 || [pass length] == 0) {
        return;
    }
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:user forKey:USERNAME_KEY];
    [defaults setObject:pass forKey:PASSWORD_KEY];
    [defaults synchronize];
}

- (void) updateButtons
{
    self.forwardBarButtonItem.enabled = self.actWebView.canGoForward;
    self.backBarButtonItem.enabled = self.actWebView.canGoBack;
//    if ([actWebView canGoBack])
//    {
//        self.backBarButtonItem.enabled = self.actWebView.canGoBack;
//    }
//    else
//    {
//        // You've reached the end of the line, so reload your own data
//        if (backCounterBool)
//        {
//            self.backBarButtonItem.enabled = YES;
//        }
//        else
//        {
//            self.backBarButtonItem.enabled = NO;
//        }
//    }
    
}

//-(void) firstViewReload {
//    backCounter = 0;
//    backCounterBool = NO;
//    self.backBarButtonItem.enabled = NO;
//    
//    [[self actWebView] loadHTMLString:firstViewHtml baseURL:theUrl];
//    
//}


//- (void)loadNewMode {
//    isClassicMode = NO;
//    NSLog(@"%d", isClassicMode);
//    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"act_detail" ofType:@"html"];
//    NSString *htmlContent = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
//    NSLog(@"%@", htmlContent);
//    
//    [self.actWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
//    [self.actWebView loadHTMLString:htmlContent baseURL:[[NSBundle mainBundle] bundleURL]];
//}

- (void)loadClassicMode {
    
    //isClassicMode = YES;
    //NSLog(@"URL: %@", WEB_URL);
    
    theUrl = [NSURL URLWithString:WEB_URL];
    //[self.actWebView loadHTMLString:@"about:blank" baseURL:nil];
    
    //[self.actWebView loadRequest:[NSURLRequest requestWithURL:theUrl]];
    
    if (USER == nil || PWD ==  nil || [USER length] == 0 || [PWD length] == 0) {
        [self.actWebView loadRequest:[NSURLRequest requestWithURL:theUrl]];
        self.actWebView.delegate = self;
        return;
    }
    
    [self.actWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    
    NSString *webString = [self getHtmlContent:WEB_URL];
    
    //html parsing code
    NSError *error = nil;
    
    HTMLParser *parser = [[HTMLParser alloc] initWithString:webString error:&error];
    
    if (error) {
        //NSLog(@"Error: %@", error);
        return;
    }
    
    HTMLNode *bodyNode = [parser form];
    //NSLog(@"OP/Method: %@", [bodyNode findChildWithAttribute:@"name" matchingName:@"op" allowPartial:NO]);
    
    if([bodyNode findChildWithAttribute:@"name" matchingName:@"op" allowPartial:NO] && [bodyNode findChildWithAttribute:@"name" matchingName:@"method" allowPartial:NO])
    {
        NSArray *inputNodes = [bodyNode findChildTags:@"input"];
        
        NSMutableDictionary *postDict = [[NSMutableDictionary alloc] init];
        NSMutableArray *headerList = [[NSMutableArray alloc] init];
        
        for (HTMLNode *inputNode in inputNodes) {
            if ([[inputNode getAttributeNamed:@"name"] isEqualToString:@"webguiCsrfToken"]) {
                // NSLog(@"%@", [inputNode getAttributeNamed:@"value"]);
                [postDict setValue: [inputNode getAttributeNamed:@"value"] forKey: [inputNode getAttributeNamed:@"name"]];
                //[headerList addObject:[inputNode getAttributeNamed:@"name"]];
            }
            if ([[inputNode getAttributeNamed:@"name"] isEqualToString:@"op"]) {
                [postDict setValue: [inputNode getAttributeNamed:@"value"] forKey: [inputNode getAttributeNamed:@"name"]];
            }
            if ([[inputNode getAttributeNamed:@"name"] isEqualToString:@"method"]) {
                [postDict setValue: [inputNode getAttributeNamed:@"value"] forKey: [inputNode getAttributeNamed:@"name"]];
            }
            if([inputNode getAttributeNamed:@"name"])
            {
                [headerList addObject:[inputNode getAttributeNamed:@"name"]];
            }
        }
        
        [postDict setValue:USER  forKey: @"username"];
        [postDict setValue:PWD  forKey: @"identifier"];
        
        //NSLog(@"Dict: %@ Array: %@", postDict, headerList);
        
        [self sendPostReq:postDict withKeys:headerList];
    }
    else
    {
       // NSLog(@"Load Direct");

        firstViewHtml = webString;
        [self.actWebView loadHTMLString:webString baseURL:theUrl];
        [self actWebView].delegate = self;
    }
    
}

- (void)sendPostReq:(NSDictionary *)postDict withKeys:(NSArray *)headerKeys
{
    NSURL *mainPage = [NSURL URLWithString:[WEB_URL stringByAppendingString:@"/home/medintellibase"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: mainPage];
    
    // Specify that it will be a POST request
    [request setHTTPMethod:@"POST"];
    
    // This is how we set header fields
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    //[request setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
    //[request setValue:@"gzip,deflate,sdch" forHTTPHeaderField:@"Accept-Encoding"];
    
    NSString *stringData = @""; //= @"webguicsrftoken=wYmG3r_BGlNRM65eA5a5hg&op=auth&method=login&username=mark.kunzmann@ext.actelion.com&identifier=medalert&";
    
    
    for(NSString *keyValue in headerKeys){
        //NSLog(@"Post Dict: %@ -- For Key: %@", [postDict objectForKey:keyValue], keyValue);
        
        stringData = [stringData stringByAppendingString:[NSString stringWithFormat:@"%@=%@&",keyValue, [postDict objectForKey:keyValue]]];
    }
    //NSLog(@"REQUEST: %@", stringData);
    
    NSData *requestBodyData = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = requestBodyData;
    
    // Create url connection and fire request
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if(conn)
    {
       webData = [NSMutableData data];
    }
    
}

- (NSString *)getHtmlContent:(NSString *)url {
    NSURL *theURL = [NSURL URLWithString:url];
    
    NSError *error;
    return [NSString stringWithContentsOfURL:theURL encoding:NSASCIIStringEncoding error:&error];
}

- (void)customStyleInjection: (UIWebView *)webView
{
    NSString *bodyStyle = @"document.getElementById('main').style.width = '100%';";//@"document.getElementsByTagName('body')[0].style.width = '200%';";
    NSString *marginStyle = @"document.getElementById('main').style.margin = 'auto';";//@"document.getElementsByTagName('body')[0].style.margin = 'auto';";
    NSString *leftTableStylePos = @"document.getElementsByClassName('miniToc')[0].style.left = '5px';";
    NSString *leftTableStyleWidth = @"document.getElementsByClassName('miniToc')[0].style.width = '160px';";
    
    NSString *breakingNewsLink = @"document.getElementById('abstract').style.margin = '20px';";
    
    NSString *tutorialLink = @"document.getElementsByClassName('navlinks')[0].getElementsByTagName('a')[1].style.display='none';";
    
    [webView stringByEvaluatingJavaScriptFromString:bodyStyle];
    [webView stringByEvaluatingJavaScriptFromString:marginStyle];
    [webView stringByEvaluatingJavaScriptFromString:leftTableStylePos];
    [webView stringByEvaluatingJavaScriptFromString:leftTableStyleWidth];
    [webView stringByEvaluatingJavaScriptFromString:breakingNewsLink];
    [webView stringByEvaluatingJavaScriptFromString:tutorialLink];
}


#pragma 
#pragma mark- NSURLConnection Delegate

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [webData setLength:0];
    //NSLog(@"Response: %@", response);
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [webData appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
   // NSLog(@"Error with connection %@",error);
}


-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //NSLog(@"NSURLconnectionDidFinishLoading. received Bytes: %d", [webData length]);
    
    firstViewHtml = [[NSString alloc] initWithBytes:[webData mutableBytes] length:[webData length] encoding:NSUTF8StringEncoding];
    
    //NSLog(@"received html %@", thehtml);
    NSError* error = nil;
    
    if (error) {
       // NSLog(@"Post connection error: %@",[error localizedDescription]);
    }
    
    [[self actWebView] loadHTMLString:firstViewHtml baseURL:theUrl];
    [self actWebView].delegate = self;

}



#pragma
#pragma mark- UIAlertView Delegate

- (void)webviewLoadingErrorAlertView {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Load Error" message:@"The site data could not be loaded.\n(If you are using the Modern layout, only the alert list is implemented. Switch back to Standard layout)." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Try Again", nil];
    [alert show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        [self loadClassicMode];
    }
}


#pragma 
#pragma mark- UIWebView Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [progressActivityIndactionView startAnimating];
    progressActivityIndactionView.hidden= NO;
    //toggleButtonBarItem.enabled = NO;
    [self updateButtons];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [progressActivityIndactionView stopAnimating];
    progressActivityIndactionView.hidden = YES;
    //toggleButtonBarItem.enabled = YES;
    
    NSLog(@"Web View Did Finish Load Delegate");
    [self customStyleInjection:webView];
    
    [self updateButtons];
    
    if (isPDF) {}
    else
    {
        NSString *string = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
        if ([string length] < 1) {
            // home view
            //NSLog(@"Back end...call 1st  %@",string);
            //        NSString *webString = [self getHtmlContent:WEB_URL];
            //        [self.actWebView loadHTMLString:webString baseURL:theUrl];
            [[self actWebView] loadHTMLString:firstViewHtml baseURL:theUrl];
        }
        
    }
    isPDF = NO;
    
    
//    backCounter = backCounter + 1;
//    NSLog(@"backcounter: %d", backCounter);
//    //backCounterBool = NO;
//    
//    if (backCounter > 1) {
//        backCounterBool = YES;
//        backCounter = 1;
//    }
//    
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [progressActivityIndactionView stopAnimating];
    progressActivityIndactionView.hidden = YES;
    //toggleButtonBarItem.enabled = YES;
    [self updateButtons];
    
    //[self webviewLoadingErrorAlertView];
}

- (void)viewDidUnload {
    //[self setBrowserButtonBarItem:nil];
    [super viewDidUnload];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //NSLog(@"In shouldStartLoadWithRequest");

    if ([[[request.URL pathExtension] lowercaseString] isEqualToString:@"pdf"]) {
        isPDF = NO;
        
        [self previewDocument:request.URL];
        return NO;
    }
    
    if (navigationType == UIWebViewNavigationTypeFormSubmitted) {
        
        NSString *username = [webView stringByEvaluatingJavaScriptFromString: @"document.getElementsByName('username')[0].value"];
        NSString *password = [webView stringByEvaluatingJavaScriptFromString: @"document.getElementsByName('identifier')[0].value"];
        //NSLog(@"USER: %@ PASS: %@", username, password);
        [self saveUsername:username andPassword:password];

    }
    
    if ([[[[request.URL lastPathComponent] pathExtension] lowercaseString] isEqualToString:@"swf"]) {
        //NSLog(@"Request URL: %@",request.URL);
        return NO;
    }
    return YES;
}



#pragma mark -
#pragma mark Document Interaction Controller Delegate Methods
- (UIViewController *) documentInteractionControllerViewControllerForPreview: (UIDocumentInteractionController *) controller
{
    return self;
}

- (UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller
{
    return self.view;
}

- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController *)controller
{
    return self.view.frame;
}

- (void)previewDocument:(NSURL *)url
{
    
    if (url) {
        
        NSURLRequest *req = [[NSURLRequest alloc] initWithURL:url];
        [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *resp, NSData *respData, NSError *error){
            //NSLog(@"resp data length: %i", respData.length);
            NSString* theFileName = [[url absoluteString] lastPathComponent];
            NSString * path = [NSTemporaryDirectory() stringByAppendingPathComponent:theFileName];
            NSError *errorC = nil;
            BOOL success = [respData writeToFile:path
                                         options:NSDataWritingFileProtectionComplete
                                           error:&errorC];
            
            if (success) {
                // Initialize Document Interaction Controller
                self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:path]];
                
                // Configure Document Interaction Controller
                [self.documentInteractionController setDelegate:self];
                
                //CGRect dummyRect=CGRectMake(0, 5, 1, 1);
                bool didShow = [self.documentInteractionController presentPreviewAnimated:YES]; //[self.documentInteractionController presentOptionsMenuFromRect:dummyRect inView:self.view animated:NO];
                
                
                if (!didShow) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Preview Error"
                                                                    message:@"Sorry. The appropriate apps are not found on this device."
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles: nil];
                    [alert show];
                }
                
            } else {
                //NSLog(@"fail: %@", errorC.description);
            }
        }];
    }

}


@end
