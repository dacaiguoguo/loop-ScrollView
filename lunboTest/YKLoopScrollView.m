//
//  YKLoopScrollView.m
//  testScrollView2
//
//  Created by sihai sihai on 11-11-28.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "YKLoopScrollView.h"

static const int maxRange=1000;    //

#define widthScroll  260
@interface YKLoopScrollView()
/*
 设置绝对pageindex [0-2000]; [1000]==0
 */
-(void)setAbsolutePageIndex:(int)index animated:(BOOL) anim;
-(int)absolutePageIndex;

@end


@implementation YKLoopScrollView
@synthesize delegate;


/*
 返回aindex的view
 @param aindex : 第几个view，arrayindex ,可能为负
 */
-(UIView*) viewAtIndex:(int) arrayindex{
    UIView* ret=nil;
        id<YKLoopScrollViewDelegate> adelegate=(id<YKLoopScrollViewDelegate>) self.delegate;
        ret=[adelegate scrollView:self viewAtPageIndex:arrayindex];  //需要处理超大负值
    assert(ret!=nil);
    return ret;
    
}
-(void) layoutPage:(int) centerIndex{
    sizeOfPage=self.frame.size;
    sizeOfPage.width = 260;
    if(numOfPage>0){
        const int range=2;
        NSMutableDictionary* newdic=[[NSMutableDictionary alloc] init]; //生成新的view
        for(int i=centerIndex-range;i<centerIndex+range;++i){     //    
            int atArrayIndex=((i-maxRange)%numOfPage+numOfPage)%numOfPage;
            NSNumber* key=[NSNumber numberWithInt:atArrayIndex];
            UIView* v=[addSubViewDictionary objectForKey:key];
            if(v==nil || [[newdic allKeys] containsObject:key]){
                v=[self viewAtIndex:atArrayIndex];
            }
            assert(v!=nil);
            CGRect frame=CGRectMake(i*sizeOfPage.width+30, 0, sizeOfPage.width, sizeOfPage.height);
            v.frame=frame;
            [contentScrollView addSubview:v];
            //NSLog(@"v=%@, contentScrollView=%@",v,contentScrollView);
            if([[newdic allKeys] containsObject:key]){  //当数量很少时会有闪动
                [newdic setObject:v forKey:[NSNumber numberWithInt:i]];
            }else{
                [newdic setObject:v forKey:key];
            }
        }
        for(UIView* v in [addSubViewDictionary allValues]){
            if(![[newdic allValues] containsObject:v]){
                [v removeFromSuperview];
            }
        }
        [addSubViewDictionary removeAllObjects];
        [addSubViewDictionary addEntriesFromDictionary:newdic];
    }    
}
-(void)setAbsolutePageIndex:(int)index animated:(BOOL) anim setContentOffset:(BOOL) set{
    //NSLog(@"%s index=%d",__FUNCTION__,index);
    if(index==m_absolutePageIndex || numOfPage<1){
        return;
    }
    if(index+1>=2*maxRange || index-1<=0){
        index=maxRange+((index-maxRange)%numOfPage+numOfPage)%numOfPage;  
        set=YES;
    }
    [self layoutPage:index];
    m_absolutePageIndex=index;
    contentScrollView.contentSize=CGSizeMake(sizeOfPage.width*maxRange*2, sizeOfPage.height);    
    if(set){
        float x=index*sizeOfPage.width;
        [contentScrollView setContentOffset:CGPointMake(x, 0) animated:anim];
        //NSLog(@"contentScrollView=%@",contentScrollView);
    }else{
        //setContenOffset 后会引起page change
        if([delegate respondsToSelector:@selector(scrollView:didSelectedPageIndex:)]){
            [delegate scrollView:self didSelectedPageIndex:[self pageIndex]];
        }    
    }
    //NSLog(@" contentScrollView=%@",contentScrollView);
}
-(void)setAbsolutePageIndex:(int)index animated:(BOOL) anim{
    [self setAbsolutePageIndex:index animated:anim setContentOffset:YES];
}

-(void)setAbsolutePageIndex:(int)index {
    [self setAbsolutePageIndex:index animated:NO];
}
-(int)absolutePageIndex{
    return m_absolutePageIndex;
}

-(void)setPageIndex:(int)index animated:(BOOL) anim{
    assert(index>=0 && index<numOfPage );
    int absindex= maxRange+index;
    [self setAbsolutePageIndex:absindex animated:anim];
}
-(int) pageIndex{
    return ((m_absolutePageIndex-maxRange)%numOfPage+numOfPage)%numOfPage;
}

-(void)nextPage:(BOOL)anim{
    int currentindex=m_absolutePageIndex+1;
    [self setAbsolutePageIndex:currentindex animated:anim];
}

-(void) reloadData{
    id<YKLoopScrollViewDelegate> adelegate=(id<YKLoopScrollViewDelegate>) self.delegate;
    int num=[adelegate numOfPageForScrollView:self];
    assert(num>=0);
    numOfPage=num;
    m_absolutePageIndex=-1;
    for(NSNumber* key in [addSubViewDictionary allKeys]){
        UIView* v=[addSubViewDictionary objectForKey:key];
        [v removeFromSuperview];
    }
    [addSubViewDictionary removeAllObjects];
    if(num>0){
        [self setAbsolutePageIndex:maxRange];
    }

}

-(void) internalInit{
    addSubViewDictionary=[[NSMutableDictionary alloc] init];
    contentScrollView=[[YKLoopScrollViewInternal alloc] initWithFrame:self.bounds];
    contentScrollView.delegate=self;
    contentScrollView.scrollsToTop = NO;
    contentScrollView.pagingEnabled=NO;
    contentScrollView.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    contentScrollView.showsVerticalScrollIndicator=NO;
    contentScrollView.showsHorizontalScrollIndicator=NO;
    [self addSubview:contentScrollView];
    [self reloadData];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self=[super initWithCoder:aDecoder];
    if(self){
        [self internalInit];
    }
    return self;
}
-(id)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if(self){
        [self internalInit];
    }
    return self;
}

-(void)dealloc{
    for(NSNumber* key in [addSubViewDictionary allKeys]){
        UIView* v=[addSubViewDictionary objectForKey:key];
        [v removeFromSuperview];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    oldOffsetX = scrollView.contentOffset.x;
    startDate = [NSDate date];
}
-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    CGPoint pOff =  scrollView.contentOffset;
    
    float currentX = pOff.x;
    float cha = currentX-oldOffsetX;
    endDate = [NSDate date];
    NSTimeInterval inter = [endDate timeIntervalSinceDate:startDate];
    if (inter<0.2) {
        if (cha<0) {
            pOff.x = ((int)(oldOffsetX/widthScroll)-1)*widthScroll;
        }else{
            pOff.x = ((int)(oldOffsetX/widthScroll)+1)*widthScroll;
        }
    }else{
        
        if (abs(cha)<160) {
            pOff.x = ((int)(oldOffsetX/widthScroll))*widthScroll;
        }else{
            if (cha<0) {
                pOff.x = ((int)(oldOffsetX/widthScroll)-1)*widthScroll;
            }else{
                pOff.x = ((int)(oldOffsetX/widthScroll)+1)*widthScroll;
            }
            
        }
    }
    
    [scrollView setContentOffset:pOff animated:YES];
    if([delegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]){
        [delegate scrollViewWillBeginDecelerating:self];
    }
}




- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        CGPoint pOff =  scrollView.contentOffset;
        
        float currentX = pOff.x;
        float cha = currentX-oldOffsetX;
        if (abs(cha)<160) {
            pOff.x = ((int)(oldOffsetX/widthScroll))*widthScroll;
        }else{
            if (cha<0) {
                pOff.x = ((int)(oldOffsetX/widthScroll)-1)*widthScroll;
            }else{
                pOff.x = ((int)(oldOffsetX/widthScroll)+1)*widthScroll;
            }
            
        }

        [scrollView setContentOffset:pOff animated:YES];
    }

}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    oldOffsetX = scrollView.contentOffset.x;

}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    //在当前位置左右都铺上subview
    if([delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]){
        [delegate scrollViewDidEndDecelerating:self];
    }
    
}
-(void) onSetContentOffset:(CGPoint)contentOffset{
    //NSLog(@"%s contentOffset=%@",__FUNCTION__,NSStringFromCGPoint(contentOffset));
    if(skipSetContentOffset){
        skipSetContentOffset=NO;
        return;
    }
    int currentindex=round(contentOffset.x/sizeOfPage.width);
    if(currentindex+1>=2*maxRange || currentindex-1<=0){
        skipSetContentOffset=YES;
        [self setAbsolutePageIndex:currentindex animated:NO setContentOffset:YES];
    }else{
        [self setAbsolutePageIndex:currentindex animated:NO setContentOffset:NO];
        
    }
}


@end


@implementation YKLoopScrollViewInternal

-(void)setContentOffset:(CGPoint)contentOffset{
    [super setContentOffset:contentOffset];
    if([self.delegate respondsToSelector:@selector(onSetContentOffset:)]){
        [(id<YKLoopScrollViewInternalDelegate>)self.delegate onSetContentOffset:contentOffset];
    }
}

@end



