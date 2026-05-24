// Configure your import map in config/importmap.rb

const historyKey = 'zork:command-history';

const loadHistory = () => {
  try {
    return JSON.parse(window.sessionStorage.getItem(historyKey) || '[]');
  } catch {
    return [];
  }
};

const saveHistory = (history) => {
  window.sessionStorage.setItem(historyKey, JSON.stringify(history.slice(0, 50)));
};

const scrollTranscriptToBottom = (output) => {
  if (output) {
    output.scrollTop = output.scrollHeight;
  }
};

document.addEventListener('turbo:load', () => {
  const commandField = document.querySelector('.command-field');
  const commandForm = document.querySelector('.command-form');
  const output = document.querySelector('.terminal-output');
  const commandHistory = loadHistory();
  let historyIndex = -1;

  scrollTranscriptToBottom(output);

  if (!commandField || !commandForm) {
    return;
  }

  commandField.focus();

  document.addEventListener('click', () => {
    commandField.focus();
  }, { once: true });

  commandForm.addEventListener('submit', () => {
    const command = commandField.value.trim();
    if (!command) {
      return;
    }

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
});