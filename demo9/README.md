# demo9: 纯 C++ 去畸变（无第三方库）

这个 demo 只依赖 C++ 标准库：
- 读取/写入二进制 PPM(P6) 图像
- 使用 pinhole + Brown 畸变模型 (k1 k2 p1 p2 k3)
- 输出同尺寸去畸变结果（可能出现黑边）

## 构建

在仓库根目录：

```bash
cmake -S . -B build
cmake --build build -j
```

产物一般在：`build/demo9/demo9`（或类似路径）。

## 运行

```bash
./build/demo9/demo9 undistort input.ppm output.ppm params.txt
```

`params.txt` 格式（空白分隔，`#` 可写注释）：

```txt
# fx fy cx cy
800 800 320 240
# k1 k2 p1 p2 k3
-0.2 0.03 0 0 0
```

## 说明（关键映射）

对输出图像每个像素 (u,v)：
1) 归一化：x=(u-cx)/fx, y=(v-cy)/fy
2) 做“正向畸变”：(x,y)->(xd,yd)
3) 回到输入像素：us=fx*xd+cx, vs=fy*yd+cy
4) 在输入图像 (us,vs) 双线性采样

为什么用“正向畸变”？
- 因为输出像素是规则网格，逐像素找它在输入图里的来源更自然，避免空洞。
