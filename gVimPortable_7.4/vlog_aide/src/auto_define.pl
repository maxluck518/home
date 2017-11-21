#!/usr/bin/perl

my %ff_reg;
my %comb_reg;
my %wire;
my %inst_output;
my %user_def;
my @src;
my @dst;
my @tmp;
my @ptrs;
my %output_reg;
my %output_unexplict;

while (<STDIN>) {
    chomp;
    push @src, $_;
}
# remove already existed auto defines
@src = &remove_defined(@src);
# remove commonets
@tmp = &pre_filter(@src);
# get output signals
@ptrs = &get_outputs(\@tmp);
%output_reg = %{$ptrs[0]};
%output_unexplict = %{$ptrs[1]};
# get output signals from auto instance
@ptrs = &get_inst_output_wire(\@src, \%output_unexplict);
@tmp = @{$ptrs[0]};
%inst_output = %{$ptrs[1]};
@tmp = &pre_filter(@tmp);
# transale to recommand format
@tmp = &re_format(@tmp);
# remove for, initial and instantces statements
@tmp = &post_filter(@tmp);
# get user defined signals
%user_def = &get_user_signals(@tmp);
@ptrs = &get_reg("<=", \@tmp, \%user_def, \%output_reg, \%output_unexplict);
%ff_reg = %{$ptrs[0]};
%output_unexplict = %{$ptrs[1]};
@ptrs = &get_reg("=", \@tmp, \%user_def, \%output_reg, \%output_unexplict);
%comb_reg = %{$ptrs[0]};
%output_unexplict = %{$ptrs[1]};
@ptrs = &get_wire(\@tmp, \%user_def, \%output_unexplict);
%wire = %{$ptrs[0]};
%output_unexplict = %{$ptrs[1]};
#%output_unexplict = &remove_unexplict(\%output_unexplict, \%ff_reg, \%comb_reg);
@ptrs = &add_margin(\%ff_reg, \%comb_reg, \%wire, \%inst_output);
%ff_reg = %{$ptrs[0]};
%comb_reg = %{$ptrs[1]};
%wire = %{$ptrs[2]};
%inst_output = %{$ptrs[3]};
@dst = &insert_def(\@src, \%ff_reg, \%comb_reg, \%wire, \%inst_output, \%user_def, \%output_reg, \%output_unexplict);

foreach (@dst) {
    print "$_\n";
}

sub remove_defined {
    my @lines = @_;
    my $idx = 0;
    my @dst;
    while ($idx < scalar(@lines)) {
        my $line = $lines[$idx];
        if ($line =~ /\/\/\s*vlog_aide\s*:\s*auto_define/) {
            push @dst, "/*vlog_aide:auto_define*/";
        } elsif ($line =~ /\/\*vlog_aide:auto_define begin\*\//) {
            $idx ++;
            $line = $lines[$idx];
            while ($line !~ /\/\*vlog_aide:auto_define end\*\//) {
                $idx ++;
                $line = $lines[$idx];
            }
        } elsif ($line !~ /\/\*\s*vlog_aide\s*:\s*auto_define\s+user defined signals\*\//) {
            push @dst, $line;
        }
        $idx ++;
        $line = $lines[$idx];
    }
    return @dst;
}

sub get_outputs {
    my @lines = @{$_[0]};
    my $idx = 0;
    my %explict;
    my %unexplict;
    while ($idx < scalar(@lines)) {
        my $line = $lines[$idx];
        $line =~ s/;.*$//;
        if ($line =~ /\s*output\s+reg\s+signed\s*(\[.*\])*\s*(.*)/) {
            my $signal_exp = $2;
            $signal_exp =~ s/\s//g;
            my @signal = split /,/, $signal_exp;
            foreach (@signal) {
                $explict{$_} = "reg signed $1";
            }
        } elsif ($line =~ /\s*output\s+reg\s*(\[.*\])*\s*(.*)/) {
            my $signal_exp = $2;
            $signal_exp =~ s/\s//g;
            my @signal = split /,/, $signal_exp;
            foreach (@signal) {
                $explict{$_} = "reg $1";
            }
        } elsif ($line =~ /\s*(output|inout)\s*signed\s*(\[.*\])*\s*(.*)/) {
             my $signal_exp = $3;
            $signal_exp =~ s/\s//g;
            my @signal = split /,/, $signal_exp;
            foreach (@signal) {
                $explict{$_} = "wire signed $2";
            }
        } elsif ($line =~ /\s*(output|inout)\s*(\[.*\])*\s*(.*)/) {
            my $signal_exp = $3;
            $signal_exp =~ s/\s//g;
            my @signal = split /,/, $signal_exp;
            foreach (@signal) {
                $unexplict{$_} = "wire $2";
            }
        }  
        $idx ++;
    }
    return (\%explict, \%unexplict);
}

sub get_inst_output_wire {
    my @lines = @{$_[0]};
    my %unexplict = %{$_[1]};
    my @dst;
    my %inst_outputs;
    my $idx = 0;
    my %inst_ports;
    my @module_outputs;
    my %inst_outputs;
    my $inst_file;
    while ($idx < scalar(@lines)) {
        my $line = $lines[$idx];
        if ($line =~ /^\s*(\w+)\s*(#\([^()]*\))*\s*\w+\s*\((.*)\)\s*;/) {
            $inst_file = $1 . ".v";
            my $port_list = $3;
            $port_list =~ s/\s//g;
            my @ports = split /,/, $port_list;
            foreach (@ports) {
                if ($_ =~ /\.(\w+)\((.*)\)/) {
                    $inst_ports{$1} = $2;
                }
            }
            @module_outputs = &get_module_outputs($inst_file);
            %inst_outputs = &get_inst_outputs(\%inst_ports, \@module_outputs, \%unexplict, \%inst_outputs);
        } elsif ($line =~ /^\s*(\w+)\b\s*(#\([^()]*\))*\s*\b(\w+)\b\s*\(/) {
            if (($1 ne 'if') && ($1 ne 'while') && ($1 ne 'for') && ($1 ne 'case') && ($1 ne 'casex') && ($1 ne 'casez') && ($1 ne 'module')) {
                $inst_file = $1 . ".v";
                while (1) {
                    $line =~ s/\s//g;
                    if ($line =~ /\.(\w+)\((.*)\)/) {
                        $inst_ports{$1} = $2;
                    }
                    if (($line =~ /\)\s*;/) || ($idx >= scalar(@lines))) {
                        last;
                    } else {
                        $idx ++;
                        $line = $lines[$idx];
                    }
                }
            }
            @module_outputs = &get_module_outputs($inst_file);
            %inst_outputs = &get_inst_outputs(\%inst_ports, \@module_outputs, \%unexplict, \%inst_outputs);
        } else {
            push @dst, $line;
        }
        $idx ++;
    }
    return (\@dst, \%inst_outputs);
}

sub get_module_outputs {
    my $inst_file = $_[0];
    my @rtl_path = split /:/, $ENV{"VLOG_AIDE_RTL_PATH"};
    my @outputs;
    foreach my $path (@rtl_path) {
        if (-e "$path/$inst_file") {
            open FP, "<$path/$inst_file";
            while (<FP>) {
                chomp;
                my $line = $_;
                if ($line =~ /^\s*output\s*(reg|wire)*\s*(signed)*\s*(\[.*\])*\s*(.*)/) {
                    my $tmp = $4;
                    $tmp =~ s/\s//g;
                    $tmp =~ s/\)\s*;//;
                    $tmp =~ s/;//;
                    my @signals = split /,/, $tmp;
                    foreach (@signals) {
                        push @outputs, $_;
                    }
                } elsif ($line =~ /^\s*inout\s*(wire)*\s*(signed)*\s*(\[.*\])*\s*(.*)/) {
                    my $tmp = $4;
                    $tmp =~ s/\s//g;
                    $tmp =~ s/\)\s*;//;
                    $tmp =~ s/;//;
                    my @signals = split /,/, $tmp;
                    foreach (@signals) {
                        push @outputs, $_;
                    }
                }
            }
            return @outputs;
        }
    }
    return @outputs;
}

sub get_inst_outputs {
    my %ports = %{$_[0]};
    my @outputs = @{$_[1]};
    my %unexplict = %{$_[2]};
    my %inst_outputs = %{$_[3]};
    foreach my $output (@outputs) {
        if (exists $ports{$output}) {
            $output = $ports{$output};
            if ($output =~ /(\w+)\[(\d+):/) {
                my $wire = $1;
                my $width = $2;
                unless (exists $unexplict{$wire}) {
                    if (exists $inst_outputs{$wire}) {
                        if ($inst_outputs{$wire} =~ /^\d+$/) {
                            if ($inst_outputs{$wire} < $width) {
                                $inst_outputs{$wire} = $width;
                            }
                        }
                    } else {
                        $inst_outputs{$wire} = $width;
                    }
                }
            } elsif ($output =~ /(\w+)\[(.*):/) {
                my $wire = $1;
                my $width = $2;
                unless (exists $unexplict{$wire}) {
                    $inst_outputs{$wire} = $width;
                }
            } elsif ($output =~ /^(\w+)$/) {
                my $wire = $1;
                unless (exists $unexplict{$wire}) {
                    $inst_outputs{$wire} = "0";
                }
            }
        }
    }
    return %inst_outputs;
}

sub re_format {
    my @lines = @_;
    my @dst;
    my $idx = 0;
    while ($idx < scalar(@lines)) {
        my $line = $lines[$idx];
        while ($line =~ /\\\s*$/) {
            $idx ++;
            $line = $` . $lines[$idx];
        }
        if (($line =~ /^\s*begin\s+/) || ($line =~ /^\s*begin$/)) {
            my $pre_line = pop @dst;
            $line = "$pre_line $line";
        }
        if ($line =~ /begin\s+\S+.*$/) {
            push @dst, "$` begin";
            $line =~ s/^.*begin\s+//;
        }
        if ($line =~ /^(\s*\S+.*\W+)end\s*$/) {
            push @dst, $1;
            $line = "end";
        }
        if ($line =~ /^\s*for\s*\(.*\)\s*$/) {
            $idx ++;
            $line = $line . $lines[$idx];
        }
        push @dst, $line;
        $idx ++;
    }
    return @dst;
}

sub pre_filter {
    my @lines = @_;
    my @dst;
    my $idx = 0;
    while ($idx < scalar(@lines)) {
        my $line = $lines[$idx];
        if ($line =~ /\/\//) {
        } elsif ($line =~ /\/\*.*\*\//) {
            push @dst, "$` $'";
        } elsif ($line =~ /\/\*/) {
            while ($line !~ /\*\//) {
                $idx ++;
                $line = $lines[$idx];
            }
        } else {
            push @dst, $line;
        }
        $idx ++;
    }
    return @dst;
}

sub post_filter {
    my @lines = @_;
    my @dst;
    my $idx = 0;
    while ($idx < scalar(@lines)) {
        my $line = $lines[$idx];
        if ($line =~ /^\s*function\s+/) {
            while ($line !~ /^\s*endfunction/) {
                $idx ++;
                $line = $lines[$idx];
            }
        } elsif ($line =~ /^\s*task\s+/) {
            while ($line !~ /^\s*endtask/) {
                $idx ++;
                $line = $lines[$idx];
            }
        } elsif ($line =~ /^\s*for\s*\(/) {
            my $offset = 0;
            if ($line =~ /\W+begin\s*$/) {
                $offset = 1;
            }
            while (($offset > 0) && ($idx < scalar(@lines))) {
                $idx ++;
                $line = $lines[$idx];
                if ($line =~ /\W+begin\s*$/) {
                    $offset ++;
                } elsif ($line =~ /\s*end\s*$/) {
                    $offset --;
                }
            }
        } elsif ($line =~ /^\s*initial\s+/) {
            my $offset = 0;
            if ($line =~ /\W+begin\s*$/) {
                $offset = 1;
            }
            while (($offset > 0) && ($idx < scalar(@lines))) {
                $idx ++;
                $line = $lines[$idx];
                if ($line =~ /\W+begin\s*$/) {
                    $offset ++;
                } elsif ($line =~ /\s*end\s*$/) {
                    $offset --;
                }
            }
        } else {
            push @dst, $line;
        }
        $idx ++;
    }
    return @dst;
}

sub get_user_signals {
    my @lines = @_;
    my $idx = 0;
    my %user_def;
    while ($idx < scalar(@lines)) {
        my $line = $lines[$idx];
        if ($line =~ /^\s*(reg|wire)\s+(signed)*\s*(\[.*\])*/) {
            my $signal_expr = $';
            my $define_expr = $&;
            $signal_expr =~ s/\s//g;
            $signal_expr =~ s/;//;
            my @signals = split /,/, $signal_expr;
            foreach (@signals) {
                $user_def{$_} = $define_expr;
            }
        }
        $idx ++;
    }
    return %user_def;
}

sub get_reg {
    my $opt = $_[0];
    my @lines = @{$_[1]};
    my %user_def = %{$_[2]};
    my %explict = %{$_[3]};
    my %unexplict = %{$_[4]};
    my %regs;
    my %sum_regs;
    my $idx = 0;
    while ($idx < scalar(@lines)) {
        my @ptrs;
        if ($opt eq '<=') {
            @ptrs = &find_ff_block($idx, \@lines);
        } else {
            @ptrs = &find_comb_block($idx, \@lines);
        }
        my @block = @{$ptrs[0]};
        $idx = $ptrs[1];
        %regs = &find_reg($opt, \@block, \%user_def, \%explict);
        foreach my $reg (keys %regs) {
            if (exists $user_def{$reg}) {
            } elsif (exists $explict{$reg}) {
            } elsif (exists $unexplict{$reg}) {
                if ($unexplict{$reg} =~ /wire\s+\[(.+)\s*:.*\]/) {
                    $sum_regs{$reg} = $1;
                } else {
                    $sum_regs{$reg} = "0";
                }
                delete $unexplict{$reg};
            } elsif (exists $sum_regs{$reg}) {
                if ($regs{$reg} =~ /^\d+$/) {
                    if ($sum_regs{$reg} =~ /^\d+$/) {
                        if ($regs{$reg} > $sum_regs{$reg}) {
                            $sum_regs{$reg} = $regs{$reg};
                        }
                    }
                } elsif ($sum_regs{$reg} =~ /^\d+$/) {
                    $sum_regs{$reg} = $regs{$reg};
                }
            } else {
                $sum_regs{$reg} = $regs{$reg};
            }
        }
    }
    return (\%sum_regs, \%unexplict);
}

sub find_ff_block {
    my $idx = $_[0];
    my @lines = @{$_[1]};
    my @dst;
    while ($idx < scalar(@lines)) {
        my $line = $lines[$idx];
        if ($line =~ /^\s*always\s*@\s*\((posedge|negedge).*\bbegin\b/) {
            my $offset = 1;
            $idx ++;
            $line = $lines[$idx];
            while (($offset > 0) && ($idx < scalar(@lines))) {
                if ($line =~ /\bbegin\b/) {
                    $offset ++;
                } elsif ($line =~ /\bend\b/) {
                    $offset --;
                }
                push @dst, $line;
                $idx ++;
                $line = $lines[$idx];
            }
            my $tmp = pop @dst;
            return (\@dst, $idx);
        } elsif ($line =~ /^\s*always\s*@\s*\((posedge|negedge)/) {
            $idx ++;
            $line = $lines[$idx];
            while (($line !~ /^\s*always\W+/) && ($line !~ /^\s*assign\s+/) && ($line !~ /^\s*\w+\s*#\s*\(.*\)\s*\w+\s*\(/) && ($line !~ /^\s*endmodule/)) {
                if ($line =~ /^\s*(\w+)\s+(\w+)\s*\(/) {
                    if (($1 ne "if") && ($1 ne "else") && ($1 ne "case") && ($1 ne "casex") && ($1 ne "casez") && ($1 ne "for")) {
                        last;
                    }
                }
                push @dst, $line;
                $idx ++;
                $line = $lines[$idx];
            }
            $idx --;
            return (\@dst, $idx);
        }
        $idx ++;
    }
    push @dst, "null";
    return (@dst, $idx);
}
                
sub find_reg {
    my $opt = $_[0];
    my @lines = @{$_[1]};
    my %user_def = %{$_[2]};
    my %explict = %{$_[3]};
    my $idx = 0;
    my %regs;
    while ($idx < scalar(@lines)) {
        my $line = $lines[$idx];
        if ($line =~ /^\s*if\s*\(/) {
            my $offset = 1;
            $line = $';
            while ($offset > 0) {
                if ($line =~ /^[^()]*\(/) {
                    $line = $';
                    $offset ++;
                } elsif ($line =~ /^[^()]*\)/) {
                    $line = $';
                    $offset --
                }
                else {
                    die "Incomplete if statement!";
                }
            }
        }
        if ($line =~ /\w+\s*\?/) {
            $line =~ s/\w+\s*\?//g;
        }
        if ($line =~ /\)\s*\?/) {
            while ($line =~ /\)\s*\?/) {
                my $offset = 1;
                my $prefix = $`;
                my $suffix = $';
                while ($offset > 0) {
                    if ($prefix =~ /\([^()]*$/) {
                        $prefix = $`;
                        $offset --;
                    } elsif ($prefix =~ /\)[^()]*$/) {
                        $prefix = $`;
                        $offset ++;
                    } else {
                        die "incomplete ()? statement! $prefix, $&\n";
                    }
                }
                $line = "$prefix$suffix";
            }
        }
        if ($line =~ /$opt/) {
             while (($line !~ /;\s*$/) && ($idx < scalar(@lines))) {
                $idx ++;
                $line = $line . $lines[$idx];
            }
        }
        if ($line =~ /\s*$opt\s*(#\s*\S+)*\s*/) {
            my $drive = $`;
            my $load = $';
            my $width;
            $drive =~ s/\s//g;
            $load =~ s/\s//g;
            if ($drive =~ /(\w+)\s*\[(\d+)(:|\])/) {
                $drive = $1;
                $width = $2;
                if (! ((exists $explict{$drive}) | (exists $user_def{$drive})))  {
                    if (exists $regs{$drive}) {
                        if ($regs{$drive} =~ /^\d+$/) {
                            if ($width > $regs{$drive}) {
                                $regs{$drive} = $width;
                            }
                        }
                    } else {
                        $regs{$drive} = $width;
                    }
                }
            } elsif ($drive =~ /(\w+)$/) {
                $drive = $1;
                if ($load =~ /(\d+)'(h|d|b)/) {
                    $width = $1;
                    if (! ((exists $explict{$drive}) | (exists $user_def{$drive})))  {
                        if (exists $regs{$drive}) {
                            if ($regs{$drive} =~ /^\d+$/) {
                                if ($width > $regs{$drive}) {
                                    $regs{$drive} = $width - 1;
                                }
                            }
                        } else {
                            $regs{$drive} = $width - 1;
                        }
                    }
                } elsif (! ((exists $explict{$drive}) | (exists $user_def{$drive}) | (exists $regs{$drive})))  {
                    $regs{$drive} = "0";
                }
            } elsif ($drive =~ /(\w+)\s*\[(.*):/) {
                $drive = $1;
                $width = $2;
                if (! ((exists $explict{$drive}) | (exists $user_def{$drive}))) {
                    $regs{$drive} = "$width";
                }
            } elsif ($drive =~ /(\w+)\s*\[(.*)\]/) {
                $drive = $1;
                $width = $2;
                if (! ((exists $explict{$drive}) | (exists $user_def{$drive}))) {
                    $regs{$drive} = "$width";
                }
            }
        }
        $idx ++;
    }
    return %regs;
}

sub find_comb_block {
    my $idx = $_[0];
    my @lines = @{$_[1]};
    my @dst;
    while ($idx < scalar(@lines)) {
        my $line = $lines[$idx];
        if (($line =~ /^\s*always\s*@\(.*\)\s*\bbegin\b/) && ($line !~ /^\s*always\s*@\s*\((posedge|negedge)/)) {
            my $offset = 1;
            $idx ++;
            $line = $lines[$idx];
            while (($offset > 0) && ($idx < scalar(@lines))) {
                if ($line =~ /\bbegin\b/) {
                    $offset ++;
                } elsif ($line =~ /\bend\b/) {
                    $offset --;
                }
                push @dst, $line;
                $idx ++;
                $line = $lines[$idx];
            }
            my $tmp = pop @dst;
            return (\@dst, $idx);
        } elsif (($line =~ /^\s*always\s*@\s*\(.*\)/) && ($line !~ /^\s*always\s*@\s*\((posedge|negedge)/)) {
            $idx ++;
            $line = $lines[$idx];
            while (($line !~ /^\s*always\W+/) && ($line !~ /^\s*assign\s+/) && ($line !~ /^\s*\w+\s*#\s*\(.*\)\s*\w+\s*\(/) && ($line !~ /^\s*endmodule/)) {
                if ($line =~ /^\s*(\w+)\s+(\w+)\s*\(/) {
                    if (($1 ne "if") && ($1 ne "else") && ($1 ne "case") && ($1 ne "casex") && ($1 ne "casez") && ($1 ne "for")) {
                        last;
                    }
                }
                push @dst, $line;
                $idx ++;
                $line = $lines[$idx];
            }
            $idx --;
            return (\@dst, $idx);
        }
        $idx ++;
    }
    push @dst, "null";
    return (@dst, $idx);
}

sub get_wire {
    my @lines = @{$_[0]};
    my %unexplict = %{$_[1]};
    my %wire;
    my $idx = 0;
    while ($idx < scalar(@lines)) {
        my $line = $lines[$idx];
        while (($line =~ /^\s*assign\s+/) && ($line !~ /;\s*$/) && ($idx < scalar(@lines))) {
            $idx ++;
            $line = $line . $lines[$idx];
        }
        $line =~ s/\w+\s*\?//g;
        if ($line =~ /\)\s*\?/) {
            while ($line =~ /\)\s*\?/) {
                my $offset = 1;
                my $prefix = $`;
                my $suffix = $';
                while ($offset > 0) {
                    if ($prefix =~ /\([^()]*$/) {
                        $prefix = $`;
                        $offset --;
                    } elsif ($prefix =~ /\)[^()]*$/) {
                        $prefix = $`;
                        $offset ++;
                    } else {
                        die "incomplete ()? statement! $prefix, $&\n";
                    }
                }
                $line = "$prefix$suffix";
            }
        }
        if ($line =~ /^\s*assign\s+(.*)=(.*)/) {
            my $drive = $1;
            my $load = $2;
            my $width;
            $drive =~ s/\s//g;
            $load =~ s/\s//g;
            $drive =~ s/#\s*\S+//;
            if ($drive =~ /(\w+)$/) {
                $drive = $1;
                if ($load =~ /(\d+)'(h|d|b)/) {
                    $width = $1;
                    if (! ((exists $explict{$drive}) | (exists $user_def{$drive}))) {
                        if (exists $wire{$drive}) {
                            if ($wire{$drive} =~ /^\d+$/) {
                                if ($width > $wire{$drive}) {
                                    $wire{$drive} = $width - 1;
                                }
                            }
                        } else {
                            $wire{$drive} = $width - 1;
                        }
                    }
                }
            } elsif ($drive =~ /(\w+)\s*\[(.*):/) {
                $drive = $1;
                $width = $2;
                if (! ((exists $explict{$drive}) | (exists $user_def{$drive}))) {
                    $wire{$drive} = $width;
                }
            } elsif ($drive =~ /(\w+)\s*\[(.*)\]/) {
                $drive = $1;
                $width = $2;
                if (! ((exists $explict{$drive}) | (exists $user_def{$drive}))) {
                    $wire{$drive} = $width;
                }
            }
        }
        $idx ++;
    }
    return (\%wire, \%unexplict);
}

sub remove_unexplict {
    my %unexplict = %{$_[0]};
    my %ff_reg = %{$_[1]};
    my %comb_reg = %{$_[2]};
    foreach (keys %ff_reg) {
        if (exists $unexplict{$_}) {
            delete $unexplict{$_};
        }
    }
    foreach (keys %comb_reg) {
        if (exists $unexplict{$_}) {
            delete $unexplict{$_};
        }
    }
    return %unexplict;
}

sub add_margin {
    my %ff_reg = %{$_[0]};
    my %comb_reg = %{$_[1]};
    my %wire = %{$_[2]};
    my %inst_output = %{$_[3]};
    my $max_len = 0;
    foreach my $key (keys %ff_reg) {
        if ($ff_reg{$key} eq "0") {
            $ff_reg{$key} = "reg  ";
        } else {
            $ff_reg{$key} = "reg  [" . $ff_reg{$key} . ":0] ";
        }
        if ($max_len < length($ff_reg{$key})) {
            $max_len = length($ff_reg{$key});
        }
    }
    foreach my $key (keys %comb_reg) {
        if ($comb_reg{$key} eq "0") {
            $comb_reg{$key} = "reg  ";
        } else {
            $comb_reg{$key} = "reg  [" . $comb_reg{$key} . ":0] ";
        }
        if ($max_len < length($comb_reg{$key})) {
            $max_len = length($comb_reg{$key});
        }
    }
    foreach my $key (keys %wire) {
        if ($wire{$key} eq "0") {
            $wire{$key} = "wire ";
        } else {
            $wire{$key} = "wire [" . $wire{$key} . ":0] ";
        }
        if ($max_len < length($wire{$key})) {
            $max_len = length($wire{$key});
        }
    }
    foreach my $key (keys %inst_output) {
        if ($inst_output{$key} eq "0") {
            $inst_output{$key} = "wire ";
        } else {
            $inst_output{$key} = "wire [" . $inst_output{$key} . ":0] ";
        }
        if ($max_len < length($inst_output{$key})) {
            $max_len = length($inst_output{$key});
        }
    }
    foreach my $key (keys %ff_reg) {
        my $margin_len = $max_len - length($ff_reg{$key});
        $ff_reg{$key} = $ff_reg{$key} . (" " x $margin_len);
    }
    foreach my $key (keys %comb_reg) {
        my $margin_len = $max_len - length($comb_reg{$key});
        $comb_reg{$key} = $comb_reg{$key} . (" " x $margin_len);
    }
    foreach my $key (keys %wire) {
        my $margin_len = $max_len - length($wire{$key});
        $wire{$key} = $wire{$key} . (" " x $margin_len);
    }
    foreach my $key (keys %inst_output) {
        my $margin_len = $max_len - length($inst_output{$key});
        $inst_output{$key} = $inst_output{$key} . (" " x $margin_len);
    }
    return (\%ff_reg, \%comb_reg, \%wire, \%inst_output);
}

sub insert_def {
    my @lines = @{$_[0]};
    my %ff_reg = %{$_[1]};
    my %comb_reg = %{$_[2]};
    my %wire = %{$_[3]};
    my %inst_output = %{$_[4]};
    my %user_def = %{$_[5]};
    my %explict = %{$_[6]};
    my @dst;
    my $idx = 0;
    while ($idx < scalar(@lines)) {
        my $line = $lines[$idx];
        if ($line =~ /^\s*\/\*\s*vlog_aide\s*:\s*auto_define\s*\*\//) {
            push @dst, "//vlog_aide:auto_define";
            push @dst, "/*vlog_aide:auto_define begin*/";
            push @dst, "/*vlog_aide:auto_define reg signals in sequential blocks*/";
            foreach my $key (keys %ff_reg) {
                push @dst, $ff_reg{$key} . "$key;";
            }
            push @dst, "/*vlog_aide:auto_define reg signals in combinational blocks*/";
            foreach my $key (keys %comb_reg) {
                push @dst, $comb_reg{$key} . "$key;";
            }
            push @dst, "/*vlog_aide:auto_define wire signals in assign statements*/";
            foreach my $key (keys %wire) {
                push @dst, $wire{$key} . "$key;";
            }
            push @dst, "/*vlog_aide:auto_define wire signals of instances' outputs*/";
            foreach my $key (keys %inst_output) {
                push @dst, $inst_output{$key} . "$key;";
            }
            push @dst, "/*vlog_aide:auto_define signals of output ports*/";
            foreach my $key (keys %explict) {
                push @dst, $explict{$key} . " $key;";
            }
            foreach my $key (keys %unexplict) {
                push @dst, $unexplict{$key} . " $key;";
            }
            push @dst, "/*vlog_aide:auto_define end*/";
            push @dst, "/*vlog_aide:auto_define user defined signals*/";
            foreach my $key (keys %user_def) {
                push @dst, $user_def{$key} . " $key;";
            }
        } elsif (($line =~ /\/\*/) && ($line !~ /\*\//)) {
            while ($line !~ /\*\//) {
                push @dst, $line;
                $idx ++;
                $line = $lines[$idx];
            }
            push @dst, $line;
        } elsif ($line !~ /^\s*(reg|wire)\s+/) {
            push @dst, $line;
        }
        $idx ++;
    }
    return @dst;
}
