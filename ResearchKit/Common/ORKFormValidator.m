//
//  ORKFormValidator.m
//  ResearchKit
//
//  Created by Ivan Ostafiichuk on 6/22/15.
//  Copyright (c) 2015 researchkit.org. All rights reserved.
//

#import "ORKFormValidator.h"
#import "ORKFormStep.h"
#import "ORKAnswerFormat.h"
#import "ORKErrors.h"
#import "ORKResult.h"
#import "ORKStepViewController.h"


@interface ORKFormValidator ()

@property (nonatomic, assign, readonly) ORKValidationRelation itemRelation;
@property (nonatomic, weak, readonly) ORKFormItem *formItem;
@property (nonatomic, weak, readonly) ORKFormItem *toFormItem;

@end

@implementation ORKFormValidator

NSError *makeValidationError(NSString *description) {
    return [NSError errorWithDomain:ORKErrorDomain
                               code:ORKErrorValidationError
                           userInfo:@{ NSLocalizedDescriptionKey: description }];
}

- (instancetype)initWithFormItem:(ORKFormItem *)formItem
                       relatedBy:(ORKValidationRelation)relation
                      toFormItem:(ORKFormItem *)toFormItem {
    self = [super init];
    if (self) {
        _formItem = formItem;
        _itemRelation = relation;
        _toFormItem = toFormItem;
    }
    return self;
}

- (BOOL)validateWithError:(NSError **)error {
    *error = [NSError errorWithDomain:ORKErrorDomain code:ORKErrorValidationError userInfo:nil];

    return NO;
}

- (BOOL)validateResult:(ORKStepResult *)stepResult withError:(NSError **)error {
    NSString *formItemIdentifier = self.formItem.identifier;
    NSString *toFormItemIdentifier = self.toFormItem.identifier;

    // TODO: Verify identifiers for nonnull

    ORKQuestionResult *result1 = [stepResult resultForIdentifier:formItemIdentifier];
    ORKQuestionResult *result2 = [stepResult resultForIdentifier:toFormItemIdentifier];

    if (result1.questionType != result2.questionType) {
        *error = makeValidationError(@"Question Type Mismatch!");
        return NO;
    }

    switch (self.itemRelation) {
        case ORKValidationRelationLessThanOrEqual: {
            NSComparisonResult comparisonResult = NSOrderedAscending;
            if ([result1 isKindOfClass:[ORKTextQuestionResult class]]) {
                NSString *resultValue1 = [(ORKTextQuestionResult *)result1 textAnswer];
                NSString *resultValue2 = [(ORKTextQuestionResult *)result2 textAnswer];

                if (resultValue1 && resultValue2) {
                    comparisonResult = [resultValue1 compare:resultValue2];
                }
            }
            if ([result1 isKindOfClass:[ORKNumericQuestionResult class]]) {
                NSNumber *resultValue1 = [(ORKNumericQuestionResult *)result1 numericAnswer];
                NSNumber *resultValue2 = [(ORKNumericQuestionResult *)result2 numericAnswer];

                if (resultValue1 && resultValue2) {
                    comparisonResult = [resultValue1 compare:resultValue2];
                }
            }
            if ([result1 isKindOfClass:[ORKTimeOfDayQuestionResult class]]) {
                NSDateComponents *resultValue1 = [(ORKTimeOfDayQuestionResult *)result1 dateComponentsAnswer];
                NSDateComponents *resultValue2 = [(ORKTimeOfDayQuestionResult *)result2 dateComponentsAnswer];

                if (resultValue1 && resultValue2) {
                    if (! (resultValue1.hour <= resultValue2.hour &&
                            resultValue1.minute <= resultValue2.minute &&
                            resultValue1.second <= resultValue2.second)) {
                        comparisonResult = NSOrderedDescending;
                    }
                }
            }
            if ([result1 isKindOfClass:[ORKDateQuestionResult class]]) {
                NSDate *resultValue1 = [(ORKDateQuestionResult *)result1 dateAnswer];
                NSDate *resultValue2 = [(ORKDateQuestionResult *)result2 dateAnswer];

                if (resultValue1 && resultValue2) {
                    comparisonResult = [resultValue1 compare:resultValue2];
                }
            }
            return comparisonResult != NSOrderedDescending;
        }
    }
    return YES;
}

@end
