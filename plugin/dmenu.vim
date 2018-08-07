" dmenu.vim
"
" Maintainer: Troy Zimmerman
" Version: 1.0

if exists("g:loaded_dmenu") || &cp || v:version < 700
    finish
endif

let g:loaded_dmenu = 1

function! s:get_repo(filepath)
    if len(a:filepath) != 0
        for type in ['git', 'hg', 'svn']
            let currpath = a:filepath
            while 1
                let prevpath = currpath
                let currpath = fnamemodify(currpath, ':h')
                let filename = currpath . (currpath == '/' ? '' : '/') . "." . type
                if filereadable(filename) || isdirectory(filename)
                    let info = {}
                    let info.repo_path = filename
                    let info.repo_type = type
                    return info
                endif
                if currpath == prevpath
                    break
                endif
            endwhile
        endfor
    endif
    return {}
endfunction

function! s:get_cwd()
    let fp = resolve(expand('%:p'))
    let fp = len(fp) == 0 ? getcwd() : fp
    return fp
endfunction

function! s:get_dmenu_cfg()
    if !exists("g:dmenu")
        let g:dmenu = {}
    endif

    if !has_key(g:dmenu, 'default_cmd')
        let g:dmenu.cmd='find .'
    endif

    if !has_key(g:dmenu, 'git_cmd')
        let g:dmenu.git_cmd = 'git ls-files'
    endif

    if !has_key(g:dmenu, 'hg_cmd')
        let g:dmenu.hg_cmd = 'hg manifest'
    endif

    if !has_key(g:dmenu, 'svn_cmd')
        let g:dmenu.svn_cmd = 'svn list'
    endif

    if !has_key(g:dmenu, 'menu_bg')
        let g:dmenu.menu_bg = synIDattr(synIDtrans(hlID('Pmenu')), 'bg')
    endif

    if !has_key(g:dmenu, 'menu_fg')
        let g:dmenu.menu_fg = synIDattr(synIDtrans(hlID('Pmenu')), 'fg')
    endif

    if !has_key(g:dmenu, 'select_bg')
        let g:dmenu.select_bg = synIDattr(synIDtrans(hlID('PmenuSel')), 'bg')
    endif

    if !has_key(g:dmenu, 'select_fg')
        let g:dmenu.select_fg = synIDattr(synIDtrans(hlID('PmenuSel')), 'fg')
    endif

    if !has_key(g:dmenu, 'max_lines')
        let g:dmenu.max_lines = 10
    endif

    if !has_key(g:dmenu, 'bottom_menu')
        let g:dmenu.bottom_menu = 0
    endif

    if !has_key(g:dmenu, 'case_insensitive')
        let g:dmenu.case_insensitive = 1
    endif

    return g:dmenu
endfunction

function! s:get_dmenu_cmd(prompt)
    let cfg = s:get_dmenu_cfg()
    let cmd = "dmenu "
    let cmd .= get(cfg, 'bottom_menu') ? " -b" : ""
    let cmd .= get(cfg, 'case_insensitive') ? " -i" : ""
    let cmd .= " -l " . get(cfg, 'max_lines')
    let cmd .= " -nb \"" . get(cfg, 'menu_bg') . "\""
    let cmd .= " -nf \"" . get(cfg, 'menu_fg') . "\""
    let cmd .= " -sb \"" . get(cfg, 'select_bg') . "\""
    let cmd .= " -sf \"" . get(cfg, 'select_fg') . "\""
    let cmd .= " -p " . a:prompt
    return cmd
endfunction

function! s:get_find_cmd(cfg, repo)
    if len(a:repo) == 0
        return get(a:cfg, 'default_cmd')
    else
        return get(a:cfg, get(a:repo, 'repo_type') . '_cmd')
    endif
endfunction

function! s:get_file_cmd(prompt)
    let cfg = s:get_dmenu_cfg()
    let cwd = s:get_cwd()
    let repo = s:get_repo(cwd)
    let cmd = s:get_find_cmd(cfg, repo)
    let cmd .= " | "
    let cmd .= s:get_dmenu_cmd(a:prompt)
    return cmd
endfunction

function! s:get_buffer_cmd(prompt)
    return s:get_dmenu_cmd(a:prompt)
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
    let cmd = s:get_buffer_cmd(a:cmd)
    let buffers = s:get_listed_buffer_names()
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

command! -nargs=0 DmenuGetCwd :echo <SID>get_cwd()
command! -nargs=0 DmenuIsRepo :echo <SID>get_repo(<SID>get_cwd())
