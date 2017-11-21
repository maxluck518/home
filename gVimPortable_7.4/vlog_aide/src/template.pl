#!/usr/bin/perl

my @src;
my @dst;
my $pattern = $ARGV[0];
my $lib_home = $ENV{"VLOG_LIBRARY_PATH"};

while (<STDIN>) {
    chomp;
    push @src, $_;
}

if ($pattern eq "") {
    foreach my $line (@src) {
        if ($line =~ /\/\*\s*vlog_aide\s*:\s*template\s+(\S*)\s+(.*)\*\//) {
            my $lib = $1;
            my $tmp = $2;
            $tmp =~ s/\s//g;
            my @param = split /,/, $tmp;
            my @append = &replace_pattern("$lib_home/$lib", \@param);
            push @dst, "//vlog_aide:template $lib $tmp";
            push @dst, "/*vlog_aide:template begin*/";
            foreach (@append) {
                push @dst, $_;
            }
            push @dst, "/*vlog_aide:template end*/";
        } else {
            push @dst, $line;
        }
    }
} else {
    my @param = @ARGV;
    my $tmp = shift @param;
    my @append = &replace_pattern("$lib_home/$pattern", \@param);
    foreach (@append) {
        push @dst, $_;
    }
}

foreach (@dst) {
    print "$_\n";
}

sub replace_pattern {
    my $lib = $_[0];
    my @value = @{$_[1]};
    my @append;
    my %parameters;
    open FP, "<$lib" or die "Library file $lib does not exist!";
    while (<FP>) {
        chomp;
        my $line = $_;
        if ($line =~ /^\s*#\s*\w+\s*\((.*)\)/) {
            my $tmp = $1;
            $tmp =~ s/\s//g;
            my @keys = split /,/, $tmp;
            my $idx = 0;
            foreach (@keys) {
                $parameters{$_} = $value[$idx];
                $idx ++;
            }
        } else {
            while ($line =~ /\$\((\w+)\)/) {
                if (exists $parameters{$1}) {
                    $line = "$`" . $parameters{$1} . "$'";
                } else {
                    last;
                }
            }
            push @append, $line;
        }
    }
    close FP;
    return @append;
}
