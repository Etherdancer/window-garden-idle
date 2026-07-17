{{flutter_js}}
{{flutter_build_config}}

const progressBar = document.getElementById('progress-bar');
const loadingText = document.getElementById('loading-text');
const loaderContainer = document.getElementById('loader-container');

function setProgress(pct, text) {
  if (progressBar) progressBar.style.width = pct + '%';
  if (loadingText) loadingText.textContent = text;
}

let currentProgress = 5;
setProgress(currentProgress, 'Connecting...');

// Simulate a smooth progress bar while waiting for main.dart.js to compile and download.
// 'flutter run' compiles on the fly on the first request, which can take 10-30 seconds.
let slowProgressInterval = setInterval(() => {
  if (currentProgress < 20) {
    currentProgress += 1;
    setProgress(currentProgress, 'Downloading engine...');
  } else if (currentProgress < 45) {
    currentProgress += 0.5;
    setProgress(Math.floor(currentProgress), 'Compiling application (may take a minute)...');
  } else if (currentProgress < 80) {
    // Slow down significantly as it approaches 80% to wait for the actual download
    currentProgress += 0.1;
    setProgress(Math.floor(currentProgress), 'Almost there...');
  }
}, 200);

_flutter.loader.load({
  onEntrypointLoaded: async function(engineInitializer) {
    clearInterval(slowProgressInterval);
    
    // Stage 2: main.dart.js is fully downloaded
    setProgress(85, 'Initializing engine...');
    const appRunner = await engineInitializer.initializeEngine();
    
    // Stage 3: Flutter engine is ready, starting the app
    setProgress(95, 'Growing your garden...');
    await appRunner.runApp();
    
    // Stage 4: App is fully running, hide the loader
    setProgress(100, 'Ready!');
    if (loaderContainer) {
      loaderContainer.classList.add('loader-hidden');
      setTimeout(() => loaderContainer.remove(), 800);
    }
  }
});
