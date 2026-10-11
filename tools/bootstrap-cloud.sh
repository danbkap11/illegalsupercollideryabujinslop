#!/usr/bin/env bash
# Rootless Debian 13 cloud validation toolchain. Run again to reuse a valid install.
# Desktop users should install the official SuperCollider application instead.
set -euo pipefail

ISM_TOOLCHAIN_DIR="${ISM_TOOLCHAIN_DIR:-/workspace/ism-toolchain}"
if [[ "$ISM_TOOLCHAIN_DIR" != /* || "$ISM_TOOLCHAIN_DIR" == *$'\n'* || "$ISM_TOOLCHAIN_DIR" == *'"'* || "$ISM_TOOLCHAIN_DIR" == *'\\'* ]]; then
    echo 'ISM_TOOLCHAIN_DIR must be an absolute path without quotes, backslashes, or newlines.' >&2
    exit 1
fi

ready() {
    [[ -x "$ISM_TOOLCHAIN_DIR/bin/sclang" && -x "$ISM_TOOLCHAIN_DIR/bin/scsynth" \
        && -x "$ISM_TOOLCHAIN_DIR/bin/jackd" && -x "$ISM_TOOLCHAIN_DIR/bin/Xvfb" \
        && -f "$ISM_TOOLCHAIN_DIR/root/usr/share/SuperCollider/SCClassLibrary/Common/Core/Object.sc" \
        && -f "$ISM_TOOLCHAIN_DIR/root/usr/bin/qt.conf" ]] &&
    "$ISM_TOOLCHAIN_DIR/bin/sclang" -v >/dev/null 2>&1 &&
    "$ISM_TOOLCHAIN_DIR/bin/scsynth" -v >/dev/null 2>&1
}

if ready; then
    printf 'Reusing verified local SuperCollider toolchain: %s\n' "$ISM_TOOLCHAIN_DIR"
    exit 0
fi

if [[ ! -r /usr/share/keyrings/debian-archive-keyring.gpg || ! -x /usr/bin/apt-get ]] || ! command -v dpkg-deb >/dev/null; then
    echo 'This helper requires Debian, apt, dpkg-deb, and the official Debian archive keyring.' >&2
    exit 1
fi
# Package dependencies use the host ABI. Keep this helper explicit rather than
# silently combining another distribution with Debian 13 binary libraries.
if ! rg -q '^VERSION_ID="?13"?$' /etc/os-release; then
    echo 'This cloud helper supports Debian 13. Install SuperCollider normally on other systems.' >&2
    exit 1
fi

mkdir -p "$ISM_TOOLCHAIN_DIR"/{apt/lists/partial,apt/cache/archives/partial,apt/etc/sources.list.d,apt/etc/apt.conf.d,apt/etc/preferences.d,root,bin,xdg-cache,xdg-config,xdg-data,xdg-runtime}
chmod 700 "$ISM_TOOLCHAIN_DIR/xdg-runtime"
cp /var/lib/dpkg/status "$ISM_TOOLCHAIN_DIR/apt/status"
cat > "$ISM_TOOLCHAIN_DIR/apt/etc/sources.list" <<'SOURCES'
deb [signed-by=/usr/share/keyrings/debian-archive-keyring.gpg] https://deb.debian.org/debian trixie main
deb [signed-by=/usr/share/keyrings/debian-archive-keyring.gpg] https://deb.debian.org/debian-security trixie-security main
SOURCES
cat > "$ISM_TOOLCHAIN_DIR/apt/config" <<CONFIG
Dir::State "$ISM_TOOLCHAIN_DIR/apt";
Dir::State::status "$ISM_TOOLCHAIN_DIR/apt/status";
Dir::State::lists "$ISM_TOOLCHAIN_DIR/apt/lists";
Dir::Cache "$ISM_TOOLCHAIN_DIR/apt/cache";
Dir::Cache::archives "$ISM_TOOLCHAIN_DIR/apt/cache/archives";
Dir::Etc "$ISM_TOOLCHAIN_DIR/apt/etc";
Dir::Etc::sourcelist "sources.list";
Dir::Etc::sourceparts "sources.list.d";
Dir::Etc::parts "apt.conf.d";
APT::Sandbox::User "$(id -un)";
CONFIG
# APT_CONFIG is read before global configuration, so system package hooks and
# protected /var/lib and /var/cache locations are never used by this helper.
APT_CONFIG="$ISM_TOOLCHAIN_DIR/apt/config" /usr/bin/apt-get update
APT_CONFIG="$ISM_TOOLCHAIN_DIR/apt/config" /usr/bin/apt-get \
    --download-only --no-install-recommends -y \
    install supercollider-language supercollider-server xvfb jackd2
# apt verifies archive signatures and package checksums. Extract those verified
# packages locally; no dpkg installation or package maintainer script is run.
shopt -s nullglob
ISM_PACKAGES=("$ISM_TOOLCHAIN_DIR/apt/cache/archives/"*.deb)
if (( ${#ISM_PACKAGES[@]} == 0 )); then
    echo 'apt supplied no local packages. Use the installed system SuperCollider, or a fresh cloud host.' >&2
    exit 1
fi
for package in "${ISM_PACKAGES[@]}"; do
    dpkg-deb -x "$package" "$ISM_TOOLCHAIN_DIR/root"
done

cat > "$ISM_TOOLCHAIN_DIR/sclang_conf.yaml" <<CONFIG
includePaths:
  - "$ISM_TOOLCHAIN_DIR/root/usr/share/SuperCollider/SCClassLibrary"
  - "$ISM_TOOLCHAIN_DIR/root/usr/share/SuperCollider/Extensions"
excludePaths: []
postInlineWarnings: false
CONFIG
# Qt 5 reads qt.conf (the Qt 6 resource-path environment override is not enough).
cat > "$ISM_TOOLCHAIN_DIR/root/usr/bin/qt.conf" <<CONFIG
[Paths]
Data=$ISM_TOOLCHAIN_DIR/root/usr/share/qt5
Translations=$ISM_TOOLCHAIN_DIR/root/usr/share/qt5/translations
Plugins=/usr/lib/$(dpkg-architecture -qDEB_HOST_MULTIARCH)/qt5/plugins
CONFIG
ISM_QT_LIBEXEC="$ISM_TOOLCHAIN_DIR/root/usr/lib/$(dpkg-architecture -qDEB_HOST_MULTIARCH)/qt5/libexec"
if [[ -d "$ISM_QT_LIBEXEC" ]]; then
    cp "$ISM_TOOLCHAIN_DIR/root/usr/bin/qt.conf" "$ISM_QT_LIBEXEC/qt.conf"
fi

# These wrappers set only application paths and writable XDG cache/config paths;
# HOME, authentication, and package trust configuration remain untouched.
cat > "$ISM_TOOLCHAIN_DIR/bin/sclang" <<'WRAPPER'
#!/usr/bin/env bash
set -euo pipefail
ISM_TOOLCHAIN_ROOT="$(cd -- "$(dirname -- "$0")/.." && pwd)"
ISM_MULTIARCH="$(dpkg-architecture -qDEB_HOST_MULTIARCH)"
export LD_LIBRARY_PATH="$ISM_TOOLCHAIN_ROOT/root/usr/lib:$ISM_TOOLCHAIN_ROOT/root/usr/lib/$ISM_MULTIARCH${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export PATH="$ISM_TOOLCHAIN_ROOT/bin:$PATH"
export SC_PLUGIN_PATH="$ISM_TOOLCHAIN_ROOT/root/usr/lib/SuperCollider/plugins"
export QTWEBENGINEPROCESS_PATH="$ISM_TOOLCHAIN_ROOT/root/usr/lib/$ISM_MULTIARCH/qt5/libexec/QtWebEngineProcess"
export QT_PLUGIN_PATH="$ISM_TOOLCHAIN_ROOT/root/usr/lib/$ISM_MULTIARCH/qt5/plugins:/usr/lib/$ISM_MULTIARCH/qt5/plugins${QT_PLUGIN_PATH:+:$QT_PLUGIN_PATH}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$ISM_TOOLCHAIN_ROOT/xdg-cache}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$ISM_TOOLCHAIN_ROOT/xdg-config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$ISM_TOOLCHAIN_ROOT/xdg-data}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-$ISM_TOOLCHAIN_ROOT/xdg-runtime}"
exec "$ISM_TOOLCHAIN_ROOT/root/usr/bin/sclang" -l "$ISM_TOOLCHAIN_ROOT/sclang_conf.yaml" "$@"
WRAPPER
for app in scsynth jackd Xvfb; do
    cat > "$ISM_TOOLCHAIN_DIR/bin/$app" <<'WRAPPER'
#!/usr/bin/env bash
set -euo pipefail
ISM_TOOLCHAIN_ROOT="$(cd -- "$(dirname -- "$0")/.." && pwd)"
ISM_MULTIARCH="$(dpkg-architecture -qDEB_HOST_MULTIARCH)"
export LD_LIBRARY_PATH="$ISM_TOOLCHAIN_ROOT/root/usr/lib:$ISM_TOOLCHAIN_ROOT/root/usr/lib/$ISM_MULTIARCH${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export SC_PLUGIN_PATH="$ISM_TOOLCHAIN_ROOT/root/usr/lib/SuperCollider/plugins"
export JACK_DRIVER_DIR="$ISM_TOOLCHAIN_ROOT/root/usr/lib/$ISM_MULTIARCH/jack"
export JACK_INTERNAL_DIR="$ISM_TOOLCHAIN_ROOT/root/usr/lib/$ISM_MULTIARCH/jack"
WRAPPER
    printf 'exec "$ISM_TOOLCHAIN_ROOT/root/usr/bin/%s" "$@"\n' "$app" >> "$ISM_TOOLCHAIN_DIR/bin/$app"
done
chmod +x "$ISM_TOOLCHAIN_DIR/bin/"{sclang,scsynth,jackd,Xvfb}
if ! ready; then
    echo 'The extracted toolchain did not pass version checks; inspect missing libraries with ldd.' >&2
    exit 1
fi
printf 'Local SuperCollider toolchain is ready: %s\n' "$ISM_TOOLCHAIN_DIR"
printf 'Headless command: QT_QPA_PLATFORM=offscreen %s/bin/sclang -D tools/render.scd\n' "$ISM_TOOLCHAIN_DIR"
