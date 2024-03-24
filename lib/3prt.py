import os
# main = "Notepad.exe"
# params = r'F:\Qt6\vsc\data\docs\readme.json'
# r_v = os.system(main + ' ' + params)
# print(r_v)

class ThirdPartTools():
    
    def __init__(self) -> None:
        pass

    # 调用第三方程度打开文件
    def thirdPartExeOpenFile(self, main:str, params:str):
        param = ''
        for i in params:
            param = param + i 
        r_v = os.system(main, param)
        return r_v