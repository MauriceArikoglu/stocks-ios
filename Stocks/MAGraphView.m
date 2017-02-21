//
//  MAGraphView.m
//  MetalDollar (old name)
//
//  Updated by Maurice Arikoglu on 09.02.17. Originally created by Maurice Arikoglu for 'MetalDollar' on 26.03.14.
//  Copyright © 2017 Maurice Arikoglu. All rights reserved.
//

#import "MAGraphView.h"

const double FINE_SPACE = 4.0;
const double LABEL_HEIGHT = 22.0;
const double INDICATOR_WIDTH = 2.0;
const double FONTSIZE = 10.0f;


@interface MAGraphView()

@property (nonatomic, retain) NSMutableArray *drawParameters;
@property (nonatomic, retain) NSMutableArray *drawDates;

@property (nonatomic, retain) UIView *positionIndicator;
@property (nonatomic, retain) UILabel *detailLabel;

@property (nonatomic, assign) BOOL isIndicatorRemoveable;

@end

@implementation MAGraphView

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.positionIndicator = [[UIView alloc] initWithFrame:
                                  CGRectMake(self.frame.origin.x, 0.0, INDICATOR_WIDTH, self.frame.size.height)];
        
        self.positionIndicator.backgroundColor = [UIColor whiteColor];
        self.positionIndicator.alpha = 0.0;
        
        self.detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.origin.x + FINE_SPACE, 0.0, self.frame.size.width, LABEL_HEIGHT)];
        
        self.detailLabel.font = [UIFont systemFontOfSize:FONTSIZE];
        self.detailLabel.textColor = [UIColor whiteColor];
        
        self.detailLabel.alpha = 0.0;
        
        [self addSubview:self.positionIndicator];
        [self addSubview:self.detailLabel];
        
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
        self.positionIndicator = [[UIView alloc] initWithFrame:
                                  CGRectMake(self.frame.origin.x, 0.0, INDICATOR_WIDTH, self.frame.size.height)];
        
        self.positionIndicator.backgroundColor = [UIColor whiteColor];
        self.positionIndicator.alpha = 0.0;
        
        self.detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.origin.x + FINE_SPACE, 0.0, self.frame.size.width, LABEL_HEIGHT)];
        
        self.detailLabel.font = [UIFont systemFontOfSize:FONTSIZE];
        self.detailLabel.textColor = [UIColor whiteColor];
        
        self.detailLabel.alpha = 0.0;
        
        [self addSubview:self.positionIndicator];
        [self addSubview:self.detailLabel];
        
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (void)setPriceData:(NSMutableArray *)priceData dateData:(NSMutableArray *)dateData {
    
    self.drawParameters = [NSMutableArray arrayWithArray:priceData];
    self.drawDates = [NSMutableArray arrayWithArray:dateData];
    
    [self setNeedsDisplay];
    
}

//-----------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    self.isIndicatorRemoveable = NO;
    
    [UIView animateWithDuration:0.5 animations:^{
        
        self.positionIndicator.alpha = 1.0;
        self.detailLabel.alpha = 1.0;
        
    }];
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    self.isIndicatorRemoveable = NO;
    
    UITouch *touch = [touches anyObject];
    
    CGPoint touchLocation = [touch locationInView:self];
    
    float xInterval = self.frame.size.width / self.drawParameters.count;
    
    int object = roundf(touchLocation.x/xInterval);
    
    if (self.drawParameters && ((object >= 0) && (object < self.drawParameters.count))) {
        
        float price = [[self.drawParameters objectAtIndex:object] floatValue];
        NSString *dateString = [self.drawDates objectAtIndex:object];
        
        self.detailLabel.text = [NSString stringWithFormat:@"%@ $%.2f", dateString, price];
        // +currency Symbol (maybe a currency property?)
        
    }
    
    if (touchLocation.x < self.frame.size.width / 2) {
        //show label on the right side
        
        CGRect labelRect = self.detailLabel.frame;
        
        labelRect.origin = CGPointMake(touchLocation.x + FINE_SPACE, labelRect.origin.y);
        
        self.detailLabel.textAlignment = NSTextAlignmentLeft;
        self.detailLabel.frame = labelRect;
        
    } else {
        
        CGRect labelRect = self.detailLabel.frame;
        
        labelRect.origin = CGPointMake(touchLocation.x - (labelRect.size.width + FINE_SPACE), labelRect.origin.y);
        
        self.detailLabel.textAlignment = NSTextAlignmentRight;
        self.detailLabel.frame = labelRect;
        
    }
    
    self.positionIndicator.frame = CGRectMake(touchLocation.x, 0.0, INDICATOR_WIDTH, self.frame.size.height);
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    self.isIndicatorRemoveable = YES;
    
    [self performSelector:@selector(removeDetailInformation) withObject:nil afterDelay:.5];
    
}

- (void)removeDetailInformation{
    
    if (self.isIndicatorRemoveable == YES) {
        
        [UIView animateWithDuration:1 animations:^{
            
            self.positionIndicator.alpha = 0.0;
            self.detailLabel.alpha = 0.0;
            
        }];
        
    }
    
}

- (void)drawRect:(CGRect)rect
{
    
    CGFloat height = rect.size.height * .8;
    CGFloat topSpace = rect.size.height *.1;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(context, rect);
    
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 2.0);
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:[self.drawParameters mutableCopy]];
    
    [array sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"floatValue" ascending:YES]]]; //resort array to find bounds
    
    float max = [[array lastObject] floatValue];
    float min = [[array firstObject] floatValue];
    
    float margin = (max - min);
    
    NSLog(@"%@", array);
    NSLog(@"%f, %f, %f", min, max, margin);
    
    float value = 1 - (([self.drawParameters.firstObject floatValue] - min)/margin);
    
    CGContextMoveToPoint(context, 0.0, topSpace + (height * value));
    
    int count = 0;
    float xInterval = rect.size.width/ self.drawParameters.count;
    
    while (count < self.drawParameters.count) {
        
        value = 1 - (([[self.drawParameters objectAtIndex:count] floatValue] - min)/margin);
        
        CGContextAddLineToPoint(context, CGContextGetPathCurrentPoint(context).x + xInterval, topSpace + (height * value));
        
        count++;
        
    }
    
    CGContextStrokePath(context);
    
}


@end
