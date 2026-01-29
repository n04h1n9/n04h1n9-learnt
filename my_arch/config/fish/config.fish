if status is-interactive
    # Commands to run in interactive sessions can go here
end

#开头提示
set fish_greeting 你想何出什么样的意味

#yazi——终端文件管理器的有关配置
function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if read -z cwd <"$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

#vim你带我走吧😭
fish_vi_key_bindings

#设置别名
alias b='btop'
alias f='fastfetch'
alias yay='paru'
alias n='ncdu'
alias s='arch_news; sudo pacman -Syyuu && yay -Syyuu'

# fzf安装软件包
function pac --description "Fuzzy search and install packages (Official Repo first)"
    # --- 配置区域 ---
    # 1. 定义颜色 (ANSI 标准色，兼容 Matugen)
    set color_official "\033[34m"
    set color_aur "\033[35m"
    set color_reset "\033[0m"

    # 2. AUR 净化过滤器 (正则)
    # 修复点：这里必须用单引号 ''，否则正则表达式末尾的 $ 会被 fish 误判为变量
    set aur_filter '^(mingw-|lib32-|cross-|.*-debug$)'

    # --- 逻辑区域 ---
    set preview_cmd 'paru -Si {2}'

    # 生成列表 -> 过滤 -> 上色 -> fzf
    set packages (begin
        # 1. 官方源：蓝色前缀
        pacman -Sl | awk -v c=$color_official -v r=$color_reset \
            '{printf "%s%-10s%s %-30s %s\n", c, $1, r, $2, $3}'

        # 2. AUR 源：紫色前缀 + 过滤垃圾包
        paru -Sl aur | grep -vE "$aur_filter" | awk -v c=$color_aur -v r=$color_reset \
            '{printf "%s%-10s%s %-30s %s\n", c, $1, r, $2, $3}'
    end | \
    fzf --multi --ansi \
        --preview $preview_cmd --preview-window=right:60%:wrap \
        --height=95% --layout=reverse --border \
        --tiebreak=index \
        --nth=2 \
        --header 'Tab:多选 | Enter:安装 | Esc:退出' \
        --query "$argv" | \
    awk '{print $2}') # 直接提取纯净包名

    # --- 执行安装 ---
    if test -n "$packages"
        echo "正在准备安装: $packages"
        # 修复点：直接使用 $packages 列表，不要再用 awk 处理，否则多选会失效
        yay -S $packages
    end
end
# fzf卸载软件包
function pacr --description "Fuzzy find and remove packages (UI matched with pac)"
    # --- 配置区域 ---
    # 1. 定义颜色 (保持与 pac 一致)
    set color_official "\033[34m"
    set color_aur "\033[35m"
    set color_reset "\033[0m"

    # --- 逻辑区域 ---
    # 预览命令：查询本地已安装详细信息 (-Qi)，目标是第2列(包名)
    set preview_cmd 'paru -Qi {2}'

    # 生成列表 -> 上色 -> fzf
    set packages (begin
        # 1. 官方源安装 (Native): 蓝色前缀 [local]
        pacman -Qn | awk -v c=$color_official -v r=$color_reset \
            '{printf "%s%-10s%s %-30s %s\n", c, "local", r, $1, $2}'

        # 2. AUR/外部源安装 (Foreign): 紫色前缀 [aur]
        pacman -Qm | awk -v c=$color_aur -v r=$color_reset \
            '{printf "%s%-10s%s %-30s %s\n", c, "aur", r, $1, $2}'
    end | \
    fzf --multi --ansi \
        --preview $preview_cmd --preview-window=right:60%:wrap \
        --height=95% --layout=reverse --border \
        --tiebreak=index \
        --nth=2 \
        --header 'Tab:多选 | Enter:卸载 | Esc:退出' \
        --query "$argv" | \
    awk '{print $2}') # 提取第2列纯净包名

    # --- 执行卸载 ---
    if test -n "$packages"
        echo "正在准备卸载: $packages"
        # -Rns: 递归删除配置文件和不再需要的依赖
        paru -Rns $packages
    end
end

# --- 新增功能：Arch 新闻推送 (仿 CachyOS) ---
function arch_news
    # Python 脚本：获取 -> 显示 -> 交互
    python -c "
import urllib.request, xml.etree.ElementTree as ET, webbrowser, sys

try:
    print('\033[1;36m:: 正在获取 Arch Linux 最新公告...\033[0m')
    url = 'https://archlinux.org/feeds/news/'
    # 存储链接的列表
    links = []
    
    with urllib.request.urlopen(url, timeout=3) as response:
        root = ET.fromstring(response.read())
        
        print('\n\033[1;36m:: Arch Linux News (Top 5)\033[0m')
        
        # 遍历前5条
        items = root.findall('./channel/item')[:5]
        for idx, item in enumerate(items, 1):
            title = item.find('title').text
            link = item.find('link').text
            date = item.find('pubDate').text[5:16]
            
            links.append(link)
            # 格式: [1] [日期] 标题
            print(f'\033[1;32m[{idx}]\033[0m \033[35m[{date}]\033[0m {title}')

    # 交互循环
    while True:
        try:
            # 提示输入
            choice = input('\n\033[1;33m>> 输入序号查看详情，或按 Enter 继续更新: \033[0m')
            
            if not choice:
                break # 回车跳出循环，继续执行 fish 脚本
            
            if choice.isdigit():
                i = int(choice) - 1
                if 0 <= i < len(links):
                    print(f'   正在打开: {links[i]}')
                    webbrowser.open(links[i])
                else:
                    print('   序号无效')
            else:
                break
        except KeyboardInterrupt:
            sys.exit(1) # Ctrl+C 彻底终止
except Exception as e:
    print(f'\033[31m[!] 获取或解析失败: {e}\033[0m\n')
"
end

#让cargo的东西可用
fish_add_path ~/.cargo/bin
