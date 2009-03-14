#
# $Id: Ptrace.pm,v 0.1 2009/03/14 12:45:27 dankogai Exp dankogai $
#
package FreeBSD::i386::Ptrace;
use 5.008001;
use strict;
use warnings;
our $VERSION = '0.01';
require Exporter;
our @ISA = qw/Exporter/;

# XXX should be auto-generated like Syscall.pm

our @EXPORT = qw(
  ptrace pt_trace_me pt_attach pt_detach pt_syscall pt_getcall pt_kill
  PT_TRACE_ME
  PT_READ_I PT_READ_D
  PT_WRITE_I PT_WRITE_D
  PT_IO
  PT_CONTINUE
  PT_STEP
  PT_KILL
  PT_ATTACH
  PT_DETACH
  PT_GETREGS
  PT_SETREGS
  PT_GETFPREGS
  PT_SETFPREGS
  PT_GETBRREGS
  PT_SETBRREGS
  PT_LWPINFO
  PT_GETNUMLWPS
  PT_GETLWPLIST
);
our %EXPORT_TAGS = ( 'all' => [qw()] );
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

require XSLoader;
XSLoader::load( 'FreeBSD::i386::Ptrace', $VERSION );

# Preloaded methods go here.
use constant {
    PT_TRACE_ME   => 0,
    PT_READ_I     => 1,
    PT_READ_D     => 2,
    PT_READ_U     => 3,
    PT_WRITE_I    => 4,
    PT_WRITE_D    => 5,
    PT_WRITE_U    => 6,
    PT_CONTINUE   => 7,
    PT_KILL       => 8,
    PT_STEP       => 9,
    PT_ATTACH     => 10,
    PT_DETACH     => 11,
    PT_IO         => 12,
    PT_LWPINFO    => 13,
    PT_GETNUMLWPS => 14,
    PT_GETLWPLIST => 15,
    PT_CLEARSTEP  => 16,
    PT_SETSTEP    => 17,
    PT_SUSPEND    => 18,
    PT_RESUME     => 19,
    PT_TO_SCE     => 20,
    PT_TO_SCX     => 21,
    PT_SYSCALL    => 22,
    PT_GETREGS    => 33,
    PT_SETREGS    => 34,
    PT_GETFPREGS  => 35,
    PT_SETFPREGS  => 36,
    PT_GETDBREGS  => 37,
    PT_SETDBREGS  => 38,
    PT_FIRSTMACH  => 64,
};

use FreeBSD::i386::Ptrace::Syscall;
no warnings 'once';
*ptrace = \&pt_ptrace;
#*syscall = \&pt_syscall;
#*getcall = \&pt_getcall;


1;
__END__

=head1 NAME

FreeBSD::i386::Ptrace - Ptrace for FreeBSD-i386

=head1 VERSION

$Id: Ptrace.pm,v 0.1 2009/03/14 12:45:27 dankogai Exp dankogai $

=head1 SYNOPSIS

  # simple strace in perl
  use strict;
  use warnings;
  use FreeBSD::i386::Ptrace;
  use FreeBSD::i386::Ptrace::Syscall;
  die "$0 prog args ..." unless @ARGV;
  my $pid = fork();
  die "fork failed:$!" if !defined($pid);
  if ($pid == 0){ # son
    pt_trace_me;
    exec @ARGV;
  }else{  mom
    wait; # for exec;
    my $count = 0; # odd on enter, even on leave
    my ($call, $retval);  
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

=head1 EXPORT

C<ptrace>, C<pt_trace_me>, C<pt_attach>, C<pt_detach>, C<pt_syscall>
C<pt_getcall> C<pt_kill> and PT_* constants.

for C<%SYS>, use <FreeBSD::i386::Ptrace::Syscall>.

=head1 FUNCTIONS

=over 2

=item ptrace($request, $pid, $addr, $data)

A thin wrapper to L<ptrace/2>.

     #include <sys/types.h>
     #include <sys/ptrace.h>
     int
     ptrace(int request, pid_t pid, caddr_t addr, int data);

All arguments are integer from perl.

=item pt_trace_me()

Shortand for C<ptrace(PT_TRACE_ME, 0, 0, 0)>.

=item pt_attach($pid)

Shortand for C<ptrace(PT_ATTACH, pid, 0, 0)>.

=item pt_detach($pid)

Shortand for C<ptrace(PT_DETACH, pid, 0, 0)>.

=item pt_syscall($pid)

Shortand for C<ptrace(PT_SYSCALL, pid, 1, 0)>.  Unlike Linux the 3rd argument must be 1 or it loops infinitely.

Note PT_SYSCALL is invoked both on entry to and return from the system
call.  See L</SYNOPSIS> to see how to switch between them.

=item pt_getcall($pid)

Returns the value of EAX register which holds the system call NUMBER
on entry and the return value on return.

To get the name of system call you can import C<FreeBSD::i386::Ptrace::Syscall> and use C<%SYS>.

  my $call = pt_getcall(pid);
  my $name = %SYS{$call};

=item pt_kill($pid)

Shortand for C<ptrace(PT_KILL, $pid, 0, 0>;
C<ptrace>, C<pt_trace_me>, C<pt_attach>, C<pt_detach>, C<pt_syscall>
C<pt_getcall> C<pt_kill> and PT_* constants.

=back

=head1 AUTHOR

Dan Kogai, C<< <dankogai at dan.co.jp> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-freebsd-i386-ptrace at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=FreeBSD-i386-Ptrace>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc FreeBSD::i386::Ptrace

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=FreeBSD-i386-Ptrace>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/FreeBSD-i386-Ptrace>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/FreeBSD-i386-Ptrace>

=item * Search CPAN

L<http://search.cpan.org/dist/FreeBSD-i386-Ptrace>

=back

=head1 ACKNOWLEDGEMENTS

L<Sys::Ptrace>


=head1 COPYRIGHT & LICENSE

Copyright 2009 Dan Kogai, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
