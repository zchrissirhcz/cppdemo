# Shared Memory IPC Example

Minimal inter-process communication using shared memory for Windows and Linux.

## Principle

1. **writer** process creates named shared memory, writes data, waits for user input
2. **reader** process opens the same shared memory, reads data

## Core API

### Windows

- `CreateFileMappingA()` - Create named shared memory
- `OpenFileMappingA()` - Open existing shared memory
- `MapViewOfFile()` - Map to process address space
- `UnmapViewOfFile()` / `CloseHandle()` - Cleanup

### POSIX (Linux/Mac)

- `shm_open()` - Create/open shared memory object
- `ftruncate()` - Set shared memory size
- `mmap()` - Map to process address space
- `munmap()` - Unmap from address space
- `shm_unlink()` - Remove shared memory object

## Run

```bash
# Terminal 1
./writer
Writer: Wrote message "Hello from writer process!"
Writer: Press Enter to exit...

# Terminal 2
./reader
Reader: Got message "Hello from writer process!"
```
