# Common zip extraction helpers for make_package scripts

zzpkg_extract_zip_cross_platform() {
    local zip_file="$1"
    local dest_dir="$2"

    mkdir -p "${dest_dir}"

    local seven_zip=""
    if command -v 7z >/dev/null 2>&1; then
        seven_zip="7z"
    elif command -v 7za >/dev/null 2>&1; then
        seven_zip="7za"
    elif command -v 7zr >/dev/null 2>&1; then
        seven_zip="7zr"
    fi

    if [[ -n "${seven_zip}" ]]; then
        echo "Using ${seven_zip} to extract: ${zip_file}"
        "${seven_zip}" x -y "${zip_file}" -o"${dest_dir}"
        return 0
    fi

    if command -v bsdtar >/dev/null 2>&1; then
        echo "Using bsdtar to extract: ${zip_file}"
        if bsdtar -xf "${zip_file}" -C "${dest_dir}"; then
            return 0
        fi
        echo "bsdtar failed; will try Python fallback." >&2
    fi

    local py=""
    if command -v python3 >/dev/null 2>&1; then
        py="python3"
    elif command -v python >/dev/null 2>&1; then
        # Only use 'python' if it's Python 3
        if python - <<'PY' >/dev/null 2>&1
import sys
sys.exit(0 if sys.version_info[0] == 3 else 1)
PY
        then
            py="python"
        fi
    fi

    if [[ -n "${py}" ]]; then
        echo "Using ${py} fallback to extract (GBK/CP936 filenames): ${zip_file}"
        "${py}" - "${zip_file}" "${dest_dir}" <<'PY'
import re
import sys
import zipfile
from pathlib import Path

zip_path = Path(sys.argv[1])
dest = Path(sys.argv[2])

def safe_relpath(p: str) -> Path:
    p = p.replace('\\', '/')
    p = re.sub(r'^/+', '', p)
    parts = [x for x in p.split('/') if x not in ('', '.', '..')]
    return Path(*parts)

def decode_zip_name(name: str) -> str:
    # Recover original bytes from the typical cp437 decoding, then decode as GBK/CP936.
    raw = name.encode('cp437', errors='replace')
    for enc in ('gbk', 'cp936', 'gb18030'):
        try:
            return raw.decode(enc)
        except UnicodeDecodeError:
            continue
    return name

with zipfile.ZipFile(zip_path) as zf:
    for zi in zf.infolist():
        decoded = decode_zip_name(zi.filename)
        rel = safe_relpath(decoded)
        if not rel.parts:
            continue
        out_path = dest / rel
        if zi.is_dir() or zi.filename.endswith('/'):
            out_path.mkdir(parents=True, exist_ok=True)
            continue
        out_path.parent.mkdir(parents=True, exist_ok=True)
        with zf.open(zi, 'r') as src, open(out_path, 'wb') as dst:
            dst.write(src.read())
PY
        return 0
    fi

    echo "ERROR: No suitable unzip tool found. Install one of: 7z/7za/7zr, bsdtar, or python3." >&2
    return 1
}

# Find a likely payload directory under an extraction root.
# Usage: zzpkg_find_payload_dir <extract_root> [preferred_dirname] [glob_pattern]
# - preferred_dirname: e.g. "h264测试视频" (optional)
# - glob_pattern: e.g. "*.h264" (optional; defaults to "*")
zzpkg_find_payload_dir() {
    local extract_root="$1"
    local preferred_dirname="${2:-}"
    local glob_pattern="${3:-*}"

    if [[ -n "${preferred_dirname}" && -d "${extract_root}/${preferred_dirname}" ]]; then
        echo "${extract_root}/${preferred_dirname}"
        return 0
    fi

    # First, find directory containing matching files
    local first_match
    first_match=$(find "${extract_root}" -type f -name "${glob_pattern}" -print -quit 2>/dev/null || true)
    if [[ -n "${first_match}" ]]; then
        dirname "${first_match}"
        return 0
    fi

    # Fallback: any files
    local first_file
    first_file=$(find "${extract_root}" -type f -print -quit 2>/dev/null || true)
    if [[ -n "${first_file}" ]]; then
        dirname "${first_file}"
        return 0
    fi

    return 1
}
