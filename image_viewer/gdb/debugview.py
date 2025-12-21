import gdb
import socket
import struct

class DebugViewCommand(gdb.Command):
    """Send cv::Mat to image viewer
    Usage: debugview <variable_name>
    """
    
    def __init__(self):
        super(DebugViewCommand, self).__init__("debugview", gdb.COMMAND_USER)
    
    def invoke(self, arg, from_tty):
        var_name = arg.strip()
        if not var_name:
            print("Usage: debugview <variable>")
            return
        
        try:
            # 获取变量
            var = gdb.parse_and_eval(var_name)
            
            # 读取 cv::Mat 成员
            rows = int(var['rows'])
            cols = int(var['cols'])
            flags = int(var['flags'])
            data_ptr = int(var['data'])
            
            if rows == 0 or cols == 0:
                print("Invalid image dimensions")
                return
            
            # 解析 CV 类型
            channels = ((flags >> 3) & 511) + 1
            depth = flags & 7
            cv_type = depth + ((channels - 1) << 3)
            
            # 计算数据大小
            data_size = rows * cols * channels
            
            # 读取内存
            inferior = gdb.selected_inferior()
            data = inferior.read_memory(data_ptr, data_size)
            
            # 连接到查看器
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.connect(('localhost', 9999))
            
            # 发送头部和数据
            header = struct.pack('III', cols, rows, cv_type)
            sock.sendall(header + bytes(data))
            sock.close()
            
            print(f"✓ Sent: {cols}x{rows}, {channels}ch")
            
        except gdb.error as e:
            print(f"GDB error: {e}")
        except Exception as e:
            print(f"Error: {e}")

# 注册命令
DebugViewCommand()
print("✓ Command 'debugview' loaded (GDB)")