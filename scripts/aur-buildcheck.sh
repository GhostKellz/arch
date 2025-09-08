#!/usr/bin/env bash
set -u

YELLOW="\033[33m"; RED="\033[31m"; GREEN="\033[32m"; BOLD="\033[1m"; RESET="\033[0m"

say()  { printf "%b\n" "$*"; }
ok()   { say "${GREEN}✔${RESET} $*"; }
warn() { say "${YELLOW}⚠${RESET} $*"; }
err()  { say "${RED}✘${RESET} $*"; }
hdr()  { say "\n${BOLD}# $*${RESET}"; }

issue_count=0
has_issue(){ issue_count=$((issue_count+1)); err "$*"; }

# --- Helpers ---------------------------------------------------------------

exists() { command -v "$1" >/dev/null 2>&1; }
read_conf_val() { # read key from conf (first non-comment match)
  local key="$1" file="$2"
  awk -v k="$key" '
    $0 !~ /^[[:space:]]*#/ && $0 ~ k {
      print $0; exit 0
    }' "$file" 2>/dev/null
}

grep_any(){
  local pat="$1"; shift
  grep -Hn --color=never -E "$pat" "$@" 2>/dev/null
}

path_is_before(){
  # $1 must occur before $2 in PATH (string compare, not fs checks)
  [[ ":$PATH:" == *":$1:"* ]] || return 1
  [[ ":$PATH:" == *":$2:"* ]] || return 0
  # split PATH into lines and compare first occurrence
  local a b i=0
  IFS=: read -r -a parts <<< "$PATH"
  for i in "${!parts[@]}"; do
    [[ "${parts[$i]}" == "$1" ]] && { a=$i; break; }
  done
  for i in "${!parts[@]}"; do
    [[ "${parts[$i]}" == "$2" ]] && { b=$i; break; }
  done
  [[ -n "${a:-}" && -n "${b:-}" && $a -lt $b ]]
}

# --- Checks ----------------------------------------------------------------

hdr "System basics"
say "User:      $(id -un) ($(id -u))"
say "Kernel:    $(uname -r)"
say "Shell:     $SHELL"
say "PATH:      $PATH"
exists yay && ok "yay found: $(yay --version 2>/dev/null | head -n1)" || warn "yay not found"

hdr "ccache & toolchain"
if pacman -Q ccache >/dev/null 2>&1; then
  ok "ccache installed: $(ccache --version 2>/dev/null | head -n1)"
else
  has_issue "ccache not installed (recommended with Arch builds). Fix: sudo pacman -S ccache"
fi

if exists gcc && exists g++; then
  ok "gcc:  $(gcc --version | head -n1)"
  ok "g++:  $(g++ --version | head -n1)"
else
  has_issue "gcc/g++ missing. Fix: sudo pacman -S base-devel"
fi

if exists cmake; then
  ok "cmake: $(cmake --version | head -n1)"
else
  warn "cmake not found (only needed for some PKGBUILDs). Fix: sudo pacman -S cmake"
fi

hdr "PATH wrapper order (ccache bin before compilers)"
if exists ccache; then
  CCACHE_BIN="/usr/lib/ccache/bin"
  if [[ -d "$CCACHE_BIN" ]]; then
    if path_is_before "$CCACHE_BIN" "/usr/bin"; then
      ok "$CCACHE_BIN appears before /usr/bin in PATH (good)"
    else
      warn "$CCACHE_BIN is not before /usr/bin in PATH — compilers may bypass ccache"
      say "  Fix (bash/zsh): echo 'export PATH=$CCACHE_BIN:\$PATH' >> ~/.bashrc && source ~/.bashrc"
    fi
  else
    warn "$CCACHE_BIN not present (some distros use alternatives or wrappers)"
  fi
fi

hdr "Environment variables that break invocation"
bad_env=0
for var in CC CXX; do
  val="${!var-}"
  if [[ -n "${val}" ]]; then
    say "$var = $val"
    if [[ "$val" =~ ccache[[:space:]]*- ]]; then
      has_issue "$var injects flags *before* the compiler via ccache (e.g. '-std=c++17'): this breaks builds."
      say "  Fix: unset $var  # (and remove from your shell rc files)"
      bad_env=1
    elif [[ "$val" =~ (-std=|-O|-g|-pipe) ]]; then
      warn "$var includes compiler flags; recommended to move flags to makepkg.conf CFLAGS/CXXFLAGS"
    elif [[ "$val" =~ ccache[[:space:]]+g(\+\+|cc)$ ]]; then
      warn "$var uses 'ccache g++' form (works), but better to use CMAKE_*_LAUNCHER or PATH wrappers."
    fi
  else
    ok "$var not set (good)"
  fi
done

if (( bad_env == 0 )); then
  ok "No obviously harmful CC/CXX environment detected"
fi

hdr "/etc/makepkg.conf & ~/.makepkg.conf"
for conf in /etc/makepkg.conf ~/.makepkg.conf; do
  [[ -f "$conf" ]] || continue
  say "Inspecting: $conf"

  line=$(read_conf_val '^BUILDENV' "$conf")
  if [[ -n "$line" ]]; then
    say "  $line"
    if [[ "$line" =~ ccache ]]; then
      ok "  ccache enabled in BUILDENV"
    else
      warn "  ccache not enabled in BUILDENV. Fix: set BUILDENV=(!distcc color ccache)"
    fi
  else
    warn "  BUILDENV not found — default likely OK, but consider enabling ccache"
  fi

  # Check for CC/CXX overrides in makepkg.conf
  found_bad=0
  if grep_any '^[[:space:]]*(CC|CXX)[[:space:]]*=' "$conf" >/dev/null; then
    while IFS= read -r L; do
      say "  $L"
      if [[ "$L" =~ ccache[[:space:]]*- ]]; then
        has_issue "  $conf: CC/CXX uses 'ccache -std=...' (bad order)"
        found_bad=1
      fi
    done < <(grep_any '^[[:space:]]*(CC|CXX)[[:space:]]*=' "$conf")
  fi
  (( found_bad==0 )) && ok "  No harmful CC/CXX overrides in $conf"
done

hdr "Shell rc files defining CC/CXX (for your awareness)"
rc_hits=0
for rc in ~/.bashrc ~/.zshrc ~/.config/fish/config.fish ~/.profile; do
  [[ -f "$rc" ]] || continue
  if grep -E '(^|[^#])(export[[:space:]]+)?(CC|CXX)=' "$rc" >/dev/null 2>&1; then
    rc_hits=1
    warn "Found CC/CXX definitions in $rc:"
    grep -nE '(^|[^#])(export[[:space:]]+)?(CC|CXX)=' "$rc" | sed 's/^/  /'
    say "  Consider removing these or ensuring they do NOT include ccache/flags."
  fi
done
(( rc_hits==0 )) && ok "No CC/CXX definitions found in common shell rc files"

hdr "Quick smoke test: correct ccache invocation"
if exists ccache && exists g++; then
  echo "" | ccache g++ -std=c++17 -dM -E - >/dev/null 2>&1
  if [[ $? -eq 0 ]]; then
    ok "ccache → g++ → flags order works"
  else
    has_issue "ccache/g++ simple invocation failed — check toolchain install"
  fi
fi

hdr "Yay/build cache hygiene"
say "To clear build caches if needed:"
say "  yay -Scc      # clear yay pkg cache"
say "  yay -Sc       # clear unused pkgs"
say "  rm -rf ~/.cache/yay/<pkg>  # per-package clean"
ok "If you rerun a build, prefer: env CCACHE_DISABLE=1 CC=gcc CXX=g++ yay -S <pkg>"

hdr "Summary"
if (( issue_count == 0 )); then
  ok "No blocking issues detected. You should be able to build AUR packages cleanly."
else
  err "$issue_count issue(s) detected. See fixes above."
  say "Common one-liners:"
  say "  ${BOLD}# Disable bad env for this session${RESET}"
  say "  unset CC CXX"
  say "  ${BOLD}# Rebuild without ccache (one-off)${RESET}"
  say "  env CCACHE_DISABLE=1 CC=gcc CXX=g++ yay -S <pkg>"
  say "  ${BOLD}# Ensure ccache is enabled the right way${RESET}"
  say "  sudo sed -i 's/^BUILDENV=.*/BUILDENV=(!distcc color ccache)/' /etc/makepkg.conf"
fi

