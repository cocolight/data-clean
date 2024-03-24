# sqlite 相关方法

from sqlite3 import Error
from sqlite3 import connect

# 封装的sqlite3的一些基础方法
class SqliteBaseFuncs():
    def __init__(self,db_file_path) -> None:
        self.db_file_path = db_file_path
        self.conn = None
        self.cur = None

    # 建立连接，获得连接conn和游标cur
    def getDBConn(self):
        conn = None

        try:
            conn = connect(self.db_file_path)
            cur = conn.cursor()
        except Error as e:
            # print(e)
            raise Exception("连接sqlite出错，错误{}".format(e))

        if conn is not None:
            self.conn = conn
            self.cur = cur

    # 获取所有的表名
    def queryTable(self) -> list:
        self.cur.execute("select name from sqlite_master where type='table'")
        table_name = self.cur.fetchall()
        return table_name
    
    # 将queryTable读取的 数据库表名的[(gbk,)]的列表转化为['gbk']列表
    def queryTableList(self, tbs:list) -> list:
        res = []
        for tp in tbs:
            res.append(tp[0])
        return res

    # 读取指定表中的数据，返回二维列表
    def queryData(self, table_name:str, arraysize=0) -> list:
        # table_name='main'
        sql = 'select * from {}'.format(table_name)# 这里可能有安全问题，先这样
        self.cur.execute(sql)

        # 根据指定大小读取
        if arraysize == 0:
            return self.cur.fetchall()
        else:
            return self.cur.fetchmany(arraysize)

    # 返回指定名称的数据表的属性名称组成的list
    def queryTableColumnList(self, table_name:str) -> list:
        sql = "SELECT * FROM {}".format(table_name)
        self.cur.execute(sql)
        # self.cur.execute("SELECT * FROM {}".format(table_name))
        col_name_list = [tuple[0] for tuple in self.cur.description]
        return col_name_list

    # 获取指定表名的信息
    def getTableInfo(self, table_name:str):
        self.cur.execute("PRAGMA table_info({})".format(table_name))
        # print(self.cur.fetchall())

    # 关闭数据库，释放资源
    def closeDBConn(self):
        if self.cur is not None:
            self.cur.close() 
        if self.conn is not None:
            self.conn.close()



if __name__ == '__main__':
    file = r"D:\Users\yun_9\Downloads\gonggao.s3db"
    Sql = SqliteBaseFuncs(file)
    con = Sql.getDBConn()
    tables = Sql.queryTable()
    table = Sql.queryTableList(tables)
    # print(table)
    str = 'G334_clcp_zk'
    # S = Sql.queryData(str,1)
    S =Sql.queryTableColumnList(str)
    # S =Sql.getTableInfo(str)
    print(S)
    cls = Sql.closeDBConn()
