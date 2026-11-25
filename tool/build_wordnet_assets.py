"""Convert the Princeton WordNet 3.0 database into compact app assets.

Input is a locally downloaded, untrusted data archive. This script only reads
it; it is kept outside the downloaded directory.
"""
import gzip
import re
import sys
from pathlib import Path

src = Path(sys.argv[1])
out = Path(sys.argv[2])
out.mkdir(parents=True, exist_ok=True)

word_re = re.compile(r"^[a-zA-Z]+(?:['’][a-zA-Z]+)*$")
pos_order = {"n": 0, "v": 1, "a": 2, "s": 2, "r": 3}
pos_name = {"n": "noun", "v": "verb", "a": "adjective", "s": "adjective", "r": "adverb"}

# Head words (base lemmas) from the index files.
lemmas = set()
for name in ["index.noun", "index.verb", "index.adj", "index.adv"]:
    with open(src / name, encoding="utf-8", errors="replace") as fh:
        for line in fh:
            if not line or line[0].isspace():
                continue
            parts = line.split()
            if not parts:
                continue
            lemma = parts[0].lower()
            if word_re.match(lemma):
                lemmas.add(lemma)

# SemCor sense frequencies, used to put the most frequently encountered sense
# first instead of always preferring nouns.
freq = {}
with open(src / "index.sense", encoding="utf-8", errors="replace") as fh:
    for line in fh:
        parts = line.split()
        if len(parts) < 4:
            continue
        key = parts[0]
        try:
            offset = int(parts[1])
            tag_count = int(parts[3])
        except ValueError:
            continue
        if "%" not in key:
            continue
        lemma, pos_code = key.split("%", 1)
        pos_letter = {"1": "n", "2": "v", "3": "a", "4": "r", "5": "a"}.get(pos_code[:1])
        if not pos_letter or "_" in lemma:
            continue
        lemma = lemma.lower()
        if not word_re.match(lemma):
            continue
        freq[(lemma, pos_letter, offset)] = max(
            tag_count, freq.get((lemma, pos_letter, offset), 0)
        )

# First few glosses for each lemma.
senses = {}
for name, pos in [("data.noun", "n"), ("data.verb", "v"), ("data.adj", "a"), ("data.adv", "r")]:
    with open(src / name, encoding="utf-8", errors="replace") as fh:
        for line in fh:
            if not line or line[0].isspace():
                continue
            pipe = line.find("|")
            if pipe < 0:
                continue
            head = line[:pipe].strip()
            gloss = line[pipe + 1:].strip()
            if not gloss:
                continue
            fields = head.split()
            if len(fields) < 5:
                continue
            try:
                offset = int(fields[0])
                w_cnt = int(fields[3], 16)
            except ValueError:
                continue
            words = []
            idx = 4
            for _ in range(w_cnt):
                if idx >= len(fields):
                    break
                words.append(fields[idx])
                idx += 2
            for word in words:
                lower = word.lower()
                if "_" in lower or not word_re.match(lower):
                    continue
                bucket = senses.setdefault(lower, [])
                if any(entry[1] == gloss for entry in bucket):
                    continue
                bucket.append(
                    (pos, gloss, freq.get((lower, pos, offset), 0))
                )

out.joinpath("lemmas.txt").write_text("\n".join(sorted(lemmas)) + "\n", encoding="utf-8")
with gzip.open(out / "glosses.tsv.gz", "wt", encoding="utf-8", compresslevel=9) as fh:
    for lemma in sorted(senses):
        entries = sorted(
            senses[lemma],
            key=lambda entry: (-entry[2], pos_order.get(entry[0], 9)),
        )
        for pos, gloss, _ in entries[:3]:
            clean = " ".join(gloss.split())
            fh.write(f"{lemma}\t{pos_name.get(pos, 'word')}\t{clean}\n")

print(f"lemmas: {len(lemmas)}")
print(f"gloss lemmas: {len(senses)}")
print(f"gloss bytes: {(out / 'glosses.tsv.gz').stat().st_size}")
print(f"lemma bytes: {(out / 'lemmas.txt').stat().st_size}")
