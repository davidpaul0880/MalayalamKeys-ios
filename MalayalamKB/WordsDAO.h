//
//  WordsDAO.h
//  MalayalamEditor
//
//  Created by jijo on 3/26/15.
//  Copyright (c) 2015 jeesmon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface WordsDAO : NSObject{
    
    sqlite3 *database;
}


-(void)initWithDataBase;
-(void)closeAll;

-(NSArray *)getAllMatchedWords:(NSString *)matchstr Mode:(int)mode;
@end
