export const scrollTranscriptToBottom = (output) => {
  if (output) {
    output.scrollTop = output.scrollHeight;
  }
};

export const animateTranscriptToBottom = (output, duration = 700) => {
  if (!output) {
    return;
  }

  const start = output.scrollTop;
  const target = output.scrollHeight - output.clientHeight;
  const distance = target - start;

  if (Math.abs(distance) <= 1) {
    output.scrollTop = target;
    return;
  }

  const startTime = performance.now();
  const easeOutCubic = (t) => 1 - (1 - t) ** 3;

  const step = (timestamp) => {
    const elapsed = timestamp - startTime;
    const progress = Math.min(elapsed / duration, 1);
    output.scrollTop = start + distance * easeOutCubic(progress);

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

export const scheduleScrollToBottom = (output, smooth = false) => {
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

export const bindTranscriptAutoScroll = (output) => {
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
    characterData: true,
  });
};
