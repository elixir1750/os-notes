#!/usr/bin/env bash
# Build the notes site with Quartz. Usage: build.sh <notes-dir> <quartz-dir>
set -euo pipefail
NOTES="$1"; Q="$2"
rm -rf "$Q/content"; mkdir -p "$Q/content"
find "$NOTES" -maxdepth 1 -name '*.md' ! -name 'README.md' -exec cp {} "$Q/content/" \;
cp "$Q/content/00 课程笔记索引.md" "$Q/content/index.md"
sed -i '0,/^# .*/s//# 操作系统学习笔记/' "$Q/content/index.md"
# 课件 PDF 不上传：把指向 PDF 的双链换成纯文本
python3 - "$Q/content" <<'PY'
import re,sys,pathlib
for f in pathlib.Path(sys.argv[1]).glob("*.md"):
    s=f.read_text(encoding="utf-8")
    s=re.sub(r"\[\[[^\]|]*\.pdf[^\]|]*\|([^\]]*)\]\]",r"\1",s)
    s=re.sub(r"\[\[([^\]|#]*\.pdf)[^\]]*\]\]",r"`\1`",s)
    s=re.sub(r'^source: .*\n',"",s,flags=re.M)
    f.write_text(s,encoding="utf-8")
PY
cd "$Q"
sed -i 's|pageTitle: .*|pageTitle: "操作系统学习笔记",|; s|locale: .*|locale: "zh-CN",|; s|baseUrl: .*|baseUrl: "elixir1750.github.io/os-notes",|' quartz.config.ts
npx quartz build
