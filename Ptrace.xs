#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <unistd.h>
#include <sys/ptrace.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <machine/reg.h>

MODULE = FreeBSD::i386::Ptrace		PACKAGE = FreeBSD::i386::Ptrace

PROTOTYPES: ENABLE

int
pt_ptrace(request, pid, addr, data)
    int request;
    int pid;
    int addr;
    int data;
CODE:
    RETVAL = ptrace(request, pid, addr, data);
OUTPUT:
    RETVAL

int
pt_syscall(pid)
	int pid;
CODE:
    RETVAL = ptrace(PT_SYSCALL, pid, (caddr_t)1, 0);
OUTPUT:
    RETVAL

int
pt_trace_me()
CODE:
    RETVAL = ptrace(PT_TRACE_ME, 0, 0, 0);
OUTPUT:
    RETVAL

int
pt_attach(pid)
	int pid;
CODE:
    RETVAL = ptrace(PT_ATTACH, pid, 0, 0);
OUTPUT:
    RETVAL

int
pt_dettach(pid)
	int pid;
CODE:
    RETVAL = ptrace(PT_DETACH, pid, 0, 0);
OUTPUT:
    RETVAL

int
pt_kill(pid)
	int pid;
CODE:
    RETVAL = ptrace(PT_KILL, pid, 0, 0);
OUTPUT:
    RETVAL

int
pt_getcall(pid)
	int pid;
CODE:
    struct reg r;
    ptrace(PT_GETREGS, pid, (caddr_t)&r, 0);
    RETVAL = r.r_eax;
OUTPUT:
    RETVAL

