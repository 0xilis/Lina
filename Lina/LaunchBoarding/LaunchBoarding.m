//
//  LaunchBoarding.m
//  Lina
//
//  Created by Snoolie Keffaber on 2025/06/05.
//

#import "LaunchBoarding.h"

@implementation LaunchBoardingPage

+ (instancetype)pageWithIcon:(UIImage *)icon
                       title:(NSString *)title
             descriptionText:(NSString *)descriptionText
                  showButton:(BOOL)showButton {
    LaunchBoardingPage *page = [[LaunchBoardingPage alloc] init];
    page.icon = icon;
    page.title = title;
    page.descriptionText = descriptionText;
    page.showButton = showButton;
    return page;
}

@end

@implementation LaunchBoardingConfiguration

+ (instancetype)configurationWithPages:(NSArray<LaunchBoardingPage *> *)pages {
    LaunchBoardingConfiguration *config = [[LaunchBoardingConfiguration alloc] init];
    config.pages = pages;
    
    config.tintColor = [UIColor systemBlueColor];
    if (@available(iOS 13.0, *)) {
        config.titleColor = [UIColor labelColor];
        config.textColor = [UIColor secondaryLabelColor];
    }
    config.buttonColor = [UIColor systemBlueColor];
    config.buttonTextColor = [UIColor whiteColor];
    config.titleFont = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
    config.textFont = [UIFont systemFontOfSize:17 weight:UIFontWeightRegular];
    config.shouldShowSkipButton = YES;
    
    return config;
}

@end

@interface LaunchBoardingContentViewController : UIViewController
@property (nonatomic, strong) LaunchBoardingPage *page;
@property (nonatomic, strong) LaunchBoardingConfiguration *configuration;
@property (nonatomic, assign) NSInteger pageIndex;
@end

@interface LaunchBoardingController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIButton *skipButton;
@property (nonatomic, strong) UIButton *continueButton;
@property (nonatomic, strong) NSArray<LaunchBoardingContentViewController *> *contentViewControllers;
@end

@implementation LaunchBoardingController {
    BOOL _isAnimatingTransition;
}

- (instancetype)initWithConfiguration:(LaunchBoardingConfiguration *)configuration {
    self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                    navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                  options:nil];
    if (self) {
        _configuration = configuration;
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.dataSource = self;
    self.delegate = self;
    _isAnimatingTransition = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self createContentViewControllers];
    [self setupPageControl];
    [self setupButtons];
    
    if (self.contentViewControllers.count > 0) {
        [self setViewControllers:@[self.contentViewControllers.firstObject]
                      direction:UIPageViewControllerNavigationDirectionForward
                       animated:NO
                     completion:nil];
    }
}

- (void)setupView {
    UIImage *backgroundImage = self.configuration.backgroundImage;
    if (backgroundImage) {
        UIImageView *backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
        backgroundView.contentMode = UIViewContentModeScaleAspectFill;
        backgroundView.frame = self.view.bounds;
        [self.view insertSubview:backgroundView atIndex:0];
    } else {
        if (@available(iOS 13.0, *)) {
            self.view.backgroundColor = [UIColor systemBackgroundColor];
        } else {
            self.view.backgroundColor = [UIColor whiteColor];
        }
    }
}

- (void)createContentViewControllers {
    NSMutableArray *controllers = [NSMutableArray array];
    LaunchBoardingConfiguration *configuration = self.configuration;
    for (NSInteger i = 0; i < configuration.pages.count; i++) {
        LaunchBoardingContentViewController *vc = [[LaunchBoardingContentViewController alloc] init];
        vc.page = configuration.pages[i];
        vc.configuration = configuration;
        vc.pageIndex = i;
        [controllers addObject:vc];
    }
    self.contentViewControllers = controllers.copy;
}

- (void)setupPageControl {
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    self.pageControl = pageControl;
    pageControl.numberOfPages = self.configuration.pages.count;
    pageControl.currentPage = 0;
    pageControl.pageIndicatorTintColor = [UIColor systemGrayColor];
    pageControl.currentPageIndicatorTintColor = self.configuration.tintColor;
    pageControl.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:pageControl];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.pageControl.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.pageControl.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-100]
    ]];
}

- (void)setupButtons {
    UIButton *skipButton;
    if (self.configuration.shouldShowSkipButton) {
        skipButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.skipButton = skipButton;
        [skipButton setTitle:@"Skip" forState:UIControlStateNormal];
        [skipButton setTitleColor:self.configuration.textColor forState:UIControlStateNormal];
        skipButton.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
        [skipButton addTarget:self action:@selector(skipTapped) forControlEvents:UIControlEventTouchUpInside];
        skipButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:skipButton];
    }
    
    UIButton *continueButton;
    continueButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.continueButton = continueButton;
    [continueButton setTitle:@"Continue" forState:UIControlStateNormal];
    [continueButton setTitleColor:self.configuration.buttonTextColor forState:UIControlStateNormal];
    continueButton.backgroundColor = self.configuration.buttonColor;
    continueButton.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
    continueButton.layer.cornerRadius = 14;
    continueButton.layer.masksToBounds = YES;
    [continueButton addTarget:self action:@selector(continueTapped) forControlEvents:UIControlEventTouchUpInside];
    continueButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:continueButton];
    
    if (skipButton) {
        [NSLayoutConstraint activateConstraints:@[
            [skipButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
            [skipButton.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-20],
            [continueButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
            [continueButton.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-20],
            [continueButton.heightAnchor constraintEqualToConstant:50],
            [continueButton.widthAnchor constraintEqualToConstant:150]
        ]];
    } else {
        [NSLayoutConstraint activateConstraints:@[
            [continueButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
            [continueButton.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-20],
            [continueButton.heightAnchor constraintEqualToConstant:50],
            [continueButton.widthAnchor constraintEqualToConstant:150]
        ]];
    }
}

- (void)skipTapped {
    [self.onboardingDelegate onboardingDidSkip];
}

- (void)continueTapped {
    NSInteger currentIndex = ((LaunchBoardingContentViewController *)self.viewControllers.firstObject).pageIndex;
    if (currentIndex == self.contentViewControllers.count - 1) {
        [self.onboardingDelegate onboardingDidFinish];
    } else {
        LaunchBoardingContentViewController *nextVC = self.contentViewControllers[currentIndex + 1];
        [self setViewControllers:@[nextVC]
                      direction:UIPageViewControllerNavigationDirectionForward
                       animated:YES
                     completion:nil];
        self.pageControl.currentPage = currentIndex + 1;
        [self updateButtonForPage:currentIndex + 1];
    }
}

- (void)updateButtonForPage:(NSInteger)pageIndex {
    if (pageIndex == self.contentViewControllers.count - 1) {
        [self.continueButton setTitle:@"Get Started" forState:UIControlStateNormal];
        [self.skipButton setHidden:YES];
    } else {
        [self.continueButton setTitle:@"Continue" forState:UIControlStateNormal];
        [self.skipButton setHidden:NO];
    }
}

#pragma mark - PageViewController DataSource & Delegate

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController {
    NSInteger currentIndex = ((LaunchBoardingContentViewController *)viewController).pageIndex;
    if (currentIndex == 0) return nil;
    return self.contentViewControllers[currentIndex - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController {
    NSInteger currentIndex = ((LaunchBoardingContentViewController *)viewController).pageIndex;
    if (currentIndex == self.contentViewControllers.count - 1) return nil;
    return self.contentViewControllers[currentIndex + 1];
}

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers
       transitionCompleted:(BOOL)completed {
    if (completed && !_isAnimatingTransition) {
        NSInteger currentIndex = ((LaunchBoardingContentViewController *)self.viewControllers.firstObject).pageIndex;
        self.pageControl.currentPage = currentIndex;
        [self updateButtonForPage:currentIndex];
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController
willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    _isAnimatingTransition = YES;
}

@end

@implementation LaunchBoardingContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupContent];
}

- (void)setupContent {
    UIImageView *iconView = [[UIImageView alloc] initWithImage:self.page.icon];
    iconView.tintColor = self.configuration.tintColor;
    iconView.translatesAutoresizingMaskIntoConstraints = NO;
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:iconView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = self.page.title;
    titleLabel.textColor = self.configuration.titleColor;
    titleLabel.font = self.configuration.titleFont;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 0;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:titleLabel];
    
    UILabel *descriptionLabel = [[UILabel alloc] init];
    descriptionLabel.text = self.page.descriptionText;
    descriptionLabel.textColor = self.configuration.textColor;
    descriptionLabel.font = self.configuration.textFont;
    descriptionLabel.textAlignment = NSTextAlignmentCenter;
    descriptionLabel.numberOfLines = 0;
    descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:descriptionLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [iconView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [iconView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:80],
        [iconView.widthAnchor constraintEqualToConstant:80],
        [iconView.heightAnchor constraintEqualToConstant:80],
        
        [titleLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [titleLabel.topAnchor constraintEqualToAnchor:iconView.bottomAnchor constant:40],
        [titleLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:40],
        [titleLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-40],
        
        [descriptionLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [descriptionLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:20],
        [descriptionLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:40],
        [descriptionLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-40]
    ]];
    
    if (self.page.showButton) {
        UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [actionButton setTitle:@"Action" forState:UIControlStateNormal];
        [actionButton setTitleColor:self.configuration.buttonTextColor forState:UIControlStateNormal];
        actionButton.backgroundColor = self.configuration.buttonColor;
        actionButton.layer.cornerRadius = 10;
        actionButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:actionButton];
        
        [NSLayoutConstraint activateConstraints:@[
            [actionButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
            [actionButton.topAnchor constraintEqualToAnchor:descriptionLabel.bottomAnchor constant:30],
            [actionButton.widthAnchor constraintEqualToConstant:200],
            [actionButton.heightAnchor constraintEqualToConstant:44]
        ]];
    }
}

@end
