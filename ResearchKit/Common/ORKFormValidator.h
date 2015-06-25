//
//  ORKFormValidator.h
//  ResearchKit
//
//  Created by Ivan Ostafiichuk on 6/22/15.
//  Copyright (c) 2015 researchkit.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ORKFormItem;
@class ORKStepResult;


typedef enum {
    ORKValidationRelationLessThanOrEqual = -1,
    ORKValidationRelationEqual = 0,
    ORKValidationRelationGreaterThanOrEqual = 1,
} ORKValidationRelation;

@interface ORKFormValidator : NSObject

/**
 A user-friendly error message.
 */
@property (nonatomic, strong) NSString *errorMessage;

- (instancetype)initWithFormItem:(ORKFormItem *)formItem relatedBy:(ORKValidationRelation)relation toFormItem:(ORKFormItem *)toFormItem;
- (BOOL)validateResult:(ORKStepResult *)result withError:(NSError **)error;

@end
