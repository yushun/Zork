// Configure your import map in config/importmap.rb

document.addEventListener('turbo:load', () => {
  const commandHistory = [];
  let historyIndex = -1;
  const commandField = document.querySelector('.command-field');
  const output = document.querySelector('.terminal-output');

  if (commandField) {
    // Auto-focus the command input
    commandField.focus();

    // Keep focus on the command input
    document.addEventListener('click', () => {
      commandField.focus();
    });

    // Handle command history
    commandField.addEventListener('keydown', (e) => {
      if (e.key === 'Enter') {
        const command = commandField.value.trim();
        if (command) {
          commandHistory.unshift(command);
          historyIndex = -1;
        }
      } else if (e.key === 'ArrowUp') {
        e.preventDefault();
        if (historyIndex < commandHistory.length - 1) {
          historyIndex++;
          commandField.value = commandHistory[historyIndex];
        }
      } else if (e.key === 'ArrowDown') {
        e.preventDefault();
        if (historyIndex > -1) {
          historyIndex--;
          commandField.value = historyIndex === -1 ? '' : commandHistory[historyIndex];
        }
      }
    });
  }

  // Auto-scroll to bottom of output
  if (output) {
    output.scrollTop = output.scrollHeight;
  }
});

// Add sound effects (optional)
const playTypingSound = () => {
  const audio = new Audio('/typing.mp3');
  audio.volume = 0.2;
  audio.play();
}; 