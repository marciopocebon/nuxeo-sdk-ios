//
//  NUXHierarchyDB.h
//  NuxeoSDK
//
//  Created by Arnaud Kervern on 03/12/13.
//  Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NUXHierarchyDB : NSObject
+(NUXHierarchyDB *)shared;

-(void)createTableIfNeeded;
-(void)insertNodes:(NSArray *)docs fromHierarchy:(NSString *)hierarchyName withParent:(NSString *)parentId;
-(NSArray *)selectNodesFromParent:(NSString *)parentId hierarchy:(NSString *)hierarchyName;

@end
