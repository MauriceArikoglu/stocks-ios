//
//  YahooFinance.m
//  Stocks
//
//  Created by Maurice Arikoglu on 18.02.17.
//  Copyright © 2017 Maurice Arikoglu. All rights reserved.
//

#import "YahooFinance.h"

const double SURGERY_6M = 2.0;
const double SURGERY_1Y = 4.0;

#define kUSD_EXCHANGES [NSURL URLWithString: @"http://query.yahooapis.com/v1/public/yql?q=select+*+from+yahoo.finance.xchange+where+pair+in+(%22XAUUSD%22,%22USDAUD%22,%22USDEUR%22,%22USDGBP%22,%22USDJPY%22)&format=json&diagnostics=true&env=store://datatables.org/alltableswithkeys&callback="]
#define kYahooRealTimePartOne @"http://query.yahooapis.com/v1/public/yql?q=select+*+from+csv+where+url='http://download.finance.yahoo.com/d/quotes.csv%3Fs="
#define kYahooRealTimePartTwo @"%26f=sl1d1t1c1ohgv%26e=.csv'+and+columns='symbol,price,date,time,change,col1,high,low,col2'&format=json&diagnostics=true&callback="
#define kYahooQueryString @"http://query.yahooapis.com/v1/public/yql?q=select+*+from+yahoo.finance.historicaldata+where+symbol+=+%@+and+startDate+=+%@+and+endDate+=+%@&format=json&diagnostics=true&env=store://datatables.org/alltableswithkeys&callback="
#define kYahooFinanceNewsPartOne @"https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20rss%20where%20url%3D'http%3A%2F%2Ffeeds.finance.yahoo.com%2Frss%2F2.0%2Fheadline%3Fs%3D"
#define kYahooFinanceNewsPartTwo @"%26region%3DUS%26lang%3Den-US'&format=json&diagnostics=true&callback="

//we need to add %22 wrapping the passed values to to-be-formatted string (query takes characters and urls encoded characters)

@interface YahooFinance()

@property (nonatomic, assign) YFInterval requestInterval;

@end

@implementation YahooFinance

- (id)init {
    
    self = [super init];
    
    if (self) {
       
        //get exchange rates here
        
    }
    
    return self;
}

- (void)getNewsForSymbol:(NSString *)symbol {
    
    [self queryYahooNewsWithSymbol:symbol];
}

- (void)queryYahooNewsWithSymbol:(NSString *)symbolString {
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", kYahooFinanceNewsPartOne, symbolString, kYahooFinanceNewsPartTwo]];
    
    NSURLRequest *URL_request = [NSURLRequest requestWithURL:URL];
    NSURLSession *URL_session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionDataTask *URL_dataTask = [URL_session dataTaskWithRequest:URL_request completionHandler:^(NSData *taskData, NSURLResponse *response, NSError *error){
        
        if (!error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:taskData options:kNilOptions error:nil];
                
//                NSLog(@"%@", json);
                
                NSDictionary *queryResult = [[NSDictionary alloc] initWithDictionary:[json objectForKey:@"query"]];
                
                if (([queryResult objectForKey:@"results"] != [NSNull null]) && ([queryResult objectForKey:@"results"] != nil)) {
                    
                    NSDictionary *result = [[NSDictionary alloc] initWithDictionary:[queryResult objectForKey:@"results"]];
                    
                    NSMutableArray *items = [[NSMutableArray alloc] initWithArray:[result objectForKey:@"item"]];
                    
                    NSLog(@"%@", items);
                    
                    if ([self.delegate respondsToSelector:@selector(yahooFinanceNews:)]) [self.delegate yahooFinanceNews:items];

                }
                
            });
            
        } else {
            
            //            [self.delegate fetchWithID:ID fromURL:URL failedWithError:error];
            NSLog(@"Error while requesting Data:%@\n************", error.localizedDescription);
            //Do something when there is no internet connection or the server wont respond
        }
        
    }];
    
    [URL_dataTask resume];
    
}

- (void)getRealTimeInformationForSymbols:(NSArray *)symbols {
    
    NSString *formattedSymbols = symbols.firstObject;
    
    for (int i = 1; i < symbols.count; i++) {
        
        formattedSymbols = [NSString stringWithFormat:@"%@, %@", formattedSymbols, [symbols objectAtIndex:i]];
    }
    
    [self queryYahooForRealTimeWithSymbol:formattedSymbols];
}

- (void)queryYahooForRealTimeWithSymbol:(NSString *)symbolString {
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", kYahooRealTimePartOne, symbolString, kYahooRealTimePartTwo]];
    
    NSURLRequest *URL_request = [NSURLRequest requestWithURL:URL];
    NSURLSession *URL_session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionDataTask *URL_dataTask = [URL_session dataTaskWithRequest:URL_request completionHandler:^(NSData *taskData, NSURLResponse *response, NSError *error){
        
        if (!error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{

                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:taskData options:kNilOptions error:nil];
                
//                NSLog(@"%@", json);
                
                NSDictionary *queryResult = [[NSDictionary alloc] initWithDictionary:[json objectForKey:@"query"]];
                
                if (([queryResult objectForKey:@"results"] != [NSNull null]) && ([queryResult objectForKey:@"results"] != nil)) {
                    
                    NSDictionary *result = [[NSDictionary alloc] initWithDictionary:[queryResult objectForKey:@"results"]];
                    
                    if ([self.delegate respondsToSelector:@selector(yahooRealTimeData:)]) [self.delegate yahooRealTimeData:[result objectForKey:@"row"]];

                }
                
            });
            
        } else {
            
            //            [self.delegate fetchWithID:ID fromURL:URL failedWithError:error];
            NSLog(@"Error while requesting Data:%@\n************", error.localizedDescription);
            //Do something when there is no internet connection or the server wont respond
        }
        
    }];
    
    [URL_dataTask resume];

}

- (void)getDataForSymbol:(NSString *)symbol fromTimeInterval:(YFInterval)timeInterval {
    
    self.requestInterval = timeInterval;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"%22yyyy-MM-dd%22"];

    NSString *historicFormattedDate;
    NSString *formattedSymbol = [[@"%22" stringByAppendingString:symbol] stringByAppendingString:@"%22"];
    
    switch (timeInterval) {
        case YFLastMonth:
        {
            historicFormattedDate = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-2629743]];
        }
            break;
            
        case YFLast3Months:
        {
            historicFormattedDate = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-7889231]];
        }
            break;
            
        case YFLast6Months:
        {
            historicFormattedDate = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-15778463]];
        }
            break;
            
        case YFLastYear:
        {
            historicFormattedDate = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-31556926]];
        }
            break;
            
        default:
        {
            historicFormattedDate = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-7889231]];
        }
            break;
    }
    
    [self queryYahooWithSymbol:formattedSymbol andTimeInterval:historicFormattedDate];
}

- (void)queryYahooWithSymbol:(NSString *)symbolString andTimeInterval:(NSString *)timeIntervalString {

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    [dateFormatter setDateFormat:@"%22yyyy-MM-dd%22"];
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:kYahooQueryString, symbolString, timeIntervalString, [dateFormatter stringFromDate:[NSDate date]]]];
    
    NSURLRequest *URL_request = [NSURLRequest requestWithURL:URL];
    NSURLSession *URL_session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionDataTask *URL_dataTask = [URL_session dataTaskWithRequest:URL_request completionHandler:^(NSData *taskData, NSURLResponse *response, NSError *error){
        
        if (!error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if ([self.delegate respondsToSelector:@selector(yahooFinanceData:)]) [self.delegate yahooFinanceData:[self processHistoricalPriceData:taskData]];
                
            });
            
        } else {
            
//            [self.delegate fetchWithID:ID fromURL:URL failedWithError:error];
            NSLog(@"Error while requesting Data:%@\n************", error.localizedDescription);
            //Do something when there is no internet connection or the server wont respond
        }
        
    }];
    
    [URL_dataTask resume];
}

- (NSMutableDictionary *)processHistoricalPriceData:(NSData *)data {
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    NSDictionary *queryResult = [[NSDictionary alloc] initWithDictionary:[json objectForKey:@"query"]];
    
    if (([queryResult objectForKey:@"results"] != [NSNull null]) && ([queryResult objectForKey:@"results"] != nil)) {
        
        NSDictionary *result = [[NSDictionary alloc] initWithDictionary:[queryResult objectForKey:@"results"]];
        
        NSMutableArray *quotes = [[NSMutableArray alloc] initWithArray:[result objectForKey:@"quote"]];
        
        NSMutableArray *priceParameters = [[NSMutableArray alloc] init];
        NSMutableArray *dateParameters = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dayObject in quotes) {
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            
            NSDate *date = [dateFormatter dateFromString:[dayObject objectForKey:@"Date"]];
            
            [dateFormatter setDateStyle:NSDateFormatterLongStyle];
            [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
            
            [dateParameters insertObject:[dateFormatter stringFromDate:date] atIndex:0];
            [priceParameters insertObject:[NSString stringWithFormat:@"%.2f", [[dayObject objectForKey:@"Close"] floatValue]] atIndex:0];
            
        }
        
        switch (self.requestInterval) {
            case YFLast6Months:
            {
                return [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        [self performPlasticSurgeryOn:priceParameters withSteps:SURGERY_6M], @"prices",
                        [self performPlasticSurgeryOn:dateParameters withSteps:SURGERY_6M], @"dates",
                        nil];
            }
                break;
                
            case YFLastYear:
            {
                return [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        [self performPlasticSurgeryOn:priceParameters withSteps:SURGERY_1Y], @"prices",
                        [self performPlasticSurgeryOn:dateParameters withSteps:SURGERY_1Y], @"dates",
                        nil];
            }
                break;
                
            default:
                break;
        }
        
        
        return [NSMutableDictionary dictionaryWithObjectsAndKeys:
                priceParameters, @"prices",
                dateParameters, @"dates",
                nil];
    }

    return nil;
}

- (NSMutableArray *)performPlasticSurgeryOn:(NSArray *)patient withSteps:(int)steps {
    
    int count = 0;
    NSMutableArray *curedPatient = [NSMutableArray array];
    
    while (count < patient.count) {
        
        if ([patient objectAtIndex:count] != nil) {
            
            [curedPatient addObject:[patient objectAtIndex:count]];
            
        }
        
        count += steps;
    }

    return curedPatient;
}

@end
