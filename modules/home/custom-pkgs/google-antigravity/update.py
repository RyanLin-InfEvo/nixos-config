#!/usr/bin/env python3
import sys
import os
import re
import urllib.request
import json
import base64

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
DEFAULT_NIX_PATH = os.path.join(SCRIPT_DIR, "default.nix")
UPSTREAM_VERSIONS_URL = "https://raw.githubusercontent.com/jacopone/antigravity-nix/master/artifacts/versions.json"

def log(msg):
    print(f"[update-antigravity] {msg}", flush=True)

def normalize_sri_hash(sri_hash):
    if '-' not in sri_hash:
        return sri_hash
    hash_type, hash_val = sri_hash.split('-', 1)
    is_hex = False
    if hash_type == 'sha256' and len(hash_val) == 64 and all(c in '0123456789abcdefABCDEF' for c in hash_val):
        is_hex = True
    elif hash_type == 'sha512' and len(hash_val) == 128 and all(c in '0123456789abcdefABCDEF' for c in hash_val):
        is_hex = True
        
    if is_hex:
        bytes_val = bytes.fromhex(hash_val)
        base64_val = base64.b64encode(bytes_val).decode('utf-8')
        return f"{hash_type}-{base64_val}"
    return sri_hash

def get_upstream_info():
    log(f"Fetching upstream versions.json from: {UPSTREAM_VERSIONS_URL}")
    req = urllib.request.Request(UPSTREAM_VERSIONS_URL, headers={'User-Agent': 'Mozilla/5.0'})
    try:
        with urllib.request.urlopen(req) as response:
            content = response.read().decode('utf-8')
    except Exception as e:
        log(f"Error fetching upstream versions.json: {e}")
        sys.exit(1)
        
    try:
        data = json.loads(content)
    except Exception as e:
        log(f"Error parsing upstream versions.json: {e}")
        sys.exit(1)
        
    info = data.get("Antigravity 2.0", {}).get("x86_64-linux", {})
    url = info.get("url")
    sri_hash = info.get("hash")
    
    if not url or not sri_hash:
        log("Error: Could not find url or hash for Antigravity 2.0 on x86_64-linux in versions.json")
        sys.exit(1)
        
    url = url.replace('\n', '').replace(' ', '')
    sri_hash = normalize_sri_hash(sri_hash)
    
    version_match = re.search(r'/([0-9]+\.[0-9]+\.[0-9]+-[0-9]+)/', url)
    if not version_match:
        version_match = re.search(r'/([0-9]+\.[0-9]+\.[0-9]+)/', url)
        
    if not version_match:
        log(f"Error: Could not parse version from URL: {url}")
        sys.exit(1)
        
    return version_match.group(1), url, sri_hash

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

def get_current_url():
    if not os.path.exists(DEFAULT_NIX_PATH):
        log(f"Error: {DEFAULT_NIX_PATH} not found.")
        sys.exit(1)
    with open(DEFAULT_NIX_PATH, 'r') as f:
        content = f.read()
    match = re.search(r'url\s*=\s*"([^"]+)"', content)
    if not match:
        log("Error: Could not extract current url from default.nix")
        sys.exit(1)
    return match.group(1)

def get_current_hash():
    if not os.path.exists(DEFAULT_NIX_PATH):
        log(f"Error: {DEFAULT_NIX_PATH} not found.")
        sys.exit(1)
    with open(DEFAULT_NIX_PATH, 'r') as f:
        content = f.read()
    match = re.search(r'(sha256|hash)\s*=\s*"([^"]+)"', content)
    if not match:
        log("Error: Could not extract current hash from default.nix")
        sys.exit(1)
    return match.group(2)

def update_default_nix(new_version, new_url, sri_hash):
    with open(DEFAULT_NIX_PATH, 'r') as f:
        content = f.read()
        
    content = re.sub(r'version\s*=\s*"[^"]+"', f'version = "{new_version}"', content)
    content = re.sub(r'url\s*=\s*"[^"]+"', f'url = "{new_url}"', content)
    content = re.sub(r'(sha256|hash)\s*=\s*"[^"]+"', f'hash = "{sri_hash}"', content)
    
    with open(DEFAULT_NIX_PATH, 'w') as f:
        f.write(content)
    log(f"Successfully updated default.nix to version {new_version}, url {new_url}, and hash {sri_hash}")

def main():
    current_ver = get_current_version()
    current_url = get_current_url()
    current_hash = get_current_hash()
    latest_ver, latest_url, sri_hash = get_upstream_info()
    
    log(f"Current local version: {current_ver}")
    log(f"Latest upstream version: {latest_ver}")
    
    needs_update = (current_ver != latest_ver) or (current_url != latest_url) or ("${version}" in current_url) or (current_hash != sri_hash)
    
    if not needs_update:
        log("Antigravity is already up to date.")
        sys.exit(0)
        
    if current_ver != latest_ver:
        log(f"New version found! Upgrading from {current_ver} to {latest_ver}")
    else:
        log(f"Updating URL/hash for version {latest_ver}")
        
    update_default_nix(latest_ver, latest_url, sri_hash)

if __name__ == "__main__":
    main()
