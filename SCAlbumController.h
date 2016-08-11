//
//  AlbumCtrl.h
//  Album
//
//  Created by user on 15-2-6.
//  Copyright (c) 2015年 tousan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIImageView+WebCache.h>

typedef void (^AlbumDismissProgress)(NSUInteger page);
typedef void (^AlbumDismissComplete)(void);

@interface SCAlbumController : UIViewController <UIScrollViewDelegate>

@property(nonatomic,strong)NSArray *imageArray;
@property(nonatomic,assign)NSUInteger page;
@property(nonatomic,copy)AlbumDismissProgress dismissProgress;
@property(nonatomic,copy)AlbumDismissComplete dismissComplete;

- (id)initWithImageArray:(NSArray *)imageArray Page:(NSUInteger)page DismissProgress:(AlbumDismissProgress)progress Complete:(AlbumDismissComplete)complete;

@end
