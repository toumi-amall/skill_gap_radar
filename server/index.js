const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// In production, set the JWT_SECRET environment variable.
const JWT_SECRET = process.env.JWT_SECRET || 'dev-secret-change-me';

const app = express();
app.use(cors());
app.use(express.json());

const EN = { locale: 'en', strength: 2 }; // case-insensitive comparisons
const owner = { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true };
const wrap = (fn) => (req, res, next) => Promise.resolve(fn(req, res, next)).catch(next);

// ---------- models ----------
const User = mongoose.model(
  'User',
  new mongoose.Schema(
    {
      name: { type: String, required: true, trim: true },
      email: { type: String, required: true, unique: true, lowercase: true, trim: true },
      passwordHash: { type: String, required: true },
    },
    { timestamps: true }
  )
);
const Skill = mongoose.model(
  'Skill',
  new mongoose.Schema(
    {
      userId: owner,
      name: { type: String, required: true },
      level: { type: Number, min: 1, max: 3, default: 2 },
    },
    { timestamps: true }
  )
);
const Offer = mongoose.model(
  'Offer',
  new mongoose.Schema(
    { userId: owner, title: String, company: String, required: [String] },
    { timestamps: true }
  )
);
const Snapshot = mongoose.model(
  'Snapshot',
  new mongoose.Schema({ userId: owner, score: Number }, { timestamps: true })
);

const sampleOffers = [
  { title: 'Data Analyst Intern', company: 'Company A', required: ['SQL', 'Power BI', 'Python', 'Git'] },
  { title: 'Flutter Developer', company: 'Company B', required: ['Flutter', 'Dart', 'Git', 'Docker'] },
  { title: 'Full Stack Developer', company: 'Company C', required: ['React', 'Node.js', 'Docker', 'Git'] },
  { title: 'BI Developer', company: 'Company D', required: ['SQL', 'Power BI', 'Python', 'Docker'] },
];

const clampLevel = (v) => Math.min(3, Math.max(1, Number(v) || 2));
const sign = (user) => jwt.sign({ id: user._id }, JWT_SECRET, { expiresIn: '7d' });

// ---------- auth ----------
function auth(req, res, next) {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) return res.status(401).json({ error: 'Login required' });
  try {
    req.userId = jwt.verify(token, JWT_SECRET).id;
    next();
  } catch {
    res.status(401).json({ error: 'Invalid or expired token' });
  }
}

app.post('/api/auth/register', wrap(async (req, res) => {
  const name = String(req.body.name || '').trim();
  const email = String(req.body.email || '').trim().toLowerCase();
  const password = String(req.body.password || '');

  if (name.length < 2) return res.status(400).json({ error: 'Enter your name' });
  if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)) return res.status(400).json({ error: 'Enter a valid email' });
  if (password.length < 8) return res.status(400).json({ error: 'Password needs at least 8 characters' });
  if (await User.findOne({ email })) return res.status(409).json({ error: 'This email is already registered' });

  const user = await User.create({ name, email, passwordHash: await bcrypt.hash(password, 10) });
  await Offer.insertMany(sampleOffers.map((o) => ({ ...o, userId: user._id })));
  res.status(201).json({ token: sign(user), name: user.name, email: user.email });
}));

app.post('/api/auth/login', wrap(async (req, res) => {
  const email = String(req.body.email || '').trim().toLowerCase();
  const password = String(req.body.password || '');
  const user = await User.findOne({ email });
  const ok = user && (await bcrypt.compare(password, user.passwordHash));
  if (!ok) return res.status(401).json({ error: 'Wrong email or password' });
  res.json({ token: sign(user), name: user.name, email: user.email });
}));

// ---------- skills ----------
app.get('/api/skills', auth, wrap(async (req, res) => {
  const skills = await Skill.find({ userId: req.userId }).sort({ createdAt: 1 });
  res.json(skills.map((s) => ({ name: s.name, level: s.level || 2 })));
}));

app.post('/api/skills', auth, wrap(async (req, res) => {
  const name = String(req.body.name || '').trim();
  if (!name) return res.status(400).json({ error: 'name is required' });
  const level = clampLevel(req.body.level);
  const exists = await Skill.findOne({ userId: req.userId, name }).collation(EN);
  if (!exists) await Skill.create({ userId: req.userId, name, level });
  res.status(201).json({ name, level });
}));

app.put('/api/skills/:name', auth, wrap(async (req, res) => {
  const level = clampLevel(req.body.level);
  await Skill.updateOne({ userId: req.userId, name: req.params.name }, { level }).collation(EN);
  res.json({ ok: true, level });
}));

app.delete('/api/skills/:name', auth, wrap(async (req, res) => {
  await Skill.deleteOne({ userId: req.userId, name: req.params.name }).collation(EN);
  res.json({ ok: true });
}));

// ---------- offers ----------
app.get('/api/offers', auth, wrap(async (req, res) => {
  const offers = await Offer.find({ userId: req.userId }).sort({ createdAt: -1 });
  res.json(offers.map((o) => ({ title: o.title, company: o.company, required: o.required })));
}));

app.post('/api/offers', auth, wrap(async (req, res) => {
  const { title, company, required } = req.body;
  if (!title || !Array.isArray(required)) {
    return res.status(400).json({ error: 'title and required[] are needed' });
  }
  const offer = await Offer.create({ userId: req.userId, title, company, required });
  res.status(201).json(offer);
}));

// ---------- score history ----------
app.get('/api/snapshots', auth, wrap(async (req, res) => {
  const rows = await Snapshot.find({ userId: req.userId }).sort({ createdAt: -1 }).limit(30);
  res.json(rows.reverse().map((r) => r.score));
}));

app.post('/api/snapshots', auth, wrap(async (req, res) => {
  const score = Number(req.body.score);
  if (Number.isNaN(score)) return res.status(400).json({ error: 'score is required' });
  await Snapshot.create({ userId: req.userId, score });
  res.status(201).json({ score });
}));

// ---------- errors + start ----------
app.use((err, _req, res, _next) => {
  console.error(err);
  res.status(500).json({ error: 'Server error' });
});

mongoose
  .connect('mongodb://127.0.0.1:27017/skill_gap_radar')
  .then(() => {
    console.log('MongoDB connected');
    app.listen(3000, () => console.log('API on http://localhost:3000'));
  })
  .catch((e) => console.error('MongoDB error:', e.message));