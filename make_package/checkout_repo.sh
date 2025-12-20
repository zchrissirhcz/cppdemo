normalize_git_url() {
    local url="$1"
    # 去掉末尾 .git
    url="${url%.git}"
    # 转小写
    url=$(echo "$url" | tr '[:upper:]' '[:lower:]')
    # 移除协议和用户信息，统一为 host/path 格式
    case "$url" in
        git@*)
            # git@github.com:opencv/opencv → github.com/opencv/opencv
            echo "$url" | sed 's|^git@||; s|:|/|'
            ;;
        ssh://*)
            # ssh://git@host:port/path → host/path （忽略端口）
            echo "$url" | sed -E 's|^ssh://[^@]*@||; s|:[0-9]+(/.*)|\1|; s|:$||'
            ;;
        https://*|http://*)
            # https://github.com/opencv/opencv.git → github.com/opencv/opencv
            echo "$url" | sed 's|^[^:]*://||; s|/*$||'
            ;;
        *)
            # 其他情况直接返回（去掉末尾斜杠）
            echo "${url%/}"
            ;;
    esac
}

# 检查是否需要更新（基于时间戳）
should_update_repo() {
    local repo_path="$1"
    local cache_minutes="${GIT_CACHE_MINUTES:-5}"  # 默认 5 分钟缓存
    local timestamp_file="$repo_path/.git/last_fetch"
    
    if [[ ! -f "$timestamp_file" ]]; then
        return 0  # 没有时间戳，需要更新
    fi
    
    local last_fetch=$(cat "$timestamp_file")
    local now=$(date +%s)
    local age=$((now - last_fetch))
    
    if [[ $age -gt $((cache_minutes * 60)) ]]; then
        return 0  # 超过缓存时间，需要更新
    fi
    
    echo "⚡ Skipping git operations (last updated $((age / 60)) min ago)"
    return 1  # 不需要更新
}

# 记录更新时间
mark_repo_updated() {
    local repo_path="$1"
    date +%s > "$repo_path/.git/last_fetch"
}

checkout_repo() {
    local repo_name="$1"
    local official_url="$2"
    local mirror_url="$3"
    local repo_path="$4"
    local target_ref="$5"

    # Handle existing directory that is not a git repo
    if [ -d "$repo_path" ] && [ ! -d "$repo_path/.git" ]; then
        echo "⚠️  Directory '$repo_path' exists but is not a git repository."
        if [ -z "$(ls -A "$repo_path")" ]; then
            echo "   Directory is empty. Removing to proceed with clone..."
            rmdir "$repo_path"
        else
            echo "❌ Error: Directory is not empty and not a git repository. Please remove it manually." >&2
            return 1
        fi
    fi

    # Clone if not exists
    if [ ! -d "$repo_path" ]; then
        echo "Cloning $repo_name from mirror..."
        git clone "$mirror_url" "$repo_path" || {
            echo "Mirror clone failed, trying official..."
            git clone "$official_url" "$repo_path" || {
                echo "Failed to clone from both sources." >&2
                return 1
            }
        }
        mark_repo_updated "$repo_path"
    fi

    # 检查是否需要更新
    if ! should_update_repo "$repo_path"; then
        echo "✅ Repository $repo_name ready (cached)."
        return 0
    fi

    # Remote management
    local current_origin
    current_origin=$(git -C "$repo_path" remote get-url origin 2>/dev/null)

    if [ "$current_origin" = "$mirror_url" ]; then
        echo "Renaming origin to mirror and adding official as origin..."
        git -C "$repo_path" remote rename origin mirror
        git -C "$repo_path" remote add origin "$official_url"
        git -C "$repo_path" fetch origin --tags
    elif [ "$(normalize_git_url "$current_origin")" = "$(normalize_git_url "$official_url")" ]; then
        echo "Origin already points to official. Fetching updates..."
        git -C "$repo_path" fetch origin --tags
    else
        echo "Unexpected origin, resetting to official..."
        git -C "$repo_path" remote set-url origin "$official_url"
        git -C "$repo_path" fetch origin --tags
    fi

    # Checkout target ref
    if [ -n "$target_ref" ]; then
        echo "Checking out: $target_ref"
        if git -C "$repo_path" show-ref --verify --quiet "refs/tags/$target_ref"; then
            git -C "$repo_path" checkout "$target_ref"
        elif git -C "$repo_path" show-ref --verify --quiet "refs/heads/$target_ref"; then
            git -C "$repo_path" checkout "$target_ref"
        elif git -C "$repo_path" show-ref --verify --quiet "refs/remotes/origin/$target_ref"; then
            git -C "$repo_path" checkout -b "$target_ref" "origin/$target_ref"
        elif git -C "$repo_path" rev-parse --verify "$target_ref^{commit}" >/dev/null 2>&1; then
            git -C "$repo_path" checkout "$target_ref"
        else
            echo "Error: '$target_ref' not found as branch, tag, or commit." >&2
            return 1
        fi
    else
        echo "Pulling latest from origin..."
        git -C "$repo_path" pull --rebase
    fi

    mark_repo_updated "$repo_path"
    echo "✅ Repository $repo_name ready."
}