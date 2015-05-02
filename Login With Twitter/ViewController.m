//
//  ViewController.m
//  Login With Twitter
//
//  Created by Nada Kamel Abdelhady on 4/27/15.
//  Copyright (c) 2015 Nada Kamel Abdelhady. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnTwitterLogin:(id)sender {
    //Get a reference to the application delegate.
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    //NSString *strID = [NSString stringWithFormat:@"Ready-Tweet-IDsMai"];
    //NSMutableArray *_IDs = [self convertFromTxtToPlist: strID];
    //NSString *strClass = [NSString stringWithFormat:@"Ready-Tweet-ClassMai"];
    //NSMutableArray *_Classes = [self convertFromTxtToPlist: strClass];

    
    // Read from pList
    NSString *path = [NSString stringWithFormat:@"/Users/NadaKamel/Desktop/Ready-Tweet-IDsMai.plist"];
    NSMutableArray *IDs = [[NSMutableArray alloc] initWithContentsOfFile:path];
    NSString *path1 = [NSString stringWithFormat:@"/Users/NadaKamel/Desktop/Ready-Tweet-ClassMai.plist"];
    NSMutableArray *Classes = [[NSMutableArray alloc] initWithContentsOfFile:path1];
    
    //Get Twitter account, stored in on the device, for the first time.
    [appDelegate getTwitterAccountOnCompletion:^(ACAccount *twitterAccount){
            //If we successfully retrieved a Twitter account
            if(twitterAccount) {
                // Lets create the request.
                NSMutableString *link = [NSMutableString stringWithFormat: @"https://api.twitter.com/1.1/statuses/show.json?id="];
                NSUInteger index = 0;
                NSString *strID = [IDs objectAtIndex:index];
                [link appendString: strID];
                NSString *strClass = [Classes objectAtIndex:index];
                
                NSURL *credentialsUrl = [NSURL URLWithString: link];
                TWRequest *credentialsRequest = [[TWRequest alloc] initWithURL:credentialsUrl
                                                                    parameters:nil
                                                                 requestMethod:TWRequestMethodGET];
                
                //Be sure to attach the Twitter ACAccount object to the request.
                credentialsRequest.account = twitterAccount;
                [credentialsRequest performRequestWithHandler:^(NSData *responseData,
                                                                NSHTTPURLResponse *urlResponse,
                                                                NSError *error) {
                    //If there is an error, display a message to the user.
                    if(error != nil) {
                        [self displayErrorMessage];
                        return;
                    }
                    // Parse the JSON response.
                    NSError *jsonError = nil;
                    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData
                                                                             options:0
                                                                               error:&jsonError];
                    NSString *jsonOut = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                    //If the JSON parser has thrown an error, display a message to the user.
                    if(jsonError != nil) {
                        [self displayErrorMessage];
                        return;
                    }
                    
                    // Retrieve the user's status
                    NSString *status = [response objectForKey:@"text"];
                    if(status != nil) {
                        // Write the status to the text file.
                        [self writeToTextFileWithAppend:status :strClass];
                        [self displaySuccessMessage];
                    }
                    else {
                        [self displayErrorMessage];
                    }
                    [IDs removeObjectAtIndex:index];
                    [IDs writeToFile:path atomically:YES];
                    [Classes removeObjectAtIndex:index];
                    [Classes writeToFile:path1 atomically:YES];
                    
                    /*
                    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                    if ([[NSFileManager defaultManager] fileExistsAtPath: path]  == YES)
                        NSLog (@"File exists");
                    else
                        NSLog (@"File not found");
                    
                    //[IDsEdit removeLastObject];
                    //[IDsEdit writeToFile:path atomically:YES];
                    if ([[NSFileManager defaultManager] fileExistsAtPath: path]  == YES)
                        NSLog (@"File exists");
                    else
                        NSLog (@"File not found");
                    */
                    
                    
                }];
                
             }
        }];
}

// Method to dispaly an error message when it occurs
- (void) displaySuccessMessage {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Twitter success"]
                                                    message:[NSString stringWithFormat:@"Status saved to file."]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

// Method to dispaly an error message when it occurs
- (void) displayErrorMessage {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Twitter error"]
                                                    message:[NSString stringWithFormat:@"There was an error talking to %@. Please try again later.", @"Twitter"]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

// Method writes a string to a text file and appends to it if exists
- (void) writeToTextFileWithAppend: (NSString*)text :(NSString*)mood {
    //get the documents directory
    NSString *documentsDirectory = @"/Users/NadaKamel/Desktop";
    
    //make a file name to write the data to using the documents directory
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"Mai.txt"];
    
    //get text
    if([mood isEqualToString:@"neutral"])
        mood = [NSString stringWithFormat:@"objective"];
    else if([mood isEqualToString:@"objective-OR-neutral"])
        mood = [NSString stringWithFormat:@"objective"];
    
    NSMutableString *str = [NSMutableString stringWithFormat: @"%@,%@", text, mood];
    [str appendString:@"\n"];
    
    //save content to the documents directory
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:filePath])
    {
        [str writeToFile:filePath
              atomically:YES];
    }
    else
    {
        NSFileHandle *myHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
        [myHandle seekToEndOfFile];
        [myHandle writeData:[str dataUsingEncoding: NSUTF8StringEncoding]];
    }
}

- (NSMutableArray*) convertFromTxtToPlist: (NSString*) fileName {
    // Get the document directory
    NSMutableString *path = [NSMutableString stringWithFormat: @"/Users/NadaKamel/Desktop/%@.txt", fileName];
    
    // Read IDs from the text file.
    NSString* content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    NSArray *IDs = [content componentsSeparatedByString:@"\r\n"];
    
    // Write it to a pList
    path = [NSMutableString stringWithFormat: @"/Users/NadaKamel/Desktop/%@.plist", fileName];
    NSMutableArray *dict = [[NSMutableArray alloc] init];
    [dict addObjectsFromArray:IDs];
    [dict writeToFile:path atomically:YES];
    
    return dict;
}

@end
