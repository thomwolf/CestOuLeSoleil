//
//  NSDictionary+terrasses_package.m
//  INSPIRED FROM WeatherTutorial
//
//  Created by Scott on 26/01/2013.
//  Updated by Joshua Greene 16/12/2013.
//  Updated Thom WOLF 15/04/2014
//
//  Copyright (c) 2013 Scott Sherwood. All rights reserved.
//

#import "NSDictionary+terrasses_package.h"

@implementation NSDictionary (terrasses_package)

- (NSNumber *)first_time
{
    NSArray *ar = self[@"first_time"];
    NSDictionary *dict = ar[0];
    NSArray* foo = [dict[@"time_value"] componentsSeparatedByString: @":"];
    return [foo firstObject];
}

- (NSArray *)tableau
{
    NSArray *ar = self[@"tableau"];
    return ar;
}

- (NSNumber *)max_time
{
    NSArray *ar = self[@"max_time"];
    NSDictionary *dict = ar[0];
    NSNumber* n = @([dict[@"max"] intValue]);
    return n;
}

- (NSDictionary *)terr_info
{
    NSArray *ar = self[@"terr_info"];
    NSDictionary *dict = ar[0];
    return dict;
}

- (NSArray *)terr_time_table
{
    NSArray *ar = self[@"terr_time_table"];
    return ar;
}

- (NSNumber *)num
{
    NSString *cc = self[@"num"];
    NSLog(cc.description);
    NSNumber *n = @([cc intValue]);
    NSLog([NSString stringWithFormat:@"n: %d", n.intValue]);
    return n;
};
- (NSString *)address
{
    return self[@"address"];
};
- (NSNumber *)zip
{
    NSString *cc = self[@"zip"];
    NSNumber *n = @([cc intValue]);
    return n;
};
- (NSString *)dosred_type
{
    return self[@"dosred_type"];
};
- (NSNumber *)longitude
{
    NSString *cc = self[@"longitude"];
    NSNumber *n = @([cc doubleValue]);
    return n;
};
- (NSNumber *)latitude
{
    NSString *cc = self[@"latitude"];
    NSNumber *n = @([cc doubleValue]);
    return n;
};
- (NSString *)placename_ter
{
    return self[@"placename_ter"];
};
- (NSNumber *)nombretot
{
    NSString *cc = self[@"nombretot"];
    NSNumber *n = @([cc intValue]);
    return n;
};
- (NSNumber *)nombresoleil
{
    NSString *cc = self[@"nombresoleil"];
    NSNumber *n = @([cc intValue]);
    return n;
};
- (NSNumber *)time_num
{
    NSString *cc = self[@"time_num"];
    NSNumber *n = @([cc intValue]);
    return n;
};
- (NSString *)timenext
{
    NSString *cc = self[@"timenext"];
    return cc;
};


@end