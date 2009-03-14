#!/usr/local/bin/perl
use strict;
use warnings;
use FreeBSD::i386::Ptrace;
use FreeBSD::i386::Ptrace::Syscall;

die "$0 prog args ..." unless @ARGV;
my $pid = fork();
die "fork failed:$!" if !defined($pid);
if ($pid == 0){
    pt_trace_me;
    exec @ARGV;
}else{
    wait; # for exec;
    my $count = 0;
    my ($call, $retval);
   # note ptrace(PT_SYSCALL) traps both enter and leave; enter first
    while(pt_syscall($pid) == 0){ 
	last if wait == -1;
	if (++$count & 1){
	    $call = pt_getcall($pid);
	}else{
	    $retval = pt_getcall($pid);
	    my $name = $SYS{$call} || 'unknown';
	    warn "$name -> $retval";

        }
    }
    warn $count/2," system calls issued";
}
