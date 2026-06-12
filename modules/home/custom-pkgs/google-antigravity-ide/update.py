#!/usr/bin/env python3
import sys
import os
import re
import urllib.request

import json

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
DEFAULT_NIX_PATH = os.path.join(SCRIPT_DIR, "default.nix")
UPSTREAM_VERSIONS_URL = "https://raw.githubusercontent.com/jacopone/antigravity-nix/master/artifacts/versions.json"

def log(msg):
    print(f"[update-antigravity-ide] {msg}", flush=True)

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
        
    ide_info = data.get("Antigravity IDE", {}).get("x86_64-linux", {})
    url = ide_info.get("url")
    sri_hash = ide_info.get("hash")
    
    if not url or not sri_hash:
        log("Error: Could not find url or hash for Antigravity IDE on x86_64-linux in versions.json")
        sys.exit(1)
        
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

def update_default_nix(new_version, new_url, sri_hash):
    with open(DEFAULT_NIX_PATH, 'r') as f:
        content = f.read()
        
    # Replace version
    content = re.sub(r'version\s*=\s*"[^"]+"', f'version = "{new_version}"', content)
    # Replace url
    content = re.sub(r'url\s*=\s*"[^"]+"', f'url = "{new_url}"', content)
    # Replace sha256
    content = re.sub(r'sha256\s*=\s*"[^"]+"', f'sha256 = "{sri_hash}"', content)
    
    with open(DEFAULT_NIX_PATH, 'w') as f:
        f.write(content)
    log(f"Successfully updated default.nix to version {new_version}, url {new_url}, and hash {sri_hash}")

def main():
    current_ver = get_current_version()
    current_url = get_current_url()
    latest_ver, latest_url, sri_hash = get_upstream_info()
    
    log(f"Current local version: {current_ver}")
    log(f"Latest upstream version: {latest_ver}")
    
    needs_update = (current_ver != latest_ver) or (current_url != latest_url) or ("${version}" in current_url)
    
    if not needs_update:
        log("Google Antigravity IDE is already up to date.")
        sys.exit(0)
        
    if current_ver != latest_ver:
        log(f"New version found! Upgrading from {current_ver} to {latest_ver}")
    else:
        log(f"Updating URL/hash for version {latest_ver}")
        
    update_default_nix(latest_ver, latest_url, sri_hash)

if __name__ == "__main__":
    main()
