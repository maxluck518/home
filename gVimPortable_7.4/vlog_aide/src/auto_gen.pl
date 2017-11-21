#!/usr/bin/perl

my @src;
my @dst;
while (<STDIN>) {
    chomp;
    push @src, $_;
}
my $idx = 0;
while ($idx < scalar(@src)) {
    $line = $src[$idx];
    my $loop_idx = 0;
    my @loop;
    if ($line =~ /^\s*\/\*\s*vlog_aide\s*:\s*auto_gen\s+(.*)\s+begin\s*$/) {
        my $var = $1;
        $var =~ s/\s//g;
        while ($var =~ /^(\w+)=(\d+),(\d+),(\d+)/) {
            $loop[$loop_idx][0] = $1;
            $loop[$loop_idx][1] = $2;
            $loop[$loop_idx][2] = $3;
            $loop[$loop_idx][3] = $4;
            $var = $';
            $loop_idx ++;
        }
        my @generate;
        push @dst, "$line*/";
        $idx ++;
        $line = $src[$idx];
        my $end_var;
        for (my $i = 0; $i < $loop_idx; $i ++) {
            $end_var = $end_var . $loop[$i][0] . ",";
        }
        while (($line !~ /^\s*vlog_aide\s*:\s*auto_gen\s+$end_var\s+end\*\//) && ($idx < scalar(@src))) {
            push @generate, $line;
            $idx ++;
            $line = $src[$idx];
        }
        for (my $j = ($loop_idx - 1) ; $j >= 0; $j --) {
            my @swap;
            for (my $i = $loop[$j][1]; $i <= $loop[$j][2]; $i = $i + $loop[$j][3]) {
                my $var = $loop[$j][0];
                foreach (@generate) {
                    my $line = $_;
                    while ($line =~ /\$\(([^()]*\b$var\b[^()]*)\)/) {
                        my $tmp = $1;
                        my $prefix = $`;
                        my $suffix = $';
                        $tmp =~ s/$var/$i/g;
                        while ($tmp =~ /(\d+)\*(\d+)/) {
                            $tmp = $1 * $2;
                            $tmp = "$`$tmp$'";
                        }
                        while ($tmp =~ /(\d+)(\+|-)(\d+)/) {
                            if ($2 eq '+') {
                                $tmp = $1 + $3;
                            } else {
                                $tmp = $1 - $3;
                            }
                            $tmp = "$`$tmp$'";
                        }
                        $line = "$prefix$tmp$suffix";
                    }
                    push @swap, $line;
                }
            }
            @generate = @swap;
        }
        foreach (@generate) {
            push @dst, $_;
        }
        push @dst, "/*vlog_aide:auto_gen end*/";
    } else {
        push @dst, $line;
    }
    $idx ++;
}

foreach (@dst) {
    print "$_\n";
}
        
