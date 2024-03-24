# 一、功能介绍

读取公告库数据，并按规则清洗匹配，导出`xlsx`。

⚠️**本软件只能读取工信部公告数据库（将`conf.json`文件的`ftype`设置成`db3`），和excel文件（将`conf.json`文件的`ftype`设置成`xlsx`）**

## 1.1、使用方法

🎉一共两步：1. 配置 `conf.json`	2. 启动程序

**配置说明：**

1. **Process** [string]：程序执行方式
   + modify：修改表的内容，不改变表的范围大小
   + relations：修改表的大小，会改变表的大小，主要是表之间的集合运算
   + analyse：表的数据分析，透视，聚类等（version ≥ 1.0）
2. **Run.How** [dict]：对表的处理
   + modify 模式下
     + ReplaceAll：替换整个单元格
     + ReplacePart：替换部分字符
     + UserDefine：用户自定义处理脚本（version ≥ 0.9）
   + realtions 模式下
     + extract：摘取选定的表，改变表的范围
     + match：两个表关联匹配
     + UserDefine：用户自定义处理脚本（version ≥ 0.9）

**配置文件：**📄**conf.json**

```json
// 配置key不区分大小写
{
    "inputFiles": [
        {
            "f_path": "D:\\Downloads\\gonggao.s3db",
            "ftype": "db3",
            "sheets": [
                "G366_clcp_zk"
            ]
        },
        {
            "f_path": "D:\\Downloads\\gonggao.s3db",
            "ftype": "db3",
            "sheets": [
                "G366_chpdpk_zk"
            ]
        }
    ],
    "outputFile": "D:\\Downloads\\output.xlsx",
    "1":{
		"Process":"modify", // modify：修改；relations：修改表的范围；analyse：数据分析
        "SaveResult": "false",
        "SaveFileAlias": "底盘", // SaveResult 为 true 条件下，这个必填
        "SheetName": ["G366_clcp_zk"], // 只能填一个
        "Select":[	// 逻辑 与 
                {"column":"底盘型号","value":["null"],"logic":"nan","reverse":"0"}, // 判断是否为空，reverse表示取反
                {"column":"底盘品牌","value":["东风牌"],"logic":"contain","reverse":"0"}, // 包含
                {"column":"底盘型号","value":["ZZ1257N"],"logic":"equal","reverse":"0"}, // 等于
                {"column":"底盘型号","value":["DF1185"],"logic":"notequal","reverse":"0"}, // 不等于
                {"column":"整备质量","value":["18000"],"logic":"more","reverse":"0"}, // 大于
                {"column":"整备质量","value":["25000"],"logic":"less","reverse":"0"}, // 小于
                {"column":"整备质量","value":["25000"],"logic":"min less","reverse":"0"}, // 多值单元格最小值小于value
				{"column":"整备质量","value":["25000"],"logic":"min equal","reverse":"0"}, // 多值单元格最小值等于value
				{"column":"整备质量","value":["25000"],"logic":"min more","reverse":"0"}, // 多值单元格最小值大于value
				{"column":"整备质量","value":["25000"],"logic":"max less","reverse":"0"}, // 多值单元格最大值小于value
				{"column":"整备质量","value":["25000"],"logic":"max equal","reverse":"0"}, // 多值单元格最小值等于value
				{"column":"整备质量","value":["25000"],"logic":"max more","reverse":"0"}, // 多值单元格最大值大于value
            ], 
        "Run":{	// 处理逻辑
            "How":"ReplaceAll", // 类型 ReplaceAll:指定列替换，保留原表;ReplacePart:替换其中的字符; UserDefine:自定义脚本，这几个使用时只能保留一个
            "ReplaceAll":[ // replaceall 读取这个
                {"column":"列名","valueafter":"替换值"},
                {"column":"列名","valueafter":"替换值"}
            ],
        	"ReplacePart":[ // replacePart 读取这个
        		{"column":"列名","valueBefore":"","valueafter":"替换值"},
        		{"column":"列名","valueBefore":"","valueafter":"替换值"}
            ],

			"UserDefine":{ // 用户自定义脚本处理
				"path":"脚本路径",
				"other":""// 没想好，可能是一些预处理
			}
        }
    },
    "2":{
		"Process":"relations", // relations：修改表的范围
        "SaveResult": "false",
        "SaveFileAlias": "底盘", // SaveResult 为 true 条件下，这个必填
        "SheetName": ["G366_clcp_zk"], // 只能填一个
        "Run":{	// 处理逻辑
            "How":"Extract", //  extract:摘取，仅保留选定数据；match:两表匹配；UserDefine:自定义脚本
        	"Extract":{ // extract 读这个
				"rows":[
                {"column":"车辆型号","value":["null"],"logic":"nan","reverse":"1"},
                {"column":"中文品牌","value":["东风牌","中集"],"logic":"contain","reverse":"0"}, 
                {"column":"车辆名称","value":["随车起重运输车"],"logic":"equal","reverse":"0"}, 
                {"column":"车辆型号","value":["DFZ5251JSQSZ6D"],"logic":"notequal","reverse":"0"}
                ],
                "columns":{ // 留空则不对列进行删除，remain和delete不可以同时设置
                    "remain":[],
                    "delete":[]
                }
    		},
			"Match":{
				"how":"right" ,// 默认，用户不要更改，inner 表示取交集
                "targetcolumn":"", // G366_clcp_zk 中要匹配的列名
                "sheets":[
				{"sheet":"","column": "", "appendColumns":[]},//sheet是表名，column只能填1个,appendColumns是指从columns中合并过来的列
                ]
			},
			"UserDefine":{ // 用户自定义脚本处理
				"path":"脚本路径",
				"other":""// 没想好，可能是一些预处理
			}
        }
    },
    "3":{
		"Process":"analyse", // analyse：数据分析（这个功能没想好怎么写）
        "SaveResult": "false",
        "SaveFileAlias": "底盘", // SaveResult 为 true 条件下，这个必填
        "SheetName": ["G366_clcp_zk"], // 
        "Select":[	// 逻辑 与 
            ], 
        "Run":{	// 处理逻辑
            "How":"ReplaceAll", // 
			"UserDefine":{ // 用户自定义脚本处理
				"path":"脚本路径",
				"other":""// 没想好，可能是一些预处理
			}
        }
    }
}
```



## 1.2、使用举例

1. 修改表中某些字段：选择**G366_clcp_zk**表中**车辆型号**列中不为空，且**中文品牌**中包含`东风牌`或`中集`，车辆名称等于`随车起重运输车`，车辆型号不等于`DFZ5251JSQSZ6D`的行，将**英文品牌**列中所有的`阿里`替换成`腾讯`，表大小不变

```
"1":{
		"Process":"modify", 
        "SaveResult": "true",
        "SaveFileAlias": "底盘", 
        "SheetName": ["G366_clcp_zk"], 
        "Select":[	
                {"column":"车辆型号","value":["null"],"logic":"nan","reverse":"1"},
                {"column":"中文品牌","value":["东风牌","中集"],"logic":"contain","reverse":"0"}, 
                {"column":"车辆名称","value":["随车起重运输车"],"logic":"equal","reverse":"0"}, 
                {"column":"车辆型号","value":["DFZ5251JSQSZ6D"],"logic":"notequal","reverse":"0"}
            ], 
        "Run":{	
            "How":"ReplacePart", 
            "ReplacePart":[ 
                {"column":"英文品牌",
                    "valueBefore": "阿里",
                    "valueafter": "腾讯"}
            ]
        }
    }
```

2. 将**G366_clcp_zk**表中**车辆型号**列中不为空，且**中文品牌**中包含`东风牌`或`中集`，车辆名称等于`随车起重运输车`，车辆型号不等于`DFZ5251JSQSZ6D`的行，列名为`CPNO`，`企业`，`ID`，`车辆型号`，`车辆名称`，`中文品牌`，`英文品牌`，`识别代号`的列组成一个新表

```
"1":{
		"Process":"relations", 
        "SaveResult": "true",
        "SaveFileAlias": "底盘", 
        "SheetName": ["G366_clcp_zk"], 
        "Run":{	
            "How":"Extract", 
            "Extract":{
                "rows": [
                {
                    "column": "车辆型号",
                    "value": [
                        "null"
                    ],
                    "logic": "nan",
                    "reverse": "1"
                },
                {
                    "column": "中文品牌",
                    "value": [
                        "东风牌",
                        "中集"
                    ],
                    "logic": "contain",
                    "reverse": "0"
                },
                {
                    "column": "车辆名称",
                    "value": [
                        "随车起重运输车"
                    ],
                    "logic": "equal",
                    "reverse": "0"
                },
                {
                    "column": "车辆型号",
                    "value": [
                        "DFZ5251JSQSZ6D"
                    ],
                    "logic": "notequal",
                    "reverse": "0"
                }
                ],
                "columns": {
                    "remain": ["CPNO","企业ID","车辆型号","车辆名称","中文品牌","英文品牌","识别代号"]
                }
            }
        }
    }
```

3. 将**G366_chpdpk_zk**表按`底盘型号`匹配**G366_clcp_zk**表`车辆型号`列，并且将**G366_chpdpk_zk**的`底盘型号`，`底盘类别`，`产品名称`，`产品商标`，`批次`列添加到**G366_chpdpk_zk**中

```
    "1":{
		"Process":"relations", 
        "SaveResult": "true",
        "SaveFileAlias": "底盘", 
        "SheetName": ["G366_clcp_zk"], 
        "Run":{	
            "How":"Match", 
            "Match":{
                "how": "right", 
                "targetcolumn": "车辆型号",
                "sheets": [
                    {
                        "sheet": "G366_chpdpk_zk",
                        "column": "底盘型号",
                        "appendColumns": ["底盘型号","底盘类别","产品名称","产品商标","批次"]
                    }
                ]
            }
        }
    }
```



## 1.3、更新计划



### TODO:

- [x] 1. 读取文件增加错误捕捉（2023-1-13 :heavy_check_mark:）
- [x] 2. 读取**sqlite3**增加错误捕捉（2023-1-13 :heavy_check_mark:）
- [x] 3. debug **sqlite3** 的数据读取（2023-1-14 :heavy_check_mark:）
- [ ] 4. 修改报错方式，需要不阻碍程序执行
- [ ] 5. 增加**GUI**
- [ ] 6. 增加`conf.json`配置校验功能
- [ ] 7. 增加配置文件映射，不直接将配置文件的变量传递到函数中，增加安全性
- [x] 8. ~~增加新能源标识（2023-1-17 :heavy_check_mark:）~~
- [x] 9. 增加区间筛选功能，可以划分区间（2023-1-19 :heavy_check_mark:）
- [x] 10. 增加值替换功能，全部替换，部分字符替换（2023-2-16 :heavy_check_mark:）
- [ ] 11. 增加日志记录，可设置开/关
- [x] 12. path 读取相关方法使用  `os.path` 方法重构一下（2023-2-16 :heavy_check_mark:）
- [ ] 13. 优化`tables`，不然步骤多了会很大 -> 根据配置文件设定的清洗顺序，可以根据实际执行进度优化 **tables** 的大小
- [x] 14. 根据需要保留某个步骤输出的表（2023-1-14 :heavy_check_mark:）
- [x] 15. 修复筛选删除包含字符串无法过滤`Nan`值报错（2023-1-14 :heavy_check_mark:）
- [ ] 16. 增加文件是否存在判断，读取
- [ ] 17. 所有的逻辑中`how`可以调用**自定义的函数脚本**，方便个人按需添加处理逻辑
- [ ] 18. 优化性能
- [x] 19. 内置一个**json**编辑器，默认启动（2023-2-5 :heavy_check_mark:）
- [x] 20. 针对**删除**功能，增加how，和bool，增加条件筛选功能，多条件筛选确定（2023-2-16 :heavy_check_mark:）
- [ ] 21. 增加`select`中可以筛选行索引的功能

### BUG：



# 二、二次开发



## 2.1、项目结构

```markdown
├─ 📁3pt	// 第三方工具
├─ 📁build 	// 安装包
│  ├─ 📁{app}
│  ├─ 📁{code}
│  ├─ 📁{lang}
│  ├─ 📁{output}
│  ├─ 📁{psd}
│  ├─ 📁{snap}
│  ├─ 📁{tmp}
│  ├─ 📄MySetup.ico	// 安装包图标
│  ├─ 📄MySetup.iss	// Inno Setup Compiler 脚本
│  └─ 📄README.md
├─ 📁conf		// 配置文件
├─ 📁extend		// 扩展插件
├─ 📁gui 		// gui文件
├─ 📁lib 		// 程序文件
├─ 📁log		// log文件夹
└─ 📄main.py	// 主入口
```



## 2.2、环境安装

```shell
pip install -r requirements.txt
```



## 2.3、打包exe

```shell
python -m nuitka --standalone --enable-plugin=pyside6 --plugin-enable=upx --nofollow-import-to=numpy --nofollow-import-to=openpyxl --nofollow-import-to=pandas --nofollow-import-to=xlsxwriter --include-data-file=./conf/conf.json=./conf/ --include-data-file=./docs/使用说明.md=./ --include-data-dir=./3pt=./3pt --windows-icon-from-ico=./build/MySetup.ico --remove-output --output-dir='./build/{app}/ex_x86' main.py
```



## 2.4、制作安装包

使用 Inno Setup Compiler 打开`setup.iss`文件，修改其中的`[Files]`下的路径为上一步生成的文件夹，执行打包即可。

# 参考引用

1. [Inno Setup WizardForm简介._静以修身](https://blog.csdn.net/lossed1990/article/details/9491751)：介绍了 WizardForm 的 14 种页面
2. [互联网风格安装程序.wangwenx190](https://github.com/wangwenx190/installer)：完整的可运行的项目，我主要的参考
3. [Inno Setup界面美化.Suarezz](https://www.cnblogs.com/suxia/p/14167606.html)：介绍了 Inno Setup 的流程
4. [Inno Setup打包美化.码客](https://www.psvmc.cn/article/2022-09-21-innosetup-beautify.html)：从头构建了一个美化项目，有注解，较详细
5. [MinecraftInstaller.Iseason2000](https://github.com/Iseason2000/MinecraftInstaller)：没看
6. [Beautiful-InnoSetup-Demo.linxinfa](https://www.codenong.com/cs108995508/)：从头构建了一个项目，有注解，较详细
7. [互联网软件的安装包界面设计-Inno setup.沉森心](https://blog.csdn.net/oceanlucy/article/details/50033773)：有流程图，有注释，较详细
