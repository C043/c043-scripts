import requests
import json
import os
from dotenv import load_dotenv
from utils import (
    fetchResults,
    parseResults,
    loadState,
    saveState,
    findNewComics,
    sendTelegramPhoto,
)

load_dotenv()


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
