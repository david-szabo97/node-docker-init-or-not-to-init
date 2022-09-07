
# Docker `init` or not to `init`

This repository exists to prove that you need an `init` process in your Docker container.

Uses Node.js as an example, but this is basically applicable to all runtimes.

**You can read more about PID 1, orphaned processes, zombie processes, process adopting in my [blog article](https://daveiscoding.com/why-do-you-need-an-init-process-inside-your-docker-container-pid-1).**

## Run it

### Run without --init

Runs the docker container without the `--init` flag to prove that the Node.js runtime doesn't take care of zombie processes.

```bash
./run.sh
```

### Run with --init

Runs the docker container with the `--init` flag to prove that the `init` process takes care of zombie processes.

```bash
./run.sh with-init
```

## What does this do?

1. Build Node.js application image
2. Run image as a container. Boots up the `main.js` script which starts a child process that runs `child.js`. The child process starts another child process that runs `sub-child.js`.
3. Print out the process table before killing any processes.
4. Kill `child.js` process. Thus `sub-child.js` becomes an orphan and PID 1 (`main.js` process or `init`) adopts it.
5. Kill `sub-child.js` process. Thus `sub-child.js` is terminated and becomes a zombie process. In case of `init`, this zombie process is removed from the process table.

## Example output

This is the output of running the bash script without the `with-init` argument. This shows that there is a zombie process at the end.

```
$ ./run.sh
[+] Building 1.7s (10/10) FINISHED
....

Currently running processes (before kills):
UID        PID  PPID  C STIME TTY      STAT   TIME CMD
root         1     0  5 19:25 ?        Ssl    0:00 node lib/main.js
root        14     1  0 19:26 ?        Sl     0:00 /usr/local/bin/node /app/lib/child.js
root        21    14  0 19:26 ?        Sl     0:00 /usr/local/bin/node /app/lib/sub-child.js
root        28     0  0 19:26 pts/0    Rs+    0:00 ps -eaf -w 10000

Killed child process

Currently running processes (after killing child):
UID        PID  PPID  C STIME TTY      STAT   TIME CMD
root         1     0  2 19:25 ?        Ssl    0:00 node lib/main.js
root        21     1  3 19:26 ?        Sl     0:00 /usr/local/bin/node /app/lib/sub-child.js
root        46     0  0 19:26 pts/0    Rs+    0:00 ps -eaf -w 10000

Killed sub-child process

Currently running processes (after killing sub-child):
UID        PID  PPID  C STIME TTY      STAT   TIME CMD
root         1     0  1 19:25 ?        Ssl    0:00 node lib/main.js
root        21     1  1 19:26 ?        Z      0:00 [node] <defunct>
root        64     0  0 19:26 pts/0    Rs+    0:00 ps -eaf -w 10000

Found 1 zombie processes!
```
