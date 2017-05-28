# nihserver

Multi-threaded web server written in pure assembly for x86 64-bit Linux.

The [NIH](https://en.wikipedia.org/wiki/Not_invented_here) aspect (no libraries or high-level languages) was mostly a learning exercise. No libraries means no libc, so no dynamic linker, no thread or mutex library, and no nice high-level functions like `malloc()`, `printf()`, or `main()`.

But why? I think programmers know how these things are implemented in theory but it's always interesting to go and see for yourself. The assembly part is still pretty pointless, because you can always link asm-critical code into an existing application. But there are claims that writing assembly is good for the soul.

Overall it's ~5k lines of x86-64 asm.

## Requirements

- 64-bit Linux
- nasm
- make

## Quick Start

1. Install dependencies, e.g. `sudo apt install -y nasm make` on Ubuntu.

2. Clone the repo. From the base directory: `make`. The executable is placed in `target/nihserver/nihserver`.

3. Run it. Usage is `nihserver [port] [web_directory] [num_threads]`.

    For example `target/nihserver/nihserver 8000 . 768`.

    Then navigate to e.g. http://localhost:8000/README.md in your browser.

    Navigating to a directory will try to find `index.html` in that directory, and responds with it if it's a regular file.

    Output should look something like:

    ```
    $ target/nihserver/nihserver 8000 . 768
    Starting server with {
        "port": 8000,
        "web_directory": ".",
        "num_threads": 768
    }
    Listening on [0.0.0.0:8000] (fd 3)
    Accepted connection from [192.168.114.1:49745] (fd 4)
    [192.168.114.1:49745] (fd 4) -> /README.md
    200 OK (9273 bytes) -> [192.168.114.1:49745] (fd 4)
    Accepted connection from [192.168.114.1:49746] (fd 5)
    [192.168.114.1:49746] (fd 5) -> /favicon.ico
    404 Not Found (14 bytes) -> [192.168.114.1:49746] (fd 5)
    ```

    `Segmentation fault (core dumped)`, on the other hand, I have never even heard of. What is it? Is it from Haskell?

## Notes

Without libraries, all we get is the kernel. Luckily the 64-bit Linux API has everything we want. [Here](http://blog.rchapman.org/posts/Linux_System_Call_Table_for_x86_64/) is a table of all the syscalls you can make.

We put the syscall number in `rax` and then use the `syscall` instruction to make the call. Be careful, though. The calling convention is not the same as with normal functions (`rdi`, `rsi`, `rdx`, `rcx`, `r8`, `r9`, stack), because the `syscall` instruction puts the return address inside `rcx` (as opposed to the stack) before context switching into the kernel. `rcx` is then used by `syscallret` on return. Since `rcx` is in use, the 4th argument has to be put into `r10` instead.
Details are in [here](https://software.intel.com/sites/default/files/article/402129/mpx-linux64-abi.pdf).

This is not the same thing as with the 32-bit Linux API, which exists for backwards-compatibility. That's accessed via `int 0x80` as opposed to `syscall`, and the syscall numbers are completely different. The 32-bit calling convention is different too.

### `main(int argc, char **argv)`

On Linux, programs start in `_start()`. libc normally provides the `_start` symbol in `crt0.o` or `crt1.o` etc. depending on platform, which we link into our program (`crt` is short for C runtime). You can see these `crt*.o` files get linked if you use your compiler with the verbose flag. libc's `_start()` does a bunch of stuff like read `argc` and `argv` from the stack, do shared library init, etc. Then it calls `exit(main(argc, argv))`.

We can do the args part by reading `argc` from `[rsp + 8]`, and then `argv[0]`, `argv[1]`, etc. from `[rsp + 16]`, `[rsp + 24]`, etc. onwards. `argv` is just `&argv[0]`, aka `rbp + 16`. And `gdb` shows me that there's a null ptr at `argv[argc]`, but let's not go to such dangerous places.

`_start()` should never return. There is no return address on the stack anyway, so it's either death or glory.

### File / Network I/O

This is pretty standard, just in assembly. All of the libc `socket()`, `bind()` `listen()`, `accept()`, `read()`, `write()`, `open()`, `close()` stuff is almost just raw syscalls anyway. The only difference is that the syscalls return `-errno` on error as opposed to `-1` and setting `errno`. So we can have solid error handling too.

Having a bunch of threads blocked on `accept()` consumes a file desc for each of them, which can lead to fd exhaustion errors. That gives us massive CPU usage if `accept()`ing in a loop, so on error it probably helps to `nanosleep()` for a few seconds and log it when this happens. `num_threads` equal to about 3/4 of `max_files` seems good.

I didn't dare use events and async I/O. So due to blocking I/O and 1 thread per connection, this server will probably fall over after about 10k concurrent connections (like Apache).

### Memory

We can mostly sidestep this issue. It's really hard to write a thread-safe general-purpose allocator. I guess you would normally do that by using `brk()` to increase the bottom memory boundary (the edge of the heap), and then using free lists, thread locals, synchronisation, etc.

The longest things to keep in memory are the path to the web directory, which is limited to 8,192 bytes, and the request URI (`/README.md` or whatever), which is limited to 2,048 bytes. We also want to be able to concat them together and concat `index.html` onto the end with a null-terminator. So we just make sure threads have about 32 Ki of stack space and allocate 16 Ki on the stack and be done with that. Blocking I/O makes it really easy to just keep everything on the
stack.

There's one case where we are forced to use dynamic allocation, and it's when allocating stacks for new threads, which is next. But luckily we don't need a general-purpose allocator for that.

### Threading

In Linux, threads are just processes but with a shared address space, file desc table, virtual memory table, signal handlers, etc. You can start such processes with `clone()`, which is similar to `fork()`, but takes a stack to use and lets you specify which parts of the process to share.

We allocate stack space by using `mmap()`, which simply allocates `len` bytes of page-boundary-aligned memory when passing the `MAP_ANONYMOUS` flag. Then we can call `clone()` with a pointer to this memory + `len` - `sizeof(void *)`. Two processes return out of `clone()`, with the child's tid returned in the parent's call and 0 in the child's call, similar to `fork()`.

The child's stack pointer `rsp` is simply set to the pointer passed to `clone()`. Be careful if using your own wrapper function for `clone()` like I did, which results in the child immediately returning from said function to a garbage address on its new stack and taking the whole program down with it. So [copy the return address over to the child too](https://github.com/winstonli/nihserver/blob/master/src/nihserver/linux/syscall.s#L86-L87).

When the child is done, it has to `munmap()` its own stack and call `exit()`. Be careful when doing this because freeing your own stack means you can't call functions anymore due to pushing of the return address. But luckily you can still `syscall` (which puts the return address in `rcx`, not the stack) and hence `exit()`, which exits the child process like `pthread_exit()` would.

This lets us make a nice [`pthread_create()`-like API](https://github.com/winstonli/nihserver/blob/master/src/nihserver/thread/thread.s).

### Synchronisation

We only have to synchronise `stdout` and `stderr`, so a lock will do. We could just use atomic spinlocks and call it a day, but it's better if we can ask the kernel to block threads when the lock is contended.

There is a `futex()` syscall that is used to implement synchronisation primitives that are efficient in user-space. We can use this to implement our lock. It takes a pointer to a "futex word", which is a 32-bit int. Let's call this pointer `int *fptr`. The `futex()` call gives us 2 operations we are interested in:

1. `FUTEX_WAIT`: Take another int, `val` and atomically check `val == *fptr`. Put the caller to sleep if they are equal.
2. `FUTEX_WAKE`: Wake `n` threads that are waiting on `fptr`.

With this, we can implement a lock by giving 3 possible values to the futex word:

1. `0` (unlocked, uncontended)
2. `1` (locked, uncontended)
3. `2` (locked, contended)

The nice thing is that in the uncontended case we can just try atomic check-and-set (CAS) to do `0 -> 1` (lock) and `1 -> 0` (unlock), which is very efficient and never has to enter the kernel. If that isn't successful, get the checked value from each CAS and loop around this state machine:

To lock:

- `0`: Atomically try `0 -> 1`. If successful, return. Otherwise, loop again.
- `1`: Atomically try `1 -> 2`. Loop again.
- `2`: Ask `futex()` to sleep us if the value is still `2`. Loop again.

To unlock:

- `0`: What happened? Assert out.
- `1`: Atomically try `1 -> 0`. If successful, return. Otherwise, loop again.
- `2`: Only we can change the value, so just set it to 0. Ask `futex()` to wake someone. Return.

This may not be the best way to implement locks, but it seems pretty solid. [Implementation](https://github.com/winstonli/nihserver/blob/master/src/nihserver/thread/lock.s).
