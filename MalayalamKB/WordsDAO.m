//
//  WordsDAO.m
//  MalayalamEditor
//
//  Created by jijo on 3/26/15.
//  Copyright (c) 2015 jeesmon. All rights reserved.
//

#import "WordsDAO.h"


@implementation WordsDAO

-(NSUInteger)preparingStatement:(sqlite3_stmt **)stmt Query:(NSString *)sql{
    
    BOOL continueTrying = YES;
    NSInteger retVal = SQLITE_ERROR;
    while (continueTrying) {
        retVal = sqlite3_prepare_v2(database, [sql UTF8String], -1, stmt, NULL);
        switch (retVal) {
            case SQLITE_BUSY:
            case SQLITE_LOCKED:
                NSLog(@" SQLITE_BUSY: sleeping fow a while...");
                [NSThread sleepForTimeInterval:0.5];
                break;
            case SQLITE_OK:
                continueTrying = NO; // We're done
                break;
            case SQLITE_CANTOPEN://+20140603
                
                NSLog(@"Can't execute %s, ret=%lu, %@", sqlite3_errmsg(database) ,(long)retVal, sql);
                exit(0);
            default:
                NSLog(@"Can't execute %s\n", sqlite3_errmsg(database));
                continueTrying = NO;
                break;
        }
    }
    return retVal;
    
}
-(NSUInteger)preparingStatement:(sqlite3_stmt **)stmt QueryChar:(const char *)sql{
    
    BOOL continueTrying = YES;
    NSUInteger retVal = SQLITE_ERROR;
    while (continueTrying) {
        retVal = sqlite3_prepare_v2(database, sql, -1, stmt, NULL);
        switch (retVal) {
            case SQLITE_BUSY:
            case SQLITE_LOCKED:
                NSLog(@" SQLITE_BUSY: sleeping fow a while...");
                [NSThread sleepForTimeInterval:0.5];
                break;
            case SQLITE_OK:
                continueTrying = NO; // We're done
                break;
            case SQLITE_CANTOPEN://+20140603
                
                NSLog(@"Can't execute %s, ret=%lu, %s", sqlite3_errmsg(database) ,(unsigned long)retVal, sql);
                exit(0);
            default:
                NSLog(@"Can't execute %s\n", sqlite3_errmsg(database));
                continueTrying = NO;
                break;
        }
    }
    return retVal;
}
-(NSUInteger)steppingStatement:(sqlite3_stmt *)stmt{
    
    BOOL continueTrying = YES;
    NSUInteger retVal = SQLITE_ERROR;
    while (continueTrying) {
        retVal = sqlite3_step(stmt);
        switch (retVal) {
            case SQLITE_BUSY:
            case SQLITE_LOCKED:
                NSLog(@" SQLITE_BUSY: sleeping fow a while...");
                [NSThread sleepForTimeInterval:0.5];
                break;
            case SQLITE_ROW:
            case SQLITE_DONE:
            case SQLITE_OK:
                continueTrying = NO; // We're done
                break;
            case SQLITE_CANTOPEN://+20140603
                
                NSLog(@"Can't execute %s, ret=%lu", sqlite3_errmsg(database) ,(unsigned long)retVal);
                exit(0);
            default:
                NSLog(@"Can't step %s\n", sqlite3_errmsg(database));
                continueTrying = NO;
                break;
        }
    }
    return retVal;
    
}
-(NSUInteger)executeQueryChar:(const char *)sql{
    
    BOOL continueTrying = YES;
    NSUInteger retVal = SQLITE_ERROR;
    while (continueTrying) {
        
        retVal = sqlite3_exec(database, sql, NULL, NULL, NULL);
        switch (retVal) {
            case SQLITE_BUSY:
            case SQLITE_LOCKED:
                NSLog(@" SQLITE_BUSY: sleeping fow a while...");
                [NSThread sleepForTimeInterval:0.5];
                break;
            case SQLITE_OK:
            case SQLITE_ROW:
            case SQLITE_DONE:
                continueTrying = NO; // We're done
                break;
            case SQLITE_CANTOPEN://+20140603
                
                NSLog(@"Can't execute %s, ret=%lu, %s", sqlite3_errmsg(database) ,(unsigned long)retVal, sql);
                exit(0);
            default:
                NSLog(@"Can't execute %s\n", sqlite3_errmsg(database));
                continueTrying = NO;
                break;
        }
    }
    return retVal;
}
-(NSUInteger)executeQuery:(NSString *)sql{
    
    BOOL continueTrying = YES;
    NSUInteger retVal = SQLITE_ERROR;
    while (continueTrying) {
        
        retVal = sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL);
        switch (retVal) {
            case SQLITE_BUSY:
            case SQLITE_LOCKED:
                NSLog(@" SQLITE_BUSY: sleeping fow a while...");
                [NSThread sleepForTimeInterval:0.5];
                break;
            case SQLITE_OK:
            case SQLITE_ROW:
            case SQLITE_DONE:
                continueTrying = NO; // We're done
                break;
            case SQLITE_CANTOPEN://+20140603
                
                NSLog(@"Can't execute %s, ret=%lu, %@", sqlite3_errmsg(database) ,(unsigned long)retVal, sql);
                exit(0);
            default:
                NSLog(@"Can't execute %s\n", sqlite3_errmsg(database));
                continueTrying = NO;
                break;
        }
    }
    return retVal;
}



-(void)initWithDataBase{
    
   
    NSString *dbPath =  [[NSBundle mainBundle] pathForResource:@"mlwords" ofType:@"sqlite"];
    
    if (sqlite3_open_v2([dbPath UTF8String], &database, SQLITE_OPEN_READONLY, NULL) == SQLITE_OK){
        
        /*
        char *sql = "select word from dict where word like '1%' limit 3";
        
        
        if ([self preparingStatement:&selectstmt QueryChar:sql] != SQLITE_OK) {
            NSLog(@"failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }else{
            NSLog(@"prepared");
        }

        
        while([self steppingStatement:selectstmt] == SQLITE_ROW) {
            
            char *wordd = (char *)sqlite3_column_text(selectstmt, 0);
            
            if(wordd){
                NSLog(@"prepared = %@", [NSString stringWithUTF8String:wordd]);
            }
            
            
        }*/
        
    }else{
        NSLog(@"db not opened");
    }
    
    
}

-(void)closeAll{
    if (sqlite3_close(database) != SQLITE_OK) {
        NSLog(@"Error:DataStore.closeAll: failed to close database with message '%s'.", sqlite3_errmsg(database));
    }
}

-(NSArray *)getAllMatchedWords:(NSString *)matchstr Mode:(int)mode{
    
    
    sqlite3_stmt *selectstmt = nil;
    
    NSMutableArray *array = [NSMutableArray array];
    //NSString *arg = [NSString stringWithFormat:@"'%@%%'", matchstr];
    
   // NSLog(@"arg = %@", arg);
    //char *sql = "select word from dict where word like ? limit 3";
    
    
    
    //sqlite3_bind_text(selectstmt, 1, [arg UTF8String], -1, SQLITE_TRANSIENT);
    
    @try {
        
        if (mode == 0) {
            
            NSString *sql = [NSString stringWithFormat:@"select zword from zwords where zpriority=50 and zword like '%@%%' order by zpriority limit 15", matchstr];
            
            NSLog(@"sql = %@", sql);
            
            if ([self preparingStatement:&selectstmt Query:sql] != SQLITE_OK) {
                NSLog(@"failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }else{
                //(@"prepared");
            }
        }else{
            NSString *sql = [NSString stringWithFormat:@"select zword from zwords where zword like '%@%%' order by zpriority limit 15", matchstr];
            
            
            
            if ([self preparingStatement:&selectstmt Query:sql] != SQLITE_OK) {
                NSLog(@"failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }else{
                //(@"prepared");
            }
        }
        
        
        
        
        
        while([self steppingStatement:selectstmt] == SQLITE_ROW) {
            
            char *wordd = (char *)sqlite3_column_text(selectstmt, 0);
            
            if(wordd){
                [array addObject:[NSString stringWithUTF8String:wordd]];
            }
            
            
        }

    }
    @catch (NSException *exception) {
        NSLog(@"catch");
    }
    @finally {
        sqlite3_finalize(selectstmt);
    }
    
    
    //    sqlite3_clear_bindings(selectstmt);
    
    
    
    return array;
    
    
}

@end
