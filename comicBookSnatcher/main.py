import requests
from bs4 import BeautifulSoup
from pathlib import Path
import json
import os
from dotenv import load_dotenv

load_dotenv()


def fetchResults(url):
    try:
        res = requests.get(url, timeout=30)
        res.raise_for_status()
        return res.text
    except requests.RequestException as e:
        print(f"There was an error fetching {url}: {e}")


def parseResults(html, comicName):
    soup = BeautifulSoup(html, "lxml")
    articles = list(reversed(soup.find_all("article")))
    results = []

    for article in articles:
        header = article.find(class_="post-title")
        titleLink = header.find("a") if header else None
        img = article.find("img")

        title = titleLink.get_text(strip=True) if titleLink else None
        link = titleLink.get("href") if titleLink else None
        image = img.get("src") if img else None

        if title and link and image:
            results.append(
                {"title": title, "link": link, "image": image, "comic": comicName}
            )

    return results


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


def findNewComics(items, state, comicName):
    key = f"lastRun-{comicName}"
    previous = state.get(key, [])
    previousLinks = {item["link"] for item in previous if "link" in item}

    newItems = [item for item in items if item.get("link") not in previousLinks]

    state[key] = items

    return newItems


def sendTelegramPhoto(token, chatId, item):
    url = f"https://api.telegram.org/bot{token}/sendPhoto"
    caption = (
        f"🆕 New Comic from your pull list!\n{item['title']}\nRead here: {item['link']}"
    )

    res = requests.post(
        url,
        data={"chat_id": chatId, "photo": item["image"], "caption": caption},
        timeout=30,
    )

    res.raise_for_status()
    return res.json


token = os.getenv("TELEGRAM_BOT_TOKEN")
chatId = os.getenv("TELEGRAM_CHAT_ID")

if not token or not chatId:
    raise RuntimeError("Missing TELEGRAM_BOT_TOKEN or TELEGRAM_CHAT_ID")

with open("pullList.json", "r", encoding="utf-8") as f:
    items = json.load(f)
    state = loadState()

    for entry in items:
        name = entry.get("name")
        url = entry.get("url")
        html = fetchResults(url)
        comics = parseResults(html, name)
        newComics = findNewComics(comics, state, name)

        for comic in newComics:
            try:
                sendTelegramPhoto(token, chatId, comic)
            except requests.RequestException as e:
                print(f"Failed to send Telegram message for {comic['title']}: {e}")

        saveState(state)
