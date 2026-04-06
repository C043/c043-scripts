import json
import os
import re
from pathlib import Path

import requests
from bs4 import BeautifulSoup
from dotenv import load_dotenv
from playwright.sync_api import sync_playwright

load_dotenv()


def getCurrentTopWpm():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()
        page.goto("https://www.keybr.com/profile/j49ntjd", wait_until="networkidle")

        html = page.content()
        browser.close()

    soup = BeautifulSoup(html, "html.parser")

    label = soup.find(string=re.compile(r"Top speed:"))
    span = label.find_next("span") if label else None
    value = span.get_text(strip=True).split("w")[0] if span else None

    return value


def loadState():
    stateFile = Path("state.json")

    if not stateFile.exists():
        return {}

    try:
        content = stateFile.read_text(encoding="utf-8").strip()
        if not content:
            return {}

        data = json.loads(content)
        return data if isinstance(data, dict) else {}
    except json.JSONDecodeError:
        return {}


def saveState(state):
    stateFile = Path("state.json")
    tempFile = stateFile.with_suffix(".json.tmp")

    tempFile.write_text(
        json.dumps(state, indent=2, ensure_ascii=False), encoding="utf-8"
    )

    tempFile.replace(stateFile)


def updateWpmGist(wpm: str):
    gist_id = "eefea5f58960ee35e2379cde975f3589"
    token = os.getenv("GITHUB_TOKEN")

    url = f"https://api.github.com/gists/{gist_id}"

    payload = {"files": {"stats.txt": {"content": f"{wpm}"}}}

    headers = {
        "Accept": "application/vnd.github+json",
        "Authorization": f"Bearer {token}",
        "X-GitHub-Api-Version": "2022-11-28",
    }

    try:
        res = requests.patch(url, headers=headers, json=payload)
        res.raise_for_status()
    except requests.RequestException as e:
        print(f"Failed to update wpm gist: {e}")
