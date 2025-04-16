
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /Users/sergioghislergomez/miniconda3/bin/conda
    eval /Users/sergioghislergomez/miniconda3/bin/conda "shell.fish" "hook" $argv | source
else
    if test -f "/Users/sergioghislergomez/miniconda3/etc/fish/conf.d/conda.fish"
        . "/Users/sergioghislergomez/miniconda3/etc/fish/conf.d/conda.fish"
    else
        set -x PATH "/Users/sergioghislergomez/miniconda3/bin" $PATH
    end
end
# <<< conda initialize <<<

