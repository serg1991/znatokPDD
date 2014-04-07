//
//  StatisticsChildViewController.m
//  diplom
//
//  Created by Sergey Kiselev on 23.03.14.
//  Copyright (c) 2014 Sergey Kiselev. All rights reserved.
//

#import "StatisticsChildViewController.h"

@interface StatisticsChildViewController ()

@end

@implementation StatisticsChildViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    
    return self;
}

- (void)getBiletStatistics {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    NSString *docsDir;
    NSArray *dirPaths;
    NSString *databasePath;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"pdd_stat.sqlite"]];
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt *statement1, *statement2;
    int i = 0;
    if (sqlite3_open(dbpath, &_pdd_ab_stat) == SQLITE_OK) {
        UILabel *BiletCommonStatTitle = [[UILabel alloc] initWithFrame: CGRectMake(10, 2, 300, 40)];
        BiletCommonStatTitle.text = @"Общая статистика ответов на билеты\nПравильных ответов\t\t\t  Неправильных ответов";
        BiletCommonStatTitle.textAlignment = NSTextAlignmentCenter;
        BiletCommonStatTitle.numberOfLines = 2;
        BiletCommonStatTitle.font = [UIFont italicSystemFontOfSize:11];
        [BiletCommonStatTitle sizeToFit];
        [scrollView addSubview:BiletCommonStatTitle];
        NSString *querySQL1 = [NSString stringWithFormat:@"SELECT SUM(rightCount), SUM(wrongCount), (SUM(rightCount) + SUM(wrongCount)) FROM paper_ab_stat"];
        const char *query_stmt1 = [querySQL1 UTF8String];
        if (sqlite3_prepare_v2(_pdd_ab_stat, query_stmt1, -1, &statement1, NULL) == SQLITE_OK) {
            if (sqlite3_step(statement1) == SQLITE_ROW) {
                if (sqlite3_column_int(statement1, 2) != 0) {
                    NSString *stat = [NSString stringWithFormat:@" %d \t\t\t\t\t\t\t\t %d ", sqlite3_column_int(statement1, 0), sqlite3_column_int(statement1, 1)];
                    UILabel *BiletCommonStat = [[UILabel alloc] initWithFrame: CGRectMake(10, 30, 300, 20)];
                    BiletCommonStat.text = stat;
                    BiletCommonStat.textColor = [UIColor whiteColor];
                    UIGraphicsBeginImageContext(CGSizeMake(300, 20));
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    if (sqlite3_column_int(statement1, 0) != 0) {
                        CGContextSetRGBFillColor(context,  0.0, 0.8, 0.0, 1.0);
                        CGContextFillRect(context, CGRectMake(0.0, 0.0, 300 * (sqlite3_column_int(statement1, 0) * 1.0 / sqlite3_column_int(statement1, 2)), 20));
                    }
                    if (sqlite3_column_int(statement1, 1) != 0) {
                        CGContextSetRGBFillColor(context,  0.8, 0.0, 0.0, 1.0);
                        CGContextFillRect(context, CGRectMake(300 * (sqlite3_column_int(statement1, 0) * 1.0 / sqlite3_column_int(statement1, 2)), 0.0, 300 * ((sqlite3_column_int(statement1, 1) * 1.0 / sqlite3_column_int(statement1, 2))), 20));
                    }
                    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    BiletCommonStat.backgroundColor = [UIColor colorWithPatternImage:resultingImage];
                    [scrollView addSubview:BiletCommonStat];
                }
                else {
                    NSString *stat = [NSString stringWithFormat:@" 0 \t\t\t\t\t\t\t\t 0 "];
                    UILabel *BiletCommonStat = [[UILabel alloc] initWithFrame: CGRectMake(10, 30, 300, 20)];
                    BiletCommonStat.text = stat;
                    BiletCommonStat.textColor = [UIColor whiteColor];
                    UIGraphicsBeginImageContext(CGSizeMake(300, 20));
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    CGContextSetRGBFillColor(context,  0.0, 0.8, 0.0, 1.0);
                    CGContextFillRect(context, CGRectMake(0.0, 0.0, 300 * 0.5, 20));
                    CGContextSetRGBFillColor(context,  0.8, 0.0, 0.0, 1.0);
                    CGContextFillRect(context, CGRectMake(300 * 0.5, 0.0, 300 * 0.5, 20));
                    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    BiletCommonStat.backgroundColor = [UIColor colorWithPatternImage:resultingImage];
                    [scrollView addSubview:BiletCommonStat];
                }
            }
            sqlite3_finalize(statement1);
        }
        else {
            NSLog(@"Ne mogu vypolnit' zapros #1!");
        }
        UILabel *BiletStatTitle = [[UILabel alloc] initWithFrame: CGRectMake(10, 80, 300, 40)];
        BiletStatTitle.text = @"\tСтатистика правильности ответов по билетам";
        BiletStatTitle.textAlignment = NSTextAlignmentCenter;
        BiletStatTitle.font = [UIFont italicSystemFontOfSize:11];
        [BiletStatTitle sizeToFit];
        [scrollView addSubview:BiletStatTitle];
        NSString *querySQL2 = [NSString stringWithFormat:@"SELECT biletNumber, SUM(rightCount), SUM(wrongCount), cast(SUM(rightCount) AS FLOAT) / cast ((SUM(rightCount) + SUM(wrongCount))AS FLOAT) as percent FROM paper_ab_stat GROUP BY biletNumber ORDER BY percent DESC"];
        const char *query_stmt2 = [querySQL2 UTF8String];
        if (sqlite3_prepare_v2(_pdd_ab_stat, query_stmt2, -1, &statement2, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement2) == SQLITE_ROW) {
                NSString *stat = [NSString stringWithFormat:@" Билет №%d - %3.2f%%", sqlite3_column_int(statement2, 0), sqlite3_column_double(statement2, 3) * 100];
                UILabel *BiletStat = [[UILabel alloc] initWithFrame: CGRectMake(10, 110 + (i * 30), 300, 20)];
                BiletStat.text = stat;
                BiletStat.textColor = [UIColor whiteColor];
                UIGraphicsBeginImageContext(CGSizeMake(300, 20));
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextSetRGBFillColor(context,  0.0, 0.8, 0.0, 1.0);
                CGContextFillRect(context, CGRectMake(0.0, 0.0, 300 * sqlite3_column_double(statement2, 3), 20));
                CGContextSetRGBFillColor(context,  0.8, 0.0, 0.0, 1.0);
                CGContextFillRect(context, CGRectMake(300 * sqlite3_column_double(statement2, 3), 0.0, 300 * (1 - sqlite3_column_double(statement2, 3)), 20));
                UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                BiletStat.backgroundColor = [UIColor colorWithPatternImage:resultingImage];
                [scrollView addSubview:BiletStat];
                i++;
            }
            sqlite3_finalize(statement2);
        }
        else {
            NSLog(@"Ne mogu vypolnit' zapros #2!");
        }
        sqlite3_close(_pdd_ab_stat);
    }
    else {
        NSLog(@"Ne mogu ustanovit' soedinenie!");
    }
    [scrollView setContentSize:CGSizeMake(scrollView.bounds.size.width, scrollView.bounds.size.height + 30 * (i - 12))];
    [self.view addSubview:scrollView];
}

- (void)getThemeStatistics {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    NSString *docsDir;
    NSArray *dirPaths;
    NSString *databasePath;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"pdd_stat.sqlite"]];
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt *statement1, *statement2;
    int i = 0;
    if (sqlite3_open(dbpath, &_pdd_ab_stat) == SQLITE_OK) {
        UILabel *BiletCommonStatTitle = [[UILabel alloc] initWithFrame: CGRectMake(10, 2, 300, 40)];
        BiletCommonStatTitle.text = @"Общая статистика ответов на темы\nПравильных ответов\t\t\t  Неправильных ответов";
        BiletCommonStatTitle.textAlignment = NSTextAlignmentCenter;
        BiletCommonStatTitle.numberOfLines = 2;
        BiletCommonStatTitle.font = [UIFont italicSystemFontOfSize:11];
        [BiletCommonStatTitle sizeToFit];
        [scrollView addSubview:BiletCommonStatTitle];
        NSString *querySQL1 = [NSString stringWithFormat:@"SELECT SUM(rightCount), SUM(wrongCount), (SUM(rightCount) + SUM(wrongCount)) FROM paper_ab_theme_stat"];
        const char *query_stmt1 = [querySQL1 UTF8String];
        if (sqlite3_prepare_v2(_pdd_ab_stat, query_stmt1, -1, &statement1, NULL) == SQLITE_OK) {
            if (sqlite3_step(statement1) == SQLITE_ROW) {
                if (sqlite3_column_int(statement1, 2) != 0) {
                    NSString *stat = [NSString stringWithFormat:@" %d \t\t\t\t\t\t\t\t %d ", sqlite3_column_int(statement1, 0), sqlite3_column_int(statement1, 1)];
                    UILabel *BiletCommonStat = [[UILabel alloc] initWithFrame: CGRectMake(10, 30, 300, 20)];
                    BiletCommonStat.text = stat;
                    BiletCommonStat.textColor = [UIColor whiteColor];
                    UIGraphicsBeginImageContext(CGSizeMake(300, 20));
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    if (sqlite3_column_int(statement1, 0) != 0) {
                        CGContextSetRGBFillColor(context,  0.0, 0.8, 0.0, 1.0);
                        CGContextFillRect(context, CGRectMake(0.0, 0.0, 300 * (sqlite3_column_int(statement1, 0) * 1.0 / sqlite3_column_int(statement1, 2)), 20));
                    }
                    if (sqlite3_column_int(statement1, 1) != 0) {
                        CGContextSetRGBFillColor(context,  0.8, 0.0, 0.0, 1.0);
                        CGContextFillRect(context, CGRectMake(300 * (sqlite3_column_int(statement1, 0) * 1.0 / sqlite3_column_int(statement1, 2)), 0.0, 300 * ((sqlite3_column_int(statement1, 1) * 1.0 / sqlite3_column_int(statement1, 2))), 20));
                    }
                    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    BiletCommonStat.backgroundColor = [UIColor colorWithPatternImage:resultingImage];
                    [scrollView addSubview:BiletCommonStat];
                }
                else {
                    NSString *stat = [NSString stringWithFormat:@" 0 \t\t\t\t\t\t\t\t 0 "];
                    UILabel *BiletCommonStat = [[UILabel alloc] initWithFrame: CGRectMake(10, 30, 300, 20)];
                    BiletCommonStat.text = stat;
                    BiletCommonStat.textColor = [UIColor whiteColor];
                    UIGraphicsBeginImageContext(CGSizeMake(300, 20));
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    CGContextSetRGBFillColor(context,  0.0, 0.8, 0.0, 1.0);
                    CGContextFillRect(context, CGRectMake(0.0, 0.0, 300 * 0.5, 20));
                    CGContextSetRGBFillColor(context,  0.8, 0.0, 0.0, 1.0);
                    CGContextFillRect(context, CGRectMake(300 * 0.5, 0.0, 300 * 0.5, 20));
                    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    BiletCommonStat.backgroundColor = [UIColor colorWithPatternImage:resultingImage];
                    [scrollView addSubview:BiletCommonStat];
                }
            }
            sqlite3_finalize(statement1);
        }
        else {
            NSLog(@"Ne mogu vypolnit' zapros #1!");
        }
        UILabel *ThemeStatTitle = [[UILabel alloc] initWithFrame: CGRectMake(10, 80, 300, 40)];
        ThemeStatTitle.text = @"\tСтатистика правильности ответов по темам";
        ThemeStatTitle.textAlignment = NSTextAlignmentCenter;
        ThemeStatTitle.font = [UIFont italicSystemFontOfSize:11];
        [ThemeStatTitle sizeToFit];
        [scrollView addSubview:ThemeStatTitle];
        NSString *querySQL2 = [NSString stringWithFormat:@"SELECT themeNumber, SUM(rightCount), SUM(wrongCount), cast(SUM(rightCount) AS FLOAT) / cast ((SUM(rightCount) + SUM(wrongCount))AS FLOAT) as percent FROM paper_ab_theme_stat GROUP BY themeNumber ORDER BY percent DESC"];
        const char *query_stmt2 = [querySQL2 UTF8String];
        if (sqlite3_prepare_v2(_pdd_ab_stat, query_stmt2, -1, &statement2, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement2) == SQLITE_ROW) {
                NSString *stat = [NSString stringWithFormat:@" Тема №%d - %3.2f%%", sqlite3_column_int(statement2, 0), sqlite3_column_double(statement2, 3) * 100];
                UILabel *BiletStat = [[UILabel alloc] initWithFrame: CGRectMake(10, 110 + (i * 30), 300, 20)];
                BiletStat.text = stat;
                BiletStat.textColor = [UIColor whiteColor];
                UIGraphicsBeginImageContext(CGSizeMake(300, 20));
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextSetRGBFillColor(context,  0.0, 0.8, 0.0, 1.0);
                CGContextFillRect(context, CGRectMake(0.0, 0.0, 300 * sqlite3_column_double(statement2, 3), 20));
                CGContextSetRGBFillColor(context,  0.8, 0.0, 0.0, 1.0);
                CGContextFillRect(context, CGRectMake(300 * sqlite3_column_double(statement2, 3), 0.0, 300 * (1 - sqlite3_column_double(statement2, 3)), 20));
                UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                BiletStat.backgroundColor = [UIColor colorWithPatternImage:resultingImage];
                [scrollView addSubview:BiletStat];
                i++;
            }
            sqlite3_finalize(statement2);
        }
        else {
            NSLog(@"Ne mogu vypolnit' zapros #2!");
        }
        sqlite3_close(_pdd_ab_stat);
    }
    else {
        NSLog(@"Ne mogu ustanovit' soedinenie!");
    }
    [scrollView setContentSize:CGSizeMake(scrollView.bounds.size.width, scrollView.bounds.size.height + 30 * (i - 12))];
    [self.view addSubview:scrollView];
}

- (void)getExamenStatistics {
    NSString *docsDir;
    NSArray *dirPaths;
    NSString *databasePath;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"pdd_stat.sqlite"]];
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt *statement1, *statement2, *statement3;
    if (sqlite3_open(dbpath, &_pdd_ab_stat) == SQLITE_OK) {
        NSString *querySQL1 = [NSString stringWithFormat:@"SELECT SUM(rightCount), SUM(wrongCount), (SUM(rightCount)+SUM(wrongCount)) FROM paper_ab_examen_stat"];
        const char *query_stmt1 = [querySQL1 UTF8String];
        if (sqlite3_prepare_v2(_pdd_ab_stat, query_stmt1, -1, &statement1, NULL) == SQLITE_OK) {
            if (sqlite3_step(statement1) == SQLITE_ROW) {
                UILabel *ExCommonResultTitle = [[UILabel alloc] initWithFrame: CGRectMake(10, 2, 300, 40)];
                ExCommonResultTitle.textAlignment = NSTextAlignmentCenter;
                ExCommonResultTitle.numberOfLines = 2;
                ExCommonResultTitle.text = @" Общая статистика прохождения экзамена\nПравильных ответов\t\t\t  Неправильных ответов";
                ExCommonResultTitle.font = [UIFont italicSystemFontOfSize:11];
                [ExCommonResultTitle sizeToFit];
                [self.view addSubview:ExCommonResultTitle];
                if (sqlite3_column_int(statement1, 2) != 0) {
                    NSString *stat = [NSString stringWithFormat:@" %d \t\t\t\t\t\t\t\t %d ", sqlite3_column_int(statement1, 0), sqlite3_column_int(statement1, 1)];
                    UILabel *ExResult = [[UILabel alloc] initWithFrame: CGRectMake(10, 30, 300, 20)];
                    ExResult.text = stat;
                    ExResult.textColor = [UIColor whiteColor];
                    UIGraphicsBeginImageContext(CGSizeMake(300, 20));
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    CGContextSetRGBFillColor(context,  0.0, 0.8, 0.0, 1.0);//green
                    CGContextFillRect(context, CGRectMake(0.0, 0.0, 300 * (sqlite3_column_int(statement1, 0) * 1.0 / sqlite3_column_int(statement1, 2)), 20));
                    CGContextSetRGBFillColor(context,  0.8, 0.0, 0.0, 1.0);//red
                    CGContextFillRect(context, CGRectMake(300 * (sqlite3_column_int(statement1, 0) * 1.0 / sqlite3_column_int(statement1, 2)), 0.0, 300 * (sqlite3_column_double(statement1, 1) * 1.0 / sqlite3_column_int(statement1, 2)), 20));
                    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    ExResult.backgroundColor = [UIColor colorWithPatternImage:resultingImage];
                    [self.view addSubview:ExResult];
                }
                else {
                    NSString *stat = [NSString stringWithFormat:@" 0 \t\t\t\t\t\t\t\t 0 "];
                    UILabel *ExResult = [[UILabel alloc] initWithFrame: CGRectMake(10, 30, 300, 20)];
                    ExResult.text = stat;
                    ExResult.textColor = [UIColor whiteColor];
                    UIGraphicsBeginImageContext(CGSizeMake(300, 20));
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    CGContextSetRGBFillColor(context,  0.0, 0.8, 0.0, 1.0);//green
                    CGContextFillRect(context, CGRectMake(0.0, 0.0, 300 * 0.5, 20));
                    CGContextSetRGBFillColor(context,  0.8, 0.0, 0.0, 1.0);//red
                    CGContextFillRect(context, CGRectMake(300 * 0.5, 0.0, 300 * 0.5, 20));
                    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    ExResult.backgroundColor = [UIColor colorWithPatternImage:resultingImage];
                    [self.view addSubview:ExResult];
                }
            }
            sqlite3_finalize(statement1);
        }
        else {
            NSLog(@"Ne mogu vypolnit' zapros #1!");
        }
        NSString *querySQL2 = [NSString stringWithFormat:@"SELECT Count(*), Count(CASE WHEN rightCount>17 THEN 1 ELSE NULL END), (Count(*) - Count(CASE WHEN rightCount>17 THEN 1 ELSE NULL END)) FROM paper_ab_examen_stat"];
        const char *query_stmt2 = [querySQL2 UTF8String];
        if (sqlite3_prepare_v2(_pdd_ab_stat, query_stmt2, -1, &statement2, NULL) == SQLITE_OK) {
            if (sqlite3_step(statement2) == SQLITE_ROW) {
                if (sqlite3_column_int(statement2, 0) != 0) {
                    UILabel *ExTriesTitle = [[UILabel alloc] initWithFrame: CGRectMake(10, 80, 300, 40)];
                    ExTriesTitle.numberOfLines = 2;
                    ExTriesTitle.text = [NSString stringWithFormat:@"   Попыток прохождения экзаменационного теста : %d\nУспешных \t\t\t\t\t\t  Неуспешных", sqlite3_column_int(statement2, 0)];
                    ExTriesTitle.font = [UIFont italicSystemFontOfSize:11];
                    [ExTriesTitle sizeToFit];
                    [self.view addSubview:ExTriesTitle];
                    NSString *stat = [NSString stringWithFormat:@" %d \t\t\t\t\t\t\t\t\t %d ", sqlite3_column_int(statement2, 1), sqlite3_column_int(statement2, 2)];
                    UILabel *ExResult = [[UILabel alloc] initWithFrame: CGRectMake(10, 110, 300, 20)];
                    ExResult.text = stat;
                    ExResult.textColor = [UIColor whiteColor];
                    UIGraphicsBeginImageContext(CGSizeMake(300, 20));
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    CGContextSetRGBFillColor(context,  0.0, 0.8, 0.0, 1.0);//green
                    CGContextFillRect(context, CGRectMake(0.0, 0.0, 300 * (1 - (sqlite3_column_double(statement2, 2) * 1.0 / sqlite3_column_int(statement2, 0))), 20));
                    CGContextSetRGBFillColor(context,  0.8, 0.0, 0.0, 1.0);//red
                    CGContextFillRect(context, CGRectMake(300 * (1 - (sqlite3_column_double(statement2, 2) * 1.0 / sqlite3_column_int(statement2, 0))), 0.0, 300 * (sqlite3_column_double(statement2, 2) * 1.0 / sqlite3_column_int(statement2, 0)), 20));
                    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    ExResult.backgroundColor = [UIColor colorWithPatternImage:resultingImage];
                    [self.view addSubview:ExResult];
                    _bottomBestResult = ExResult.frame;
                }
                else {
                    UILabel *ExTriesTitle = [[UILabel alloc] initWithFrame: CGRectMake(10, 80, 300, 40)];
                    ExTriesTitle.numberOfLines = 2;
                    ExTriesTitle.text = [NSString stringWithFormat:@"   Попыток прохождения экзаменационного теста : 0\nУспешных \t\t\t\t\t\t  Неуспешных"];
                    ExTriesTitle.font = [UIFont italicSystemFontOfSize:11];
                    [ExTriesTitle sizeToFit];
                    [self.view addSubview:ExTriesTitle];
                    NSString *stat = [NSString stringWithFormat:@" 0 \t\t\t\t\t\t\t\t\t 0 "];
                    UILabel *ExResult = [[UILabel alloc] initWithFrame: CGRectMake(10, 110, 300, 20)];
                    ExResult.text = stat;
                    ExResult.textColor = [UIColor whiteColor];
                    UIGraphicsBeginImageContext(CGSizeMake(300, 20));
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    CGContextSetRGBFillColor(context,  0.0, 0.8, 0.0, 1.0);//green
                    CGContextFillRect(context, CGRectMake(0.0, 0.0, 300 * 0.5, 20));
                    CGContextSetRGBFillColor(context,  0.8, 0.0, 0.0, 1.0);//red
                    CGContextFillRect(context, CGRectMake(300 * 0.5, 0.0, 300 * 0.5, 20));
                    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    ExResult.backgroundColor = [UIColor colorWithPatternImage:resultingImage];
                    [self.view addSubview:ExResult];
                    _bottomBestResult = ExResult.frame;
                }
            }
            sqlite3_finalize(statement2);
        }
        else {
            NSLog(@"Ne mogu vypolnit' zapros #2!");
        }
        UILabel *ExBestResultTitle = [[UILabel alloc] initWithFrame: CGRectMake(0, _bottomBestResult.origin.y + 50, 300, 20)];
        ExBestResultTitle.textAlignment = NSTextAlignmentCenter;
        ExBestResultTitle.numberOfLines = 2;
        ExBestResultTitle.text = @"\tЛучшие результаты при прохождении экзамена\n   Ошибки     \t    Дата тестирования \t          Время ";
        ExBestResultTitle.font = [UIFont italicSystemFontOfSize:11];
        [ExBestResultTitle sizeToFit];
        [self.view addSubview:ExBestResultTitle];
        NSString *querySQL3 = [NSString stringWithFormat:@"SELECT rightCount, finishDate, startDate FROM paper_ab_examen_stat ORDER BY rightCount DESC, (finishDate-startDate) LIMIT 5"];
        const char *query_stmt3 = [querySQL3 UTF8String];
        if (sqlite3_prepare_v2(_pdd_ab_stat, query_stmt3, -1, &statement3, NULL) == SQLITE_OK) {
            int i = 0;
            while (sqlite3_step(statement3) == SQLITE_ROW) {
                int timeDiff = sqlite3_column_int(statement3, 1) - sqlite3_column_int(statement3, 2);
                NSString *minutes = [NSString stringWithFormat:@"%d", timeDiff / 60];
                NSString *seconds = [NSString stringWithFormat:@"%d", timeDiff % 60];
                NSUInteger myMinute = [minutes intValue];
                NSUInteger mySecond = [seconds intValue];
                if (myMinute < 10)
                    minutes = [NSString stringWithFormat:@"0%d", timeDiff / 60];
                if (mySecond < 10)
                    seconds = [NSString stringWithFormat:@"0%d", timeDiff % 60];
                NSString *exTime =  [NSString stringWithFormat:@"%@ : %@", minutes, seconds];
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_int(statement3, 1)];
                NSDateFormatter *date_formatter = [[NSDateFormatter alloc] init];
                [date_formatter setDateFormat:@"dd MMMM YYYY"];
                NSString *result = [date_formatter stringFromDate:date];
                NSString *stat2 = [NSString stringWithFormat:@" %d\t     |\t\t %@\t | %@ ", 20 - sqlite3_column_int(statement3, 0), result, exTime];
                UILabel *exBestResults = [[UILabel alloc] initWithFrame: CGRectMake(10, _bottomBestResult.origin.y + 80 + (30 * i), 300, 20)];
                exBestResults.text = stat2;
                exBestResults.textColor = [UIColor blackColor];
                exBestResults.layer.borderColor = [UIColor blackColor].CGColor;
                exBestResults.layer.borderWidth = 1.0;
                [exBestResults sizeToFit];
                [self.view addSubview:exBestResults];
                i++;
            }
            sqlite3_finalize(statement3);
        }
        else {
            NSLog(@"Ne mogu vypolnit' zapros #3!");
        }
        sqlite3_close(_pdd_ab_stat);
    }
    else {
        NSLog(@"Ne mogu ustanovit' soedinenie!");
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    switch (_index) {
        case 0:
            [self getBiletStatistics];
            break;
        case 1:
            [self getThemeStatistics];
            break;
        case 2:
            [self getExamenStatistics];
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end