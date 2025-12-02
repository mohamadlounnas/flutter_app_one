# 🚂 Railway Deployment - Quick Start

Your project is ready to deploy to Railway! Follow these simple steps:

## Step 1: Go to Railway
Visit: **https://railway.app**

## Step 2: Sign In
- Click "Start a New Project"
- Sign in with your **GitHub** account
- Authorize Railway to access your repositories

## Step 3: Deploy from GitHub
1. Click **"New Project"**
2. Select **"Deploy from GitHub repo"**
3. Find and select: **`mohamadlounnas/flutter_app_one`**
4. Railway will automatically:
   - ✅ Detect the `Dockerfile`
   - ✅ Read `railway.json` config
   - ✅ Start building and deploying

## Step 4: Configure (Optional)
Railway will automatically:
- Set PORT environment variable
- Expose the service on port 8080
- Create a public URL for your server

You can customize:
- **Environment Variables**: Add any custom vars in the Railway dashboard
- **Domain**: Railway provides a free `.railway.app` domain, or add your own

## Step 5: Get Your Server URL
Once deployed:
1. Go to your project in Railway dashboard
2. Click on the service
3. Go to **"Settings"** → **"Networking"**
4. Copy the **Public Domain** URL
5. Update your Flutter app's `baseUrl` to this URL

## Your Server Will Be Available At:
```
https://your-app-name.railway.app
```

## Update Flutter App
In `lib/main.dart`, change:
```dart
client.options.baseUrl = 'https://your-app-name.railway.app';
```

## That's It! 🎉

Railway will:
- ✅ Auto-deploy on every git push to main
- ✅ Provide persistent storage for SQLite database
- ✅ Handle SSL/HTTPS automatically
- ✅ Scale automatically

## Troubleshooting

**Build fails?**
- Check Railway logs in the dashboard
- Ensure all files are committed to GitHub

**Server not starting?**
- Check that PORT environment variable is set (Railway sets this automatically)
- Verify the health check endpoint: `/health`

**Database issues?**
- Railway provides persistent volumes automatically
- Database file is stored in `/app/data/app.db` in the container

---

**Need help?** Check Railway docs: https://docs.railway.app



