#!/usr/bin/perl

my @src;
my @dst;
my %parameters;
my $top_inf;
my @top_signals;
my $idx = 0;
my $sub_idx = 0;
my $specify_inf = $ARGV[0];
my $begin = $ARGV[1];
my $end = $ARGV[2];

foreach (<STDIN>) {
    chomp;
    my $line = $_;
    push @src, $line;
    if ($line =~ /^\s*module\s+(\w+)\s*\(/) {
        $top_inf = $1 . "Inf";
    } elsif ($line =~ /^\s*parameter\s+(.*);/) {
        $param = $1;
        $param =~ s/\s//g;
        my @tmp = split /,/, $param;
        foreach (@tmp) {
            if ($_ =~ /(.+)=(.+)/) {
                $parameters{$1} = $2;
            }
        }
    } elsif ($line =~ /^\s*parameter\s+(.*,)/) {
        $param = $1;
        $param =~ s/\s//g;
        $idx ++;
        $line = $src[$idx];
        while (($line !~ /.*;/) && ($idx < scalar(@src))) {
            my $tmp = $line;
            $tmp =~ s/;.*//;
            $tmp =~ s/\s//g;
            $param = $param . $tmp;
            $idx ++;
            $line = $src[$idx];
        }
        $line =~ s/;.*//;
        $line =~ s/\s//g;
        $param = $param . $line;
        my @tmp = split /,/, $param;
        foreach (@tmp) {
            if ($_ =~ /(.+)=(.+)/) {
                $parameters{$1} = $2;
            }
        }
    }
    $idx ++;
    $line = $src[$idx];
}
$idx = 0;

if ($specify_inf eq "") {
    while ($idx < scalar(@src)) {
        my @sub_signals;
        my $sub_inf;
        my $line = $src[$idx];
        if ($line =~ /^\s*\/\*\s*vlog_aide\s*:\s*auto_inf\s+(\w+)\s+begin\s*\*\//) {
            $sub_inf = $1;
            $idx ++;
            print "$sub_inf\n";
            $line = $src[$idx];
            while ($line !~ /^\s*\/\*\s*vlog_aide\s*:\s*auto_inf\s+$1\s+end\s*\*\//) {
                push @sub_signals, $line;
                $idx ++;
                $line = $src[$idx];
            }
            &gen_inf($sub_inf, \@sub_signals);
        } elsif ($line =~ /^\s*(input|output|inout)\b/) {
            push @top_signals, $line;
        }
        $idx ++;
    }
    &gen_inf($top_inf, \@top_signals);
} else {
    my @signals;
    $idx = $begin - 1;
    if ($end eq "") {
        $end = scalar(@src);
    }
    while ($idx < $end) {
        my $line = $src[$idx];
        push @signals, $line;
        $idx ++;
    }
    &gen_inf($specify_inf, \@signals);
}
foreach (@src) {
    print "$_\n";
}

sub gen_inf {
    my $inf = $_[0];
    my @src = @{$_[1]};
    my %inputs;
    my %outputs;
    my %inouts;
    my %inf_param;
    my $param_list;
    my @ptr = &get_signals(@src);
    %inputs = %{$ptr[0]};
    %outputs = %{$ptr[1]};
    %inouts = %{$ptr[2]};
    %inf_param = %{$ptr[3]};
    open FP, ">$inf.sv";
    while (keys %inf_param) {
        $param_list = $param_list . "$_=". $inf_param{$_} . ", ";
    }
    $param_list =~ s/,$//;
    print FP "interface $inf $param_list();\n";
    print FP "// Input ports of DUT\n";
    foreach (keys %inputs) {
        print FP "logic " . $inputs{$_} . " $_;\n";
    }
    print FP "// Output ports of DUT\n";
    foreach (keys %outputs) {
        print FP "logic " . $outputs{$_} . " $_;\n";
    }
    print FP "// Inout ports of DUT\n";
    foreach (keys %inouts) {
        print FP "wire " . $inouts{$_} . " $_;\n";
    }
    print FP "endinterface\n";
    close FP;
}

sub get_signals {
    my @src = @_;
    my $idx = 0;
    my %inputs;
    my %outputs;
    my %inouts;
    my %inf_param;
    while ($idx < scalar(@src)) {
        my $width;
        my @signals;
        my $line = $src[$idx];
        $line =~ s/\/\*.*\*\///g;
        $line =~ s/\/\/.*$//;
        if ($line =~ /^\s*input\s*(signed)*\s*(\[.*\])*\s*(.*)/) {
            $width = $2;
            my $tmp = $3;
            $tmp =~ s/\s//g;
            $tmp =~ s/\)\s*;//;
            $tmp =~ s/;//;
            @signals = split /,/, $tmp;
            foreach (@signals) {
                $inputs{$_} = $width;
            }
            while ($width =~ /\w+/) {
                if (exists $parameters{$&}) {
                    $inf_param{$&} = $parameters{$&};
                }
                $width = $` . $';
            }
        } elsif ($line =~ /^\s*output\s*(reg|wire)*\s*(signed)*\s*(\[.*\])*\s*(.*)/) {
            $width = $3;
            my $tmp = $4;
            $tmp =~ s/\s//g;
            $tmp =~ s/\)\s*;//;
            $tmp =~ s/;//;
            @signals = split /,/, $tmp;
            foreach (@signals) {
                $outputs{$_} = $width;
            }
        } elsif ($line =~ /^\s*inout\s*(wire)*\s*(signed)*\s*(\[.*\])*\s*(.*)/) {
            $width = $3;
            my $tmp = $4;
            $tmp =~ s/\s//g;
            $tmp =~ s/\)\s*;//;
            $tmp =~ s/;//;
            @signals = split /,/, $tmp;
            foreach (@signals) {
                $inouts{$_} = $width;
            }
        }
        $idx ++;
    }
    return (\%inputs, \%outputs, \%inouts, \%inf_param);
}
