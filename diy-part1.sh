#!/bin/bash
PATCHES_DIR="$GITHUB_WORKSPACE/patches"
USER_BRANCH="$1"

echo "用户选择分支: $USER_BRANCH"

if [ "$USER_BRANCH" = "master-XG-040G-MD" ]; then
    PATCH_FILE="$PATCHES_DIR/airoha-en7581-support-master.patch"
elif [ "$USER_BRANCH" = "openwrt-25.12-XG-040G-MD" ]; then
    PATCH_FILE="$PATCHES_DIR/airoha-en7581-support-25.12.patch"
else
    echo "未知分支，跳过补丁"
    exit 0
fi

if [ -f "$PATCH_FILE" ]; then
    echo "正在应用补丁: $PATCH_FILE"
    # 创建临时补丁文件，排除 xg-040g-md.config 相关的所有 hunk
    TEMP_PATCH=$(mktemp)
    # 使用 sed 删除从 diff --git a/xg-040g-md.config 到下一个 diff --git 或文件结束的内容
    sed '/^diff --git a\/xg-040g-md.config/,/^diff --git /{ /^diff --git a\/xg-040g-md.config/d; /^--- a\/xg-040g-md.config/d; /^\+\+\+ b\/xg-040g-md.config/d; /^@@.*xg-040g-md.config/d; }' "$PATCH_FILE" > "$TEMP_PATCH"
    # 如果临时文件非空，应用它
    if [ -s "$TEMP_PATCH" ]; then
        patch -p1 < "$TEMP_PATCH"
        PATCH_EXIT=$?
    else
        echo "补丁过滤后为空，跳过"
        PATCH_EXIT=0
    fi
    rm -f "$TEMP_PATCH"
    if [ $PATCH_EXIT -eq 0 ]; then
        echo "补丁应用成功"
    else
        echo "补丁应用失败！"
        exit 1
    fi
else
    echo "错误: 找不到补丁文件 $PATCH_FILE"
    exit 1
fi
