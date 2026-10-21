#!/usr/bin/env bash
# 整理阶段新增；只配置指定仓库，不生成密钥、不连接网络、不提交或推送。
set -euo pipefail
repo=''; name=''; email=''; remote=''; apply=0
usage() { echo '用法: bash configure-github-repo.sh --repo 路径 --name 名称 --email 邮箱 --remote git@github.com:OWNER/REPO.git [--apply]'; }
while (($#)); do
  case "$1" in
    --apply) apply=1; shift ;;
    --repo|--name|--email|--remote)
      key=$1; shift; (($#)) || { usage >&2; exit 2; }
      case "$key" in --repo) repo=$1 ;; --name) name=$1 ;; --email) email=$1 ;; --remote) remote=$1 ;; esac
      shift ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
done
[[ -n $repo && -n $name && -n $email && -n $remote ]] || { usage >&2; exit 2; }
[[ $remote =~ ^git@github\.com:[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+\.git$ ]] || { echo '仅支持 github.com 标准 SSH URL；别名/其他主机请用手动流程。' >&2; exit 2; }
[[ $name != *$'\n'* && $email != *$'\n'* ]] || exit 2
command -v git >/dev/null
[[ $(git -C "$repo" rev-parse --is-bare-repository) == false ]] || { echo '需要已有的非 bare 仓库。' >&2; exit 1; }
# 不静默替换已有 origin，不保留隐含的其他推送目标。
mapfile -t old_urls < <(git -C "$repo" config --local --get-all remote.origin.url || true)
if ((${#old_urls[@]} > 1)) || { ((${#old_urls[@]} == 1)) && [[ ${old_urls[0]} != "$remote" ]]; }; then
  echo 'origin 已有其他地址；请先手动核对迁移，未修改。' >&2; exit 1
fi
if git -C "$repo" config --get-all remote.origin.pushurl >/dev/null; then
  echo 'origin 存在独立 pushurl，请用手动流程核对。' >&2; exit 1
fi
printf '计划：仓库 %q 的本地提交身份 %q <%q>，origin=%q\n' "$repo" "$name" "$email" "$remote"
((apply)) || { echo '仅预览；增加 --apply 才修改。'; exit 0; }
umask 077
state_root=${XDG_STATE_HOME:-$HOME/.local/state}/wiki-github-repo
mkdir -p -- "$state_root"
backup=$(mktemp -d "$state_root/run-XXXXXXXX")
config_path=$(git -C "$repo" rev-parse --path-format=absolute --git-path config)
cp -- "$config_path" "$backup/config.before"
printf '%s\n' "$config_path" > "$backup/config-path.txt"
# replace-all 使相同输入重复应用时不产生重复值。
git -C "$repo" config --local --replace-all user.name "$name"
git -C "$repo" config --local --replace-all user.email "$email"
if ((${#old_urls[@]} == 0)); then git -C "$repo" remote add origin "$remote"; fi
printf '配置完成，备份目录：%s\n' "$backup"
echo 'SSH 身份与私有仓库权限仍需手动验证；未提交、改分支或推送。'
