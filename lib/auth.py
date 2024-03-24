# Windows Registry Editor Version 5.00

# [HKEY_CLASSES_ROOT\Python.File\shell\runas]
# "HasLUAShield"=""

# [HKEY_CLASSES_ROOT\Python.File\shell\runas\command]
# @="x:\……\python.exe \"%1\" %*"

# uac是在程序运行前检测的。


import ctypes, sys

class Auth():

    def is_admin(self):# 判断是否是管理员
        try:
            return ctypes.windll.shell32.IsUserAnAdmin()
        except:
            return False

    def privileges(self):# 提权
        ctypes.windll.shell32.ShellExecuteW(None, "runas", sys.executable, __file__, None, 1)

if __name__ =='__main__':
  
    A = Auth()

    if A.is_admin():
        # Code of your program here
        print('is admin')
    else:
        # Re-run the program with admin rights
        print('请以管理员权限运行')
        A.privileges()