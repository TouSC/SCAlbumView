//
//  AlbumCtrl.m
//  Album
//
//  Created by user on 15-2-6.
//  Copyright (c) 2015年 tousan. All rights reserved.
//

#import "SCAlbumController.h"
#define SCALBUMCONTROLLER_SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define SCALBUMCONTROLLER_SCREENHEIGHT [UIScreen mainScreen].bounds.size.height

@interface SCAlbumController ()

@end

@implementation SCAlbumController
{
    UIScrollView *wholeScroll;
    CGPoint orPoint1;
    CGPoint orPoint2;
    CGFloat orLength;
    CGPoint newPoint1;
    CGPoint newPoint2;
    CGPoint orCententPoint;
    CGFloat newLength;
    CGSize orSize;
    CGSize newSize;
    CGSize maxSize;
    CGSize minSize;
    CGFloat singleScrollContentX ;
    CGFloat singleScrollContentY ;
    BOOL isTapped;

}

- (id)initWithImageArray:(NSArray *)imageArray Page:(NSUInteger)page DismissProgress:(AlbumDismissProgress)progress Complete:(AlbumDismissComplete)complete;
{
    self = [super init];
    if (self)
    {
        _imageArray = imageArray;
        _dismissProgress = progress;
        _dismissComplete = complete;
        wholeScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCALBUMCONTROLLER_SCREENWIDTH, SCALBUMCONTROLLER_SCREENHEIGHT)];
        wholeScroll.backgroundColor = [UIColor blackColor];
        wholeScroll.pagingEnabled = YES;
        wholeScroll.contentSize = CGSizeMake(SCALBUMCONTROLLER_SCREENWIDTH*_imageArray.count, SCALBUMCONTROLLER_SCREENHEIGHT);
        wholeScroll.contentOffset = CGPointMake(SCALBUMCONTROLLER_SCREENWIDTH*page, 0);
        [self scrollViewDidEndDecelerating:wholeScroll];
        wholeScroll.delegate = self;
        orSize = wholeScroll.frame.size;
        maxSize = CGSizeMake(SCALBUMCONTROLLER_SCREENWIDTH*3.0, SCALBUMCONTROLLER_SCREENHEIGHT*3.0);
        minSize = CGSizeMake(SCALBUMCONTROLLER_SCREENWIDTH*1.0, SCALBUMCONTROLLER_SCREENHEIGHT*1.0);
        [self.view addSubview:wholeScroll];
        for (int i=0; i<_imageArray.count; i++)
        {
            UIScrollView *singleScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(SCALBUMCONTROLLER_SCREENWIDTH*i, 0, SCALBUMCONTROLLER_SCREENWIDTH, SCALBUMCONTROLLER_SCREENHEIGHT)];
            [wholeScroll addSubview:singleScroll];
            singleScroll.tag = 101+i;
            singleScroll.contentSize = CGSizeMake(SCALBUMCONTROLLER_SCREENWIDTH, SCALBUMCONTROLLER_SCREENHEIGHT);
            UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, singleScroll.frame.size.width, singleScroll.frame.size.height)];
            img.contentMode = UIViewContentModeScaleAspectFit;
            if ([_imageArray[i] isKindOfClass:[NSString class]])
            {
                [img sd_setImageWithURL:[NSURL URLWithString:_imageArray[i]] placeholderImage:nil];
            }
            else if ([_imageArray[i] isKindOfClass:[UIImage class]])
            {
                img.image = _imageArray[i];
            }

            [singleScroll addSubview:img];
            
            UIPinchGestureRecognizer *ScaleGestrue = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(ScaleImg:)];
            [singleScroll addGestureRecognizer:ScaleGestrue];
            
            UITapGestureRecognizer *doubleTapScale = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
            doubleTapScale.numberOfTapsRequired = 2;
            [singleScroll addGestureRecognizer:doubleTapScale];
            
            UITapGestureRecognizer *cancelFullGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cancelFullScreen:)];
            [cancelFullGesture requireGestureRecognizerToFail:doubleTapScale];
            [singleScroll addGestureRecognizer:cancelFullGesture];
            
            UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
            [singleScroll addGestureRecognizer:longPressGesture];
        }
    }
    return self;
}

- (BOOL)prefersStatusBarHidden;
{
    return YES;
}

- (void)ScaleImg:(UIPinchGestureRecognizer*)pinch;
{
    if (pinch.numberOfTouches==2)
    {
        CGFloat kScale;
        if (pinch.state==UIGestureRecognizerStateBegan)
        {
            orPoint1 = [pinch locationOfTouch:0 inView:pinch.view];
            orPoint2 = [pinch locationOfTouch:1 inView:pinch.view];
            orCententPoint = CGPointMake(orPoint1.x + (orPoint2.x - orPoint1.x)/2, orPoint1.y + (orPoint2.y - orPoint2.y)/2);
            orLength = [self caculateLengthBetweenP1:orPoint1 P2:orPoint2];
            UIScrollView *singleScroll = (UIScrollView*)[wholeScroll viewWithTag:101+_page];
            singleScrollContentX = singleScroll.contentOffset.x;
            singleScrollContentY = singleScroll.contentOffset.y;
        }
        else if (pinch.state==UIGestureRecognizerStateChanged)
        {
            newPoint1 = [pinch locationOfTouch:0 inView:pinch.view];
            newPoint2 = [pinch locationOfTouch:1 inView:pinch.view];
            newLength = [self caculateLengthBetweenP1:newPoint1 P2:newPoint2];
            kScale = newLength/orLength;
            newSize = CGSizeMake(orSize.width*kScale, orSize.height*kScale);
            if (newSize.width>maxSize.width)
            {
                newSize = maxSize;
            }
            [self changeMethod];
        }
        else
        {
            if (newSize.width<minSize.width)
            {
                newSize = minSize;
                [self changeMethod];
            }
            orSize = newSize;
        }
    }
    else
    {
        if (newSize.width<minSize.width)
        {
            newSize = minSize;
            [self changeMethod];
        }
        orSize = newSize;
    }
    
}
- (CGFloat)caculateLengthBetweenP1:(CGPoint)p1 P2:(CGPoint)p2;
{
    CGFloat x = p1.x-p2.x;
    CGFloat y = p1.y-p2.y;
    return sqrtf(x*x+y*y);
}

- (void)changeMethod;
{
    UIScrollView *singleScroll = (UIScrollView*)[wholeScroll viewWithTag:101+_page];
    singleScroll.contentSize = newSize;
    singleScroll.contentOffset = CGPointMake((newSize.width-[UIScreen mainScreen].bounds.size.width)/2, (newSize.height-[UIScreen mainScreen].bounds.size.height)/2);
    UIImageView *imgView = singleScroll.subviews[0];
    CGRect imgRect = CGRectMake(0, 0, newSize.width, newSize.height);
    imgView.frame = imgRect;
}

- (void)doubleTap:(UITapGestureRecognizer*)tap;
{
    if (isTapped==NO)
    {
        isTapped = YES;
        newSize = maxSize;
        orSize = maxSize;
        [UIView animateWithDuration:0.5 animations:^{
            [self changeMethod];
        }];
    }
    else if (isTapped==YES||orSize.height==maxSize.height)
    {
        isTapped = NO;
        newSize = minSize;
        orSize = minSize;
        [UIView animateWithDuration:0.5 animations:^{
            [self changeMethod];
        }];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
{
    if (scrollView==wholeScroll)
    {
        _page = scrollView.contentOffset.x/SCALBUMCONTROLLER_SCREENWIDTH;
        newSize = minSize;
        orSize = minSize;
        [UIView animateWithDuration:0.5 animations:^{
            [self changeMethod];
        }];
    }
}

- (void)cancelFullScreen:(UITapGestureRecognizer*)cancelFullTap;
{
    _dismissProgress(_page);
    [self dismissViewControllerAnimated:NO completion:^{
        _dismissComplete();
    }];
}

- (void)longPress:(UILongPressGestureRecognizer*)longPress;
{
    ;
}

@end
