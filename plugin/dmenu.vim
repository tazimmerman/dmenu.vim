" dmenu.vim
"
" Maintainer: Troy Zimmerman
" Version: 1.0

if exists("g:loaded_dmenu") || &cp || v:version < 700
    finish
endif

let g:loaded_dmenu = 1

function! s:get_dmenu_cfg()
    if !exists("g:dmenu")
        let g:dmenu = {}
    endif

    if !has_key(g:dmenu, 'cmd')
        let g:dmenu.cmd='find .'
    endif

    if !has_key(g:dmenu, 'bg')
        let g:dmenu.bg=synIDattr(synIDtrans(hlID('Normal')), 'bg')
    endif

    if !has_key(g:dmenu, 'fg')
        let g:dmenu.fg=synIDattr(synIDtrans(hlID('Normal')), 'fg')
    endif

    if !has_key(g:dmenu, 'lines')
        let g:dmenu.lines=10
    endif

    return g:dmenu
endfunction

function! s:get_dmenu_cmd(prompt)
    let cfg = s:get_dmenu_cfg()
    let cmd = "dmenu -b -i"
    let cmd .= " -l " . get(cfg, 'lines')
    let cmd .= " -nb \"" . get(cfg, 'bg') . "\""
    let cmd .= " -nf \"" . get(cfg, 'fg') . "\""
    let cmd .= " -p " . a:prompt
    return cmd
endfunction

function! s:get_file_cmd(prompt)
    let cfg = s:get_dmenu_cfg()
    let cmd = get(cfg, 'cmd')
    let cmd .= " | "
    let cmd .= s:get_dmenu_cmd(a:prompt)
    return cmd
endfunction

function! s:get_buffer_cmd(prompt)
    return <SID>get_dmenu_cmd(a:prompt)
endfunction

function! s:open_file_dmenu(cmd)
    let cmd = s:get_file_cmd(a:cmd)
    let fn = substitute(system(cmd), '\n$', '', '')
    if !empty(fn)
        exec a:cmd . " " . fn
    endif
endfunction

function! s:get_listed_buffer_names()
    return map(filter(range(1, bufnr('$')), 'buflisted(v:val)'), 'bufname(v:val)')
endfunction

function! s:open_buffer_dmenu(cmd)
    let cmd = <SID>get_buffer_cmd(a:cmd)
    let buffers = <SID>get_listed_buffer_names()
    let fn = substitute(system(cmd, buffers), '\n$', '', '')
    if !empty(fn)
        exec a:cmd . " " . fn
    endif
endfunction

nnoremap <silent> <Plug>DmenuEdit :<C-U> call <SID>open_file_dmenu("edit")<CR>
nnoremap <silent> <Plug>DmenuSplit :<C-U> call <SID>open_file_dmenu("split")<CR>
nnoremap <silent> <Plug>DmenuVsplit :<C-U> call <SID>open_file_dmenu("vsplit")<CR>

nnoremap <silent> <Plug>DmenuBuf :<C-U> call <SID>open_buffer_dmenu("buf")<CR>
nnoremap <silent> <Plug>DmenuSbuf :<C-U> call <SID>open_buffer_dmenu("sbuf")<CR>
nnoremap <silent> <Plug>DmenuVertSbuf :<C-U> call <SID>open_buffer_dmenu("vert sbuf")<CR>
