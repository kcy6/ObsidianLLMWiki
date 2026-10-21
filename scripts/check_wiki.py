#!/usr/bin/env python3
"""Read-only vault convention check; standard library, intentionally limited YAML/Markdown."""
import argparse
import datetime
from pathlib import Path
import re


def prose(text):
    lines, fence = [], None
    for line in text.splitlines():
        m = re.match(r'^\s{0,3}(`{3,}|~{3,})', line)
        if m:
            run = m[1]
            if fence is None:
                fence = run
            elif run[0] == fence[0] and len(run) >= len(fence) and re.fullmatch(r'\s*(`+|~+)\s*', line):
                fence = None
            lines.append('')
        else:
            lines.append(line if fence is None else '')
    return '\n'.join(lines)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument('--strict', action='store_true')
    args = parser.parse_args()
    root = args.root.resolve()
    findings = set()

    def report(level, code, owner, message):
        findings.add((level, code, str(owner), message))

    unavailable = []
    modules = root / '.gitmodules'
    if modules.exists():
        for name in re.findall(r'^\s*path\s*=\s*(.+?)\s*$', modules.read_text(), re.M):
            if not (root / name / '.git').exists():
                unavailable.append(name + '/')
                report('WARN', 'SOURCE_UNAVAILABLE', name, '子模块不可用，跳过文件与锚点核验')

    def target(owner, dest, anchor=''):
        full = (root / dest).resolve()
        if not full.is_relative_to(root):
            report('ERROR', 'OUTSIDE_ROOT', owner, dest)
            return
        if any(full.relative_to(root).as_posix().startswith(prefix) for prefix in unavailable):
            return
        if not full.is_file() and Path(str(full) + '.md').is_file():
            full = Path(str(full) + '.md')
        if not full.is_file():
            report('ERROR', 'MISSING_FILE', owner, dest)
            return
        if not full.stat().st_size:
            report('WARN', 'EMPTY_SOURCE', owner, dest)
        if anchor:
            body = prose(full.read_text(encoding='utf-8'))
            if anchor.startswith('^'):
                ok = re.search(r'\^' + re.escape(anchor[1:]) + r'\s*$', body, re.M)
            else:
                headings = [re.sub(r'\s+#+\s*$', '', h) for h in re.findall(r'^\s{0,3}#{1,6}\s+(.+?)\s*$', body, re.M)]
                ok = anchor in headings
            if not ok:
                report('ERROR', 'MISSING_ANCHOR', owner, dest + '#' + anchor)

    expected = dict(topics='topic', concepts='concept', guides='guide', questions='question')
    links = {}
    pages = sorted(p for p in (root / 'wiki').rglob('*.md') if p.name != 'AGENTS.md')
    if not (root / 'wiki/index.md').is_file():
        report('ERROR', 'INDEX', 'wiki/index.md', '缺少首页')
    for page in pages:
        owner = page.relative_to(root).as_posix()
        raw = page.read_text(encoding='utf-8')
        fm = re.match(r'\A---\n([\s\S]*?)\n---(?:\n|$)', raw)
        props, sources = {}, []
        if not fm:
            report('ERROR', 'FRONTMATTER', owner, '缺少属性区')
        else:
            in_sources = False
            for line in fm[1].splitlines():
                m = re.fullmatch(r'(type|status|updated|sources):\s*(.*?)\s*', line)
                if m:
                    key, value = m.groups()
                    if key in props:
                        report('ERROR', 'PROPERTY', owner, '重复属性 ' + key)
                    props[key] = value.strip('\"\'')
                    in_sources = key == 'sources'
                    if in_sources and value not in ('', '[]'):
                        report('ERROR', 'SOURCES_FORMAT', owner, line)
                elif in_sources and re.fullmatch(r'  - .+?', line):
                    sources.append(line[4:].strip().strip('\"\''))
                elif line.strip():
                    report('ERROR', 'PROPERTY_FORMAT', owner, line)
            for key in ('type', 'status', 'updated', 'sources'):
                if key not in props:
                    report('ERROR', 'PROPERTY', owner, '缺少 ' + key)
            if props.get('status') not in ('draft', 'reviewed', 'needs-verification'):
                report('ERROR', 'STATUS', owner, '非法状态')
            date = props.get('updated', '')
            try:
                if not re.fullmatch(r'\d{4}-\d{2}-\d{2}', date):
                    raise ValueError()
                datetime.date.fromisoformat(date)
            except ValueError:
                report('ERROR', 'DATE', owner, '非法日期')
            folder = page.relative_to(root / 'wiki').parts[0]
            if props.get('type') != expected.get(folder, page.stem):
                report('ERROR', 'TYPE', owner, '类型与位置不符')
            if folder in expected and not sources:
                report('WARN', 'NO_SOURCES', owner, '内容页未列出来源')
            for source in sources:
                target(owner, source)
        body = re.sub(r'`+[^`\n]*`+', '', prose(raw[fm.end():] if fm else raw))
        links[owner] = set()
        for embed, dest in re.findall(r'(!?)\[\[([^\]]+)\]\]', body):
            parts = dest.split('|', 1)[0].split('#', 1)
            dest = parts[0] or owner
            target(owner, dest, parts[1] if len(parts) > 1 else '')
            if not embed:
                links[owner].add(dest if dest.endswith('.md') else dest + '.md')
    for owner in links:
        if owner.split('/')[1] in expected:
            if owner not in links.get('wiki/index.md', set()):
                report('ERROR', 'NOT_INDEXED', owner, '首页缺少入口')
            if not any(owner in refs for other, refs in links.items() if other != owner):
                report('WARN', 'ORPHAN', owner, '无入链')
    for level, code, owner, message in sorted(findings):
        print(f'[{level}] {code} {owner}: {message}')
    errors = sum(f[0] == 'ERROR' for f in findings)
    warnings = sum(f[0] == 'WARN' for f in findings)
    print(f'Checked {len(pages)} pages; errors={errors}; warnings={warnings}')
    return int(bool(errors or (args.strict and warnings)))


if __name__ == '__main__':
    raise SystemExit(main())
