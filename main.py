from lib.filefuncs import FileFuncs
from lib.pandasfuncs import GonggaoFuncs
import collections



def main():

    print("[1/7]>打开配置文件...")

    # FileFuncs().openFile()

    print("[2/7]>读取配置文件...")

    # 读取conf.json文件，返回json内容
    conf:dict = FileFuncs().readConf()

    del_item_key = []

    print("[3/7]>读取数据表...")

    # 读取所有文件的表返回
    tables = {}
    tables = collections.OrderedDict()
    for file in conf["inputFiles"]:

        for sheet in file["sheets"]:
            del_item_key.append(sheet)

        f_tables = FileFuncs().readFile(f_path=file['f_path'],f_type=file["ftype"], sheets=file['sheets'])
        tables.update(f_tables)

    print("[4/7]>正在清洗数据，耗时较长，取决于文件大小")

    # 开始数据清洗
    for i in range(1,len(conf)-2+1):
        conf_item = conf[str(i)]
        item_sheet_name = conf_item['SheetName'][0]
        item_sheet = tables[item_sheet_name]
        item_run = conf_item['Run']
        res = None
        if conf_item['Process'] == 'modify':
            item_select = conf_item['Select']
            if len(item_select) != 0:
                res_selected = GonggaoFuncs().multiTermsSelectCells(item_select,item_sheet)
                res = GonggaoFuncs().modifyCells(res_selected,item_run,item_sheet)
            else:
                res = item_sheet
        elif conf_item['Process'] == 'relations':
            if item_run['How'].lower() == 'match':
                res = GonggaoFuncs().match2Sheets(item_run,item_sheet,tables)
            elif item_run['How'].lower() == 'extract':
                res = GonggaoFuncs().extractCells(item_run,item_sheet)
        elif conf_item['Process'] == 'analyse':
            pass
        tables.update({str(i):res})


    print("[5/7]>清理冗余数据...")

    # 设置表的别名


    for i in range(1,len(conf)-2+1):
        save_result = conf[str(i)]["SaveResult"]
        save_file_alias = conf[str(i)]["SaveFileAlias"]

        if save_result.lower() == "false":
            del_item_key.append(str(i))
        elif save_result.lower() == "true":
            tables[save_file_alias] = tables.pop(str(i))

    output_file = conf["outputFile"]

    for key in del_item_key:
        del tables[key]

    print("[6/7]>清洗完毕，正在写入表格...")
    
    FileFuncs().writeFile(tables, output_file)

    print("[6/7]>写入完毕！")
    input()


if __name__ =='__main__':
    main()