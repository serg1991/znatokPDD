//
//  ThemeChildViewController.m
//  ZnatokPDD
//
//  Created by Sergey Kiselev on 29.03.14.
//  Copyright (c) 2014 Sergey Kiselev. All rights reserved.
//

#import "ThemeChildViewController.h"

@interface ThemeChildViewController ()

@end

@implementation ThemeChildViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _mainArray = [self getAnswers];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    _flashTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(indicator:) userInfo:nil repeats:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [_flashTimer invalidate];
}

- (void)indicator:(BOOL)animated {
    [self.tableView flashScrollIndicators];
}

- (void)showComment {
    NSUInteger arrayCount = _mainArray.count;
    NSString *comment = [NSString stringWithFormat:@"%@ \n Правильный ответ - %d.", _mainArray[arrayCount - 1], [_mainArray[arrayCount - 2] intValue]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Подсказка"
                                                    message:comment
                                                   delegate:self
                                          cancelButtonTitle:@"ОК"
                                          otherButtonTitles:nil];
    alert.tag = 1;
    [alert show];
}

- (void)showTitleComment {
    NSUInteger arrayCount = _mainArray.count;
    NSString *comment = [NSString stringWithFormat:@"%@", _mainArray[arrayCount - 1]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Подсказка"
                                                    message:comment
                                                   delegate:self
                                          cancelButtonTitle:@"ОК"
                                          otherButtonTitles:nil];
    alert.tag = 2;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        NSDictionary *theInfo = [NSDictionary dictionaryWithObjectsAndKeys:self.wrongAnswersArray, @"wrongAnswersArray", nil];
        if (![self.wrongAnswersArray containsObject:[NSNumber numberWithLong:_themeCount]] ) {
            if (!buttonIndex) {
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"ClosedComment"
                 object:self
                 userInfo:theInfo];
            }
        } else {
            if (!buttonIndex) {
                double delayInSeconds = 0.5;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self performSegueWithIdentifier:@"ResultTheme" sender:self];
                });
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSUInteger)section {
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
        int height =  (_imageView.image == 0) ? 0 : 285;
        return height;
    } else {
        int height =  (_imageView.image == 0) ? 0 : 118;
        return height;
    }
}

- (NSMutableArray *)getAnswers {
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"pdd.sqlite"];
    const char * dbpath = [defaultDBPath UTF8String];
    sqlite3_stmt *statement;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    if (sqlite3_open(dbpath, &_pdd_ab) == SQLITE_OK) {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT RecNo, Picture, Question, Answer1, Answer2, Answer3, Answer4, Answer5, RightAnswer, Comment FROM paper_ab WHERE QuestionType = \"%d\" LIMIT 1 OFFSET \"%lu\"", (int)_themeNumber + 1, (unsigned long)_index];
        const char * query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(_pdd_ab, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            if (sqlite3_step(statement) == SQLITE_ROW) {
                NSData *picture = [[NSData alloc] initWithBytes:sqlite3_column_blob(statement, 1) length: sqlite3_column_bytes(statement, 1)];
                _imageView.image = [UIImage imageWithData:picture];
                for (int i = 2; i < 10; i++) {
                    if (sqlite3_column_text(statement, i) != NULL) {
                        NSString *arrayelement = [[NSString alloc]
                                                  initWithUTF8String:
                                                  (const char *) sqlite3_column_text(statement, i)];
                        [array addObject:arrayelement];
                    }
                }
                sqlite3_finalize(statement);
            } else {
                NSLog(@"Rezultatov net!");
            }
        } else {
            NSLog(@"Ne mogu vypolnit' zapros!");
        }
        sqlite3_close(_pdd_ab);
    } else {
        NSLog(@"Ne mogu ustanovit' soedinenie!");
    }
    return array;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSUInteger)numberOfSectionInTableView:(UITableView *)tableView {
    return 1;
}

- (NSUInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSUInteger)section {
    return _mainArray.count - 2;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger rowNumber = [indexPath row];
    if ([self.rightAnswersArray containsObject:[NSNumber numberWithLong:_index + 1]] ) { // делаю красиво, если пользователь возвращается к вопросу, на который уже правильно ответил
        self.tableView.allowsSelection = NO;
        if (rowNumber == [_mainArray[_mainArray.count - 2] intValue]) { // если ответ правильный
            cell.contentView.backgroundColor = [UIColor colorWithRed:0 / 255.0f green:152 / 255.0f blue:70 / 255.0f alpha:1.0f];
        }
    } else if ([self.wrongAnswersArray containsObject:[NSNumber numberWithLong:_index + 1]] ) { // делаю красиво, если пользователь возвращается к вопросу, на который уже НЕправильно ответил
        long questnum = [self.wrongAnswersArray indexOfObject:[NSNumber numberWithInteger:_index + 1]];
        self.tableView.allowsSelection = NO;
        if (rowNumber != [_mainArray[_mainArray.count - 2] intValue] && [NSNumber numberWithLong:rowNumber] == [NSNumber numberWithInt:[[self.wrongAnswersSelectedArray objectAtIndex:questnum] intValue]]) {  // если ответ НЕправильный
            cell.contentView.backgroundColor = [UIColor colorWithRed:236 / 255.0f green:30 / 255.0f blue:36 / 255.0f alpha:1.0f];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSUInteger rowNumber = [indexPath row];
    if (rowNumber == 0) {
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [self showTitleComment];
    } else {
        if (rowNumber == [_mainArray[_mainArray.count - 2] intValue]) { // если ответ правильный
            cell.contentView.backgroundColor = [UIColor colorWithRed:0 / 255.0f green:152 / 255.0f blue:70 / 255.0f alpha:1.0f];
            self.tableView.allowsSelection = NO;
            [self.rightAnswersArray addObject:[NSNumber numberWithLong:_index + 1]];
            NSDictionary *theInfo = [NSDictionary dictionaryWithObjectsAndKeys:self.rightAnswersArray, @"rightAnswersArray", nil];
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"AnsweredRight"
             object:self
             userInfo:theInfo];
        } else { // если ответ неправильный
            if ([settings boolForKey:@"needVibro"]) {
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate); // вибрация при неправильном ответе
            }
            cell.contentView.backgroundColor = [UIColor colorWithRed:236 / 255.0f green:30 / 255.0f blue:36 / 255.0f alpha:1.0f];
            self.tableView.allowsSelection = NO;
            [self.wrongAnswersArray addObject:[NSNumber numberWithLong:_index + 1]];
            [self.wrongAnswersSelectedArray addObject:[NSNumber numberWithLong:rowNumber]];
            NSDictionary *theInfo = [NSDictionary dictionaryWithObjectsAndKeys:self.wrongAnswersArray, @"wrongAnswersArray", nil];
            if ([settings boolForKey:@"showComment"]) {
                [self showComment];
            } else {
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"AnsweredWrong"
                 object:self
                 userInfo:theInfo];
            }
        }
    }
    NSUInteger wrongCount = _wrongAnswersArray.count;
    NSUInteger rightCount = _rightAnswersArray.count;
    if (rightCount + wrongCount == _themeCount) {
        [self writeStatisticsToBase];
        [self getResultOfTest];
    }
}

- (void)getResultOfTest {
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    if (![self.wrongAnswersArray containsObject:[NSNumber numberWithLong:_themeCount]] ) {
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self performSegueWithIdentifier:@"ResultTheme" sender:self];
        });
    }
}

- (void)writeStatisticsToBase {
    NSString *docsDir;
    NSArray *dirPaths;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    NSString *defaultDBPath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"pdd_stat.sqlite"]];
    const char * dbpath = [defaultDBPath UTF8String];
    sqlite3_stmt *statement;
    NSDate *date = [[NSDate alloc] init];
    _finishDate = [date timeIntervalSince1970];
    if (sqlite3_open(dbpath, &_pdd_ab_stat) == SQLITE_OK) {
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO paper_ab_theme_stat(themeNumber, rightCount, wrongCount, startDate, finishDate) VALUES ('%d', '%d', '%d', '%11.0f', '%11.0f')", (int)_themeNumber + 1, (int)_rightAnswersArray.count, (int)_wrongAnswersArray.count, _startDate, _finishDate];
        const char * insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(_pdd_ab_stat, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
        } else {
            NSLog(@"Zapis' proizvedena neuspeshno");
        }
        sqlite3_finalize(statement);
        sqlite3_close(_pdd_ab_stat);
    } else {
        NSLog(@"Ne mogu ustanovit' soedinenie!");
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ResultTheme"]) {
        ResultViewController *detailViewController = [segue destinationViewController];
        detailViewController.type = 1;
        detailViewController.themeName = _themeName;
        detailViewController.themeNumber = (int)_themeNumber;
        detailViewController.themeCommon = (int)_rightAnswersArray.count + (int)_wrongAnswersArray.count;
        detailViewController.rightCount = (int)_rightAnswersArray.count;
        detailViewController.time = _finishDate - _startDate;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger rowNumber = [indexPath row];
    static NSString * CellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    if (rowNumber == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont italicSystemFontOfSize:15.0];
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
            cell.textLabel.font = [UIFont italicSystemFontOfSize:30.0];
        }
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.text = [NSString stringWithFormat:@"Вопрос %d / %d \n %@", _index + 1, _themeCount, _mainArray[0]];
        cell.textLabel.numberOfLines = 0;
    } else {
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
            cell.textLabel.font = [UIFont systemFontOfSize:30.0];
        }
        cell.textLabel.text = [NSString stringWithFormat:@"%ld. %@", (long)rowNumber, _mainArray[rowNumber]];
        cell.textLabel.numberOfLines = 0;
    }
    UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
    backView.backgroundColor = [UIColor clearColor];
    cell.backgroundView = backView;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                              cell.textLabel.font, NSFontAttributeName,
                                              nil];
        CGRect textLabelSize = [cell.textLabel.text boundingRectWithSize:kExamenLabelFrameMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributesDictionary context:nil];
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
            textLabelSize = [cell.textLabel.text boundingRectWithSize:kExamenLabelIpadFrameMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributesDictionary context:nil];
        }
        cell.textLabel.frame = CGRectMake(5, 5, textLabelSize.size.width, textLabelSize.size.height);
        return cell;
    } else {
        CGSize textLabelSize = [cell.textLabel.text sizeWithFont:cell.textLabel.font
                                               constrainedToSize:kExamenLabelFrameMaxSize
                                                   lineBreakMode:NSLineBreakByWordWrapping];
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
            textLabelSize = [cell.textLabel.text sizeWithFont:cell.textLabel.font
                                            constrainedToSize:CGSizeMake(740.0, 200.0)
                                                lineBreakMode:NSLineBreakByWordWrapping];
        }
        cell.textLabel.frame = CGRectMake(5, 5, textLabelSize.width, textLabelSize.height);
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger rowNumber = [indexPath row];
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) { // ipad
        if (rowNumber == 0) { // question
            NSString *textLabel = [NSString stringWithFormat:@"Вопрос %d / %d \n %@", _index + 1, _themeCount, _mainArray[0]];
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.alignment = NSTextAlignmentCenter;
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
                NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                      style, NSParagraphStyleAttributeName,
                                                      [UIFont italicSystemFontOfSize:30.0f],  NSFontAttributeName,
                                                      nil];
                CGRect textLabelSize = [textLabel boundingRectWithSize:kExamenLabelIpadFrameMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributesDictionary context:nil];
                return kExamenDifference + textLabelSize.size.height;
            } else {
                CGSize textLabelSize = [textLabel sizeWithFont:[UIFont fontWithName:@"Helvetica" size:30.0f]
                                             constrainedToSize:kExamenLabelIpadFrameMaxSize
                                                 lineBreakMode:NSLineBreakByWordWrapping];
                return kExamenDifference + textLabelSize.height;
            }
        } else { // answers
            NSString *textLabel = [NSString stringWithFormat:@"%ld. %@", (long)rowNumber, _mainArray[rowNumber]];
            NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [UIFont systemFontOfSize:30.0f], NSFontAttributeName,
                                                  nil];
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
                CGRect textLabelSize = [textLabel boundingRectWithSize:kExamenLabelIpadFrameMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributesDictionary context:nil];
                return kExamenDifference + textLabelSize.size.height + 4;
            } else {
                CGSize textLabelSize = [textLabel sizeWithFont:[UIFont fontWithName:@"Helvetica" size:30.0f]
                                             constrainedToSize:kExamenLabelIpadFrameMaxSize
                                                 lineBreakMode:NSLineBreakByWordWrapping];
                return kExamenDifference + textLabelSize.height - 1;
            }
        }
    } else { // iphone
        if (rowNumber == 0) { // question
            NSString *textLabel = [NSString stringWithFormat:@"Вопрос %d / %d \n %@", _index + 1, _themeCount, _mainArray[0]];
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.alignment = NSTextAlignmentCenter;
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
                NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                      style, NSParagraphStyleAttributeName,
                                                      [UIFont italicSystemFontOfSize:15.0f],  NSFontAttributeName,
                                                      nil];
                CGRect textLabelSize = [textLabel boundingRectWithSize:kExamenLabelFrameMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributesDictionary context:nil];
                return kExamenDifference + textLabelSize.size.height - 16;
            } else {
                CGSize textLabelSize = [textLabel sizeWithFont:[UIFont fontWithName:@"Helvetica" size:15.0f]
                                             constrainedToSize:CGSizeMake(300.0, 200.0)
                                                 lineBreakMode:NSLineBreakByWordWrapping];
                return kExamenDifference + textLabelSize.height - 16;
            }
        } else { // answers
            NSString *textLabel = [NSString stringWithFormat:@"%ld. %@", (long)rowNumber, _mainArray[rowNumber]];
            NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [UIFont systemFontOfSize:15.0f], NSFontAttributeName,
                                                  nil];
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
                CGRect textLabelSize = [textLabel boundingRectWithSize:kExamenLabelFrameMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributesDictionary context:nil];
                return kExamenDifference + textLabelSize.size.height - 1;
            } else {
                CGSize textLabelSize = [textLabel sizeWithFont:[UIFont fontWithName:@"Helvetica" size:15.0f]
                                             constrainedToSize:CGSizeMake(300.0, 200.0)
                                                 lineBreakMode:NSLineBreakByWordWrapping];
                return kExamenDifference + textLabelSize.height - 1;
            }
        }
    }
}

@end
