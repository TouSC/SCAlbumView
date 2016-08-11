//
//  AlbumCtrl.h
//  Album
//
//  Created by user on 15-2-6.
//  Copyright (c) 2015年 tousan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Header.h"

@protocol AlbumCtrlDelegate <NSObject>

- (void)getCurPage:(NSInteger)curPage;

@end

@interface AlbumCtrl : UIViewController <UIScrollViewDelegate,UIActionSheetDelegate>

@property(nonatomic,strong)id<AlbumCtrlDelegate>myDelegate;
@property(nonatomic,assign)BOOL isDismissed;
@property(nonatomic,assign)BOOL isDisSave;
- (id)initWithImgURLArr:(NSArray*)imgURLArr CurPage:(NSInteger)curPage;

@end
