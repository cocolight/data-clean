# 文件相关方法

import json
import os
# import platform
# import subprocess
try:
    from pandasfuncs import DataFuncs
    from sqlitefuncs import SqliteBaseFuncs
except Exception as e:
    from lib.sqlitefuncs import SqliteBaseFuncs
    from lib.pandasfuncs import DataFuncs


# 和文件读写有关的方法
class FileBaseFuncs():

    # 读取conf.json文件，返回json内容
    def _readJson(self, f_path:str='./conf.json') -> dict:
        try:
            with open(f_path,'r',encoding='utf8') as fp:
                json_data:dict = json.load(fp)
            return json_data
        except Exception as e:
            raise e

    # 写入json文件，返回1-成功，0-失败
    def _writeJson(self):
        pass

    # 读取excel
    def _readExcel(self):
        pass# 调用pandas tools

    # 写入xlsx文件
    def _writeExcel(self):
        pass # 调用 pandas 方法

    # 获取执行文件所在文件夹路径
    def _getParentPath(self) -> str:
        parent_path = os.path.split(os.path.realpath(__file__))[0]
        ls = parent_path.split('\\')
        ls.pop()

        main_path = ''
        for i in ls:
            if ls.index(i) == 0:
                main_path = os.path.join(main_path, i, '\\')
            else:
                main_path = os.path.join(main_path, i)
        return main_path

    # 获取当前用户的桌面路径
    def _getDesktop(self) -> str:
        from winreg import OpenKey,QueryValueEx
        from winreg import HKEY_CURRENT_USER
        key = OpenKey(HKEY_CURRENT_USER,r'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders')
        return QueryValueEx(key, "Desktop")[0]

    # 获取路径文件的文件名
    def _getFileName(self, file:str) -> str:
        s = file.split('/')[-1]
        return str(s)

    # 获取路径文件的文件后缀
    def _getFileType(self, fname:str) -> str:
        s = fname.split('.')[-1]
        return str(s)
    
    # 合并路径
    def _combinePath(self, *args):
        res = ''
        for i in args:
            res =os.path.join(res,i)
        return res

    # 判断指定路径文件是否存在
    def _fileExit(self, f_path:str) -> bool:
        if os.path.isfile(f_path):
            return os.path.exists(f_path)
        else:
            return False
            
    # 判断指定路径文件夹是否存在
    def _folderExit(self, folder_path:str):
        if os.path.isdir(folder_path):
            return os.path.exists(folder_path)
        else:
            return False

    # 判断文件是否可读,可写，可执行
    def _fileIsReadWriteExecute(self, f_path:str) ->tuple:
        read = os.access(f_path,os.R_OK)
        write = os.access(f_path,os.W_OK)
        execute = os.access(f_path,os.X_OK)
        return (read,write,execute)

    # 使用系统默认程序打开指定路径文件
    def _openFileWithDefultApp(self, f_path:str)->bool:
        import platform
        import subprocess
        sys_type = platform.system()
        os_type = ('Windows','Linux','Darwin')
        result = False
        try:
            if sys_type == os_type[0]:
                os.startfile(f_path)
            elif sys_type == os_type[1]:
                subprocess.call(['xdg-open',f_path])
            elif sys_type == os_type[2]:
                subprocess.call(['open',f_path])
            result =  True
        except Exception as e:
            raise e
        finally:
            return result
                
    # 用默认浏览器打开网页
    def _openWebWithDefultApp(self, url:str)->bool:
        import webbrowser
        result = False
        try:
            webbrowser.open(url, new=1, autoraise=True) 
            result =  True
        except Exception as e:
            raise e
        finally:
            return result

    # 指定应用程序打开文件
    def _openFileWithSelectedApp(self, exe_path:str, f_path:str):
        r_v = 0
        try:
            r_v = os.system(exe_path + ' ' + f_path)
        except Exception as e:
            raise e
        finally:
            return r_v

# 对FileBaseFunc类的进一步组合封装
class FileFuncs(FileBaseFuncs):

    def __init__(self) -> None:
        super().__init__()

    # 读取文件,返回{gk_zk":dataframe}
    def readFile(self, f_path:str, f_type:str=None, sheets:list=None) -> dict:
        result_table = {}

        #判断文件类型，赋值给 f_type
        if f_type is None:
            f_type = self._getFileType(f_path)
        else:
            pass

        pd = DataFuncs()

        # 判断文件格式，选择对应方法读取
        if f_type.lower() == 'xlsx':
            res = pd.readData(f_type,f_path, sheets)
            result_table.update(res)
        elif f_type.lower() == 'db3':
            try:
                sql = SqliteBaseFuncs(f_path)
                conn = sql.getDBConn()
                for tb_name in sheets:
                    col_title = sql.queryTableColumnList(tb_name)
                    col_value = sql.queryData(tb_name)
                    tb_value = pd._convert2Df(col_value,col_title)
                    tb_value = pd._delNullRow(tb_value)
                    result_table.update({tb_name:tb_value})
            except Exception as e:
                raise e
            finally:
                cls = sql.closeDBConn()
            del conn,cls
        else:
            pass

        return result_table

    def readConf(self, conf_path='conf.json'):
        main_path = self._getParentPath()
        conf_path = self._combinePath(main_path,'conf',conf_path)
        return self._readJson(conf_path)

    # 写入文件，excel {gk_zk":dataframe}
    def writeFile(self, dic:dict, file:str):
        pd = DataFuncs()
        pd.writeFile(dic, file, 'xlsx')

    # 获取配置文件路径

    # 打开文件
    def openFile(self, f_path:str=None, exe_path:str=None):
        result = False
        if exe_path is None and f_path is not None:
            if 'http' in f_path:
                result = self._openWebWithDefultApp(url=f_path)
            else:
                result = self._openFileWithDefultApp(f_path)
        elif exe_path is None and f_path is None:
                dir_path = self._getParentPath()
                exe_path = self._combinePath(dir_path,'3pt\\ndd\\Notepad.exe')
                f_path = self._combinePath(dir_path,'conf','conf.json')
                result = self._openFileWithSelectedApp(exe_path,f_path)
        elif exe_path is not None and f_path is not None:
            result = self._openFileWithSelectedApp(exe_path,f_path)
        else:
            pass
        return result

if __name__ =='__main__':
    # FileFuncs().readConf('s')
    FileFuncs().openFile('http://www.baidu.com')


