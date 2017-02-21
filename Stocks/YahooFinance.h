//
//  YahooFinance.h
//  Stocks
//
//  Created by Maurice Arikoglu on 18.02.17.
//  Copyright © 2017 Maurice Arikoglu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, YFInterval) {
    
    YFLastMonth,
    YFLast3Months,
    YFLast6Months,
    YFLastYear
    
};


@protocol YahooFinanceDelegate <NSObject>

- (void)yahooFinanceData:(NSMutableDictionary *)financeDictionary;
- (void)yahooFinanceNews:(NSMutableArray *)financeNewsArray;
- (void)yahooRealTimeData:(NSMutableDictionary *)financeDictionary;

@end

@interface YahooFinance : NSObject

@property (nonatomic, weak) id <YahooFinanceDelegate> delegate;

- (void)getNewsForSymbol:(NSString *)symbol;
- (void)getRealTimeInformationForSymbols:(NSArray *)symbols;
- (void)getDataForSymbol:(NSString *)symbol fromTimeInterval:(YFInterval)timeInterval;

    @end
