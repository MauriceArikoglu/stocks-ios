//
//  AppDelegate.h
//  Stocks
//
//  Created by Maurice Arikoglu on 09.02.17.
//  Copyright © 2017 Maurice Arikoglu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

