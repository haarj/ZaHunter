//
//  Pizzeria.h
//  ZaHunter
//
//  Created by Justin Haar on 3/25/15.
//  Copyright (c) 2015 Justin Haar. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PizzeriaDelegate <NSObject>

-(void)pizzeria:(NSArray *)pizzeriaArray;

@end

@interface Pizzeria : NSObject

@property id<PizzeriaDelegate>delegate;

@property NSString *name;
@property NSNumber *distance;


@end
