"""
Crawl ExRx.net exercises for a single body region using Scrapling CLI.

Usage:
    python crawl_exrx_region.py <region_name> <list_url> <output_dir>
"""

import sys
import json
import re
import time
import os
import subprocess

sys.stdout.reconfigure(encoding='utf-8')

BASE_URL = "https://exrx.net"
DELAY_BETWEEN_REQUESTS = 2


def fetch_md(url: str, output_dir: str, region: str = "default") -> str | None:
    """Fetch a page via scrapling CLI, return markdown content."""
    tmp = os.path.join(output_dir, f"_tmp_{region.lower().replace(' ', '-')}_{os.getpid()}.md")
    if os.path.exists(tmp):
        os.remove(tmp)

    try:
        subprocess.run(
            ['scrapling', 'extract', 'stealthy-fetch', url, tmp, '--solve-cloudflare'],
            capture_output=True, text=True, timeout=120
        )
    except subprocess.TimeoutExpired:
        return None

    if os.path.exists(tmp):
        with open(tmp, 'r', encoding='utf-8', errors='replace') as f:
            content = f.read()
        os.remove(tmp)
        if 'Performing security verification' in content or len(content) < 200:
            return None
        return content
    return None


def parse_list_page(md: str, region: str) -> list[dict]:
    """Parse exercise list markdown. Returns stubs with name, url, equipment, targetMuscle."""
    exercises = []
    current_muscle = None
    current_equipment = None

    for line in md.split('\n'):
        stripped = line.strip()

        # Muscle headers: [MuscleLink](path/Muscles/) on its own line
        muscle_match = re.match(r'^\[([^\]]+)\]\(.*[/]Muscles[/]', stripped)
        if muscle_match:
            current_muscle = muscle_match.group(1)
            current_equipment = None
            continue

        # Equipment: bullet with plain capitalized text, no link
        equip_match = re.match(r'^\*\s+([A-Z][^[\]*\n]+)$', stripped)
        if equip_match:
            current_equipment = equip_match.group(1).strip()
            continue

        # Exercise links - many patterns:
        # + [Name](url), + *[Name](url)*, + [*Name*](url), + [**Name**](url)
        # **[Name](url)**, - [Name](url), * [Name](url)
        # Also nested: - [Seated](url), * [Alternating](url)
        ex_match = re.search(r'\[([^\]]+)\]\(([^)]+)\)', stripped)
        if ex_match and re.match(r'^\s*[\+\-\*]', stripped):
            name = ex_match.group(1).strip('*').strip()
            href = ex_match.group(2).strip()

            if not ('WeightExercises' in href or 'Stretches' in href):
                continue

            # Resolve URL
            if href.startswith('../../'):
                url = BASE_URL + '/' + href.replace('../../', '')
            elif href.startswith('/'):
                url = BASE_URL + href
            elif href.startswith('http'):
                url = href
            else:
                url = BASE_URL + '/' + href

            exercises.append({
                'name': name,
                'url': url,
                'bodyRegion': region,
                'targetMuscle': current_muscle or '',
                'equipment': current_equipment or '',
            })

    # Deduplicate by URL
    seen = set()
    unique = []
    for e in exercises:
        if e['url'] not in seen:
            seen.add(e['url'])
            unique.append(e)
    return unique


def parse_detail_page(md: str, stub: dict) -> dict:
    """Parse exercise detail page markdown."""
    r = {**stub, 'synergists': [], 'stabilizers': [], 'mechanics': None,
         'force': None, 'utility': None, 'category': 'strength',
         'preparation': '', 'execution': ''}

    # Title from page
    title = re.search(r'^([A-Z].*?)\n=+', md, re.MULTILINE)
    if title:
        r['name'] = title.group(1).strip()

    # Classification
    m = re.search(r'\*\*Mechanics:\*\*.*?\[(Isolated|Compound)\]', md)
    if m: r['mechanics'] = m.group(1).lower()

    m = re.search(r'\*\*Force:\*\*.*?\[(Push|Pull|Push & Pull)\]', md)
    if m: r['force'] = m.group(1).lower()

    m = re.search(r'\*\*Utility:\*\*.*?\[([^\]]+)\]', md)
    if m: r['utility'] = m.group(1).lower()

    # Instructions
    m = re.search(r'\*\*Preparation\*\*\s*\n\s*\n(.*?)(?=\n\s*\n\*\*Execution\*\*)', md, re.DOTALL)
    if m: r['preparation'] = m.group(1).strip()

    m = re.search(r'\*\*Execution\*\*\s*\n\s*\n(.*?)(?=\n\s*\n(?:Comments|Muscles|Force|---|\[|\*\*))', md, re.DOTALL)
    if m: r['execution'] = m.group(1).strip()

    # Muscles
    m = re.search(r'\*\*Target\*\*\].*?\n(.*?)(?=\[?\*\*Synergist)', md, re.DOTALL)
    if m:
        targets = re.findall(r'\[([^\]]+)\]\(.*?/Muscles/', m.group(1))
        if targets: r['targetMuscle'] = targets[0]

    m = re.search(r'\*\*Synergist[s]?\*\*\].*?\n(.*?)(?=\[?\*\*(?:Stabilizer|Dynamic|Antagonist)|---|\n##)', md, re.DOTALL)
    if m and 'None' not in m.group(1):
        r['synergists'] = re.findall(r'\[([^\]]+)\]\(.*?/Muscles/', m.group(1))

    m = re.search(r'\*\*Stabilizer[s]?\*\*\].*?\n(.*?)(?=\[?\*\*(?:Dynamic|Antagonist)|---|\n##)', md, re.DOTALL)
    if m and 'None' not in m.group(1):
        r['stabilizers'] = re.findall(r'\[([^\]]+)\]\(.*?/Muscles/', m.group(1))

    if '/Stretches/' in stub['url']:
        r['category'] = 'stretch'

    return r


def crawl_region(region: str, list_url: str, output_dir: str):
    os.makedirs(output_dir, exist_ok=True)
    out_file = os.path.join(output_dir, f"{region.lower().replace(' ', '-')}-exercises.json")
    fail_file = os.path.join(output_dir, f"{region.lower().replace(' ', '-')}-failed.json")

    # Resume support
    done_urls = set()
    existing = []
    if os.path.exists(out_file):
        with open(out_file, 'r', encoding='utf-8') as f:
            existing = json.load(f)
            done_urls = {e['url'] for e in existing}
        print(f"  Resuming: {len(existing)} already done")

    # Step 1: Fetch + parse list page
    print(f"[{region}] Fetching list: {list_url}")
    list_md = fetch_md(list_url, output_dir, region)
    if not list_md:
        print(f"  FATAL: Could not fetch list page")
        return

    stubs = parse_list_page(list_md, region)
    remaining = [s for s in stubs if s['url'] not in done_urls]
    print(f"  {len(stubs)} exercises found, {len(remaining)} to fetch")

    # Step 2: Fetch each exercise
    exercises = list(existing)
    failed = []

    for i, stub in enumerate(remaining):
        print(f"  [{i+1}/{len(remaining)}] {stub['name']}")
        md = fetch_md(stub['url'], output_dir, region)

        if md:
            ex = parse_detail_page(md, stub)
            exercises.append(ex)
            print(f"    -> {ex['name']} | {ex.get('mechanics','?')} | {ex.get('force','?')} | target={ex.get('targetMuscle','?')}")
        else:
            print(f"    FAILED")
            failed.append({'url': stub['url'], 'name': stub['name']})

        # Save progress
        with open(out_file, 'w', encoding='utf-8') as f:
            json.dump(exercises, f, indent=2, ensure_ascii=False)

        if i < len(remaining) - 1:
            time.sleep(DELAY_BETWEEN_REQUESTS)

    if failed:
        with open(fail_file, 'w', encoding='utf-8') as f:
            json.dump(failed, f, indent=2, ensure_ascii=False)

    print(f"\n=== {region}: {len(exercises)} saved, {len(failed)} failed ===")


if __name__ == '__main__':
    if len(sys.argv) != 4:
        print("Usage: python crawl_exrx_region.py <region_name> <list_url> <output_dir>")
        sys.exit(1)
    crawl_region(sys.argv[1], sys.argv[2], sys.argv[3])
