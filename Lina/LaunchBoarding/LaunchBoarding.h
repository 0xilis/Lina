//
//  LaunchBoarding.h
//  Lina
//
//  Created by Snoolie Keffaber on 2025/06/05.
//

#ifndef LaunchBoarding_h
#define LaunchBoarding_h

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LaunchBoardingPage : NSObject
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *descriptionText;
@property (nonatomic, assign) BOOL showButton;

+ (instancetype)pageWithIcon:(UIImage *)icon
                       title:(NSString *)title
             descriptionText:(NSString *)descriptionText
                  showButton:(BOOL)showButton;
@end

@interface LaunchBoardingConfiguration : NSObject
@property (nonatomic, copy) NSArray<LaunchBoardingPage *> *pages;
@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *buttonColor;
@property (nonatomic, strong) UIColor *buttonTextColor;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, assign) BOOL shouldShowSkipButton;

+ (instancetype)configurationWithPages:(NSArray<LaunchBoardingPage *> *)pages;
@end

@protocol LaunchBoardingDelegate <NSObject>
- (void)onboardingDidFinish;
- (void)onboardingDidSkip;
@end

@interface LaunchBoardingController : UIPageViewController
@property (nonatomic, strong) LaunchBoardingConfiguration *configuration;
@property (nonatomic, weak) id<LaunchBoardingDelegate> onboardingDelegate;

- (instancetype)initWithConfiguration:(LaunchBoardingConfiguration *)configuration;
@end

NS_ASSUME_NONNULL_END

#endif /* LaunchBoarding_h */
