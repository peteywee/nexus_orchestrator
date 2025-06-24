import express from 'express';
import path from 'path';
import { fileURLToPath } from 'url';

// Since we are using ES modules, __dirname is not available directly.
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.PORT || 3000;

// Serve static files (your index.html, css, js) from the 'public' directory
app.use(express.static(path.join(__dirname, 'public')));

// API health check route
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', message: 'Nexus Backend is healthy' });
});

// Fallback route for Single-Page Applications (SPA)
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'public/index.html'));
});

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
