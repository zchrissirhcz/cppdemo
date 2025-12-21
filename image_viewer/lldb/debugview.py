import lldb
import socket
import struct

def send_image(debugger, command, result, internal_dict):
    target = debugger.GetSelectedTarget()
    process = target.GetProcess()
    frame = process.GetSelectedThread().GetSelectedFrame()
    
    var_name = command.strip()
    if not var_name:
        print("Usage: debugview <variable>")
        return
    
    var = frame.FindVariable(var_name)
    if not var.IsValid():
        print(f"Variable '{var_name}' not found")
        return
    
    try:
        rows = var.GetChildMemberWithName('rows').GetValueAsUnsigned()
        cols = var.GetChildMemberWithName('cols').GetValueAsUnsigned()
        flags = var.GetChildMemberWithName('flags').GetValueAsUnsigned()
        data_ptr = var.GetChildMemberWithName('data').GetValueAsUnsigned()
        
        channels = ((flags >> 3) & 511) + 1
        depth = flags & 7
        cv_type = depth + ((channels - 1) << 3)
        
        data_size = rows * cols * channels
        error = lldb.SBError()
        data = process.ReadMemory(data_ptr, data_size, error)
        
        if error.Fail():
            print(f"Memory read error: {error}")
            return
        
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.connect(('localhost', 9999))
        header = struct.pack('III', cols, rows, cv_type)
        sock.sendall(header + data)
        sock.close()
        
        print(f"✓ Sent: {cols}x{rows}, {channels}ch")
    except Exception as e:
        print(f"Error: {e}")

def __lldb_init_module(debugger, internal_dict):
    debugger.HandleCommand('command script add -f debugview.send_image debugview')
    print('✓ Command "debugview" loaded')