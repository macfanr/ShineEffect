//
//  NSObject+ShineEffect.m
//  ShineEffect
//
//  Created by Xu Jun on 11/5/12.
//  Copyright (c) 2012 Xu Jun. All rights reserved.
//

#import "NSObject+ShineEffect.h"
#import <QuartzCore/QuartzCore.h>


static CFTimeInterval const kShineEffectDefaultDuration = 2.0;

#define ShineEffectOrientationIsPortrait(orientation)  ((orientation) == ShineUpToDown || (orientation) == ShineDownToUp)
#define ShineEffectOrientationIsLandscape(orientation) ((orientation) == ShineLeftToRight || (orientation) == ShineRightToLeft)

@implementation NSObject (ShineEffect)

#pragma mark - Public Interface

- (void)shine {
    [self shineWithRepeatCount:0 orientation:ShineDefaultOrientation];
}

- (void)shineWithRepeatCount:(float)repeatCount orientation:(ShineEffectOrientation)orientation{
    [self shineWithRepeatCount:repeatCount
                      duration:kShineEffectDefaultDuration
                   orientation:orientation];
}

- (void)shineWithRepeatCount:(float)repeatCount duration:(CFTimeInterval)duration orientation:(ShineEffectOrientation)orientation{
    CGFloat maskwidth = 0;
    if([self isKindOfClass:[CALayer class]]) {
        CALayer *layer = (CALayer*)self;
        maskwidth = ShineEffectOrientationIsLandscape(orientation)?CGRectGetWidth(layer.frame):CGRectGetHeight(layer.frame);
    }
    else if([self isKindOfClass:[NSView class]]) {
        NSView *view = (NSView*)self;
        maskwidth = ShineEffectOrientationIsLandscape(orientation)?NSWidth(view.frame):NSHeight(view.frame);
    }
    else {
        NSAssert(0, @"unsupport class...");
        return;
    }
    [self shineWithRepeatCount:repeatCount
                      duration:duration
                     maskWidth:floorf(maskwidth/3)
                   orientation:orientation];
}

- (void)shineWithRepeatCount:(float)repeatCount
                    duration:(CFTimeInterval)duration
                   maskWidth:(CGFloat)maskWidth
                 orientation:(ShineEffectOrientation)orientation {
    CGFloat width = 0;
    CGFloat height = 0;
    
    if([self isKindOfClass:[CALayer class]]) {
        CALayer *layer = (CALayer*)self;
        width = CGRectGetWidth(layer.frame);
        height = CGRectGetHeight(layer.frame);
    }
    else if([self isKindOfClass:[NSView class]]) {
        NSView *view = (NSView*)self;
        width = NSWidth(view.frame);
        height = NSHeight(view.frame);
        [view setWantsLayer:YES];
    }
    else {
        NSAssert(0, @"unsupport class...");
        return;
    }
    
    
    CGImageRef viewImage = [self imageForView];
    
    CALayer *shineLayer = [CALayer layer];
    CGImageRef shineImage = [self highlightedImageForImage:viewImage];
    shineLayer.contents = (id) shineImage; CGImageRelease(shineImage);
    shineLayer.frame = CGRectMake(0, 0, width, height);
    
    CALayer *mask = [CALayer layer];
    CGColorRef clearColor = CGColorCreateGenericRGB(1, 1, 1, 0);
    mask.backgroundColor = clearColor; CGColorRelease(clearColor);
    CGImageRef maskImage = [self maskImageForImage:viewImage width:maskWidth orientation:orientation];
    mask.contents = (id) maskImage;
    mask.contentsGravity = kCAGravityCenter;
    
    int sign = 1;
    CABasicAnimation *anim = NULL;
    
    switch (orientation) {
        case ShineLeftToRight:
            sign = 1;
            mask.frame = CGRectMake(-width/2, 0, width * 1.25, height);
            anim = [CABasicAnimation animationWithKeyPath:@"position.x"];
            break;
        case ShineRightToLeft:
            sign = -1;
            mask.frame = CGRectMake(width/2, 0, width * 1.25, height);
            anim = [CABasicAnimation animationWithKeyPath:@"position.x"];
            break;
        case ShineUpToDown:
            sign = -1;
            mask.frame = CGRectMake(0, height, width, height* 1.25);
            anim = [CABasicAnimation animationWithKeyPath:@"position.y"];
            break;
        case ShineDownToUp:
            sign = 1;
            mask.frame = CGRectMake(0, -height/2, width, height* 1.25);
            anim = [CABasicAnimation animationWithKeyPath:@"position.y"];
            break;
            
        default:
            break;
    }
        
    anim.byValue = @(width * 2 * sign);
    anim.repeatCount = repeatCount;
    anim.duration = duration;
    anim.autoreverses = YES;
    anim.speed = 1.5;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    CGImageRelease(viewImage);
    CGImageRelease(maskImage);
    
    if([self isKindOfClass:[CALayer class]]) {
        CALayer *layer = (CALayer*)self;
        [layer addSublayer:shineLayer];
    }
    else if([self isKindOfClass:[NSView class]]) {
        NSView *view = (NSView*)self;
        width = NSWidth(view.frame);
        height = NSHeight(view.frame);
        [view.layer addSublayer:shineLayer];
    }
    else {
        NSLog(@"unsupport class...");
        return;
    }
    shineLayer.mask = mask;
    
    [mask addAnimation:anim forKey:@"shine"];
}


#pragma mark - Internal Methods

static CGImageRef CGImageCreateWithNSImage(NSImage *image)
{
    NSSize imageSize = [image size];
    
    CGContextRef bitmapContext = CGBitmapContextCreate(NULL, imageSize.width, imageSize.height, 8, 0, [[NSColorSpace genericRGBColorSpace] CGColorSpace], kCGBitmapByteOrder32Host|kCGImageAlphaPremultipliedFirst);
    
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:bitmapContext flipped:NO]];
    [image drawInRect:NSMakeRect(0, 0, imageSize.width, imageSize.height) fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
    [NSGraphicsContext restoreGraphicsState];
    
    CGImageRef cgImage = CGBitmapContextCreateImage(bitmapContext);
    CGContextRelease(bitmapContext);
    return cgImage;
}

static CGImageRef CGImageSizeConstraint(CGImageRef image, CGSize imageDestSize)
{   
    CGContextRef bitmapContext = CGBitmapContextCreate(NULL,
                                                       imageDestSize.width,
                                                       imageDestSize.height,
                                                       8, 0,
                                                       [[NSColorSpace genericRGBColorSpace] CGColorSpace],
                                                       kCGBitmapByteOrder32Host|kCGImageAlphaPremultipliedFirst);
    
    CGContextDrawImage(bitmapContext, CGRectMake(0, 0, imageDestSize.width, imageDestSize.height), image);
    CGImageRef cgImage = CGBitmapContextCreateImage(bitmapContext);
    CGContextRelease(bitmapContext);
    return cgImage;
}

- (CGImageRef)imageForView {
    if([self isKindOfClass:[CALayer class]]) {
        CALayer *layer = (CALayer*)self;
        return CGImageSizeConstraint((CGImageRef)layer.contents, layer.frame.size);
    }
    else if([self isKindOfClass:[NSView class]]) {
        if([self isKindOfClass:[NSImageView class]]) {
            NSImageView *imageView = (NSImageView*)self;       
            CGImageRef image = CGImageCreateWithNSImage([imageView image]);
            
            CGImageRef constraintImage =  CGImageSizeConstraint(image, imageView.frame.size);
            CGImageRelease(image);
            
            return constraintImage;
        }
    
        NSView *view = (NSView*)self;
        NSRect viewFrame = [view frame];
        viewFrame.origin = NSZeroPoint;
        NSBitmapImageRep *bitmap = [view bitmapImageRepForCachingDisplayInRect:viewFrame];
        [view cacheDisplayInRect:viewFrame toBitmapImageRep:bitmap];
    
        return CGImageSizeConstraint(bitmap.CGImage, view.frame.size);
    }
    

    
    return NULL;
}

- (CGImageRef)highlightedImageForImage:(CGImageRef)image {
    CIImage *coreImage = [CIImage imageWithCGImage:image];
    CIImage *output = [[CIFilter filterWithName:@"CIColorControls" keysAndValues:
                        kCIInputImageKey, coreImage,
                        @"inputSaturation", @0.1f,
                        @"inputBrightness", @0.5f,nil]
                       valueForKey:kCIOutputImageKey];
    
    CGContextRef btmpcontext = CGBitmapContextCreate(NULL/*data - pass NULL to let CG allocate the memory*/,
                                                 CGImageGetWidth(image),
                                                 CGImageGetHeight(image),
                                                 8,
                                                 0,
                                                 [[NSColorSpace genericRGBColorSpace] CGColorSpace],
                                                 kCGBitmapByteOrder32Host|kCGImageAlphaPremultipliedFirst);
    
    CIContext *context = [CIContext contextWithCGContext:btmpcontext options:nil];
    CGImageRef cgImage = [context createCGImage:output fromRect:output.extent];
    CGContextRelease(btmpcontext);
    
    return cgImage;
}

- (CGImageRef)maskImageForImage:(CGImageRef)image width:(CGFloat)maskWidth orientation:(ShineEffectOrientation)orientation {
    CGFloat maskHeight = floorf(CGImageGetHeight(image));
    CGFloat mWidth = floorf(CGImageGetWidth(image));
    
    CGContextRef context = CGBitmapContextCreate(NULL/*data - pass NULL to let CG allocate the memory*/,
                                                 CGImageGetWidth(image),
                                                 CGImageGetHeight(image),
                                                 8,
                                                 0,
                                                 [[NSColorSpace genericRGBColorSpace] CGColorSpace],
                                                 kCGBitmapByteOrder32Host|kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGColorRef clearColor = CGColorCreateGenericRGB(1, 1, 1, 0);
    CGColorRef blackColor = CGColorCreateGenericRGB(0, 0, 0, 1);
    CGFloat locations[] = { 0.0f, 0.5f, 1.0f };
    NSArray *colors = [NSArray arrayWithObjects:(id)clearColor, blackColor, clearColor, nil];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace,
                                                        (CFArrayRef)colors,
                                                        locations);
    if(ShineEffectOrientationIsLandscape(orientation)) {
        CGFloat midY = floorf(maskHeight/2);
        CGPoint startPoint = CGPointMake(0, midY);
        CGPoint endPoint = CGPointMake(floorf(maskWidth/2), midY);
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    }
    else {
        CGFloat midX = floorf(mWidth/2);
        CGPoint startPoint = CGPointMake(midX, 0);
        CGPoint endPoint = CGPointMake(midX, floorf(maskWidth/2));
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    }
    
    CGImageRef maskImage = CGBitmapContextCreateImage(context);
    
    CGColorRelease(clearColor);
    CGColorRelease(blackColor);
    CFRelease(gradient);
    CFRelease(colorSpace);
    CGContextRelease(context);

    return maskImage;
}


@end
