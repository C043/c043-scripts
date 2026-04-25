from utils import (
    getCurrentTopWpm,
    getGithubContributions,
    getLatestBlogs,
    getLatestEnglishBlogs,
    loadState,
    saveState,
    updateGithubContributionsGist,
    updateLatestBlogEnglishPostsGist,
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

latestEnglishBlogs = getLatestEnglishBlogs()
if latestEnglishBlogs:
    updateLatestBlogEnglishPostsGist(latestEnglishBlogs)
