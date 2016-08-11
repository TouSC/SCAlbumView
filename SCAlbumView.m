//
//  SCAlbum.m
//  Album
//
//  Created by user on 15-2-6.
//  Copyright (c) 2015年 tousan. All rights reserved.
//

#import "SCAlbumView.h"
#import "SDWebImageManager.h"
#import <UIImageView+WebCache.h>

@implementation SCAlbumView
{
    CGFloat width;
    CGFloat height;
}

- (id)initWithFrame:(CGRect)frame ImageArray:(NSArray*)imageArray;
{
    self = [super initWithFrame:frame];
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    _image_Arr = imageArray;
    _imageView_Arr = [NSMutableArray array];
    [self initData];
    [self setContent];
    return self;
}

- (void)initData;
{
    self.backgroundColor = [UIColor whiteColor];
    width = self.frame.size.width;
    height = self.frame.size.height;
    self.contentSize = CGSizeMake(width*(3), height);
    self.pagingEnabled = YES;
    self.delegate = self;
}

- (void)setContent;
{
    for (int i=0; i<3; i++)
    {
        UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(i*width, 0, width, height)];
        img.backgroundColor = [UIColor whiteColor];
        img.tag = 101+i;
        img.userInteractionEnabled = (_image_Arr.count? YES:NO);
        img.contentMode = UIViewContentModeScaleAspectFill;
        img.clipsToBounds = YES;
        [self addSubview:img];
        UITapGestureRecognizer *fullScreenTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImage:)];
        [img addGestureRecognizer:fullScreenTap];
        [_imageView_Arr addObject:img];
    }
    self.contentOffset = CGPointMake(width, 0);
    [self scrollViewDidEndDecelerating:self];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
{
    if (!_image_Arr.count)
    {
        return;
    }
    _page += scrollView.contentOffset.x>width?1:scrollView.contentOffset.x<width?-1:0;
    if (_page<0)
    {
        _page = _image_Arr.count-1;
    }
    else if (_page>=_image_Arr.count)
    {
        _page = 0;
    }
    for (int i=0; i<3; i++)
    {
        UIImageView *imgView = (UIImageView*)[self viewWithTag:101+i];
        imgView.image = nil;
        NSInteger index = _page-1+i;
        if (index<0)
        {
            index = _image_Arr.count-1;
        }
        else if (index>=_image_Arr.count)
        {
            index = 0;
        }
        id item = _image_Arr[index];
        if ([item isKindOfClass:[NSString class]])
        {
            if ([(NSString*)item length])
            {
                __block TYWaveProgressView *waveProgressView = [[TYWaveProgressView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
                waveProgressView.center = CGPointMake(width+width/2,height/2);
                waveProgressView.waveViewMargin = UIEdgeInsetsMake(15, 15, 20, 20);
                waveProgressView.numberLabel.text = @"";
                waveProgressView.numberLabel.font = [UIFont boldSystemFontOfSize:10];
                waveProgressView.numberLabel.textColor = [UIColor whiteColor];
                waveProgressView.tag = 201+_page;
                [self addSubview:waveProgressView];
                __block CGFloat or_Progress = 0.0f;
                [[SDWebImageManager sharedManager]downloadImageWithURL:[NSURL URLWithString:item] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                    CGFloat progress = (float)receivedSize/(float)expectedSize;
                    if ((progress-or_Progress>0.3)||or_Progress==0)
                    {
                        waveProgressView.percent = progress;
                        [waveProgressView stopWave];
                        [waveProgressView startWave];
                        or_Progress = progress;
                    }
                } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                    if (waveProgressView.tag-201==_page)
                    {
                        imgView.image = image;
                        [self bringSubviewToFront:imgView];
                    }
                    [waveProgressView removeFromSuperview];
                }];
            }
        }
        else if ([item isKindOfClass:[UIImage class]])
        {
            imgView.image = item;
        }
    }
    scrollView.contentOffset = CGPointMake(width, 0);

    if (_myDelegate&&[_myDelegate respondsToSelector:@selector(SCAlbumView:DecelerateAtPage:)])
    {
        [_myDelegate SCAlbumView:self DecelerateAtPage:_page];
    }
}

- (void)tapImage:(UITapGestureRecognizer*)tap;
{
    if (_myDelegate&&[_myDelegate respondsToSelector:@selector(SCAlbumView:DidTapImageAtPage:)])
    {
        [_myDelegate SCAlbumView:self DidTapImageAtPage:_page];
    }
}

@end
