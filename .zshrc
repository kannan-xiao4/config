# copy from https://qiita.com/maejimayuto/items/01216e6255c156fa7bf4
# and need 'brew install zsh-completions'

## lang
export LANG=ja_JP.UTF-8

## zsh-completions
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
  autoload -Uz compinit
  compinit
fi

## completion option
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'  # 補完候補で、大文字・小文字を区別しないで補完出来るようにするが、大文字を入力した場合は区別する
zstyle ':completion:*' ignore-parents parent pwd ..  # ../ の後は今いるディレクトリを補間しない
zstyle ':completion:*:default' menu select=1  # 補間候補一覧上で移動できるように
zstyle ':completion:*:cd:*' ignore-parents parent pwd  # 補間候補にカレントディレクトリは含めない

## history
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

setopt share_history           # 履歴を他のシェルとリアルタイム共有する

setopt hist_ignore_all_dups    # 同じコマンドをhistoryに残さない
setopt hist_ignore_space       # historyに保存するときに余分なスペースを削除する
setopt hist_reduce_blanks      # historyに保存するときに余分なスペースを削除する
setopt hist_save_no_dups       # 重複するコマンドが保存されるとき、古い方を削除する
setopt inc_append_history      # 実行時に履歴をファイルにに追加していく

## keybind
bindkey -e

## search history
# ctr+r で検索

# コマンドの途中でctrl-pでそのコマンドから始まる履歴検索
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^p" history-beginning-search-backward-end
bindkey "^n" history-beginning-search-forward-end

## alias
alias ls='ls -F'
alias la='ls -Fa'
alias ll='ls -Flh'
alias lla='ls -Falh'
alias ..='cd ../'
alias ...='cd ../../'
alias dcom='docker-compose'
alias dk='docker'
alias gcl="git fetch --prune; git br --merged master | grep -vE '^\*|master$|develop$' | xargs -I % git branch -d % ; git br --merged main | grep -vE '^\*|main$|develop$' | xargs -I % git branch -d % ; git br --merged develop | grep -vE '^\*|master$|develop$' | xargs -I % git branch -d %; git br -vv"

## chpwd
# cdの後にlsを実行

chpwd() {
    ls_abbrev
}

ls_abbrev() {
    # -a : Do not ignore entries starting with ..
    # -C : Force multi-column output.
    # -F : Append indicator (one of */=>@|) to entries.
    local cmd_ls='ls'
    local -a opt_ls
    opt_ls=('--color=always' '-aFlh')
    case "${OSTYPE}" in
        freebsd*|darwin*)
            if type gls > /dev/null 2>&1; then
                cmd_ls='gls'
            else
                # -G : Enable colorized output.
                opt_ls=('-CFG')
            fi
            ;;
    esac

    local ls_result
    ls_result=$(CLICOLOR_FORCE=1 COLUMNS=$COLUMNS command $cmd_ls ${opt_ls[@]} | sed $'/^\e\[[0-9;]*m$/d')

    local ls_lines=$(echo "$ls_result" | wc -l | tr -d ' ')

    if [ $ls_lines -gt 30 ]; then
        echo "$ls_result" | head -n 15
        echo '...'
        echo "$ls_result" | tail -n 15
        echo "$(command ls -1a | wc -l | tr -d ' ') files exist"
    else
        echo "$ls_result"
    fi
}

# copy from
# https://qiita.com/koki0527/items/ca734df6fa86a8dbd241
# ここら下はbranch名を表示させるメソッドの設定-----------------------------
function rprompt-git-current-branch {
  local branch_name st branch_status

  if [ ! -e  ".git" ]; then
    # gitで管理されていないディレクトリは何も返さない
    return
  fi
  branch_name=`git rev-parse --abbrev-ref HEAD 2> /dev/null`
  st=`git status 2> /dev/null`
  if [[ -n `echo "$st" | grep "^nothing to"` ]]; then
    # 全てコミットされてクリーンな状態
    branch_status=""
  elif [[ -n `echo "$st" | grep "^Untracked files"` ]]; then
    # gitに管理されていないファイルがある状態
    branch_status=" !"
  elif [[ -n `echo "$st" | grep "^Changes not staged for commit"` ]]; then
    # git addされていないファイルがある状態
    branch_status=" *"
  elif [[ -n `echo "$st" | grep "^Changes to be committed"` ]]; then
    # git commitされていないファイルがある状態
    branch_status=" +"
  elif [[ -n `echo "$st" | grep "^rebase in progress"` ]]; then
    # コンフリクトが起こった状態
    echo "%F{red} !!"
    return
  else
    # 上記以外の状態の場合は青色で表示させる
    branch_status=""
  fi
  # ブランチ名を色付きで表示する
  echo "($branch_name${branch_status})"
}

# プロンプトが表示されるたび、毎回プロンプトの文字列を評価し、置換する
setopt prompt_subst

# ここら下はプロンプトの表示設定-----------------------------
PROMPT='%F{cyan}[%n@%m]%F{white}: %B%~%b `rprompt-git-current-branch`
$ '
