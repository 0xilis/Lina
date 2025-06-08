//
//  LaunchBoarding.m
//  Lina
//
//  Created by Snoolie Keffaber on 2025/06/05.
//

#import "LaunchBoarding.h"
#import <CoreText/CoreText.h>

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

@interface LaunchBoardingBaseContentViewController : UIViewController
@property (nonatomic, assign) NSInteger pageIndex;
@end

@implementation LaunchBoardingBaseContentViewController
@end

@interface LaunchBoardingWelcomeViewController : LaunchBoardingBaseContentViewController
@property (nonatomic, strong) LaunchBoardingConfiguration *configuration;
@property (nonatomic, strong) CAShapeLayer *welcomeLayer;
@end

@interface LaunchBoardingController ()
- (void)advanceFromWelcomePage;
@end

@implementation LaunchBoardingWelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    UIBezierPath *welcomePath = [self cursivePathForString:@"Welcome"];
    CGRect pathBounds = CGPathGetBoundingBox(welcomePath.CGPath);
    
    self.welcomeLayer = [CAShapeLayer layer];
    self.welcomeLayer.bounds = pathBounds;
    self.welcomeLayer.position = self.view.center;
    self.welcomeLayer.geometryFlipped = YES;
    self.welcomeLayer.fillColor = [UIColor clearColor].CGColor;
    if (@available(iOS 13.0, *)) {
        self.welcomeLayer.strokeColor = [UIColor labelColor].CGColor;
    } else {
        self.welcomeLayer.strokeColor = [UIColor blackColor].CGColor;
    }
    self.welcomeLayer.lineWidth = 4.0;
    self.welcomeLayer.lineCap = kCALineCapRound;
    self.welcomeLayer.lineJoin = kCALineJoinRound;
    self.welcomeLayer.path = welcomePath.CGPath;
    self.welcomeLayer.strokeEnd = 0.0;
    
    [self.view.layer addSublayer:self.welcomeLayer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupWelcomeAnimation];
}

- (void)setupWelcomeAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration = 3.0;
    animation.fromValue = @0.0;
    animation.toValue = @1.0;
    animation.repeatCount = HUGE_VALF;
    animation.autoreverses = YES;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [self.welcomeLayer addAnimation:animation forKey:@"strokeEndAnimation"];
}

- (UIBezierPath *)cursivePathForString:(NSString *)string {
    CGMutablePathRef letters = CGPathCreateMutable();
    
    CTFontRef font = CTFontCreateWithName(CFSTR("Snell Roundhand"), 72, NULL);
    NSDictionary *attrs = @{(id)kCTFontAttributeName: (__bridge id)font};
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:string attributes:attrs];
    CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)attrString);
    
    CFArrayRef runArray = CTLineGetGlyphRuns(line);
    for (CFIndex runIndex = 0; runIndex < CFArrayGetCount(runArray); runIndex++) {
        CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
        CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
        
        for (CFIndex runGlyphIndex = 0; runGlyphIndex < CTRunGetGlyphCount(run); runGlyphIndex++) {
            CFRange thisGlyphRange = CFRangeMake(runGlyphIndex, 1);
            CGGlyph glyph;
            CGPoint position;
            CTRunGetGlyphs(run, thisGlyphRange, &glyph);
            CTRunGetPositions(run, thisGlyphRange, &position);
            
            CGPathRef letter = CTFontCreatePathForGlyph(runFont, glyph, NULL);
            if (letter) {
                CGAffineTransform t = CGAffineTransformMakeTranslation(position.x, position.y);
                CGPathAddPath(letters, &t, letter);
                CGPathRelease(letter);
            }
        }
    }
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointZero];
    [path appendPath:[UIBezierPath bezierPathWithCGPath:letters]];
    
    CFRelease(line);
    CFRelease(font);
    CGPathRelease(letters);
    
    return path;
}

- (void)advanceToNextPage {
    if ([self.parentViewController isKindOfClass:[LaunchBoardingController class]]) {
        LaunchBoardingController *parent = (LaunchBoardingController *)self.parentViewController;
        [parent advanceFromWelcomePage];
    }
}

@end

@interface LaunchBoardingContentViewController : LaunchBoardingBaseContentViewController
@property (nonatomic, strong) LaunchBoardingPage *page;
@property (nonatomic, strong) LaunchBoardingConfiguration *configuration;
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

@implementation LaunchBoardingConfiguration

+ (instancetype)configurationWithPages:(NSArray<LaunchBoardingPage *> *)pages {
    LaunchBoardingConfiguration *config = [[LaunchBoardingConfiguration alloc] init];
    config.pages = pages;
    
    config.tintColor = [UIColor systemBlueColor];
    if (@available(iOS 13.0, *)) {
        config.titleColor = [UIColor labelColor];
        config.textColor = [UIColor secondaryLabelColor];
    } else {
        config.titleColor = [UIColor blackColor];
    }
    
    config.buttonColor = [UIColor systemBlueColor];
    config.buttonTextColor = [UIColor whiteColor];
    config.titleFont = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
    config.textFont = [UIFont systemFontOfSize:17 weight:UIFontWeightRegular];
    config.shouldShowSkipButton = YES;
    config.showWelcomePage = NO; /* off by default */
    config.autoAdvanceWelcomePage = NO;
    
    return config;
}

@end

@interface LaunchBoardingController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIButton *skipButton;
@property (nonatomic, strong) UIButton *continueButton;
@property (nonatomic, strong) NSArray<LaunchBoardingBaseContentViewController *> *contentViewControllers;
@end

@implementation LaunchBoardingController

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
                     completion:^(BOOL finished) {
            self.pageControl.currentPage = 0;
            [self updateButtonForPage:0];
        }];
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
    
    if (configuration.showWelcomePage) {
        LaunchBoardingWelcomeViewController *welcomeVC = [[LaunchBoardingWelcomeViewController alloc] init];
        welcomeVC.configuration = configuration;
        welcomeVC.view.frame = self.view.bounds;
        [controllers addObject:welcomeVC];
    }
    
    for (NSInteger i = 0; i < configuration.pages.count; i++) {
        LaunchBoardingContentViewController *vc = [[LaunchBoardingContentViewController alloc] init];
        vc.page = configuration.pages[i];
        vc.configuration = configuration;
        [controllers addObject:vc];
    }
    
    for (NSInteger i = 0; i < controllers.count; i++) {
        LaunchBoardingBaseContentViewController *vc = (LaunchBoardingBaseContentViewController *)controllers[i];
        vc.pageIndex = i;
    }
    
    self.contentViewControllers = controllers.copy;
}

- (void)setupPageControl {
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    self.pageControl = pageControl;
    pageControl.numberOfPages = self.contentViewControllers.count;
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
    if (self.configuration.shouldShowSkipButton) {
        self.skipButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.skipButton setTitle:@"Skip" forState:UIControlStateNormal];
        [self.skipButton setTitleColor:self.configuration.textColor forState:UIControlStateNormal];
        self.skipButton.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
        [self.skipButton addTarget:self action:@selector(skipTapped) forControlEvents:UIControlEventTouchUpInside];
        self.skipButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:self.skipButton];
    }
    
    self.continueButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.continueButton setTitle:@"Continue" forState:UIControlStateNormal];
    [self.continueButton setTitleColor:self.configuration.buttonTextColor forState:UIControlStateNormal];
    self.continueButton.backgroundColor = self.configuration.buttonColor;
    self.continueButton.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
    self.continueButton.layer.cornerRadius = 14;
    self.continueButton.layer.masksToBounds = YES;
    [self.continueButton addTarget:self action:@selector(continueTapped) forControlEvents:UIControlEventTouchUpInside];
    self.continueButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.continueButton];
    
    if (self.skipButton) {
        [NSLayoutConstraint activateConstraints:@[
            [self.skipButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
            [self.skipButton.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-20],
            [self.continueButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
            [self.continueButton.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-20],
            [self.continueButton.heightAnchor constraintEqualToConstant:50],
            [self.continueButton.widthAnchor constraintEqualToConstant:150]
        ]];
    } else {
        [NSLayoutConstraint activateConstraints:@[
            [self.continueButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
            [self.continueButton.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-20],
            [self.continueButton.heightAnchor constraintEqualToConstant:50],
            [self.continueButton.widthAnchor constraintEqualToConstant:150]
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
        LaunchBoardingBaseContentViewController *nextVC = self.contentViewControllers[currentIndex + 1];
        [self setViewControllers:@[nextVC]
                      direction:UIPageViewControllerNavigationDirectionForward
                       animated:YES
                     completion:nil];
        self.pageControl.currentPage = currentIndex + 1;
        [self updateButtonForPage:currentIndex + 1];
    }
}

- (void)advanceFromWelcomePage {
    if (self.contentViewControllers.count > 1) {
        [self setViewControllers:@[self.contentViewControllers[1]]
                      direction:UIPageViewControllerNavigationDirectionForward
                       animated:YES
                     completion:nil];
        self.pageControl.currentPage = 1;
        [self updateButtonForPage:1];
    }
}

- (void)updateButtonForPage:(NSInteger)pageIndex {
    self.continueButton.hidden = NO;
    self.pageControl.hidden = NO;
    
    if (pageIndex == self.contentViewControllers.count - 1) {
        [self.continueButton setTitle:@"Get Started" forState:UIControlStateNormal];
        self.skipButton.hidden = YES;
    } else {
        [self.continueButton setTitle:@"Continue" forState:UIControlStateNormal];
        self.skipButton.hidden = !self.configuration.shouldShowSkipButton;
    }
}

#pragma mark - PageViewController DataSource & Delegate

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController {
    NSInteger currentIndex = ((LaunchBoardingBaseContentViewController *)viewController).pageIndex;
    if (currentIndex == 0) return nil;
    return self.contentViewControllers[currentIndex - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController {
    NSInteger currentIndex = ((LaunchBoardingBaseContentViewController *)viewController).pageIndex;
    if (currentIndex == self.contentViewControllers.count - 1) return nil;
    return self.contentViewControllers[currentIndex + 1];
}

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers
       transitionCompleted:(BOOL)completed {
    if (completed) {
        NSInteger currentIndex = ((LaunchBoardingBaseContentViewController *)self.viewControllers.firstObject).pageIndex;
        self.pageControl.currentPage = currentIndex;
        [self updateButtonForPage:currentIndex];
    }
}

@end
