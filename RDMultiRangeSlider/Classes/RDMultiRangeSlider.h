//
//  RDMultiRangeSlider.h
//  RDMultiRangeSlider
//
//  Created by Richard Das on 18/3/13.
//  Copyright (c) 2013 RNA Productions, Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RDMultiRangeSlider : UIControl

@property (strong, nonatomic) UIImage *trackImage;
@property (strong, nonatomic) UIImage *trackSelectedImage;
@property (strong, nonatomic) UIImage *minThumbImage;
@property (strong, nonatomic) UIImage *minThumbImageHover;
@property (strong, nonatomic) UIImage *maxThumbImage;
@property (strong, nonatomic) UIImage *maxThumbImageHover;

@property(assign, nonatomic) CGFloat minimumValue;
@property(assign, nonatomic) CGFloat maximumValue;
@property(assign, nonatomic) CGFloat selectedMinValue;
@property(assign, nonatomic) CGFloat selectedMaxValue;
@property(assign, nonatomic) CGFloat stepValue;
@property(assign, nonatomic) UIEdgeInsets trackCapInsets;

- (void)setImageForTrack:(UIImage *)image;

- (void)setImageForTrackSelected:(UIImage *)image;

- (void)setImageForMinimumThumb:(UIImage *)image forState:(UIControlState)state;

- (void)setImageForMaximumThumb:(UIImage *)image forState:(UIControlState)state;

- (CGPoint)minHandleCenterPosition;

- (CGPoint)maxHandleCenterPosition;

@end
