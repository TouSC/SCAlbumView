//
//  SCAlbum.m
//  Album
//
//  Created by user on 15-2-6.
//  Copyright (c) 20f15年 tousan. All rights reserved.
//

#import "SCAlbum.h"
#import "SDWebImageManager.h"
#import <UIImageView+WebCache.h>
#import "RootViewController.h"

@implementation SCAlbum
{
    CGFloat width;
    CGFloat height;
    NSInteger myCurPage;
}

- (id)initWithFrame:(CGRect)frame ImgURLArr:(NSArray*)imgURLArr;
{
    self = [super initWithFrame:frame];
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    _myImgURLArr = imgURLArr;
    [self initData];
    [self setContent];
    return self;
}

- (void)initData;
{
    self.backgroundColor = [UIColor whiteColor];
    width = self.frame.size.width;
    height = self.frame.size.height;
    self.contentSize = CGSizeMake(width*(_myImgURLArr.count? _myImgURLArr.count:1), height);
    self.pagingEnabled = YES;
    self.delegate = self;
}

- (void)setContent;
{
    for (int i=0; i<(_myImgURLArr.count? _myImgURLArr.count:1); i++)
    {

        UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(i*width, 0, width, height)];
        img.tag = 101+i;
        img.userInteractionEnabled = (_myImgURLArr.count? YES:NO);
        img.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:img];
        UITapGestureRecognizer *fullScreenTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ClickFullScreen:)];
        [img addGestureRecognizer:fullScreenTap];
        [self scrollViewDidEndDecelerating:self];
    }
    _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, height-15, screenWidth, 20)];
    _pageControl.numberOfPages = (_myImgURLArr.count? _myImgURLArr.count:1);
    _pageControl.backgroundColor = [UIColor clearColor];
    _pageControl.currentPage = 0;
    _pageControl.hidesForSinglePage = YES;
    _pageControl.userInteractionEnabled = NO;
}
- (void)setIsPageNeeded:(BOOL)isPageNeeded;
{
    if (isPageNeeded)
    {
        [self.superview addSubview:_pageControl];
        [self.superview bringSubviewToFront:_pageControl];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
{
    myCurPage = scrollView.contentOffset.x/width;
    
    UIImageView *imgView = (UIImageView*)[self viewWithTag:101+myCurPage];
    imgView.clipsToBounds = YES;
    if (_myImgURLArr)
    {
        if (myCurPage > _myImgURLArr.count -1) {
            myCurPage = 0;
        }
        NSString* urlStr = _myImgURLArr.count? _myImgURLArr[myCurPage]:@"";
        if (urlStr&&![urlStr isEqualToString:@""])
        {
            [imgView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"loading_bg_cn_3_1"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (error)
                {
                    imgView.image = [UIImage imageNamed:@"loading_fail_bg_cn_3_1"];
                }
            }];
        }
        else
        {
            imgView.image = [UIImage imageNamed:@"loading_none_bg_cn_2_1"];
        }
    }

    if (_myDelegate&&[_myDelegate respondsToSelector:@selector(pageChanged:)])
    {
        [_myDelegate pageChanged:myCurPage];
    }
    _pageControl.currentPage = myCurPage;
}

- (void)ClickFullScreen:(UITapGestureRecognizer*)tap;
{
    if (_myDelegate&&[_myDelegate respondsToSelector:@selector(clickPage:)])
    {
        [_myDelegate clickPage:myCurPage];
    }
    else
    {
        UIViewController *result = nil;
        UIWindow * window = [[UIApplication sharedApplication] keyWindow];
        if (window.windowLevel != UIWindowLevelNormal)
        {
            NSArray *windows = [[UIApplication sharedApplication] windows];
            for(UIWindow * tmpWin in windows)
            {
                if (tmpWin.windowLevel == UIWindowLevelNormal)
                {
                    window = tmpWin;
                    break;
                }
            }
        }
        
        UIView *frontView = [[window subviews] objectAtIndex:0];
        id nextResponder = [frontView nextResponder];
        
        if ([nextResponder isKindOfClass:[UIViewController class]])
        {
            result = nextResponder;
            AlbumCtrl *albumCtrl = [[AlbumCtrl alloc]initWithImgURLArr:_myImgURLArr CurPage:myCurPage];
            albumCtrl.myDelegate = self;
            [result presentViewController:albumCtrl animated:NO completion:nil];
        }
        else
        {
            result = nil;
        }
    }
}

- (void)getCurPage:(NSInteger)curPage;
{
    self.contentOffset = CGPointMake(curPage*self.frame.size.width, 0);
    myCurPage = curPage;
    _pageControl.currentPage = curPage;
    [self scrollViewDidEndDecelerating:self];
}

@end
