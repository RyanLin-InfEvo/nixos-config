#!/usr/bin/env python3
import sys
import os
import re
import urllib.request
import urllib.parse
import xml.etree.ElementTree as ET
import subprocess

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
DEFAULT_NIX_PATH = os.path.join(SCRIPT_DIR, "default.nix")
GCS_BUCKET_URL = "https://storage.googleapis.com/antigravity-public"

def log(msg):
    print(f"[update-antigravity-cli] {msg}", flush=True)

def parse_version_key(version_str):
    match = re.match(r'^([0-9.]+)-([0-9]+)$', version_str)
    if not match:
        match_simple = re.match(r'^([0-9.]+)$', version_str)
        if match_simple:
            semver = [int(x) for x in match_simple.group(1).split(".")]
            return semver, 0
        raise ValueError(f"Invalid version format: {version_str}")
    semver_str, build_str = match.groups()
    semver = [int(x) for x in semver_str.split(".")]
    build = int(build_str)
    return semver, build

def get_latest_version():
    log("Scanning GCS bucket for antigravity-cli releases...")
    url = f"{GCS_BUCKET_URL}?prefix=antigravity-cli/"
    candidates = []
    
    pattern = re.compile(r'^antigravity-cli/([0-9.]+-([0-9]+))/linux-x64/cli_linux_x64\.tar\.gz$')
    
    while url:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        try:
            with urllib.request.urlopen(req) as response:
                xml_data = response.read()
        except Exception as e:
            log(f"Error fetching GCS bucket URL: {e}")
            sys.exit(1)
            
        root = ET.fromstring(xml_data)
        ns = {'s3': 'http://doc.s3.amazonaws.com/2006-03-01'}
        for key_elem in root.findall('.//s3:Key', ns):
            key = key_elem.text
            match = pattern.match(key)
            if match:
                full_version = match.group(1)
                try:
                    parsed = parse_version_key(full_version)
                    candidates.append((parsed, full_version))
                except ValueError:
                    continue
                    
        is_truncated_elem = root.find('.//s3:IsTruncated', ns)
        if is_truncated_elem is not None and is_truncated_elem.text == 'true':
            next_marker_elem = root.find('.//s3:NextMarker', ns)
            if next_marker_elem is not None:
                marker = next_marker_elem.text
            else:
                keys = root.findall('.//s3:Key', ns)
                marker = keys[-1].text if keys else None
            
            if marker:
                url = f"{GCS_BUCKET_URL}?prefix=antigravity-cli/&marker={urllib.parse.quote(marker)}"
            else:
                url = None
        else:
            url = None
            
    if not candidates:
        log("No valid antigravity-cli versions found in GCS bucket.")
        sys.exit(1)
        
    candidates.sort(key=lambda x: x[0])
    latest_version = candidates[-1][1]
    log(f"Latest version found on GCS: {latest_version}")
    return latest_version

def get_current_version():
    if not os.path.exists(DEFAULT_NIX_PATH):
        log(f"Error: {DEFAULT_NIX_PATH} not found.")
        sys.exit(1)
    with open(DEFAULT_NIX_PATH, 'r') as f:
        content = f.read()
    match = re.search(r'version\s*=\s*"([^"]+)"', content)
    if not match:
        log("Error: Could not extract current version from default.nix")
        sys.exit(1)
    return match.group(1)

def update_default_nix(new_version, sri_hash):
    with open(DEFAULT_NIX_PATH, 'r') as f:
        content = f.read()
        
    content = re.sub(r'version\s*=\s*"[^"]+"', f'version = "{new_version}"', content)
    new_url = f"https://storage.googleapis.com/antigravity-public/antigravity-cli/{new_version}/linux-x64/cli_linux_x64.tar.gz"
    content = re.sub(r'url\s*=\s*"[^"]+"', f'url = "{new_url}"', content)
    content = re.sub(r'sha256\s*=\s*"sha256-[^"]+"', f'sha256 = "{sri_hash}"', content)
    
    with open(DEFAULT_NIX_PATH, 'w') as f:
        f.write(content)
    log(f"Successfully updated default.nix to version {new_version} and hash {sri_hash}")

def main():
    current_ver = get_current_version()
    latest_ver = get_latest_version()
    
    try:
        curr_parsed = parse_version_key(current_ver)
    except ValueError:
        curr_parsed = ([0, 0, 0], 0)
        
    late_parsed = parse_version_key(latest_ver)
    
    if late_parsed <= curr_parsed:
        log("antigravity-cli is already up to date.")
        sys.exit(0)
        
    log(f"New version found! Upgrading from {current_ver} to {latest_ver}")
    
    tarball_url = f"{GCS_BUCKET_URL}/antigravity-cli/{latest_ver}/linux-x64/cli_linux_x64.tar.gz"
    log(f"Prefetching URL: {tarball_url}")
    
    try:
        prefetch_proc = subprocess.run(
            ["nix-prefetch-url", "--type", "sha256", tarball_url],
            capture_output=True, text=True, check=True
        )
        sha256_hex = prefetch_proc.stdout.strip()
        
        sri_proc = subprocess.run(
            ["nix", "hash", "to-sri", "--type", "sha256", sha256_hex],
            capture_output=True, text=True, check=True
        )
        sri_hash = sri_proc.stdout.strip()
    except subprocess.CalledProcessError as e:
        log(f"Error calculating hash: {e.stderr or e}")
        sys.exit(1)
        
    log(f"SRI Hash calculated: {sri_hash}")
    
    update_default_nix(latest_ver, sri_hash)

if __name__ == "__main__":
    main()
