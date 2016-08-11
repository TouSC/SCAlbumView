//
//  SCAlbum.h
//  Album
//
//  Created by user on 15-2-6.
//  Copyright (c) 2015年 tousan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCAlbumController.h"
#import "TYWaveProgressView.h"
@class SCAlbumView;

@protocol SCAlbumViewDelegate <NSObject>

@optional
- (void)SCAlbumView:(SCAlbumView*)view DidTapImageAtPage:(NSUInteger)page;
- (void)SCAlbumView:(SCAlbumView *)view DecelerateAtPage:(NSUInteger)page;
@end

@interface SCAlbumView : UIScrollView <UIScrollViewDelegate>

@property(nonatomic,assign)id<SCAlbumViewDelegate>myDelegate;

@property(nonatomic,assign)BOOL isPageNeeded;
@property(nonatomic,strong)NSMutableArray *imageView_Arr;
@property(nonatomic,strong)NSArray *image_Arr;
@property(nonatomic,assign)NSInteger page;

- (id)initWithFrame:(CGRect)frame ImageArray:(NSArray*)imageArray;
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
@end
