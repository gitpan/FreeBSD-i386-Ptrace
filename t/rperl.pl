#!/usr/local/bin/perl
#
# $Id: rperl.pl,v 0.1 2009/03/14 12:45:27 dankogai Exp dankogai $
#
use strict;
use warnings;
use FreeBSD::i386::Ptrace;
use FreeBSD::i386::Ptrace::Syscall;
use File::Temp;

our $DEBUG = 0;
my %banned = map { $_ => 1 } qw/fork vfork rfork bind listen accept/;
my $timeout = 1;

my $src    = slurp();

my $pfh = File::Temp->new() or die $!;
$pfh->print($src);
$pfh->close;

my $coh = File::Temp->new() or die $!;
$coh->autoflush(1);
my $ceh = File::Temp->new() or die $!;
$ceh->autoflush(1);

defined( my $pid = fork() ) or die "fork failed:$!";

if ( $pid == 0 ) {    # son
    no warnings;
    close STDIN;
    open STDOUT, '>&', $coh;
    open STDERR, '>&', $ceh;
    # showtime!
    pt_trace_me;
    exec qw/perl -Tw/, $pfh->filename;
}
else {                # mother
    wait;             # for exec;
    eval {
        local $SIG{ALRM} = sub { die "timed out\n" };    # NB: \n required
        alarm $timeout;
        my $count = 0;    # odd on enter, even on leave
        while ( pt_syscall($pid) == 0 ) {
            last if wait == -1;
            next unless ++$count & 1;    # enter only
            my $call = pt_getcall($pid);
            warn $SYS{$call} if $DEBUG;
            next if !$banned{ $SYS{$call} };
            pt_kill($pid);
            print "# $pid killed: SYS_$SYS{$call} banned.\n";
            last;
        }
        alarm 0;
    };
    if ($@) {
        pt_kill($pid);
        print "# $pid killed: $@";
    }
    #close $coh;
    #close $ceh;
    #unlink $csrcfn;
    my $cout = slurp($coh->filename);
    #unlink $coutfn;
    my $cerr = slurp($ceh->filename);
    #unlink $cerrfn;
    print "# stdout\n", $cout, "\n", "# stderr\n", $cerr, "\n";
}

sub slurp {
    my $ret;
    local $/;
    if (@_) {
        my $fn = shift;
        open my $fh, "<", $fn or die "$fn:$!";
        $ret = <$fh>;
        close $fh;
    }
    else {
        $ret = <>;
    }
    $ret;
}
