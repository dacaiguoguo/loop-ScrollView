//
//  YKLoopScrollView.h
//  testScrollView2
//
//  Created by sihai sihai on 11-11-28.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YKSmallLoopScrollViewDelegate;

/*
 横向循环滚动的图片 paging scrollview ,需要在delegate 中 实现，，主要作用是嵌入在scrollview 中比YKSlideView 更自然
 usage:
 implement delegate ,not add view to self
 @remark:
    构建一个超大contentsize 的scrollview,把需要的子view 铺在可视范围周边
 */
@interface YKSmallLoopScrollView : UIView<UIScrollViewDelegate>{
@private
    UIScrollView* contentScrollView;
    NSMutableDictionary* addSubViewDictionary;        //本类自动添加的子试图,key为pageindex (NSNumber) value 为view
    int numOfPage;                          //总共有多少页
    CGSize sizeOfPage;                  
    int m_absolutePageIndex;        //当前第几页
    float oldOffsetX;
    NSDate *startDate;
    NSDate *endDate;
    BOOL skipSetContentOffset;  //跳过处理setcontentOffset 事件
}
@property(nonatomic,assign) IBOutlet id<YKSmallLoopScrollViewDelegate> delegate;

/*
 重新加载
 */
-(void) reloadData;

-(void) nextPage:(BOOL) anim;
/*
 设置pageindex [0-delegate.numOfPageForScrollView];
 */
-(void)setPageIndex:(int)index animated:(BOOL) anim;
-(int) pageIndex;

@end




@protocol YKSmallLoopScrollViewDelegate <NSObject>

/*
 总共有多少页
 */
-(int) numOfPageForScrollView:(YKSmallLoopScrollView*) ascrollView;

/*
 总共有多少页
 */
-(int) widthForScrollView:(YKSmallLoopScrollView*) ascrollView;

/*
 第apageIndex 页的图片网址,  view会被设置为新的frame
 @param viewAtPageIndex:[0- viewAtPageIndex];
 */
-(UIView*) scrollView:(YKSmallLoopScrollView*) ascrollView viewAtPageIndex:(int) apageIndex;
           

@optional
/*
 选中第几页
 @param didSelectedPageIndex 选中的第几项，[0-numOfPageForScrollView];
 */
-(void) scrollView:(YKSmallLoopScrollView*) ascrollView didSelectedPageIndex:(int) apageIndex;

/*
 开始滚动
 */
-(void) scrollViewWillBeginDecelerating:(YKSmallLoopScrollView*) ascrollView;

//结束滚动
-(void) scrollViewDidEndDecelerating:(YKSmallLoopScrollView*) ascrollView;


@end




@protocol YKLoopScrollViewInternalDelegate <UIScrollViewDelegate>

-(void) onSetContentOffset:(CGPoint)contentOffset;

@end
@interface YKSmallLoopScrollViewInternal : UIScrollView {
@private
    
}
@end



