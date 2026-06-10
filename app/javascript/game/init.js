import { consumePendingScroll } from 'game/history';
import { bindTranscriptAutoScroll, scheduleScrollToBottom } from 'game/scroll';
import { bindCommandInput } from 'game/input';
import { renderMinimap } from 'game/minimap';

export const initializeGameView = () => {
  const commandField = document.querySelector('.command-field');
  const commandForm = document.querySelector('.command-form');
  const output = document.querySelector('.history-output');

  bindTranscriptAutoScroll(output);
  scheduleScrollToBottom(output, consumePendingScroll());
  bindCommandInput(commandField, commandForm, output);
  renderMinimap();
};
