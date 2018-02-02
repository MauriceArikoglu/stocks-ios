//
//  ViewController.m
//  Stocks
//
//  Created by Maurice Arikoglu on 09.02.17.
//  Copyright © 2017 Maurice Arikoglu. All rights reserved.
//

#import "ViewController.h"

#define kDebugSymbol @"AAPL"

@interface ViewController ()

@property (nonatomic, retain) YahooFinance *yahoo;
@property (nonatomic, retain) NSMutableArray *yahooNews;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*
    It has come to our attention that this service is being
     used in violation of the Yahoo Terms of Service.
     As such, the service is being discontinued.
     For all future markets and equities data research,
     please refer to http://finance.yahoo.com.
    */
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.yahoo = [[YahooFinance alloc] init];
    self.yahoo.delegate = self;

    self.yahooNews = [NSMutableArray array];
    
    self.symbolLabel.text = kDebugSymbol;
    
    self.fetchingInfoLabel.alpha = 1.0;
    self.intervalControl.enabled = NO;

    [self.yahoo getDataForSymbol:kDebugSymbol fromTimeInterval:YFLast3Months];
    [self.yahoo getRealTimeInformationForSymbols:@[kDebugSymbol]];
    [self.yahoo getNewsForSymbol:kDebugSymbol];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

#pragma mark - IBAction

- (IBAction)userChangedInterval:(id)sender {
    
    self.intervalControl.enabled = NO;

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    [UIView animateWithDuration:0.5 animations:^{
       
        self.graphView.alpha = 0.0;
        self.fetchingInfoLabel.alpha = 1.0;
        
    }];
    
    switch ([(UISegmentedControl *)sender selectedSegmentIndex]) {
        case 0:
        {
            [self.yahoo getDataForSymbol:kDebugSymbol fromTimeInterval:YFLastMonth];

        }
            break;
            
        case 1:
        {
            [self.yahoo getDataForSymbol:kDebugSymbol fromTimeInterval:YFLast3Months];

        }
            break;
            
        case 2:
        {
            [self.yahoo getDataForSymbol:kDebugSymbol fromTimeInterval:YFLast6Months];

        }
            break;
            
        case 3:
        {
            [self.yahoo getDataForSymbol:kDebugSymbol fromTimeInterval:YFLastYear];

        }
            break;
            
        default:
            break;
    }
}

#pragma mark - YahooFinance Delegate

- (void)yahooFinanceData:(NSMutableDictionary *)financeDictionary {
    
    if (financeDictionary != nil) {
        
        [self.graphView setPriceData:[financeDictionary objectForKey:@"prices"] dateData:[financeDictionary objectForKey:@"dates"]];
        
        [UIView animateWithDuration:0.5 animations:^{
            
            self.fetchingInfoLabel.alpha = 0.0;
            self.graphView.alpha = 1.0;
            
        }];
        
        self.intervalControl.enabled = YES;
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        //finance dictionary contains two arrays: 'prices' and conforming 'dates'

    }
    
}

- (void)yahooFinanceNews:(NSMutableArray *)financeNewsArray {

    NSLog(@"%@", financeNewsArray);

    self.yahooNews = [NSMutableArray arrayWithArray:financeNewsArray];
    [self.newsTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    //update tableview
    
}

- (void)yahooRealTimeData:(NSMutableDictionary *)financeDictionary {
    
    NSLog(@"%@", financeDictionary);
    self.valueLabel.text = [NSString stringWithFormat:@"%.2f", [[financeDictionary objectForKey:@"price"] floatValue]];
    float change = [[financeDictionary objectForKey:@"change"] floatValue];
    
    if (change >= 0) {
        
        //set color green
        self.changeLabel.backgroundColor = [UIColor colorWithRed:0 green:255.0/128.0 blue:0 alpha:0.4];
        self.changeLabel.text = [NSString stringWithFormat:@"+%.2f%%", change];

    } else {
        
        //set color red
        self.changeLabel.backgroundColor = [UIColor colorWithRed:255.0/128.0 green:0 blue:0 alpha:0.4];
        self.changeLabel.text = [NSString stringWithFormat:@"-%.2f%%", change];

    }
    
    [UIView animateWithDuration:0.3 animations:^{
       
        self.valueLabel.alpha = 1.0;
        self.changeLabel.alpha = 1.0;
        self.symbolLabel.alpha = 1.0;
        
    }];
    
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.yahooNews.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *newsCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"newsObject"];
    
    NSDictionary *newsObject = [NSDictionary dictionaryWithDictionary:[self.yahooNews objectAtIndex:indexPath.row]];
    
    newsCell.textLabel.text = [newsObject objectForKey:@"title"];
    newsCell.detailTextLabel.text = [newsObject objectForKey:@"pubDate"];
    
    newsCell.textLabel.textColor = [UIColor whiteColor];
    newsCell.detailTextLabel.textColor = [UIColor whiteColor];
    
    newsCell.backgroundColor = [UIColor clearColor];
    
    return newsCell;
}


@end
