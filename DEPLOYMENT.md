# Deployment Guide

This server can be deployed to various platforms that support Docker containers.

## 🚫 Why Not Vercel?

Vercel is designed for:
- Serverless functions (short-lived, stateless)
- Static sites
- Edge functions

Our server needs:
- ✅ Long-running process (Shelf server)
- ✅ Persistent file storage (SQLite database)
- ✅ No execution time limits

## ✅ Recommended Platforms

### 1. **Railway** (Easiest - Recommended)

Railway automatically detects Docker and deploys from GitHub.

**Steps:**
1. Go to [railway.app](https://railway.app)
2. Sign in with GitHub
3. Click "New Project" → "Deploy from GitHub repo"
4. Select your repository
5. Railway will automatically detect the Dockerfile and deploy
6. Set environment variable: `PORT=8080` (optional, defaults to 8080)

**Cost:** Free tier available, then pay-as-you-go

---

### 2. **Render**

Render supports Docker deployments with persistent storage.

**Steps:**
1. Go to [render.com](https://render.com)
2. Sign in with GitHub
3. Click "New" → "Web Service"
4. Connect your GitHub repository
5. Select "Docker" as the environment
6. Render will use the `render.yaml` config automatically
7. Deploy!

**Cost:** Free tier available (spins down after inactivity), $7/month for always-on

---

### 3. **Fly.io** (Great for Dart)

Fly.io has excellent Dart support and global edge deployment.

**Steps:**
1. Install Fly CLI: `curl -L https://fly.io/install.sh | sh`
2. Sign up: `fly auth signup`
3. Launch: `fly launch` (in project root)
4. Follow prompts - Fly will detect Dockerfile
5. Deploy: `fly deploy`

**Cost:** Free tier includes 3 shared-cpu VMs, then pay-as-you-go

---

### 4. **DigitalOcean App Platform**

**Steps:**
1. Go to [cloud.digitalocean.com](https://cloud.digitalocean.com)
2. Create App → GitHub → Select repo
3. Configure: Dockerfile detected automatically
4. Deploy!

**Cost:** $5/month minimum

---

### 5. **Heroku** (Traditional, but more expensive)

**Steps:**
1. Install Heroku CLI
2. `heroku create your-app-name`
3. `heroku container:push web`
4. `heroku container:release web`

**Cost:** $7/month minimum (no free tier anymore)

---

## Quick Deploy Commands

### Railway
```bash
# Install Railway CLI
npm i -g @railway/cli

# Login
railway login

# Deploy
railway up
```

### Fly.io
```bash
# Install Fly CLI
curl -L https://fly.io/install.sh | sh

# Launch
fly launch

# Deploy
fly deploy
```

### Render
Just push to GitHub and connect via web UI - it's that simple!

---

## Environment Variables

All platforms support setting environment variables:

- `PORT` - Server port (defaults to 8080)
- Any other variables your app needs

---

## Database Persistence

⚠️ **Important:** SQLite files are stored in the container's filesystem. For production:

1. **Use a volume/mount** (Railway, Render support this)
2. **Or migrate to PostgreSQL** (better for production)

For persistent storage:
- **Railway:** Automatically provides persistent volumes
- **Render:** Use disk mounts in the dashboard
- **Fly.io:** Use volumes: `fly volumes create data`

---

## Health Check

All platforms will check `/health` endpoint to ensure the server is running.

---

## Which Should You Choose?

- **Railway** - Best for beginners, automatic deployments
- **Render** - Good free tier, easy setup
- **Fly.io** - Best for global edge deployment, great Dart support
- **DigitalOcean** - Reliable, predictable pricing



