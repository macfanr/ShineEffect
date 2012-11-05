//
//  NSObject+ShineEffect.h
//  ShineEffect
//
//  Created by Xu Jun on 11/5/12.
//  Copyright (c) 2012 Xu Jun. All rights reserved.
//

#import <Foundation/Foundation.h>

//Note: The follow methords JUST apply to NSView, CAlayer and those subclass

typedef enum _ShineEffectOrientation {
    ShineLeftToRight=0,
    ShineRightToLeft,
    ShineUpToDown,
    ShineDownToUp ,
    ShineDefaultOrientation = ShineLeftToRight
} ShineEffectOrientation;

@interface NSObject (ShineEffect)

/// Perform a "shine" animation on the view.
/// This is equivalent to calling shineWithRepeatCount: with a value of 0.
/// @warning When generating the "shine" animation, several images are created and processed. These are only created once for each time shine or related methods are called. Therefore, performance and battery life will suffer when using this method repeatedly, as opposed to calling shineWithRepeatCount: or similar methods.
- (void)shine;

/// Perform a "shine" animation on the view as many times as specified in the repeat count.
/// @param repeatCount The number of times the "shine" animation should repeat itself. If this value is zero, the animation will only occur once. To repeat indefinitely, use `HUGE_VALF`.
- (void)shineWithRepeatCount:(float)repeatCount orientation:(ShineEffectOrientation)orientation;

/// Perform a "shine" animation on the view with the specified duration, and repeat as specified.
/// @param repeatCount The number of times the "shine" animation should repeat itself. If this value is zero, the animation will only occur once.
/// @param duration The duration of the animation.
- (void)shineWithRepeatCount:(float)repeatCount duration:(CFTimeInterval)duration orientation:(ShineEffectOrientation)orientation;

/// Perform a "shine" animation on the view with the specified duration, and repeat as specified.
/// @param repeatCount The number of times the "shine" animation should repeat itself. If this value is zero, the animation will only occur once.
/// @param duration The duration of the animation.
/// @param maskWidth The width of the "shine" mask applied to the view. For best results, specify a value less than the width of the view itself.
- (void)shineWithRepeatCount:(float)repeatCount
                    duration:(CFTimeInterval)duration
                   maskWidth:(CGFloat)maskWidth
                 orientation:(ShineEffectOrientation)orientation;

@end
