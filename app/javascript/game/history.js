const historyKey = 'zork:command-history';
const pendingScrollKey = 'zork:pending-scroll';

export const loadHistory = () => {
  try {
    return JSON.parse(window.sessionStorage.getItem(historyKey) || '[]');
  } catch {
    return [];
  }
};

export const saveHistory = (history) => {
  window.sessionStorage.setItem(historyKey, JSON.stringify(history.slice(0, 50)));
};

export const markPendingScroll = () => {
  window.sessionStorage.setItem(pendingScrollKey, '1');
};

export const consumePendingScroll = () => {
  const pending = window.sessionStorage.getItem(pendingScrollKey) === '1';
  if (pending) {
    window.sessionStorage.removeItem(pendingScrollKey);
  }
  return pending;
};
