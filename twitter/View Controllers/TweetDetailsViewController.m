//
//  TweetDetailsViewController.m
//  twitter
//
//  Created by chadfranklin on 7/2/20.
//  Copyright © 2020 Emerson Malca. All rights reserved.
//

#import "TweetDetailsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "APIManager.h"

@interface TweetDetailsViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *backBarButtonItem;
@property (weak, nonatomic) IBOutlet UILabel *displayNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetLabel;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

@end

@implementation TweetDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // odd. screen name is the @username
    self.displayNameLabel.text = self.tweet.user.name;
    self.usernameLabel.text = [usernameSymbol stringByAppendingString:self.tweet.user.screenName];
    self.dateLabel.text = self.tweet.createdAtString;
    self.tweetLabel.text = self.tweet.text;
    
    if (self.tweet.user.profilePictureURLString){
        NSURL *imageURL = [NSURL URLWithString:self.tweet.user.profilePictureURLString];
        // some error checking
        if(imageURL && [imageURL scheme] && [imageURL host]){
        
        
            NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];

            __weak TweetDetailsViewController *weakDetailsViewController = self;
            [self.profileImageView setImageWithURLRequest:request placeholderImage:nil
                                            success:^(NSURLRequest *imageRequest, NSHTTPURLResponse *imageResponse, UIImage *image) {
                                                // imageResponse will be nil if the image is cached
                                                if (imageResponse) {
                                                    //NSLog(@"Image was NOT cached, fade in image");
                                                    weakDetailsViewController.profileImageView.alpha = 0.0;
                                                    weakDetailsViewController.profileImageView.image = image;
                                                    
                                                    //Animate UIImageView back to alpha 1 over 0.3sec
                                                    [UIView animateWithDuration:0.3 animations:^{
                                                        weakDetailsViewController.profileImageView.alpha = 1.0;
                                                    }];
                                                }
                                                else {
                                                    //NSLog(@"Image was cached so just update the image");
                                                    weakDetailsViewController.profileImageView.image = image;
                                                }
                                            }
                                            failure:^(NSURLRequest *request, NSHTTPURLResponse * response, NSError *error) {
                                                // do something for the failure condition
                                                weakDetailsViewController.profileImageView.image = nil;
                                            }];
        }
    } else {
        self.profileImageView.image = nil;
    }
    
    [self updateViews];
}

- (IBAction)didTapFavorite:(id)sender {
    if(self.tweet.favorited){
        self.tweet.favorited = NO;
        self.tweet.favoriteCount -= 1;
        
        [self updateViews];
        
        [[APIManager shared] unfavorite:self.tweet completion:^(Tweet *tweet, NSError *error) {
            if(error){
                 NSLog(@"Error unfavoriting tweet: %@", error.localizedDescription);
            }
            else{
                NSLog(@"Successfully unfavorited the following Tweet: %@", tweet.text);
            }
        }];
    } else {
        self.tweet.favorited = YES;
        self.tweet.favoriteCount += 1;
        
        [self updateViews];
        
        [[APIManager shared] favorite:self.tweet completion:^(Tweet *tweet, NSError *error) {
            if(error){
                 NSLog(@"Error favoriting tweet: %@", error.localizedDescription);
            }
            else{
                NSLog(@"Successfully favorited the following Tweet: %@", tweet.text);
            }
        }];
    }
}

- (IBAction)didTapRetweet:(id)sender {
    if(self.tweet.retweeted){
        self.tweet.retweeted = NO;
        self.tweet.retweetCount -= 1;
        
        [self updateViews];
        
        [[APIManager shared] unretweet:self.tweet completion:^(Tweet *tweet, NSError *error) {
            if(error){
                 NSLog(@"Error unretweeting tweet: %@", error.localizedDescription);
            }
            else{
                NSLog(@"Successfully unretweeted the following Tweet: %@", tweet.text);
            }
        }];
    } else {
        self.tweet.retweeted = YES;
        self.tweet.retweetCount += 1;
        
        [self updateViews];
        
        [[APIManager shared] retweet:self.tweet completion:^(Tweet *tweet, NSError *error) {
            if(error){
                 NSLog(@"Error retweeting tweet: %@", error.localizedDescription);
            }
            else{
                NSLog(@"Successfully retweeted the following Tweet: %@", tweet.text);
            }
        }];
    }
}

// not DRY
- (void)updateViews{
    if(self.tweet.favorited){
        [self.favoriteButton setTitle:[@(self.tweet.favoriteCount) stringValue] forState:UIControlStateSelected];
    } else {
        [self.favoriteButton setTitle:[@(self.tweet.favoriteCount) stringValue] forState:UIControlStateNormal];
    }
    if(self.tweet.retweeted){
        [self.retweetButton setTitle:[@(self.tweet.retweetCount) stringValue] forState:UIControlStateSelected];
    }else {
        [self.retweetButton setTitle:[@(self.tweet.retweetCount) stringValue] forState:UIControlStateNormal];
    }
    self.favoriteButton.selected = self.tweet.favorited;
    self.retweetButton.selected = self.tweet.retweeted;
}

- (IBAction)onBackPressed:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
