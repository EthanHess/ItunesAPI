//
//  ViewController.m
//  googleAPI
//
//  Created by Ethan Hess on 6/5/15.
//  Copyright (c) 2015 Ethan Hess. All rights reserved.
//

#import "ViewController.h"

static NSString *kSearchCompleteNotification = @"SearchComplete";

@interface ViewController () <UISearchBarDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *results;

@end

@implementation ViewController

#pragma mark - UISearchBarDelegate

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerForNotifications];
    
}

- (void)dealloc {
    
    [self unregisterForNotifications];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [self searchItunesWithTerm:searchBar.text];
    
}

#pragma mark - Networking

- (void)searchItunesWithTerm:(NSString *)searchTerm {
    
    NSString *stringUrl = [NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@&limit=100", searchTerm];
    
    NSLog(@"making request: %@", stringUrl);
    
    NSURL *url = [NSURL URLWithString:[stringUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            
            [self handleError:error];
        }
        else {
            
            [self parseSearchResults:data response:response];
        }
    }];
    
    [dataTask resume];
    
}

- (void)parseSearchResults:(NSData *)data response:(NSURLResponse *)response {
    
//    NSLog(@"%@", response.MIMEType);
//    NSLog(@"%@", response.textEncodingName);
    
    NSError *error = nil;
    
    if (error) {
        
        [self handleError:error];
    }
    else {
        
        id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        self.results = ((NSDictionary *)result)[@"results"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kSearchCompleteNotification object:nil];
        
        NSLog(@"%@", self.results);
    }
    
}

- (void)handleError:(NSError *)error {
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:error.localizedDescription message:error.localizedFailureReason delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    
    [alert show];
}

#pragma UITableView DataSource Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    NSDictionary *resultItem = self.results[indexPath.row];
    
    cell.textLabel.text = resultItem[@"trackName"];
    cell.detailTextLabel.text = resultItem[@"artistName"];

    
    return cell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.results count];
    
}

#pragma mark - Notification Methods

- (void)registerForNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView) name:kSearchCompleteNotification object:nil];
    
}

- (void)unregisterForNotifications {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)reloadTableView {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.tableView reloadData];
    });
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
//    NSURL *url = [NSURL URLWithString:@"http://www.google.com"];
//    //    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    
//    [request setHTTPMethod:@"POST"];
//    [request addValue:@"content-type" forHTTPHeaderField:@"apllication/json"];
//    
//    UIImage *image = [UIImage imageNamed:@"image.png"];
//    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
//    
//    [request setHTTPBody:imageData];
//    
//    NSInputStream *stream = [NSInputStream inputStreamWithFileAtPath:@""];
//    [request setHTTPBodyStream:stream];
//    
//    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        
//        NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        
//        NSLog(@"%@", html);
//        
//    }];
//    
//    [task resume];
}

@end
