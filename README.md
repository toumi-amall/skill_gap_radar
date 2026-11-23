# Skill Gap Radar

A mobile app that compares your skills with job offers, shows what you are missing, and guides you to close the gap.

Paste a job offer, get a **match score** and a **radar chart**, see the **most demanded skills** across your saved offers, and follow a **learning path** that updates your score as you progress.

Built with **Flutter**, **Node.js / Express** and **MongoDB**.

## Features

- **Accounts**: sign up and log in (passwords hashed with bcrypt, JWT sessions). Each user only sees their own data. A **guest mode** is available without an account.
- **My skills**: add skills and set a level for each one (beginner, intermediate, advanced).
- **Analyze an offer**: paste the text of a job offer, the app detects the required skills and computes your match score.
- **Dashboard**: average match, radar chart (you vs market demand), top missing skills, and a score for each saved offer.
- **Statistics**: bar chart of the most demanded skills and a curve of your average score over time.
- **Learning path**: for each missing skill, links to official documentation and video tutorials, and an "I learned it" button that adds the skill to your profile.
- **Light and dark themes.**

## How the score works

For each skill an offer requires, a skill you have counts for:

- **100%** if your level is intermediate or advanced,
- **50%** if your level is beginner,
- **0%** if you do not have it.

The match score of an offer is the average of these values, shown as a percentage. The dashboard average is the mean of the scores of all saved offers.

## Tech stack

| Layer | Technology |
|---|---|
| Mobile / web app | Flutter (Dart), `fl_chart`, `http`, `shared_preferences`, `url_launcher` |
| API | Node.js, Express, Mongoose, `bcryptjs`, `jsonwebtoken` |
| Database | MongoDB (can be browsed with MongoDB Compass) |

```
Flutter app  ->  Node/Express API  ->  MongoDB  <-  MongoDB Compass
```

## Getting started

### Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) (stable channel)
- [Node.js](https://nodejs.org) 18 or later
- [MongoDB Community Server](https://www.mongodb.com/try/download/community) running locally, and optionally MongoDB Compass

### 1. Start the API

```bash
cd server
npm install
node index.js
```

You should see `MongoDB connected` and `API on http://localhost:3000`. The API connects to `mongodb://127.0.0.1:27017/skill_gap_radar`. Set the `JWT_SECRET` environment variable for anything other than local development.

### 2. Start the app

In a second terminal, from the project root:

```bash
flutter pub get
flutter run -d chrome --web-port 5000
```

Use a fixed web port so the browser keeps your session between launches. On the Android emulator, the app reaches the API through `10.0.2.2` (already handled in `lib/data/api_config.dart`).

## Project structure

```
lib/
  data/        stores (skills, offers, stats), API client, auth, session
  pages/
    welcome/   welcome screen
    auth/      login and sign up
    home/      navigation shell, home tab, dashboard
    skills/    my skills (with levels)
    analyze/   paste and analyze an offer
    stats/     statistics screen
    learn/     learning path
  theme/       colors, spacing, light and dark themes
  widgets/     shared widgets (radar logo)
server/
  index.js     Express API (auth, skills, offers, score history)
```

## API

All routes are under `/api`. Routes other than `/auth/*` need the header `Authorization: Bearer <token>`.

| Method | Route | Purpose |
|---|---|---|
| POST | `/auth/register` | Create an account |
| POST | `/auth/login` | Log in |
| GET, POST | `/skills` | List and add skills |
| PUT, DELETE | `/skills/:name` | Change the level of, or remove, a skill |
| GET, POST | `/offers` | List and save job offers |
| GET, POST | `/snapshots` | Score history for the statistics curve |

<!--
## Screenshots

Add your images to docs/screenshots/ and uncomment this section.

| Dashboard | Analyze | Statistics |
|---|---|---|
| ![Dashboard](docs/screenshots/dashboard.png) | ![Analyze](docs/screenshots/analyze.png) | ![Statistics](docs/screenshots/stats.png) |
-->

## Roadmap

- Forgot password
- Skill levels expected by each offer (instead of a single assumed level)
- Offer import from a link
- Mobile builds (Android, iOS)

## Credits

This project started from [toumi-amall/skill_gap_radar](https://github.com/toumi-amall/skill_gap_radar). This fork adds the dashboard, offer analysis, skill levels, statistics, learning path, the Node/MongoDB API and user accounts.

Academic project, ISGS Sousse. Author: Loulou.
