#!/usr/bin/perl

my @src;
my @dst;
my %inputs;
my %outputs;
my %inouts;
my %parameters;
my @param_values;

while (<STDIN>) {
    chomp;
    push @src, $_;
}

my $idx = 0;
while ($idx < scalar(@src)) {
    my $line = $src[$idx];
    if ($line =~ /^\s*(\w.*)\/\*vlog_aide:\s*auto_inst\s+(.*)\*\/(.*)$/) {
        my $prefix = $1;
        my $suffix = $3;
        my $inst_file = $2;
        if ($prefix =~ /#\((.*)\)/) {
            my $tmp = $1;
            $tmp =~ s/\s//g;
            @param_values = split /,/, $tmp;
        }
        undef(%inputs);
        undef(%outputs);
        undef(%inouts);
        &get_ports($inst_file, \@param_values);
        &add_margin();
        if ($suffix =~ /\)\s*;/) {
            push @dst, "$prefix\/\*vlog_aide:auto_inst $inst_file\*\/";
            push @dst, "    /*vlog_aide:auto_inst begin*/";            
            if (scalar(keys %inputs) > 0) {
                push @dst, "    /*vlog_aide:auto_inst input ports*/";
                &gen_ports(\%inputs);
            }
            if (scalar(keys %outputs) > 0) {
                push @dst, "    /*vlog_aide:auto_inst output ports*/";
                &gen_ports(\%outputs);
            }
            if (scalar(keys %inouts) > 0) {
                push @dst, "    /*vlog_aide:auto_inst inout ports*/";
                &gen_ports(\%inouts);
            }
            my $last_line = pop @dst;
            $last_line =~ s/,$//;
            push @dst, $last_line;
            push @dst, "    /*vlog_aide:auto_inst end*/";
            push @dst, $suffix;
        } elsif ($src[$idx+1] =~ /\/\*vlog_aide:\s*auto_inst\s+begin\*\//) {
            $idx = $idx + 2;
            $line = $src[$idx];
            while (($line !~ /\/\*vlog_aide:\s*auto_inst\s+end\*\//) && ($idx < scalar(@src))) {
                if ($line =~ /^\s*\.(\w+)\s*\(\s*([^\[\]]*)(\[.*\])*\s*\)/) {
                    my $port = $1;
                    my $net = $2;
                    my $width = $3;
                    $port =~ s/\s//g;
                    $net =~ s/\s//g;
                    &update_ports($port, $net, $width);
                }
                $idx ++;
                $line = $src[$idx];
            }
            push @dst, "$prefix\/\*vlog_aide:auto_inst $inst_file\*\/";
            push @dst, "    /*vlog_aide:auto_inst begin*/";            
            if (scalar(keys %inputs) > 0) {
                push @dst, "    /*vlog_aide:auto_inst input ports*/";
                &gen_ports(\%inputs);
            }
            if (scalar(keys %outputs) > 0) {
                push @dst, "    /*vlog_aide:auto_inst output ports*/";
                &gen_ports(\%outputs);
            }
            if (scalar(keys %inouts) > 0) {
                push @dst, "    /*vlog_aide:auto_inst inout ports*/";
                &gen_ports(\%inouts);
            }
            my $last_line = pop @dst;
            $last_line =~ s/,$//;
            push @dst, $last_line;
            push @dst, "    /*vlog_aide:auto_inst end*/";
        } else {
            push @dst, $line;
        }
    } else {
        push @dst, $line;
    }
    $idx ++;
}
foreach (@dst) {
    print "$_\n";
}

sub get_ports {
    my $inst_file = $_[0];
    my @values = @{$_[1]};
    my %parameters;
    my @src;

    open FP, "<$inst_file";
    while (<FP>) {
        chomp;
        push @src, $_;
    }
    close FP;
    my $idx = 0;
    my $param_idx = 0;
    @src = &remove_comment(@src);
    while ($idx < scalar(@src)) {
        my $line = $src[$idx];
        if ($line =~ /^\s*parameter\s+(.*);/) {
            $param = $1;
            $param =~ s/\s//g;
            my @tmp = split /,/, $param;
            foreach (@tmp) {
                if ($_ =~ /(.+)=(.+)/) {
                    if ($param_idx == scalar(@values)) {
                        $parameters{"$1"} = $2;
                    } else {
                        $parameters{"$1"} = $values[$param_idx];
                        $param_idx ++;
                    }
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
                    if ($param_idx == scalar(@values)) {
                        $parameters{"$1"} = $2;
                    } else {
                        $parameters{"$1"} = $values[$param_idx];
                        $param_idx ++;
                    }
                }
            }
        }
        $idx ++;
        $line = $src[$idx];
    }
    foreach my $key (keys %parameters) {
        foreach (keys %parameters) {
            if ($parameters{$key} =~ /\b$_\b/) {
                my $replace = $parameters{$_};
                $parameters{$key} =~ s/\b$_\b/$replace/g;
            }
        }
        while ($parameters{$key} =~ /(\d+)\*(\d+)/) {
            my $mult = $1 * $2;
            $parameters{$key} = "$`$mult$'";
        }
        while ($parameters{$key} =~ /(\d+)(\+|-)(\d+)/) {
            my $sum;
            if ($2 eq '+') {
                $sum = $1 + $3;
            } else {
                $sum = $1 - $3;
            }
            $parameters{$key} = "$`$sum$'";
        }
    }
    foreach my $line (@src) {
        my $width;
        my @signals;
        if ($line =~ /^\s*input\s*(signed)*\s*(\[.*\])*\s*(.*)/) {
            $width = $2;
            my $tmp = $3;
            $tmp =~ s/\s//g;
            $tmp =~ s/\)\s*;//;
            $tmp =~ s/;//;
            @signals = split /,/, $tmp;
            if ($width eq "") {
                foreach (@signals) {
                    $inputs{$_} = $_;
                }
            } else {
                $width = &substitute($width, \%parameters);
                foreach (@signals) {
                    $inputs{$_} = "$_$width";
                }
            }
        } elsif ($line =~ /^\s*output\s*(reg|wire)*\s*(signed)*\s*(\[.*\])*\s*(.*)/) {
            $width = $3;
            my $tmp = $4;
            $tmp =~ s/\s//g;
            $tmp =~ s/\)\s*;//;
            $tmp =~ s/;//;
            @signals = split /,/, $tmp;
            if ($width eq "") {
                foreach (@signals) {
                    $outputs{$_} = $_;
                }
            } else {
                $width = &substitute($width, \%parameters);
                foreach (@signals) {
                    $outputs{$_} = "$_$width";
                }
            }
        } elsif ($line =~ /^\s*inout\s*(wire)*\s*(signed)*\s*(\[.*\])*\s*(.*)/) {
            $width = $3;
            my $tmp = $4;
            $tmp =~ s/\s//g;
            $tmp =~ s/\)\s*;//;
            $tmp =~ s/;//;
            @signals = split /,/, $tmp;
            if ($width eq "") {
                foreach (@signals) {
                    $inouts{$_} = $_;
                }
            } else {
                $width = &substitute($width, \%parameters);
                foreach (@signals) {
                    $inouts{$_} = "$_$width";
                }
            }
        } 
    }                                                                                                    
}

sub substitute {
    my $width_expr = $_[0];
    my %parameters = %{$_[1]};
    if ($width_expr =~ /\[\d+:/) {
        return $width_expr;
    } elsif ($width_expr =~ /\[`\w+:/) {
        return $width_expr;
    } elsif ($width_expr =~ /\[(.*):/) {
        $width_expr = $1;
        $width_expr =~ s/\s//g;
        foreach (keys %parameters) {
            if ($width_expr =~ /\b$_\b/) {
                my $replace = $parameters{$_};
                $width_expr =~ s/\b$_\b/$replace/g;
            }
        }
        while ($width_expr =~ /(\d+)\*(\d+)/) {
            my $mult = $1 * $2;
            $width_expr = "$`$mult$'";
        }
        while ($width_expr =~ /(\d+)(\+|-)(\d+)/) {
            my $sum;
            if ($2 eq '+') {
                $sum = $1 + $3;
            } else {
                $sum = $1 - $3;
            }
            $width_expr = "$`$sum$'";
        } 
        return "[$width_expr:0]";
    }
    return $width_expr;
}

sub add_margin {
    my $max_len = 0;
    my $margin;

    foreach (keys %inputs) {
        if ($max_len < length($_)) {
            $max_len = length($_);
        }
    }
    foreach (keys %outputs) {
        if ($max_len < length($_)) {
            $max_len = length($_);
        }
    }
    foreach (keys %inouts) {
        if ($max_len < length($_)) {
            $max_len = length($_);
        }
    }
    $max_len = $max_len + 4;
    my @keys = (keys %inputs);
    foreach (@keys) {
        my $old_key = $_;
        $margin = $max_len - length($old_key);
        $margin = " " x $margin;
        my $new_key = $old_key . $margin;
        $inputs{"$new_key"} = $inputs{"$old_key"};
        if ($new_key ne $old_key) {
            delete $inputs{"$old_key"};
        }
    }
    @keys = (keys %outputs);
    foreach (@keys) {
        my $old_key = $_;
        $margin = $max_len - length($_);
        $margin = " " x $margin;
        my $new_key = $_ . $margin;
        $outputs{"$new_key"} = $outputs{"$old_key"};
        if ($new_key ne $old_key) {
            delete $outputs{"$old_key"};
        }
    }
    @keys = (keys %inouts);
    foreach (@keys) {
        my $old_key = $_;
        $margin = $max_len - length($_);
        $margin = " " x $margin;
        my $new_key = $_ . $margin;
        $inouts{"$new_key"} = $inouts{"$old_key"};
        if ($new_key ne $old_key) {
            delete $inouts{"$old_key"};
        }
    }
}

sub gen_ports {
    my %ports = %{$_[0]};
    foreach (keys %ports) {
        push @dst, "    .$_(" . $ports{"$_"} . "),";
    }
}

sub update_ports {
    my $port = $_[0];
    my $net = $_[1];
    my $width = $_[2];

    foreach (keys %inputs) {
        my $key = $_;
        $key =~ s/\s//g;
        if ($key eq $port) {
            my $signal_width = $inputs{$_};
            $signal_width =~ s/^\w+//;
            if ($net ne $key) {
                $inputs{$_} = "$net$width";
            } elsif ($signal_width ne $width) {
                if ($width !~ /:0\]/) {
                    $inputs{$_} = "$net$width";
                }
            }
        }
    }
    foreach (keys %outputs) {
        my $key = $_;
        $key =~ s/\s//g;
        if ($key eq $port) {
            my $signal_width = $outputs{$_};
            $signal_width =~ s/^\s+//;
            if ($net ne $key) {
                $outputs{$_} = "$net$width";
            } elsif ($signal_width ne $width) {
                if ($width !~ /:0\]/) {
                    $outputs{$_} = "$net$width";
                }
            }
        }
    }
    foreach (keys %inouts) {
        my $key = $_;
        $key =~ s/\s//g;
        if ($key eq $port) {
            my $signal_width = $inouts{$_};
            $signal_width =~ s/^\s+//;
            if ($net ne $key) {
                $inouts{$_} = "$net$width";
            } elsif ($signal_width ne $width) {
                if ($width !~ /:0\]/) {
                    $outputs{$_} = "$net$width";
                }
            }
        }
    }
}

sub remove_comment {
    my @lines = @_;
    my $idx = 0;
    my @dst;
    while ($idx < scalar(@lines)) {
        my $line = $lines[$idx];
        if ($line =~ /\/\/.*$/) {
            $line = $`;
        } 
        if ($line =~ /\/\*.*\*\//) {
            $line =~ s/\/\*[^*]*\*\///g;
        } elsif ($line =~ /\/\*/) {
            my $prefix = $`;
            while (($line !~ /\*\//) && ($idx < scalar(@lines))) {
                $idx ++;
                $line = $lines[$idx];
            }
            $line =~ s/.*\*\///;
            $line = "$prefix$line";
        }
        push @dst, $line;
        $idx ++;
    }
    return @dst;
}
