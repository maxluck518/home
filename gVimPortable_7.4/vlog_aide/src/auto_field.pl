#!/usr/bin/perl

my $begin = $ARGV[0];
my $end = $ARGV[1];
my $flag = $ARGV[2];
my @src;
my @enum;
my @dst;
my $idx;

foreach (<STDIN>) {
    chomp;
    push @src, $_;
}
if ($begin eq "") {
    $begin = 1;
}
if ($end eq "") {
    $end = scalar(@src);
}
if ($flag eq "") {
    $flag = "UVM_DEFAULT";
}
$idx = 0;
while ($idx < scalar(@src)) {
    my $line = $src[$idx];
    if ($line =~ /typedef\s+enum\s+.*\b(\w+)\s*;/) {
        push @enum, $1;
    } elsif ($line =~ /typedef\s+enum\s+/) {
        while ($idx < scalar(@src)) {
            if ($line =~ /\b(\w+)\s*;/) {
                push @enum, $1;
                last;
            } else {
                $idx ++;
                $line = $src[$idx];
            }
        }
    }
    $idx ++;
}

$idx = $begin - 1;
while ($idx < $end) {
    my $line = $src[$idx];
    my $type;
    my $var;
    my $is_enum = 0;
    my $macro_prefix = "`uvm_field_";
    my $macro_suffix = "";
    if ($line =~ /^\s*(\w+)\s+(#\(.*\))*\s*(\w+)(.*);/) {
        $type = $1;
        $var = $3;
        if ($4 =~ /\[\s*\]/) {
            $macro_prefix = "`uvm_field_array_";
        } elsif ($4 =~ /\[\$\]/) {
            $macro_prefix = "`uvm_field_queue_";
        } elsif ($4 =~ /\[(\D+)\]/) {
            $macro_prefix = "`uvm_field_aa_";
            $macro_suffix = "_$1";
        } elsif ($4 =~ /\[.*\]/) {
            $macro_prefix = "`uvm_field_sarray_";
        }
        if ($type eq 'int') {
            push @fields, $macro_prefix . "int$marco_suffix($var, $flag)";
            $idx ++;
            next;
        } elsif ($type eq 'string') {
            push @fields, $macro_prefix . "string$marco_suffix($var, $flag)";
            $idx ++;
            next;
        } elsif ($type eq 'real') {
            push @fields, $macro_prefix . "real$macro_suffix($var, $flag)";
            $idx ++;
            next;
        } elsif ($type eq 'event') {
            push @fields, $macro_prefix . "event$macro_suffix($var, $flag)";
            $idx ++;
            next;
        }
        foreach (@enum) {
            if ($_ eq $type) {
                push @fields, $macro_prefix . "enum$macro_suffix($type, $var, $flag)";
                $is_enum = 1;
                last;
            }
        }
        if ($is_enum == 0) {
            push @fields, $macro_prefix . "object$macro_suffix($var, $flag)";
        }
    }
    $idx ++;
}

foreach (@src) {
    if ($_ =~ /`uvm_\w+_utils_begin/) {
        push @dst, $_;
        foreach (@fields) {
            push @dst, "        $_";
        }
    } else {
        push @dst, $_;
    }
}

foreach (@dst) {
    print "$_\n";
}
