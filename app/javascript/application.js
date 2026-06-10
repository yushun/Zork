// Configure your import map in config/importmap.rb

const historyKey = 'zork:command-history';
const pendingScrollKey = 'zork:pending-scroll';

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

const markPendingScroll = () => {
  window.sessionStorage.setItem(pendingScrollKey, '1');
};

const consumePendingScroll = () => {
  const pending = window.sessionStorage.getItem(pendingScrollKey) === '1';
  if (pending) {
    window.sessionStorage.removeItem(pendingScrollKey);
  }
  return pending;
};

const scrollTranscriptToBottom = (output) => {
  if (output) {
    output.scrollTop = output.scrollHeight;
  }
};

const animateTranscriptToBottom = (output, duration = 700) => {
  if (!output) {
    return;
  }

  const start = output.scrollTop;
  const target = output.scrollHeight - output.clientHeight;
  const distance = target - start;

  if (distance <= 1) {
    output.scrollTop = target;
    return;
  }

  const startTime = performance.now();

  const easeOutCubic = (t) => 1 - (1 - t) ** 3;

  const step = (timestamp) => {
    const elapsed = timestamp - startTime;
    const progress = Math.min(elapsed / duration, 1);
    const eased = easeOutCubic(progress);
    output.scrollTop = start + distance * eased;

    if (progress < 1) {
      output.__scrollAnimationFrame = requestAnimationFrame(step);
    } else {
      output.__scrollAnimationFrame = null;
    }
  };

  if (output.__scrollAnimationFrame) {
    cancelAnimationFrame(output.__scrollAnimationFrame);
  }

  output.__scrollAnimationFrame = requestAnimationFrame(step);
};

const scheduleScrollToBottom = (output, smooth = false) => {
  if (!output) {
    return;
  }

  // Wait for Turbo DOM updates and layout to settle before scrolling.
  requestAnimationFrame(() => {
    requestAnimationFrame(() => {
      if (smooth) {
        animateTranscriptToBottom(output);
      } else {
        scrollTranscriptToBottom(output);
      }
    });
  });
};

const isNearBottom = (element, threshold = 32) => {
  const distanceToBottom = element.scrollHeight - (element.scrollTop + element.clientHeight);
  return distanceToBottom <= threshold;
};

const bindTranscriptAutoScroll = (output) => {
  if (!output || output.dataset.autoScrollBound === 'true') {
    return;
  }

  output.dataset.autoScrollBound = 'true';
  let stickToBottom = true;

  output.addEventListener('scroll', () => {
    stickToBottom = isNearBottom(output);
  });

  const observer = new MutationObserver(() => {
    if (stickToBottom) {
      requestAnimationFrame(() => animateTranscriptToBottom(output));
    }
  });

  observer.observe(output, {
    childList: true,
    subtree: true,
    characterData: true
  });
};

const initializeGameView = () => {
  const commandField = document.querySelector('.command-field');
  const commandForm = document.querySelector('.command-form');
  const output = document.querySelector('.terminal-output');
  const commandHistory = loadHistory();
  let historyIndex = -1;

  bindTranscriptAutoScroll(output);
  scheduleScrollToBottom(output, consumePendingScroll());

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

    markPendingScroll();
    // Keep current page pinned while request is in flight.
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

document.addEventListener('turbo:load', initializeGameView);
document.addEventListener('turbo:render', initializeGameView);