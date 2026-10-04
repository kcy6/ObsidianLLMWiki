#requires -Version 7.0
param([string]$Root = (Split-Path $PSScriptRoot -Parent), [switch]$Strict)
$ErrorActionPreference = 'Stop'
$Root = (Resolve-Path -LiteralPath $Root).Path
$findings = [System.Collections.Generic.List[object]]::new()
function Report($level, $code, $path, $message) {
    $findings.Add([pscustomobject]@{Level=$level; Code=$code; Path=$path; Message=$message})
}
# Only fenced code and inline code are excluded. This is a vault convention checker,
# not a complete Markdown/YAML parser. Unsupported property forms fail explicitly.
function Prose([string]$body) {
    $result = [System.Collections.Generic.List[string]]::new()
    $fence = ''; $length = 0
    foreach ($line in ($body -split "`n")) {
        if ($line -match '^\s{0,3}(`{3,}|~{3,})') {
            $run = $Matches[1]
            if (!$fence) { $fence = $run.Substring(0,1); $length = $run.Length }
            elseif ($run.StartsWith($fence) -and $run.Length -ge $length -and $line.Trim() -match '^(`+|~+)$') { $fence = '' }
            $result.Add(''); continue
        }
        if (!$fence) { $result.Add($line) } else { $result.Add('') }
    }
    $result -join "`n"
}
$modules = @{}
$moduleFile = Join-Path $Root '.gitmodules'
if (Test-Path -LiteralPath $moduleFile) {
    foreach ($m in [regex]::Matches((Get-Content -LiteralPath $moduleFile -Raw), '(?m)^\s*path\s*=\s*(.+?)\s*$')) {
        $path = $m.Groups[1].Value.Trim().Replace('\','/')
        $ready = Test-Path -LiteralPath (Join-Path $Root "$path/.git")
        $modules[$path] = $ready
        if (!$ready) { Report WARN SOURCE_UNAVAILABLE $path '子模块未初始化；跳过其文件与锚点核验，不判为断链。' }
    }
}
function Check-Target($owner, [string]$target, [string]$anchor = '') {
    foreach ($module in $modules.Keys) {
        if ($target.StartsWith("$module/") -and !$modules[$module]) { return }
    }
    $full = [IO.Path]::GetFullPath((Join-Path $Root $target))
    if (!$full.StartsWith($Root + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
        Report ERROR OUTSIDE_ROOT $owner $target; return
    }
    if (!(Test-Path -LiteralPath $full -PathType Leaf) -and (Test-Path -LiteralPath "$full.md" -PathType Leaf)) { $full += '.md' }
    if (!(Test-Path -LiteralPath $full -PathType Leaf)) { Report ERROR MISSING_FILE $owner $target; return }
    if ((Get-Item -LiteralPath $full).Length -eq 0) { Report WARN EMPTY_SOURCE $owner $target }
    if ($anchor) {
        $body = Prose (Get-Content -LiteralPath $full -Raw)
        if ($anchor.StartsWith('^')) {
            if ($body -notmatch ('(?m)\^' + [regex]::Escape($anchor.Substring(1)) + '\s*$')) { Report ERROR MISSING_BLOCK $owner "$target#$anchor" }
        } else {
            $headings = @([regex]::Matches($body, '(?m)^\s{0,3}#{1,6}\s+(.+?)\s*$') | ForEach-Object { $_.Groups[1].Value -replace '\s+#+\s*$','' })
            if ($anchor -cnotin $headings) { Report ERROR MISSING_HEADING $owner "$target#$anchor" }
        }
    }
}
$wikiRoot = Join-Path $Root 'wiki'
if (!(Test-Path -LiteralPath (Join-Path $wikiRoot 'index.md'))) { throw 'wiki/index.md is required' }
$pages = @(Get-ChildItem -LiteralPath $wikiRoot -Recurse -Filter '*.md' | Where-Object Name -ne 'AGENTS.md')
$links = @{}
$expected = @{topics='topic'; concepts='concept'; guides='guide'; questions='question'}
foreach ($page in $pages) {
    $path = [IO.Path]::GetRelativePath($Root, $page.FullName).Replace('\','/')
    $raw = Get-Content -LiteralPath $page.FullName -Raw
    $fm = [regex]::Match($raw, '\A---\r?\n([\s\S]*?)\r?\n---(?:\r?\n|$)')
    $properties = @{}
    $sourcePaths = @()
    if (!$fm.Success) { Report ERROR FRONTMATTER $path '缺少 YAML 属性区。' }
    else {
        $inSources = $false
        foreach ($line in ($fm.Groups[1].Value -split '\r?\n')) {
            if ($line -match '^(type|status|updated|sources):\s*(.*?)\s*$') {
                $key=$Matches[1]; $value=$Matches[2]
                if ($properties.ContainsKey($key)) { Report ERROR PROPERTY $path "重复属性：$key" }
                $properties[$key]=$value.Trim('"',"'"); $inSources=($key -eq 'sources')
                if ($inSources -and $value -notin @('','[]')) { Report ERROR SOURCES_FORMAT $path 'sources 必须使用 [] 或缩进的路径列表。' }
            } elseif ($inSources -and $line -match '^  - (.+?)\s*$') {
                $sourcePaths += $Matches[1].Trim('"',"'")
            } elseif ($line.Trim()) { Report ERROR PROPERTY_FORMAT $path "不支持的属性格式：$line" }
        }
        foreach ($key in @('type','status','updated','sources')) { if (!$properties.ContainsKey($key)) { Report ERROR PROPERTY $path "缺少 $key" } }
        if ($properties.status -notin @('draft','reviewed','needs-verification')) { Report ERROR STATUS $path '非法状态。' }
        $date=[datetime]::MinValue
        if (![datetime]::TryParseExact($properties.updated, 'yyyy-MM-dd', [cultureinfo]::InvariantCulture, [Globalization.DateTimeStyles]::None, [ref]$date)) { Report ERROR DATE $path 'updated 必须是有效的 YYYY-MM-DD。' }
        $folder = $path.Split('/')[1]
        $type = if ($expected.ContainsKey($folder)) { $expected[$folder] } else { $page.BaseName }
        if ($properties.type -ne $type) { Report ERROR TYPE $path "预期 type: $type" }
        if ($expected.ContainsKey($folder) -and !$sourcePaths.Count) { Report WARN NO_SOURCES $path '内容页未列出本库来源；请人工确认外部引用。' }
        foreach ($source in $sourcePaths) { Check-Target $path $source }
    }
    $body = Prose ($raw.Substring($fm.Length))
    $body = [regex]::Replace($body, '`+[^`\r\n]*`+', '')
    $links[$path] = @()
    foreach ($link in [regex]::Matches($body, '(!?)\[\[([^\]]+)\]\]')) {
        $dest = ($link.Groups[2].Value -split '\|',2)[0]
        $parts = $dest -split '#',2
        $target = $parts[0]; $anchor = if ($parts.Count -gt 1) { $parts[1] } else { '' }
        if (!$target) { $target=$path }
        Check-Target $path $target $anchor
        if (!$link.Groups[1].Value) { $links[$path] += ($target -replace '\.md$','') + '.md' }
    }
}
foreach ($path in $links.Keys) {
    if ($path -match '^wiki/(topics|concepts|guides|questions)/') {
        if ($path -notin $links['wiki/index.md']) { Report ERROR NOT_INDEXED $path '首页缺少此页入口。' }
        $incoming = @($links.Keys | Where-Object { $_ -ne $path -and $path -in $links[$_] })
        if (!$incoming.Count) { Report WARN ORPHAN $path '无其他 Wiki 页面链接到此页。' }
    }
}
$findings | Sort-Object Level,Code,Path -Unique | ForEach-Object { '[{0}] {1} {2}: {3}' -f $_.Level,$_.Code,$_.Path,$_.Message }
$errors = @($findings | Where-Object Level -eq ERROR).Count
$warnings = @($findings | Where-Object Level -eq WARN).Count
Write-Output "Checked $($pages.Count) pages; errors=$errors; warnings=$warnings"
if ($errors -or ($Strict -and $warnings)) { exit 1 }
exit 0
