from utils import (
    getCurrentTopWpm,
    getGithubContributions,
    getLatestBlogs,
    loadState,
    saveState,
    updateGithubContributionsGist,
    updateLatestBlogPostsGist,
    updateWpmGist,
)

state = loadState()
key = "wpm"
previous = state.get(key, "")


wpm = getCurrentTopWpm()
if wpm and wpm != previous:
    updateWpmGist(wpm)
    state[key] = wpm
    saveState(state)

githubContributions = getGithubContributions()
if githubContributions:
    updateGithubContributionsGist(githubContributions)

latestBlogs = getLatestBlogs()
if latestBlogs:
    updateLatestBlogPostsGist(latestBlogs)
