# 其他方法

from os import path
from numpy import array,unique

# 自己封装的一些方法
class Tool():
    # 获取当前时间，返回YYYY-MM-DD HH:MM:SS
    def timeNow(tp:str='A') -> str:
        from time import strftime
        now = None

        if tp == 'A':
            now = strftime("%Y-%m-%d %H:%M:%S")
        elif tp == 'Y':
            now = strftime("%Y-%m-%d-%H-%M-%S")
        return '{}'.format(now)

    # 返回CSS标记的字体
    def colorText(str:str, color='red'):
        return "<font color='{}' blod>{}</font>".format(color, str)



    # 将输入路径合并
    def combinePath(*args) -> str:
        res = ''
        for i in args:
            res += i
        return res



    # 移除字符串头尾指定的字符（默认为空格）或字符序列
    def stripAll(str:str) -> None:
        str = str.strip()


    # 元祖转为字典
    def tupleTodic(tp:tuple) -> dict:
        dic = {}
        for i in tp:
            dic[i] = ''
        return dic


    def get2DLsOneColContains(ls:list, col_name:str):
        index = ls[0].index(col_name)
        ndary = array(ls)
        rls = ndary[:,index]
        rls = rls.tolist()
        return rls




if __name__ == '__main__':

    pass