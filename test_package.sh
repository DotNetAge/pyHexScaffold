#!/bin/bash
"""测试包安装和使用的脚本"""

# 设置颜色
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# 函数：打印成功消息
function success() {
    echo -e "${GREEN}$1${NC}"
}

# 函数：打印错误消息
function error() {
    echo -e "${RED}$1${NC}"
    exit 1
}

# 函数：打印警告消息
function warning() {
    echo -e "${YELLOW}$1${NC}"
}

# 清理之前的安装
warning "清理之前的安装..."
pip uninstall -y pyHexScaffold || true

# 创建临时测试目录
TEST_DIR="$(mktemp -d)"
warning "创建临时测试目录: $TEST_DIR"

# 安装开发版本
warning "安装开发版本..."
pip install -e .
if [ $? -ne 0 ]; then
    error "安装失败！"
fi

# 测试命令行工具
warning "测试命令行工具..."
pyhexscaffold --help
if [ $? -ne 0 ]; then
    error "命令行工具测试失败！"
fi

# 生成测试项目
warning "生成测试项目..."
TEST_PROJECT="$TEST_DIR/test_project"
pyhexscaffold "$TEST_PROJECT" --name test_project --version 0.1.0
if [ $? -ne 0 ]; then
    error "项目生成失败！"
fi

# 检查项目是否生成成功
if [ -d "$TEST_PROJECT" ]; then
    success "项目生成成功！"
    
    # 列出生成的项目结构
    warning "生成的项目结构："
    ls -la "$TEST_PROJECT"
    
    # 检查关键文件是否存在
    KEY_FILES=("main.py" "Dockerfile" "Makefile" ".env" "requirements.txt")
    for file in "${KEY_FILES[@]}"; do
        if [ -f "$TEST_PROJECT/$file" ]; then
            success "✓ $file 文件已生成"
        else
            warning "✗ $file 文件未生成"
        fi
    done
else
    error "项目目录不存在，生成失败！"
fi

# 清理临时目录
warning "清理临时测试目录: $TEST_DIR"
rm -rf "$TEST_DIR"

# 安装成功
success "\n测试完成！pyHexScaffold 包可以正常安装和使用。"

# 提示如何使用
warning "\n使用方法："
warning "1. 安装：pip install pyHexScaffold"
warning "2. 生成项目：pyhexscaffold /path/to/project --name project_name --version 1.0.0"