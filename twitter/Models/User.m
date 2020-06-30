//
//  User.m
//  twitter
//
//  Created by chadfranklin on 6/30/20.
//  Copyright © 2020 Emerson Malca. All rights reserved.
//

#import "User.h"

@implementation User

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.name = dictionary[@"name"];
        self.screenName = dictionary[@"screen_name"];
      // Initialize any other properties
        if ([dictionary[@"profile_image_url_https"] isKindOfClass:[NSString class]]){
            NSString *imageURLString = dictionary[@"profile_image_url_https"];
            self.profilePictureURLString = imageURLString;
        }
    }
    return self;
}

@end
