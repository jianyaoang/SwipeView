//
//  ViewController.m
//  SwipeView
//
//  Created by VLT Labs on 8/24/15.
//  Copyright (c) 2015 JayAng. All rights reserved.
//

#import "ViewController.h"
#import <SwipeView.h>

@interface ViewController () <UIScrollViewDelegate,SwipeViewDataSource, SwipeViewDelegate, UIGestureRecognizerDelegate>
@property (strong, nonatomic) NSMutableArray *imagesMutableArray;
@property (strong, nonatomic) IBOutlet SwipeView *swipeView;
@property (strong, nonatomic) UIImageView *imageView;
@property (nonatomic, assign) CGFloat lastScale;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    self.swipeView.dataSource = self;
    self.swipeView.delegate = self;
    self.swipeView.scrollEnabled = YES;
    self.swipeView.itemsPerPage = 1;
    self.swipeView.currentItemIndex = 0;
    self.swipeView.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.swipeView];
    
    [self createTestImages];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.swipeView reloadData];
}

-(void)createTestImages {
    
    UIImageView *imageView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"library"]];
    imageView1.frame = CGRectMake(0, self.swipeView.frame.size.height / 2, self.swipeView.frame.size.width, 300);
    
    UIImageView *imageView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"phone"]];
    imageView2.frame = CGRectMake(0, self.swipeView.frame.size.height / 2, self.swipeView.frame.size.width, 300);
    
    UIImageView *imageView3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"book"]];
    imageView3.frame = CGRectMake(0, self.swipeView.frame.size.height / 2, self.swipeView.frame.size.width, 300);
    
    UIImageView *imageView4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"phone"]];
    imageView4.frame = CGRectMake(0, self.swipeView.frame.size.height / 2, self.swipeView.frame.size.width, 300);
    
    self.imagesMutableArray = [NSMutableArray arrayWithObjects:imageView1,imageView2,imageView3, imageView4,nil];
    
    [self.swipeView reloadData];
    
}

-(NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView {
    
    return self.imagesMutableArray.count;
}

-(UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {


    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(performPinchGesture:)];
    pinchGestureRecognizer.scale = 1.0;
    pinchGestureRecognizer.delegate = self;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.swipeView.frame.size.width, self.swipeView.frame.size.height)];
    scrollView.backgroundColor = [UIColor blueColor];
    scrollView.contentMode = UIViewContentModeScaleAspectFit;
    scrollView.clipsToBounds = YES;
    scrollView.contentSize = CGSizeMake(self.swipeView.frame.size.width, 300);
    scrollView.delegate = self;
    scrollView.maximumZoomScale = 10.0;
    scrollView.minimumZoomScale = 1.0;
    
//    self.imageView = (UIImageView*)view;
    self.imageView = self.imagesMutableArray[index];
    self.imageView.frame = CGRectMake(0, 100, scrollView.frame.size.width, 300);
    [self.imageView addGestureRecognizer:pinchGestureRecognizer];
    [scrollView addSubview:self.imageView];
    return scrollView;
    
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

-(UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    return self.imageView;
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView {
    self.swipeView.scrollEnabled = NO;
    self.swipeView.pagingEnabled = NO;
    NSLog(@"disabled");
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    if (scale == 1) {
        self.swipeView.scrollEnabled = YES;
        self.swipeView.pagingEnabled = YES;
        NSLog(@"enabled");
    }
}

-(void)performPinchGesture:(UIPinchGestureRecognizer*)gestureRecognizer{
    
    
    if([gestureRecognizer state] == UIGestureRecognizerStateBegan) {

        self.lastScale = [gestureRecognizer scale];
    }
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan ||
        [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        
        CGFloat currentScale = [[[gestureRecognizer view].layer valueForKeyPath:@"transform.scale"] floatValue];
        
        // Constants to adjust the max/min values of zoom
        const CGFloat kMaxScale = 5.0;
        const CGFloat kMinScale = 1.0;
        
        CGFloat newScale = 1 -  (self.lastScale - [gestureRecognizer scale]);
        newScale = MIN(newScale, kMaxScale / currentScale);
        newScale = MAX(newScale, kMinScale / currentScale);
        CGAffineTransform transform = CGAffineTransformScale([[gestureRecognizer view] transform], newScale, newScale);
        [gestureRecognizer view].transform = transform;
        
        self.lastScale = [gestureRecognizer scale];  // Store the previous scale factor for the next pinch gesture call
    }
}

- (CGSize)swipeViewItemSize:(SwipeView *)swipeView
{
    return self.swipeView.bounds.size;
}



@end
