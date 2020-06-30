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

@interface TimelineViewController () <ComposeViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tweetsTableView;
@property (nonatomic, strong) NSMutableArray *tweets;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation TimelineViewController

const NSString *usernameSymbol = @"@";

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
    //UITableViewCell *cell = [[UITableViewCell alloc] init];
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    Tweet *tweet = self.tweets[indexPath.row];
    
    [self constructTweetCell:cell :tweet];
        
    cell.tweet = tweet;
    
    return cell;
}

- (void)constructTweetCell:(TweetCell *)cell: (Tweet *)tweet{
    // odd. screen name is the @username
    cell.displayNameLabel.text = tweet.user.name;
    //cell.usernameLabel.text = tweet.user.screenName;
    cell.usernameLabel.text = [usernameSymbol stringByAppendingString:tweet.user.screenName];
    cell.dateLabel.text = tweet.createdAtString;
    cell.tweetLabel.text = tweet.text;
    
    //cell.favoriteButton.titleLabel.text = [@(tweet.favoriteCount) stringValue];
    //cell.retweetButton.titleLabel.text = [@(tweet.retweetCount) stringValue];
    
    [cell.favoriteButton setTitle:[@(tweet.favoriteCount) stringValue] forState:UIControlStateNormal];
    [cell.retweetButton setTitle:[@(tweet.retweetCount) stringValue] forState:UIControlStateNormal];
    
    //if ([tweet.user.profilePictureURL isKindOfClass:[NSString class]]){
    if (tweet.user.profilePictureURLString){
        //NSString *posterURLString = tweet.user.profilePictureURL;
        //[cell.posterView setImageWithURL:[CEFMovieFetcher.sharedObject makeBackdropURL:posterURLString]];
        
        NSURL *imageURL = [NSURL URLWithString:tweet.user.profilePictureURLString];
        // some error checking
        if(imageURL && [imageURL scheme] && [imageURL host]){
        
        
            //NSURLRequest *request = [CEFMovieFetcher.sharedObject makeSmallImageURLRequest:posterURLString];
            NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];

            __weak TweetCell *weakCell = cell; // is this correct usage?
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
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
