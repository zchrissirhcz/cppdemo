#!/bin/bash
# Batch script to create all documentation shortcuts at once
# This is more efficient than individual scripts

set -euo pipefail

: "${ZZPKG_ROOT:=$HOME/.zzpkg}"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Creating Windows Start Menu shortcuts for all documentation..."
echo ""

# Define all documentation configurations
# Format: doc-dir:shortcut-name:description
DOCS=(
    "cppreference-doc-en:CppReference:C++ Reference"
    "cppreference-doc-zh:CppReference-CN:C++ 参考手册"
    "python-doc:Python-Doc:Python Documentation"
    "numpy-doc:NumPy-Doc:NumPy Documentation"
    "cmake-doc:CMake-Doc:CMake Documentation"
    "eigen-doc:Eigen-Doc:Eigen Documentation"
    "opencv-doc:OpenCV-Doc:OpenCV Documentation"
)

# Process each documentation
for doc_config in "${DOCS[@]}"; do
    IFS=':' read -r doc_dir shortcut_name description <<< "$doc_config"
    
    bash "$SCRIPT_DIR/create-doc-shortcuts.sh" \
        --doc-dir "$doc_dir" \
        --shortcut-name "$shortcut_name" \
        --description "$description"
    
    echo ""
done

echo "=========================================="
echo "All shortcuts have been processed!"
echo "Search in Windows Start Menu to open documentation"
