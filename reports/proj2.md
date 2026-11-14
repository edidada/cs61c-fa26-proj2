# CS61C Project2：CS61Classify

依据官方 [Part A](https://cs61c.org/fa26/projects/proj2/part-a/) 和 [Part B](https://cs61c.org/fa26/projects/proj2/part-b/) 实现九任务：绝对值、ReLU、首个最大值索引、带步长点积、学生覆盖测试、矩阵乘法、二进制读取/写入、两层网络分类。

## 实现

Part A 使用临时/参数寄存器，严格保留首个最大值。Part B 保存被调用者寄存器并保持16字节栈对齐。矩阵按行排列，乘法调用 dot，整数运算采用 RV32 的32位回绕语义。分类执行 m0×input、ReLU、m1×hidden、输出文件、argmax；成功路径释放所有五个分配块。

错误码依原接口顺序检查；读取额外拒绝非正维度及字节数溢出，返回29。成功读取返回的缓冲区归调用者负责释放。终止性错误路径直接 exit，未承诺恢复调用者状态或全量释放。

## 远端验证

独立分支 edidada/proj2，工作流 .github/workflows/proj2.yml 调用 scripts/verify_proj2.sh；可在具备 Java17/Python3 的环境执行相同脚本。Java 仅运行官方 Venus。工具来自 starter 指定的 Berkeley su24 地址，SHA256 固定为 69e48a8ffecb155d1227d171ae6888be0d3e103975d04b19762a08fc9463e1cc。

- 原46项测试完整执行，原 framework、unittests、utils、二进制输入/参考数据均不修改，原校验器继续检查。
- 学生17项覆盖测试，四个给定函数要求完整指令覆盖：abs_loss 24/24、initialize_zero 23/23、squared_loss 22/22、zero_one_loss 22/22。
- 原34项兼容内存检查的子集另开 -mc，包含重复分类 chain；调用约定检查由原框架默认启用。
- scripts/check_proj2.sh 中内嵌独立 Python oracle：36组矩形/符号极值/乘加溢出及源数组不变检查；read_matrix 返回缓冲区经保存 ra 的包装器释放；分类成功路径同时检查 memcheck。
- 16组生成的多列两层网络由独立循环计算全部输出，再比较完整二进制文件、返回标签、首个并列最大值、打印与静默路径。

原套件若全局开启 -mc，读取成功测试未释放返回块以及终止性错误注入会产生遗留分配文本；原框架拒绝任何额外 stderr。因此完整原套件与上述所有权明确的 memcheck 分开执行，没有修改框架、过滤警告或降低期望结果。尚不声称错误终止路径零泄漏。

运行证据通过 proj2-evidence 工件保存原始日志、工具哈希、提交号及实际生成的汇编。具体最终提交和 run 由 langnote 的永久 results.json 登记，必须同时确认运行终态与远端 HEAD。

本地未编译或模拟，没有新增 Python 源文件。校内身份、个人过程记录、Gradescope 和私有评分未验收；公开自学结果不替代这些要求。
