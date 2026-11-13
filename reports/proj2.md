# CS61C Project2：CS61Classify

依据官方 https://cs61c.org/fa26/projects/proj2/part-a/ 与 part-b/ 实现九任务：绝对值、ReLU、首个最大值索引、带步长点积、学生覆盖测试、矩阵乘法、二进制读取/写入、两层网络分类。

Part A 使用临时/参数寄存器；Part B 保存被调用者寄存器并保持16字节栈对齐。矩阵按行排列，乘法调用 dot，分类执行 m0×input、ReLU、m1×hidden、输出文件、argmax，成功路径释放所有五个分配块。错误码依原接口顺序检查；读取额外拒绝非正维度及字节数溢出。

验证尚未完成。独立分支 edidada/proj2，Actions 调用 scripts/verify_proj2.sh，使用原框架、原测试与原数据，不修改其校验哈希。Java 仅运行官方 Venus，不属于 Java 项目实现。原测试开启调用约定检查和 memcheck，学生测试要求四个给定函数指令全覆盖。本地不编译或模拟；未进行校内提交、个人过程记录或私有评分。
