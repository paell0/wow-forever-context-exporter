"""Build the installable addon and verify local Markdown links."""
import re
from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED

ROOT = Path(__file__).resolve().parents[1]
ADDON = ROOT / 'ForeverContext'
version = re.search(r'^## Version:\s*(\S+)', (ADDON / 'ForeverContext.toc').read_text(encoding='utf-8'), re.M)[1]

for doc in [ROOT / 'README.md', ROOT / 'CONTRIBUTING.md', *sorted((ROOT / 'docs').glob('*.md'))]:
    content = doc.read_text(encoding='utf-8')
    for target in re.findall(r'\]\(([^)]+)\)', content):
        if '://' not in target and not target.startswith('#'):
            assert (doc.parent / target.split('#')[0]).exists(), (doc, target)

dist = ROOT / 'dist'
dist.mkdir(exist_ok=True)
target = dist / f'ForeverContext-{version}.zip'
with ZipFile(target, 'w', ZIP_DEFLATED) as archive:
    for path in sorted(ADDON.iterdir()):
        if path.is_file():
            archive.write(path, f'ForeverContext/{path.name}')
    archive.write(ROOT / 'README.md', 'ForeverContext/README.md')
    archive.write(ROOT / 'LICENSE', 'ForeverContext/LICENSE')
    archive.write(ROOT / 'LICENSE-MIT-v1.0.1.txt', 'ForeverContext/LICENSE-MIT-v1.0.1.txt')
    for path in sorted((ROOT / 'docs').glob('*.md')):
        archive.write(path, f'ForeverContext/docs/{path.name}')
    archive.write(ROOT / 'CONTRIBUTING.md', 'ForeverContext/CONTRIBUTING.md')
with ZipFile(target) as archive:
    assert archive.testzip() is None
    assert 'ForeverContext/ForeverContext.toc' in archive.namelist()
print(target)
