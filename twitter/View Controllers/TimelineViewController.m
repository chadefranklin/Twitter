//
//  TimelineViewController.m
//  twitter
//
//  Created by emersonmalca on 5/28/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import "TimelineViewController.h"
#import "APIManager.h"
#import "TweetCell.h"
#import "UIImageView+AFNetworking.h"
#import "ComposeViewController.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "TweetDetailsViewController.h"

@interface TimelineViewController () <ComposeViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tweetsTableView;
@property (nonatomic, strong) NSMutableArray *tweets;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation TimelineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tweetsTableView.dataSource = self;
    self.tweetsTableView.delegate = self;
    
    [self getTweets];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(getTweets) forControlEvents:UIControlEventValueChanged];
    [self.tweetsTableView insertSubview:self.refreshControl atIndex:0];
}

- (void)getTweets{
    // Get timeline
    [[APIManager shared] getHomeTimelineWithCompletion:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            NSLog(@"😎😎😎 Successfully loaded home timeline");
            //for (NSDictionary *dictionary in tweets) {
            //    NSString *text = dictionary[@"text"];
            //    NSLog(@"%@", text);
            //}
            
            self.tweets = tweets;
            [self.tweetsTableView reloadData];
        } else {
            NSLog(@"😫😫😫 Error getting home timeline: %@", error.localizedDescription);
        }
        
        [self.refreshControl endRefreshing];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //return 20;
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell"];
    
    Tweet *tweet = self.tweets[indexPath.row];
    [self configureTweetCell:cell :tweet];
        
    return cell;
}

- (void)configureTweetCell:(TweetCell *)cell: (Tweet *)tweet{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.tweet = tweet;
    
    // odd. screen name is the @username
    cell.displayNameLabel.text = tweet.user.name;
    cell.usernameLabel.text = [usernameSymbol stringByAppendingString:tweet.user.screenName];
    cell.dateLabel.text = tweet.createdAtString;
    cell.tweetLabel.text = tweet.text;
    
    if (tweet.user.profilePictureURLString){
        NSURL *imageURL = [NSURL URLWithString:tweet.user.profilePictureURLString];
        // some error checking
        if(imageURL && [imageURL scheme] && [imageURL host]){
        
        
            NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];

            __weak TweetCell *weakCell = cell;
            [cell.profileImageView setImageWithURLRequest:request placeholderImage:nil
                                            success:^(NSURLRequest *imageRequest, NSHTTPURLResponse *imageResponse, UIImage *image) {
                                                // imageResponse will be nil if the image is cached
                                                if (imageResponse) {
                                                    //NSLog(@"Image was NOT cached, fade in image");
                                                    weakCell.profileImageView.alpha = 0.0;
                                                    weakCell.profileImageView.image = image;
                                                    
                                                    //Animate UIImageView back to alpha 1 over 0.3sec
                                                    [UIView animateWithDuration:0.3 animations:^{
                                                        weakCell.profileImageView.alpha = 1.0;
                                                    }];
                                                }
                                                else {
                                                    //NSLog(@"Image was cached so just update the image");
                                                    weakCell.profileImageView.image = image;
                                                }
                                            }
                                            failure:^(NSURLRequest *request, NSHTTPURLResponse * response, NSError *error) {
                                                // do something for the failure condition
                                                weakCell.profileImageView.image = nil;
                                            }];
        }
    } else {
        cell.profileImageView.image = nil;
    }
    
    [cell updateViews];
}

- (IBAction)onLogoutPressed:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    appDelegate.window.rootViewController = loginViewController;
    
    [[APIManager shared] logout];
}





#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    //if (segue.identifier == @"toComposeTweetSegue") {
    if ([segue.identifier isEqualToString:@"toComposeTweetSegue"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        ComposeViewController *composeController = (ComposeViewController*)navigationController.topViewController;
        composeController.delegate = self;
    } else if ([segue.identifier isEqualToString:@"toTweetDetailsSegue"]) {
        UITableViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tweetsTableView indexPathForCell:tappedCell];
        Tweet *tweet = self.tweets[indexPath.row];
        
        //TweetDetailsViewController *tweetDetailsViewController = [segue destinationViewController];
        UINavigationController *navigationController = [segue destinationViewController];
        TweetDetailsViewController *tweetDetailsViewController = (TweetDetailsViewController*)navigationController.topViewController;
        tweetDetailsViewController.tweet = tweet;
    }
}



- (void)didTweet:(nonnull Tweet *)tweet {
    [self.tweets insertObject:tweet atIndex:0];
    [self.tweetsTableView reloadData];
}


@end
