from utils import getCurrentTopWpm, loadState, saveState, updateWpmGist

state = loadState()
key = "wpm"
previous = state.get(key, "")


wpm = getCurrentTopWpm()
if wpm and wpm != previous:
    updateWpmGist(wpm)
    state[key] = wpm
    saveState(state)
