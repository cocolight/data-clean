import pandas as pd
import numpy as np
from typing import TypeVar
import collections


# 定义的泛型
NUMBER_OR_STRING = TypeVar('NUMBER_OR_STRING', int, float, str)
LIST_OR_NDARRAY = TypeVar('LIST_OR_NDARRAY', list, np.ndarray)
LIST_AND_TUPLE = TypeVar("LIST_AND_TUPLE",list,tuple)

# 基础方法类
class PandasBaseFuncs():
# ============================================================== #
# 方法名称带有Cells的为对一列的操作，带Cell的为对一个单元格的操作;    #
# 1.筛选功能 2.执行功能 3.读写功能 4.数据转换功能 5.预处理            #
# =============================================================== #

    def __init__(self) -> None:
        pass

    #======预处理，单表============================================================================================================================    


    #======筛选功能，单表============================================================================================================================

    # 列操作，判断指定列的cell是否为null,返回是 bool 列
    def _selectCellsIsNull(self, df:pd.DataFrame, column:str):
        return df[column].map(lambda var : pd.isnull(var))

    # 列操作，判断指定列的cell是否包含指定字符，返回是 bool 列，str 支持正则，需要相应设置regex
    def _selectCellsCotainsStr(self, df:pd.DataFrame, column:str, var:str, regex = False):
        return df[column].str.contains(var, na=False, regex=regex)

    # 列操作，判断指定列的cell是否等于指定字符，返回是 bool 列
    def _selectCellsEqStr(self, df:pd.DataFrame, column:str, var:NUMBER_OR_STRING):
        return df[column].eq(var)

    # 列操作，判断指定列的cell是否不等于指定字符，返回是 bool 列
    def _selectCellsNeStr(self, df:pd.DataFrame, column:str, var:NUMBER_OR_STRING):
        return df[column].ne(var)

    # 列操作，判断指定列的cell是否大于指定数字，返回是 bool 列
    def _selectCellsExceedNum(self, df:pd.DataFrame, column:str, num:float):
        return df[column] > num

    # 列操作，判断指定列的cell是否小于指定数字，返回是 bool 列
    def _selectCellsLessNum(self, df:pd.DataFrame, column:str, num:float):
        return df[column] < num
    
    # 选择某几列，离散

    # 选择某几列，连续

    # 选择某几行，离散

    # 选择某几行，连续

    # cell操作，获取一个多值单元格的min与max (数值类型)
    def _getMultiValueCellMaxAndMin(self, cell_values:str, sept=","):
        str_ls = cell_values.split(sept)
        
        def ints(str_ls):
            ls = []
            for str in str_ls:
                if str.isdigit():
                    ls.append(str)
            return list(map(int, ls))

        int_ls = ints(str_ls)
        int_ls.sort()
        min = int_ls[0]
        max = int_ls[-1]

        return min, max
    
    #======执行功能，单表===========================================================================================================================

    # 删除指定的列
    def _delColumns(self, df:pd.DataFrame, columns:list) -> pd.DataFrame:
        return df.drop(columns=columns, axis=1)
    
    # 删除所有的空行，所有的换行符由“,”替代
    def _delNullRow(self, df:pd.DataFrame) -> pd.DataFrame:
        df.dropna(how='all', inplace=True)
        df = df.fillna(np.NaN)
        df = df.replace({r"\r": ",", r"\n": ",", "\t": "", ";": ",", " ": ""}, regex=True)
        return df

    # 保留满足条件的行和列组成的表
    def _remainCells(self, df:pd.DataFrame, rows_ifs=None, columns:list=[])->pd.DataFrame:
        if rows_ifs is None and len(columns)==0:
            return df
        elif rows_ifs is None and len(columns)!=0:
            return df.loc[:,columns]
        elif rows_ifs is not None and len(columns)==0:
            return df.loc[rows_ifs]
        elif rows_ifs is not None and len(columns)!=0:
            return df.loc[rows_ifs,columns]
        else:
            pass


    # # 保留指定列名的表
    # def _remainColumns(self, df:pd.DataFrame, columns:list) -> pd.DataFrame:
    #     return  df.loc[:,columns]
    
    # # 保留满足条件的行
    # def _remainRows(self, df:pd.DataFrame, ifs):
    #     return  df.loc[ifs]

    # 替换指定列部分字符,replace_str(被替换字符，替换字符)
    def _strReplace(self, df:pd.DataFrame, ifs, column:str, str_before:str, str_after:str) -> pd.DataFrame:
        result_df = df
        result_df.loc[ifs,[column]] = result_df.loc[ifs][column].str.replace(str_before, str_after)
        return result_df
    
    # 修改满足条件的列的单元格内容
    def _modifyCells(self, df:pd.DataFrame, ifs, column:str, replace_str:str):
        result_df = df
        result_df.loc[ifs,[column]] = replace_str
        return result_df

    #======读写功能，单表===========================================================================================================================

    # 读取xlsx文件指定的sheet页，为None则全读，返回{sheet name:ls}
    def _readXlsx(self, xlsx:str, sheet_names:list=None, engine:str='openpyxl') -> dict:
        try:
            sheets = pd.read_excel(xlsx, sheet_name=sheet_names, index_col=False, engine=engine)
            return sheets
        except Exception as e:
            raise e

    # 读取csv文件，分隔符为‘;’
    def _readCsv(self, csv, sep=';', low_memory=True, encoding="utf8"):
        return pd.read_csv(csv, sep=sep, low_memory=low_memory, encoding=encoding)

    # 将dataframe组成的字典写入target_filePath路径的文件中，格式为xlsx
    def _write2Xlsx(self, df_dics:dict, target_filePath:str, engine='xlsxwriter') -> None:
        writer = pd.ExcelWriter(target_filePath)

        try:
            for key, value in df_dics.items():
                value.to_excel(writer, sheet_name=key, engine=engine, index=False)
        except Exception as e:
            raise e
        finally:
            writer.close()

    #======数据转换功能，单表=======================================================================================================================

    # 数组去重
    def _lsUnique(ls:LIST_OR_NDARRAY, is_list:False):
        ndary = ls
        if isinstance(ls, list):
            ndary = np.array(ls)

        unique_ndary = np.unique(ndary)

        if is_list:
            unique_ls = unique_ndary.tolist()
        else:
            unique_ls = unique_ndary

        return unique_ls

    # 转化一个二维list为一个dataframe格式
    def _convert2Df(self,table_ls:list, columns:LIST_AND_TUPLE=None) -> pd.DataFrame:
        return pd.DataFrame(table_ls, columns=columns)

    # 转化dataframe为一个二维list
    def _convert2Ls(self, df:pd.DataFrame) -> list:
        ndary = np.array(df.values)
        ndary = np.insert(ndary, 0, df.columns, axis=0)
        ls = ndary.tolist()
        return ls

    #======数据转换功能，表间=======================================================================================================================
    
    # 按how指定方式，匹配合并两df表，
    def _merge2Df(self,original_df:pd.DataFrame, target_df:pd.DataFrame, left_on=None, right_on=None, how='right'):
        return pd.merge(original_df, target_df, left_on=left_on, right_on=right_on, how=how)

    # 纵向连接连个列名一样的表
    def _concat2Df(self,dfs:list, join='outer', sort=False) -> pd.DataFrame:
        return pd.concat(dfs, ignore_index=True, sort=sort, join=join).drop_duplicates()



# 基础实现类
class DataFuncs(PandasBaseFuncs):
# ============================================================== #
# 对配置文件的读取，解析，分配方法，这里放通用数据分析的方法         #
# ============================================================== #
    
    def __init__(self) -> None:
        super().__init__()

    # 文件数据表读取
    def readData(self, f_type:str, f_path:str, sheets:list=None, sep:str=';'):
        result = None
        if f_type.lower() == 'xlsx':
            result = self._readXlsx(f_path,sheet_names=sheets)
        elif f_type.lower() == 'csv':
            result = self._readCsv(f_path,sep=sep)
        else:
            pass
        return result
    
    # 文件写入，xlsx、csv
    def writeFile(self, dic:dict, file:str, f_type:str):
        if f_type.lower() == 'xlsx':
            self._write2Xlsx(dic,file)
        elif f_type.lower() == 'csv':
            pass # 还没写好
        else:
            pass

    #======对单个表的操作=======================================================================================================================

    # 多值单元格筛选，数字，返回 bool 
    def _rangeCompare(self, df:pd.DataFrame, logic:str, column:str, value:float)->bool:
        result_bool = None

        # 比较函数
        def compare(ordered_value:list):
            min_value = None
            max_value = None
            
            if ordered_value is np.nan:
                return False
            else:
                min_value = float(ordered_value[0])
                max_value = float(ordered_value[-1])
        
                if logic == 'min less':
                    if min_value < float(value):
                        return True
                    else:
                        return False
                elif logic == 'min equal':
                    if min_value == float(value):
                        return True
                    else:
                        return False
                elif logic == 'min more':
                    if min_value > float(value):
                        return True
                    else:
                        return False
                elif logic == 'max less':
                    if max_value < float(value):
                        return True
                    else:
                        return False
                elif logic == 'max equal':
                    if max_value == float(value):
                        return True
                    else:
                        return False
                elif logic == 'max more':
                    if max_value > float(value):
                        return True
                    else:
                        return False

        # 按最大最小排序，输出最大最小值   
        def multiValueSort(value):
            if pd.isnull(value):
                return np.nan
            else:
                ordered_seires = list(set(value.split(',')))
                ordered_seires.sort()
                if '' in ordered_seires:
                    ordered_seires.remove('')
                return ordered_seires

        # 读取要比较的列，返回series
        result_bool = None
        series = df[column]

        # 获取最大最小值 series
        ordered_seires = series.map(multiValueSort)
        # 比较条件 返回bool
        result_bool = ordered_seires.map(compare)

        return result_bool

    # 多条件筛选
    def multiTermsSelectCells(self, select:list, df:pd.DataFrame):
        result = df
        
        # 调用筛选函数
        def cbk(df,logic,column,value,reverse):
            res = None
            if logic == 'nan':
                res = self._selectCellsIsNull(df,column)
            elif logic == 'contain':
                res = self._selectCellsCotainsStr(df,column,value)
            elif logic == 'equal':
                res = self._selectCellsEqStr(df,column,value)
            elif logic == 'notequal':
                res = self._selectCellsNeStr(df,column,value)
            elif logic == 'more':
                res = self._selectCellsExceedNum(df,column,float(value))
            elif logic == 'less':
                res = self._selectCellsLessNum(df,float(value))
            else:
                t = ['min less','min equal','min more','max less','max equal','max more']
                if logic in t:
                    res = self._rangeCompare(df,logic,column,float(value))
                else:
                    pass

            return res

        select_result = None
        item_select_result = None
        # 组合条件
        for item in select:
            item_select_result = None
            for value in item['value']:
                if item_select_result is None:
                    item_select_result = cbk(result,item['logic'],item['column'],value,item['reverse'])
                else:
                    tmp = cbk(result,item['logic'],item['column'],value,item['reverse'])
                    item_select_result = item_select_result | tmp
            if item['reverse'] == '1':
                item_select_result = ~item_select_result
            if select_result is None:
                select_result = item_select_result
            else:
                select_result = select_result & item_select_result
            pass

        return select_result

    #======表与表之间的操作=======================================================================================================================
    # 表匹配合并 match
    def match2Sheets(self,run:dict, target_df:pd.DataFrame, dfs:dict):
        result = target_df
        # 根据指定列，根据how方法，将源表匹配到目标表，how为outer时，取并集
        match_type = run['Match']['how']
        target_column = run['Match']['targetcolumn']
        for item in run['Match']['sheets']:
            table_name = item['sheet']
            original_df = self._remainCells(dfs[table_name],None,item['appendColumns'])
            result = self._merge2Df(original_df,result,item['column'],target_column,match_type)
        return result
    
    # 表摘取符合条件的行和列
    def extractCells(self, run:dict, target_df:pd.DataFrame):
        result = target_df
        row_ifs = run['Extract']['rows']
        ifs  = self.multiTermsSelectCells(row_ifs,result)
        # columns 只能有一个 remain 或者 delete，在上级程序处理吧
        if list(run['Extract']['columns'].keys())[0] == 'delete':
            column_delete = run['Extract']['columns']['delete']
            result = self._delColumns(result,column_delete)
            result = self._remainCells(result,ifs)
        elif list(run['Extract']['columns'].keys())[0] == 'remain':
            column_remain = run['Extract']['columns']['remain']
            result = self._remainCells(result,ifs,column_remain)
        else:
            pass

        return result


    # 追加合并
    def extendDf(self, df_list:list, columns:list, logics:dict):
        df =df_list[0]
        for k,v in columns.items():
            df.rename(columns={k,v},inplace=True)
        return self._concat2Df([df,df_list[1]], join="inner")


    # 处理表
    def modifyCells(self, ifs, run:dict, df:pd.DataFrame):
        result = df
        if run['How'] == 'ReplaceAll':
            for item in run['ReplaceAll']:
                result = self._modifyCells(result,ifs,item['column'],item['valueafter'])
        elif run['How'] == 'ReplacePart':
            for item in run['ReplacePart']:
                result = self._strReplace(result,ifs,item['column'],item['valueBefore'],item['valueafter'])
        elif run['How'] == 'UserDefine':
            pass
        pass
        return result


# 针对公告库封装的方法
class GonggaoFuncs(DataFuncs):
# ============================================================== #
# 对配置文件的读取，解析，分配方法，这里放针对工信部公告库封装的方法 #
# ============================================================== #

    def __init__(self) -> None:
        super().__init__()


