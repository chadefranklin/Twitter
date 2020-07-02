//
//  TweetCell.m
//  twitter
//
//  Created by chadfranklin on 6/30/20.
//  Copyright © 2020 Emerson Malca. All rights reserved.
//

#import "TweetCell.h"
#import "APIManager.h"

@implementation TweetCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)didTapFavorite:(id)sender {
    if(self.tweet.favorited){
        self.tweet.favorited = NO;
        self.tweet.favoriteCount -= 1;
        
        [self refreshData];
        
        [[APIManager shared] unfavorite:self.tweet completion:^(Tweet *tweet, NSError *error) {
            if(error){
                 NSLog(@"Error favoriting tweet: %@", error.localizedDescription);
            }
            else{
                NSLog(@"Successfully unfavorited the following Tweet: %@", tweet.text);
            }
        }];
    } else {
        self.tweet.favorited = YES;
        self.tweet.favoriteCount += 1;
        
        [self refreshData];
        
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

- (void)refreshData{
    if(self.tweet.favorited){
        [self.favoriteButton setTitle:[@(self.tweet.favoriteCount) stringValue] forState:UIControlStateSelected];
        //[self.retweetButton setTitle:[@(self.tweet.retweetCount) stringValue] forState:UIControlStateSelected];
    } else {
        [self.favoriteButton setTitle:[@(self.tweet.favoriteCount) stringValue] forState:UIControlStateNormal];
        //[self.retweetButton setTitle:[@(self.tweet.retweetCount) stringValue] forState:UIControlStateNormal];
    }
    self.favoriteButton.selected = self.tweet.favorited;
}

@end
