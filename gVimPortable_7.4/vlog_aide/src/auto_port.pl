#!/usr/bin/perl

# $ARGV[0]: max characters in one line, default is 100

my @src;
my @dst;
my @inputs;
my @outputs;
my @inouts;
$idx = 0;
if ($ARGV[1] ne "") {
    $row_chr_max = $ARGV[0];
} else {
    $row_chr_max = 100;
}
while (<STDIN>) {
    chomp;
    push @src, $_; 
}
foreach my $line (@src) {
    my $tmp;
    if ($line =~ /^\s*input\s+/) {
        $tmp = $line;
        $tmp =~ s/^\s*input\s+//;
        $tmp =~ s/^\[[^\]]*\]\s*//;
        $tmp =~ s/;.*$//;
        my @ports = split /\s*,\s*/, $tmp;
        push @inputs, @ports;
    } elsif ($line =~ /^\s*output\s+/) {
        $tmp = $line;
        $tmp =~ s/^\s*output\s+//;
        $tmp =~ s/^\[[^\]]*\]\s*//;
        $tmp =~ s/;.*$//;
        my @ports = split /\s*,\s*/, $tmp;
        push @outputs, @ports;
    } elsif ($line =~ /^\s*inout\s+/) {
        $tmp = $line;
        $tmp =~ s/^\s*inout\s+//;
        $tmp =~ s/^\[[^\]]*\]\s*//;
        $tmp =~ s/;.*$//;
        my @ports = split /\s*,\s*/, $tmp;
        push @inouts, @ports;
    }
}
while ($idx < scalar(@src)) {
    my $line = $src[$idx];
    my $prefix;
    my $suffix;
    if ($line =~ /^(.*)\/\*vlog_aide:\s*auto_port\*\/\s*$/) {
        $prefix = $1;
        if ($src[$idx+1] =~ /^\s*\/\*vlog_aide:\s*auto_port start\*\//) {
            while ($line !~ /^\s*\/\*vlog_aide:\s*auto_port end\*\//) {
                $idx ++;
                $line = $src[$idx];
            }
            $idx ++;
            $suffix = $src[$idx];
            push @dst, "$prefix/*vlog_aide:auto_port*/$suffix";
        } else {
            push @dst, $line;
        }
    } else {
        push @dst, $line;
    }
    $idx ++;
}
undef(@src);
push @src, @dst;
undef(@dst);
$idx = 0;
while ($idx < scalar(@src)) {
    my $line = $src[$idx];
    my $chr_cnt = 0;
    my $out_line;
    my $nest_line;
    if ($line =~ /^(.*)\/\*vlog_aide:auto_port\*\/(.*)$/) {
        $line = "$1/*vlog_aide:auto_port*/";
        $next_line = $2;
        push @dst, $line;
        push @dst, "/*vlog_aide:auto_port begin*/";
        push @dst, "/*vlog_aide:auto_port input ports*/";
        while (scalar(@inputs) > 0) {
            $out_line = "";
            while (($chr_cnt < $row_chr_max) && (scalar(@inputs) > 0)) {
                my $port = pop(@inputs);
                $chr_cnt += length($port);
                $out_line = $out_line . "$port, ";
            }
            push @dst, $out_line;
            $chr_cnt = 0;
        }
        push @dst, "/*vlog_aide:auto_port output ports*/";
        while (scalar(@outputs) > 0) {
            $out_line = "";
            while (($chr_cnt < $row_chr_max) && (scalar(@outputs) > 0)) {
                my $port = pop(@outputs);
                $chr_cnt += length($port);
                $out_line = $out_line . "$port, ";
            }
            if ((scalar(@outputs) == 0) && (scalar(@inouts) == 0)) {
                $out_line =~ s/,\s*$//;
            }
            push @dst, $out_line;
            $chr_cnt = 0;
        }
        if (scalar(@inouts) > 0) {
            push @dst, "/*vlog_aide:auto_port inout ports*/";
            while (scalar(@inouts) > 0) {
                $out_line = "";
                while (($chr_cnt < $row_chr_max) && (scalar(@inouts) > 0)) {
                    my $port = pop(@inouts);
                    $chr_cnt += length($port);
                    $out_line = $out_line . "$port, ";
                }
                if (scalar(@inouts) == 0) {
                    $out_line =~ s/,\s*$//;
                }
                push @dst, $out_line;
                $chr_cnt = 0;
            }
        }
        push @dst, "/*vlog_aide:auto_port end*/";
        push @dst, $next_line;
    } else {
        push @dst, $line;
    }
    $idx ++;
}

foreach my $line (@dst) {
    print "$line\n";
}

