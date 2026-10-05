const SOUND_URL = '/sounds/notification.wav';

let audio: HTMLAudioElement | null = null;
let lastPlayed = 0;
let unlocked = false;
let bound = false;
let listening = false;

function getAudio(): HTMLAudioElement {
  if (!audio) {
    audio = new Audio(SOUND_URL);
    audio.preload = 'auto';
  }
  return audio;
}

export function unlockNotificationSound(): void {
  if (unlocked) return;
  const el = getAudio();
  el.muted = true;
  void el
    .play()
    .then(() => {
      el.pause();
      el.currentTime = 0;
      el.muted = false;
      unlocked = true;
    })
    .catch(() => undefined);
}

export function bindNotificationSoundUnlock(): void {
  if (bound || typeof window === 'undefined') return;
  bound = true;
  const unlock = () => unlockNotificationSound();
  window.addEventListener('pointerdown', unlock, { once: true });
  window.addEventListener('keydown', unlock, { once: true });
}

export function playNotificationSound(): void {
  const now = Date.now();
  if (now - lastPlayed < 1800) return;
  lastPlayed = now;
  const el = getAudio();
  el.muted = false;
  el.currentTime = 0;
  void el.play().catch(() => {
    unlocked = false;
  });
}

export function listenForPushSound(): void {
  if (listening || typeof navigator === 'undefined' || !('serviceWorker' in navigator)) {
    return;
  }
  listening = true;
  navigator.serviceWorker.addEventListener('message', (event: MessageEvent) => {
    if (event.data?.type === 'PLAY_NOTIFICATION_SOUND') {
      playNotificationSound();
    }
  });
}
