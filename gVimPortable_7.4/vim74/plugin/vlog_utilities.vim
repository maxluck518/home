amenu Vlog-Utilities.--Automatic--      :
amenu Vlog-Utilities.Auto-Port          :AutoPort<CR>
amenu Vlog-Utilities.Auto-Instance      :AutoInst<CR>
amenu Vlog-Utilities.Auto-Define        :AutoDef<CR>
amenu Vlog-Utilities.Auto-Generate      :AutoGen<CR>
amenu Vlog-Utilities.Auto-Interface     :AutoInf<CR>
amenu Vlog-Utilities.--Template--       :
amenu Vlog-Utilities.File-Header        :call Header()<CR>
amenu Vlog-Utilities.Flip-Flop          :Flop<CR>


command -nargs=* AutoPort       :0,$ !perl F:/mjw/vim/gVimPortable_7.4/vlog_aide/src/auto_port.pl <args>
command -nargs=* AutoInf        :0,$ !perl F:/mjw/vim/gVimPortable_7.4/vlog_aide/src/auto_inf.pl <args>
command AutoInst                :0,$ !perl F:/mjw/vim/gVimPortable_7.4/vlog_aide/src/auto_inst.pl
command AutoDef                 :0,$ !perl F:/mjw/vim/gVimPortable_7.4/vlog_aide/src/auto_define.pl
command AutoGen                 :0,$ !perl F:/mjw/vim/gVimPortable_7.4/vlog_aide/src/auto_gen.pl
command Flop                    :. !perl F:/mjw/vim/gVimPortable_7.4/vlog_aide/src/template.pl flop.v
command -nargs=* Tmp            :. !perl F:/mjw/vim/gVimPortable_7.4/vlog_aide/src/template.pl <args>

function Header()
    let filename = bufname("%")
    let date = strftime("%Y-%m-%d %H:%M")
    let command = "$VLOG_AIDE_HOME/src/template.pl header.v " . filename . " $USER " . date
    let line = system(command)
    let lines = split(line, "\n")
    call append(0, lines)
endfunction
