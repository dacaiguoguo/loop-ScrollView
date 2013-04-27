//
//  YKCamelViewController.m
//  lunboTest
//
//  Created by yanguo.sun on 13-4-27.
//  Copyright (c) 2013年 YEK. All rights reserved.
//

#import "YKCamelViewController.h"
#import "YKSmallLoopScrollView.h"

@interface YKCamelViewController ()<YKSmallLoopScrollViewDelegate>
@property (strong, nonatomic) NSMutableArray *filenames;
@end

@implementation YKCamelViewController

/*
 总共有多少页
 */
@synthesize loopScrollView = _loopScrollView;
-(int) numOfPageForScrollView:(YKSmallLoopScrollView*) ascrollView{
    return self.filenames.count;
}
-(int) widthForScrollView:(YKSmallLoopScrollView*) ascrollView{
    return 260;
}
/*
 第apageIndex 页的图片网址,  view会被设置为新的frame
 @param viewAtPageIndex:[0- viewAtPageIndex];
 */
-(UIView*) scrollView:(YKSmallLoopScrollView*) ascrollView viewAtPageIndex:(int) apageIndex{
    UIImageView *ret = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[self.filenames objectAtIndex:apageIndex]]];
    ret.contentMode = UIViewContentModeScaleToFill;
    [ret setFrame:CGRectMake(0, 0, 260, 157)];
    return ret;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.filenames= [NSMutableArray array];
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSMutableArray *paths = [[[NSBundle mainBundle]
                              pathsForResourcesOfType:@"jpg" inDirectory:nil] mutableCopy];
    
    // loop through each png file
    for (NSString *filename in paths)
    {
        // separate the file name from the rest of the path
       NSString * filenameto = [filename lastPathComponent];
        [self.filenames addObject:filenameto]; // add the display name
    }
//    self.loopScrollView.bounds = CGRectMake(0, 0, 320, 157);
    [self.loopScrollView reloadData];
    //
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setLoopScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
