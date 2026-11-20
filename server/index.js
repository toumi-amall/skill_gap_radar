const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

const EN = { locale: 'en', strength: 2 }; // case-insensitive comparisons

const Skill = mongoose.model(
  'Skill',
  new mongoose.Schema({ name: { type: String, required: true } }, { timestamps: true })
);
const Offer = mongoose.model(
  'Offer',
  new mongoose.Schema(
    { title: String, company: String, required: [String] },
    { timestamps: true }
  )
);

const sampleOffers = [
  { title: 'Data Analyst Intern', company: 'Company A', required: ['SQL', 'Power BI', 'Python', 'Git'] },
  { title: 'Flutter Developer', company: 'Company B', required: ['Flutter', 'Dart', 'Git', 'Docker'] },
  { title: 'Full Stack Developer', company: 'Company C', required: ['React', 'Node.js', 'Docker', 'Git'] },
  { title: 'BI Developer', company: 'Company D', required: ['SQL', 'Power BI', 'Python', 'Docker'] },
];

// ---- skills ----
app.get('/api/skills', async (_req, res) => {
  const skills = await Skill.find().sort({ createdAt: 1 });
  res.json(skills.map((s) => s.name));
});

app.post('/api/skills', async (req, res) => {
  const name = String(req.body.name || '').trim();
  if (!name) return res.status(400).json({ error: 'name is required' });
  const exists = await Skill.findOne({ name }).collation(EN);
  if (!exists) await Skill.create({ name });
  res.status(201).json({ name });
});

app.delete('/api/skills/:name', async (req, res) => {
  await Skill.deleteOne({ name: req.params.name }).collation(EN);
  res.json({ ok: true });
});

// ---- offers ----
app.get('/api/offers', async (_req, res) => {
  const offers = await Offer.find().sort({ createdAt: -1 });
  res.json(offers.map((o) => ({ title: o.title, company: o.company, required: o.required })));
});

app.post('/api/offers', async (req, res) => {
  const { title, company, required } = req.body;
  if (!title || !Array.isArray(required)) {
    return res.status(400).json({ error: 'title and required[] are needed' });
  }
  const offer = await Offer.create({ title, company, required });
  res.status(201).json(offer);
});

// ---- start ----
mongoose
  .connect('mongodb://127.0.0.1:27017/skill_gap_radar')
  .then(async () => {
    console.log('MongoDB connected');
    if ((await Offer.countDocuments()) === 0) await Offer.insertMany(sampleOffers);
    app.listen(3000, () => console.log('API on http://localhost:3000'));
  })
  .catch((e) => console.error('MongoDB error:', e.message));