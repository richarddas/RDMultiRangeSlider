//
//  RDMultiRangeSlider.m
//  RDMultiRangeSlider
//
//  Created by Richard Das on 18/3/13.
//  Copyright (c) 2013 RNA Productions, Ltd. All rights reserved.
//

#import "RDMultiRangeSlider.h"

#import <QuartzCore/QuartzCore.h>

@interface RDMultiRangeSlider () <UIGestureRecognizerDelegate>

@property (readonly, nonatomic) CGFloat trackWidth;

@property (nonatomic, strong) UIImageView *minThumb;
@property (nonatomic, strong) UIImageView *maxThumb;
@property (nonatomic, strong) UIImageView *track;
@property (nonatomic, strong) UIImageView *trackSelected;

-(void)initRangeSlider;
-(void)minPanGestureEngaged:(UIGestureRecognizer *)gesture;
-(void)maxPanGestureEngaged:(UIGestureRecognizer *)gesture;

-(CGFloat)posForValue:(CGFloat)value;
-(CGFloat)valueForPos:(CGFloat)pos;
-(CGFloat)roundValueToStepValue:(CGFloat)value;

@end


static CGFloat const kRPRangeSliderHandleTapTargetRadius = 22.f;


@implementation RDMultiRangeSlider

@synthesize stepValue, trackCapInsets;


#pragma mark - initialization


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return nil;
    }
    [self initRangeSlider];
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self)
    {
        return nil;
    }
    [self initRangeSlider];
    return self;
}


- (void)initRangeSlider
{
    // set some defaults
    self.minimumValue = 0.0f;
    self.maximumValue = 1.0f;
    self.selectedMinValue = 0.2f;
    self.selectedMaxValue = 0.8f;
    self.stepValue = 0.0;
    self.trackCapInsets = UIEdgeInsetsMake( 0.0f, 9.0f, 0.0f, 9.0f);
    
    self.userInteractionEnabled = YES;

    self.track = [[UIImageView alloc] init];
    [self setImageForTrack:self.trackImage];
    [self addSubview:self.track];
    
    self.trackSelected = [[UIImageView alloc] init];
    [self setImageForTrackSelected:self.trackSelectedImage];
    [self addSubview:self.trackSelected];

    self.minThumb = [[UIImageView alloc] init];
    self.minThumb.contentMode = UIViewContentModeCenter;
    [self setImageForMinimumThumb:self.minThumbImage forState:UIControlStateNormal];
    [self setImageForMinimumThumb:self.minThumbImageHover forState:UIControlStateHighlighted];
    UIPanGestureRecognizer *minPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(minPanGestureEngaged:)];
    minPanGesture.delegate = self;
    [self.minThumb addGestureRecognizer:minPanGesture];
    self.minThumb.userInteractionEnabled = YES;
    [self addSubview:self.minThumb];
    
    
    self.maxThumb = [[UIImageView alloc] init];
    self.maxThumb.contentMode = UIViewContentModeCenter;
    [self setImageForMaximumThumb:self.maxThumbImage forState:UIControlStateNormal];
    [self setImageForMaximumThumb:self.maxThumbImageHover forState:UIControlStateHighlighted];
    UIPanGestureRecognizer *maxPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(maxPanGestureEngaged:)];
    maxPanGesture.delegate = self;
    [self.maxThumb addGestureRecognizer:maxPanGesture];
    self.maxThumb.userInteractionEnabled = YES;
    [self addSubview:self.maxThumb];
}


-(void)layoutSubviews
{
    CGFloat minXPos = [self posForValue:self.selectedMinValue];
    self.minThumb.center = CGPointMake( minXPos , self.track.center.y);
    
    CGFloat maxXPos = [self posForValue:self.selectedMaxValue];
    self.maxThumb.center = CGPointMake( maxXPos , self.track.center.y);
    
	self.trackSelected.frame = CGRectMake(
                                          self.minThumb.center.x,
                                          (CGRectGetHeight( self.frame ) - self.trackSelected.image.size.height)/2.f,
                                          self.maxThumb.center.x - self.minThumb.center.x,
                                          self.trackSelected.image.size.height // match image
                                          );
}


#pragma mark - PUBLIC set image resources (just like UISlider)

- (void)setImageForTrack:(UIImage *)image
{
    [self.track setImage:[image resizableImageWithCapInsets:self.trackCapInsets]];
    
    // 2px padding either side (like UISlider)
    CGFloat trackHPadding = 2.f;

    // stretch the track image horizontally, and center it vertically
    self.track.frame = CGRectMake(
                                  trackHPadding,
                                  (CGRectGetHeight( self.frame ) - image.size.height)/2.f,
                                  CGRectGetWidth( self.frame ) - ( trackHPadding * 2.f),
                                  image.size.height );
}


- (void)setImageForTrackSelected:(UIImage *)image
{
    [self.trackSelected setImage:[image resizableImageWithCapInsets:self.trackCapInsets]];
    self.trackSelected.center = self.track.center;
}


- (void)setImageForMinimumThumb:(UIImage *)image forState:(UIControlState)state
{
    if( state == UIControlStateNormal )
    {
        [self.minThumb setImage:image];
    } else {
        [self.minThumb setHighlightedImage:image ];
    }
    // make sure it's at least 44x44
    self.minThumb.frame = CGRectMake(0, 0, MAX( CGRectGetWidth(self.minThumb.frame), kRPRangeSliderHandleTapTargetRadius*2.f), MAX( CGRectGetHeight(self.minThumb.frame), kRPRangeSliderHandleTapTargetRadius*2.f));
}


- (void)setImageForMaximumThumb:(UIImage *)image forState:(UIControlState)state
{
    if( state == UIControlStateNormal )
    {
        [self.maxThumb setImage:image];
    } else {
        [self.maxThumb setHighlightedImage:image ];
    }
    // make sure it's at least 44x44
    self.maxThumb.frame = CGRectMake(0, 0, MAX( CGRectGetWidth(self.maxThumb.frame), kRPRangeSliderHandleTapTargetRadius*2.f), MAX( CGRectGetHeight(self.maxThumb.frame), kRPRangeSliderHandleTapTargetRadius*2.f));
}


#pragma mark - Image properties


- (UIImage *)trackImage
{
    if(!_trackImage) {
        UIImage *image = [UIImage imageNamed:@"bar-background.png"];
        _trackImage = image;
    }
    return _trackImage;
}

- (UIImage *)trackSelectedImage
{
    if(!_trackSelectedImage) {
        UIImage *image = [UIImage imageNamed:@"bar-highlight.png"];
        _trackSelectedImage = image;
    }
    return _trackSelectedImage;
}

- (UIImage *)minThumbImage
{
    if(!_minThumbImage) {
        UIImage *image = [UIImage imageNamed:@"handle.png"];
        _minThumbImage = image;
    }
    return _minThumbImage;
}

- (UIImage *)minThumbImageHover
{
    if(!_minThumbImageHover) {
        UIImage *image = [UIImage imageNamed:@"handle-hover.png"];
        _minThumbImageHover = image;
    }
    return _minThumbImageHover;
}

- (UIImage *)maxThumbImage
{
    if(!_maxThumbImage) {
        UIImage *image = [UIImage imageNamed:@"handle.png"];
        _maxThumbImage = image;
    }
    return _maxThumbImage;
}

- (UIImage *)maxThumbImageHover
{
    if(!_maxThumbImageHover) {
        UIImage *image = [UIImage imageNamed:@"handle-hover.png"];
        _maxThumbImageHover = image;
    }
    return _maxThumbImageHover;
}


//- (UIImage *)trackBackgroundImage {
//    if(!_trackBackgroundImage) {
//        UIImage *image = [[UIImage imageNamed:@"slider-track-background"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 5, 4, 5)];
//        _trackBackgroundImage = image;
//    }
//    return _trackBackgroundImage;
//}
//
//- (UIImage *)trackFillImage {
//    if(!_trackFillImage) {
//        UIImage *image = [[UIImage imageNamed:@"slider-track-fill"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 5, 4, 5)];
//        _trackFillImage = image;
//    }
//    return _trackFillImage;
//}




#pragma mark - UIGestureRecognizer


- (void)minPanGestureEngaged:(UIGestureRecognizer *)gesture
{
    UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)gesture;
    
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        self.minThumb.highlighted = YES;
    }
    else if (panGesture.state == UIGestureRecognizerStateChanged)
    {
        CGPoint pointInView = [panGesture translationInView:self];
        
        CGFloat range = self.maximumValue - self.minimumValue;
        CGFloat trackPercentageChange = (pointInView.x / self.trackWidth)*100.f;
        self.selectedMinValue += (trackPercentageChange/100.f) * range;

        [panGesture setTranslation:CGPointZero inView:self];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    else if (panGesture.state == UIGestureRecognizerStateCancelled ||
             panGesture.state == UIGestureRecognizerStateEnded ||
             panGesture.state == UIGestureRecognizerStateCancelled) {
        self.minThumb.highlighted = NO;
        self.selectedMinValue = [self roundValueToStepValue:self.selectedMinValue];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}


- (void)maxPanGestureEngaged:(UIGestureRecognizer *)gesture
{    
    UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)gesture;
    
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        self.maxThumb.highlighted = YES;
    }
    if (panGesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint pointInView = [panGesture translationInView:self];
        
        CGFloat range = self.maximumValue - self.minimumValue;
        CGFloat trackPercentageChange = (pointInView.x / self.trackWidth)*100.f;
        self.selectedMaxValue += (trackPercentageChange/100.f) * range;
        
        [panGesture setTranslation:CGPointZero inView:self];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    else if (panGesture.state == UIGestureRecognizerStateCancelled ||
             panGesture.state == UIGestureRecognizerStateEnded ||
             panGesture.state == UIGestureRecognizerStateCancelled) {
        self.maxThumb.highlighted = NO;
        self.selectedMaxValue = [self roundValueToStepValue:self.selectedMinValue];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

// delegate method
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{    
    return YES;
}


#pragma mark - Helpers

// the inset width
- (CGFloat)trackWidth
{
    return (CGRectGetWidth( self.frame ) - (_minThumb.image.size.width/2.f) - (_maxThumb.image.size.width/2.f));
}


-(CGFloat)posForValue:(CGFloat)value
{
    CGFloat range = self.maximumValue - self.minimumValue;
    CGFloat incrementValue = self.trackWidth/range;
    CGFloat ret = (self.minThumb.image.size.width/2.f) + ((value - self.minimumValue) * incrementValue);
    return ret;
}


-(CGFloat)valueForPos:(CGFloat)pos
{
    CGFloat range = self.maximumValue - self.minimumValue;
    CGFloat incrementValue = range/self.trackWidth;
    CGFloat ret = pos * incrementValue;
    return ret;
}


-(CGFloat)roundValueToStepValue:(CGFloat)value
{
    if (self.stepValue == 0.f) {
        return value;
    }
    return self.stepValue * floor((value/self.stepValue)+0.5f);
}


#pragma mark - overrides


// ensure that the frame is at least as tall as the track image
- (void)setFrame:(CGRect)frame
{
    frame.size.height = MAX( self.track.image.size.height, frame.size.height );
    [super setFrame:frame];
}


- (void)setMinimumValue:(CGFloat)minimumValue
{
    _minimumValue = minimumValue;
    _selectedMinValue = _minimumValue;
    [self setNeedsLayout];
}


- (void)setMaximumValue:(CGFloat)maximumValue
{
    _maximumValue = maximumValue;
    self.selectedMaxValue = _maximumValue;
    [self setNeedsLayout];
}


// override setter to limit range and call setNeedsLayout
- (void)setSelectedMinValue:(CGFloat)selectedMinValue
{
    CGFloat pad = [self valueForPos:self.minThumbImage.size.width];
    if ( selectedMinValue <= self.minimumValue ) {
        _selectedMinValue = self.minimumValue;
    } else if (selectedMinValue >= self.minimumValue && selectedMinValue <= self.selectedMaxValue - pad) {
        _selectedMinValue = selectedMinValue;
    }
    [self setNeedsLayout];
}


// override setter to limit range and call setNeedsLayout
- (void)setSelectedMaxValue:(CGFloat)selectedMaxValue
{
    CGFloat pad = [self valueForPos:self.minThumbImage.size.width];
    if ( selectedMaxValue >= self.maximumValue ) {
        _selectedMaxValue = self.maximumValue;
    } else if (selectedMaxValue <= self.maximumValue && selectedMaxValue > self.selectedMinValue + pad) {
        _selectedMaxValue = selectedMaxValue;
    }
    [self setNeedsLayout];
}


// capture hits on subviews (so that handles can go beyond the frame of the slider)
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    for (UIView *subView in self.subviews)
    {
        UIView *hitView = [subView hitTest:[self convertPoint:point toView:subView] withEvent:event];
        if (hitView) {
            return hitView;
        }
    }
    return [super hitTest:point withEvent:event];
}


@end
