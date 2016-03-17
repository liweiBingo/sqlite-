//
//  ViewController.m
//  sqlite使用
//
//  Created by jishubu0315 on 16/2/18.
//  Copyright © 2016年 jishubu0315. All rights reserved.
//

#import "ViewController.h"

#import <sqlite3.h>
#import "shopModel.h"
@interface ViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameText;
@property (weak, nonatomic) IBOutlet UITextField *phoneText;
@property (weak, nonatomic) IBOutlet UITableView *tableVIew;

/** sqlite 对象实例 */
@property (assign, nonatomic) sqlite3 * db;

/** 数据数组 */
@property (strong, nonatomic) NSMutableArray * shops;


@end

@implementation ViewController

- (NSMutableArray *)shops{
    if (_shops == nil) {
        _shops = [NSMutableArray array];
    }
    return _shops;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.tableVIew.delegate = self;
    self.tableVIew.dataSource = self;
    
    [self toIncreaseTheSearchBox];
    
    [self setupDb];
    [self setupData];
    
//    sqlite3_close(self.db)
    
    // Do any additional setup after loading the view, typically from a nib.
}
/**
 *  增加搜索框
 */
- (void)toIncreaseTheSearchBox{
    
    UISearchBar * searchBar = [[UISearchBar alloc]init];
    searchBar.frame =   CGRectMake(0, 0, 320, 44);
    searchBar.delegate = self;
    self.tableVIew.tableHeaderView = searchBar;
}

/**
 *  初始化数据库
 */
- (void)setupDb{
//    打开数据库
    NSString *fileName = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"shop.sqlite"];
    
//    如果不存在 就新建
    
    int status = sqlite3_open(fileName.UTF8String, &_db);
    
    if (status == SQLITE_OK) {
        NSLog(@"打开数据库成功");
        
//        创建
        const char *sql = "CREATE TABLE IF NOT EXISTS t_shop (id integer PRIMARY KEY ,  name text NOT NULL, phone text NOT NULL);";
        
        char *errmsg = NULL;
        sqlite3_exec(self.db, sql , NULL, NULL, &errmsg);
        if (errmsg) {
            NSLog(@"创建表失败======%s" ,errmsg);
        }
        
    }else{
        NSLog(@"打开失败");
        
    }
    
}
#pragma mark --
#pragma mark ---每次textField内容变化触发
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    [self.shops removeAllObjects];
    NSString *sql = [NSString stringWithFormat:@"SELECT name,phone FROM t_shop WHERE name LIKE '%%%@%%' OR  phone LIKE '%%%@%%' ;", searchText, searchText];
    // stmt是用来取出查询结果的
    sqlite3_stmt *stmt = NULL;
    // 准备
    int status = sqlite3_prepare_v2(self.db, sql.UTF8String, -1, &stmt, NULL);
    if (status == SQLITE_OK) { // 准备成功 -- SQL语句正确
        while (sqlite3_step(stmt) == SQLITE_ROW) { // 成功取出一条数据
            const char *name = (const char *)sqlite3_column_text(stmt, 0);
            const char *price = (const char *)sqlite3_column_text(stmt, 1);
            
            shopModel *shop = [[shopModel alloc] init];
            shop.name = [NSString stringWithUTF8String:name];
            shop.phone = [NSString stringWithUTF8String:price];
            [self.shops addObject:shop];
        }
    }
    
    [self.tableVIew reloadData];
    
}
/**
 *  查询数据 打开默认显示全部
 */
- (void)setupData{
    const char *sql ="SELECT name , phone FROM t_shop;";
//    stmt 用来查询数据
    sqlite3_stmt * stmt = NULL;
    
//    准备
    int status = sqlite3_prepare_v2(self.db, sql, -1, &stmt, NULL);
    if (status == SQLITE_OK) {//准备成功 SQL语句正确
        while (sqlite3_step(stmt) == SQLITE_ROW) { //成功取出数据
            const char *name = (const char *)sqlite3_column_text(stmt, 0);
            const char *phone = (const char*)sqlite3_column_text(stmt, 1);
            
            shopModel * shop = [[shopModel alloc]init];
            shop.name = [NSString stringWithUTF8String:name];
            shop.phone = [NSString stringWithUTF8String:phone];
            [self.shops addObject:shop];
        }
    }
    NSLog(@"%@ -------", self.shops);
}

/**
 *  增加数据
 *
 *  @param sender
 */
- (IBAction)insert:(id)sender {
    
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO t_shop(name, phone) VALUES ('%@','%@');",self.nameText.text, self.phoneText.text];
    sqlite3_exec(self.db, sql.UTF8String , NULL, NULL, NULL);
    
    //刷新
    shopModel * shop = [[shopModel alloc]init];
    shop.name = self.nameText.text;
    shop.phone = self.phoneText.text;
    [self.shops addObject:shop];
    [self.tableVIew reloadData];
    
    
}

#pragma mark -- tableViewDelegate 素偶

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.shops.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 44;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * cellIden = @"shop";
    UITableViewCell * cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIden ];
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIden];
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    shopModel *shop = self.shops[indexPath.row];
    cell.textLabel.text = shop.name;
    cell.textLabel.textColor = [UIColor redColor];
    
    cell.detailTextLabel.text = shop.phone;
    return cell;
    
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end










