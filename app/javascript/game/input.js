import { loadHistory, saveHistory, markPendingScroll } from 'game/history';
import { scheduleScrollToBottom } from 'game/scroll';

export const bindCommandInput = (commandField, commandForm, output) => {
  if (!commandField || !commandForm) {
    return;
  }

  commandField.focus();

  document.addEventListener('click', () => {
    commandField.focus();
  }, { once: true });

  const commandHistory = loadHistory();
  let historyIndex = -1;

  commandForm.addEventListener('submit', () => {
    const command = commandField.value.trim();
    if (!command) {
      return;
    }

    markPendingScroll();
    scheduleScrollToBottom(output, true);

    if (commandHistory[0] !== command) {
      commandHistory.unshift(command);
      saveHistory(commandHistory);
    }

    historyIndex = -1;
  });

  commandField.addEventListener('keydown', (event) => {
    if (event.key === 'ArrowUp') {
      event.preventDefault();
      if (historyIndex < commandHistory.length - 1) {
        historyIndex += 1;
        commandField.value = commandHistory[historyIndex];
      }
    } else if (event.key === 'ArrowDown') {
      event.preventDefault();
      if (historyIndex > -1) {
        historyIndex -= 1;
        commandField.value = historyIndex === -1 ? '' : commandHistory[historyIndex];
      }
    }
  });
};
