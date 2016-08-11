//
//  SCAlbum.h
//  Album
//
//  Created by user on 15-2-6.
//  Copyright (c) 2015年 tousan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlbumCtrl.h"

@protocol SCAlbumDelegate <NSObject>

@optional
- (void)clickPage:(NSInteger)page;
- (void)pageChanged:(NSInteger)page;

@end

@interface SCAlbum : UIScrollView <UIScrollViewDelegate,AlbumCtrlDelegate>

@property(nonatomic,weak)id<SCAlbumDelegate>myDelegate;

@property(nonatomic,assign)BOOL isPageNeeded;
@property(nonatomic,strong)UIPageControl * pageControl;
@property(nonatomic,strong)NSArray *myImgURLArr;

- (id)initWithFrame:(CGRect)frame ImgURLArr:(NSArray*)imgURLArr;
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
@end
