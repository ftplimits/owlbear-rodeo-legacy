const express = require('express');
const path = require('path');
const rateLimit = require('express-rate-limit');

const app = express();
const PORT = process.env.PORT || 3000;

const limiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 200,
});

// Allow Discord to embed this app in an iframe
app.use((req, res, next) => {
  res.setHeader(
    'Content-Security-Policy',
    "frame-ancestors https://discord.com https://*.discord.com 'self'"
  );
  // Explicitly remove X-Frame-Options if set by anything else
  res.removeHeader('X-Frame-Options');
  next();
});

app.use(express.static(path.join(__dirname, 'build')));

// React SPA fallback: serve index.html for all non-asset routes
app.get('*', limiter, (req, res) => {
  res.sendFile(path.join(__dirname, 'build', 'index.html'));
});

app.listen(PORT, () => {
  console.log(`Owlbear Rodeo frontend running on port ${PORT}`);
});
