//
//  ViewController.h
//  Stocks
//
//  Created by Maurice Arikoglu on 09.02.17.
//  Copyright © 2017 Maurice Arikoglu. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YahooFinance.h"
#import "MAGraphView.h"

@interface ViewController : UIViewController <YahooFinanceDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet MAGraphView *graphView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *intervalControl;
@property (weak, nonatomic) IBOutlet UITableView *newsTableView;

@property (weak, nonatomic) IBOutlet UILabel *symbolLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UILabel *changeLabel;

@property (weak, nonatomic) IBOutlet UILabel *fetchingInfoLabel;

- (IBAction)userChangedInterval:(id)sender;
@end

