//
//  ViewController.m
//  ResearchKitSuveyTutorial
//
//  Created by Bryan Weber on 5/8/15.
//  Copyright (c) 2015 Intrepid Pursuits. All rights reserved.
//

#import "ViewController.h"
@import ResearchKit;

@interface ViewController () <ORKTaskViewControllerDelegate>

@property (strong, nonatomic)  ORKTaskViewController *taskViewController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    ORKOrderedTask *task = [self generateOrderedTask];
    ORKTaskViewController *taskViewController = [[ORKTaskViewController alloc] initWithTask:task taskRunUUID:nil];
    taskViewController.delegate = self;
    [self presentViewController:taskViewController animated:YES completion:nil];
}

#pragma survey - Survey Setup

- (ORKOrderedTask *)generateOrderedTask {
    ORKQuestionStep *timeSleptQuestionStep = [self timeSleptStep];
    ORKQuestionStep *sleepQualityQuestionStep = [self sleepQualityStep];
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:@"SleepSurvey" steps:@[timeSleptQuestionStep, sleepQualityQuestionStep]];
    return task;
}

- (ORKQuestionStep *)timeSleptStep {
    ORKTimeOfDayAnswerFormat *format = [[ORKTimeOfDayAnswerFormat alloc] initWithDefaultComponents:nil];
    ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"wakeUpTimeQuestion"
                                                                  title:@"What time did you wake up this morning"
                                                                 answer:format];
    return step;
}

- (ORKQuestionStep *)sleepQualityStep {
    ORKScaleAnswerFormat *format = [ORKScaleAnswerFormat scaleAnswerFormatWithMaxValue:10 minValue:0 step:1 defaultValue:5];
    ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"sleepQualityQuestion"
                                                                  title:@"How would you rate last night's sleep?"
                                                                 answer:format];
    return step;
}

#pragma mark - ORKTaskViewControllerDelegate

- (void)taskViewController:(ORKTaskViewController *)taskViewController
       didFinishWithReason:(ORKTaskViewControllerFinishReason)reason
                     error:(NSError *)error {
    
    switch (reason) {
        case ORKTaskViewControllerFinishReasonCompleted: {
            [self handleResultsForCompletedTaskViewController:taskViewController];
            break;
        }
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ORKTaskViewControllerDelegate Helpers

- (void)handleResultsForCompletedTaskViewController:(ORKTaskViewController *)taskViewController {
    NSDate *dateAnswer;
    NSNumber *scaleAnswer;
    
    NSArray *stepsResults = taskViewController.result.results;
    for (ORKStepResult *stepResult in stepsResults) {
        ORKQuestionResult *questionResult = stepResult.results.firstObject;
        switch (questionResult.questionType) {
            case ORKQuestionTypeTimeOfDay:
                dateAnswer = [self parseDateFromTimeOfDayQuestionResult:questionResult];
                break;
            case ORKQuestionTypeScale:
                scaleAnswer = [self parseValueFromScalerResult:questionResult];
                break;
            default:
                break;
        }
    }
    
    NSString *message = [NSString stringWithFormat:@"You Woke Up at %@ And Rated Your Sleep as a %@", [self timeFromDate:dateAnswer], [scaleAnswer stringValue]];
    UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:@"Result" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    [alterView show];
}

- (NSDate *)parseDateFromTimeOfDayQuestionResult:(ORKQuestionResult *)questionResult {
    if ([questionResult isKindOfClass:[ORKTimeOfDayQuestionResult class]]) {
        NSDateComponents *dateComponents = [(ORKTimeOfDayQuestionResult *)questionResult dateComponentsAnswer];
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDate *date = [gregorianCalendar dateFromComponents:dateComponents];
        return date;
    }
    return nil;
}

- (NSNumber *)parseValueFromScalerResult:(ORKQuestionResult *)questionResult {
    if ([questionResult isKindOfClass:[ORKScaleQuestionResult class]]) {
        return [(ORKScaleQuestionResult *)questionResult scaleAnswer];
    }
    return nil;
}

- (NSString *)timeFromDate:(NSDate *)date {
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"HH:mm";
    
    return [timeFormatter stringFromDate:date];
}

@end
