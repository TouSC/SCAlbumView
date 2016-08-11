//
//  AlbumCtrl.m
//  Album
//
//  Created by user on 15-2-6.
//  Copyright (c) 2015年 tousan. All rights reserved.
//

#import "AlbumCtrl.h"
#import "SDWebImageManager.h"

#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height

@interface AlbumCtrl ()

@end

@implementation AlbumCtrl
{
    NSInteger myCurPage;
    UIScrollView *wholeScroll;
    NSArray *myImgURLArr;
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

- (id)initWithImgURLArr:(NSArray*)imgURLArr CurPage:(NSInteger)curPage;
{
    self = [super init];
    if (self)
    {
        myImgURLArr = imgURLArr;
        _isDismissed = NO;
        wholeScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
        wholeScroll.backgroundColor = [UIColor blackColor];
        wholeScroll.pagingEnabled = YES;
        wholeScroll.contentSize = CGSizeMake(SCREENWIDTH*myImgURLArr.count, SCREENHEIGHT);
        wholeScroll.contentOffset = CGPointMake(SCREENWIDTH*curPage, 0);
        [self scrollViewDidEndDecelerating:wholeScroll];
        wholeScroll.delegate = self;
        orSize = wholeScroll.frame.size;
        maxSize = CGSizeMake(SCREENWIDTH*3.0, SCREENHEIGHT*3.0);
        minSize = CGSizeMake(SCREENWIDTH*1.0, SCREENHEIGHT*1.0);
        [self.view addSubview:wholeScroll];
        for (int i=0; i<myImgURLArr.count; i++)
        {
            UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            indicator.center = CGPointMake(SCREENWIDTH/2+SCREENWIDTH*i, SCREENHEIGHT/2);
            [wholeScroll addSubview:indicator];
            [indicator startAnimating];
            UIScrollView *singleScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(SCREENWIDTH*i, 0, SCREENWIDTH, SCREENHEIGHT)];
            [wholeScroll addSubview:singleScroll];
            singleScroll.tag = 101+i;
            singleScroll.contentSize = CGSizeMake(SCREENWIDTH, SCREENHEIGHT);
            UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, singleScroll.frame.size.width, singleScroll.frame.size.height)];
            img.contentMode = UIViewContentModeScaleAspectFit;
            if ([myImgURLArr[i] isKindOfClass:[NSString class]])
            {
                [[SDWebImageManager sharedManager]downloadImageWithURL:[NSURL URLWithString:myImgURLArr[i]] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                    ;
                } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                    img.backgroundColor = [UIColor blackColor];
                    if (error)
                    {
                        img.image = [UIImage imageNamed:@"loading_fail_bg_cn_2_1"];
                    }
                    else
                    {
                        img.image = image;
                    }
                    
                }];
            }
            else if ([myImgURLArr[i] isKindOfClass:[UIImage class]])
            {
                img.image = myImgURLArr[i];
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
#pragma mark-放大缩小图片
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
            UIScrollView *singleScroll = (UIScrollView*)[wholeScroll viewWithTag:101+myCurPage];
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
            NSLog(@"lower");
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
    UIScrollView *singleScroll = (UIScrollView*)[wholeScroll viewWithTag:101+myCurPage];
    singleScroll.contentSize = newSize;
    singleScroll.contentOffset = CGPointMake((newSize.width-[UIScreen mainScreen].bounds.size.width)/2, (newSize.height-[UIScreen mainScreen].bounds.size.height)/2);
    NSLog(@"%f and %f",singleScrollContentX,singleScrollContentY);
    UIImageView *imgView = singleScroll.subviews[0];
    CGRect imgRect = CGRectMake(0, 0, newSize.width, newSize.height);
    imgView.frame = imgRect;
}
#pragma mark-双击改变大小方法
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
        myCurPage = scrollView.contentOffset.x/SCREENWIDTH;
        newSize = minSize;
        orSize = minSize;
        [self changeMethod];
        [_myDelegate getCurPage:myCurPage];
    }
}

- (void)cancelFullScreen:(UITapGestureRecognizer*)cancelFullTap;
{
    _isDismissed = YES;
    [_myDelegate getCurPage:myCurPage];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)longPress:(UILongPressGestureRecognizer*)longPress;
{
    if (_isDisSave == NO) {
        if (longPress.state==UIGestureRecognizerStateBegan)
        {
            UIActionSheet *save_ActionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存图片", nil];
            [save_ActionSheet showInView:self.view];
        }
    }
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if (buttonIndex==0)
    {
        if ([myImgURLArr[myCurPage] isKindOfClass:[NSString class]])
        {
            [[SDWebImageManager sharedManager]downloadImageWithURL:[NSURL URLWithString:myImgURLArr[myCurPage]] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                ;
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
                UIAlertView *save_Alert = [[UIAlertView alloc]initWithTitle:@"已保存至相册" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
                [save_Alert show];
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [NSThread sleepForTimeInterval:1];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [save_Alert dismissWithClickedButtonIndex:0 animated:YES];
                    });
                });
            }];
        }
        else if ([myImgURLArr[myCurPage] isKindOfClass:[UIImage class]])
        {
            UIImageWriteToSavedPhotosAlbum((UIImage *)myImgURLArr[myCurPage], nil, nil, nil);
            UIAlertView *save_Alert = [[UIAlertView alloc]initWithTitle:@"已保存至相册" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
            [save_Alert show];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [NSThread sleepForTimeInterval:1];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [save_Alert dismissWithClickedButtonIndex:0 animated:YES];
                });
            });
        }
    }
}

@end
