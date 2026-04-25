import json
import os
import re
from pathlib import Path
from typing import Any

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
    value = span.get_text(strip=True).split(".")[0] if span else None

    return value


def getGithubContributions():
    try:
        url = "https://github-contributions.vercel.app/api/v1/c043"
        res = requests.get(url)
        res.raise_for_status()
        data = res.json()
        return data
    except requests.RequestException as e:
        print(f"Failed to fetch github contributions: {e}")
    except ValueError as e:
        print(f"github contributions not valid JSON: {e}")


def getLatestBlogs():
    try:
        url = "https://blog.mariofragnito.it/posts/index.xml"
        res = requests.get(url)
        res.raise_for_status()
        return res.text
    except requests.RequestException as e:
        print(f"Failed to get italian latest blog posts: {e}")


def getLatestEnglishBlogs():
    try:
        url = "https://blog.mariofragnito.it/en-gb/posts/index.xml"
        res = requests.get(url)
        res.raise_for_status()
        return res.text
    except requests.RequestException as e:
        print(f"Failed to get english latest blog posts: {e}")


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
    gist_id = "1c7c7b37ca386063f46de348852e33c0"
    token = os.getenv("GITHUB_TOKEN")

    url = f"https://api.github.com/gists/{gist_id}"

    payload = {"files": {"wpm.txt": {"content": f"{wpm}"}}}

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


def updateGithubContributionsGist(contributions: dict[str, Any]):
    gist_id = "e687124951d31484cf5ae3ef9ca2ad00"
    token = os.getenv("GITHUB_TOKEN")

    url = f"https://api.github.com/gists/{gist_id}"

    payload = {
        "files": {"githubContributions.json": {"content": json.dumps(contributions)}}
    }

    headers = {
        "Accept": "application/vnd.github+json",
        "Authorization": f"Bearer {token}",
    }

    try:
        res = requests.patch(url, headers=headers, json=payload)
        res.raise_for_status()
    except requests.RequestException as e:
        print(f"Failed to update githubContributions.json: {e}")


def updateLatestBlogPostsGist(xml: str):
    gist_id = "fd7b7e21352e830fce668281eb057e33"
    token = os.getenv("GITHUB_TOKEN")

    url = f"https://api.github.com/gists/{gist_id}"

    payload = {"files": {"latestBlogs.xml": {"content": xml}}}

    headers = {
        "Accept": "application/vnd.github+json",
        "Authorization": f"Bearer {token}",
    }

    try:
        res = requests.patch(url, headers=headers, json=payload)
        res.raise_for_status()
    except requests.RequestException as e:
        print(f"Failed to update latestBlogs gist: {e}")


def updateLatestBlogEnglishPostsGist(xml: str):
    gist_id = "806e66f2159d3841677ff2dbe6659fbf"
    token = os.getenv("GITHUB_TOKEN")

    url = f"https://api.github.com/gists/{gist_id}"

    payload = {"files": {"latestBlogsEN.xml": {"content": xml}}}

    headers = {
        "Accept": "application/vnd.github+json",
        "Authorization": f"Bearer {token}",
    }

    try:
        res = requests.patch(url, headers=headers, json=payload)
        res.raise_for_status()
    except requests.RequestException as e:
        print(f"Failed to update latestBlogsEN gist: {e}")
