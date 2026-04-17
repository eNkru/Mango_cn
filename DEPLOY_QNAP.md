# 🚀 Deploying Mango to a QNAP NAS (Build from Source)

This guide walks you through building and running Mango **from your local source code** on a QNAP NAS using **Container Station** (Docker). This ensures all your local changes are included in the deployed container.

---

## 📋 Prerequisites

| Requirement | Details |
|---|---|
| **QNAP NAS** | Any model running QTS 4.3+ or QuTS hero |
| **Container Station** | Install from the QNAP App Center (QTS → App Center → search "Container Station") |
| **SSH access** | Control Panel → Network & File Services → Telnet/SSH → Enable SSH |
| **Your manga files** | `.cbz`, `.cbr`, `.zip`, or `.rar` archives stored on the NAS |
| **Source code** | The Mango_cn project on your dev machine with your local changes |

---

## Step 1 — Transfer Source Code to Your NAS

Copy the entire project directory from your dev machine to the NAS. Choose **one** method:

### Option A: SCP (recommended)

```bash
# From your dev machine:
scp -r /Users/hju/sources/Mango_cn admin@<NAS-IP>:/share/Container/mango-src
```

### Option B: Rsync (faster for re-deploys — only transfers changed files)

```bash
# From your dev machine:
rsync -avz --exclude 'node_modules' --exclude '.git' \
  /Users/hju/sources/Mango_cn/ admin@<NAS-IP>:/share/Container/mango-src/
```

### Option C: File Station

Zip the project folder on your dev machine, upload via QNAP File Station, then extract on the NAS via SSH:

```bash
ssh admin@<NAS-IP>
cd /share/Container
unzip mango-src.zip -d mango-src
```

> **Tip:** Exclude `node_modules`, `.git`, and `lib/` to save transfer time — the Docker build will regenerate them. But it's fine to copy everything too.

---

## Step 2 — Prepare Share Folders

Create the directories Mango needs on the NAS:

```bash
# SSH into your QNAP:
ssh admin@<NAS-IP>

# Create directories for config, data, and manga library
mkdir -p /share/Container/mango/config
mkdir -p /share/Container/mango/data
```

> If your manga files are already in a share like `/share/Multimedia/Manga`, you can mount that directly — no need to copy files.

---

## Step 3 — Deploy

### Option A: Use docker-compose (SSH)

This is the recommended method. The compose file builds from source automatically.

1. **Create the compose file** on the NAS:

   ```bash
   mkdir -p /share/Container/mango
   cat > /share/Container/mango/docker-compose.yml << 'EOF'
   version: '3.7'

   services:
     mango:
       build:
         context: /share/Container/mango-src
         dockerfile: Dockerfile
       image: mango_cn:local
       container_name: mango
       restart: unless-stopped
       ports:
         - "9000:9000"
       volumes:
         - /share/Multimedia/Manga:/root/mango/library
         - /share/Container/mango/data:/root/mango
         - /share/Container/mango/config:/root/.config/mango
       environment:
         - PORT=9000
         - DB_PATH=/root/mango/mango.db
   EOF
   ```

2. **Build and start:**

   ```bash
   cd /share/Container/mango
   docker compose build    # Build from source (takes ~10-20 min on first run)
   docker compose up -d    # Start the container
   ```

   > ⚠️ The first build compiles Crystal from source — it can take 10–20 minutes depending on your NAS CPU. Subsequent builds are faster if only a few files changed.

### Option B: Use the bundled docker-compose.qnap.yml

1. Copy `docker-compose.qnap.yml` from this repo to `/share/Container/mango/` on the NAS.
2. Make sure the source code is at `/share/Container/mango-src` (from Step 1).
3. Deploy:

   ```bash
   cd /share/Container/mango
   # Rename the file and adjust if needed, then:
   docker compose -f docker-compose.qnap.yml build
   docker compose -f docker-compose.qnap.yml up -d
   ```

### Option C: Container Station GUI

1. Open **Container Station** → **Application** → **Create** → **Import compose file**
2. Point to your compose file on the NAS
3. Click **Deploy** — Container Station will build and start the container

---

## Step 4 — Verify It's Running

1. **Check the container status:**

   ```bash
   docker ps | grep mango
   ```

   You should see `mango` with status `Up`.

2. **Check logs** (if something seems wrong):

   ```bash
   docker logs mango
   ```

   On first run, Mango will:
   - Auto-generate `config.yml` in `/root/.config/mango/`
   - Scan your manga library at `/root/mango/library`
   - Create a default `admin` user and print the password to the log

3. **Open the web UI:**

   Navigate to `http://<NAS-IP>:9000` in your browser.

4. **Log in** with the default admin credentials (check the log output for the auto-generated password).

---

## 🔄 Rebuilding After Local Changes

When you make changes to the source code on your dev machine:

```bash
# 1. Sync updated source to the NAS (from your dev machine)
rsync -avz --exclude 'node_modules' --exclude '.git' \
  /Users/hju/sources/Mango_cn/ admin@<NAS-IP>:/share/Container/mango-src/

# 2. Rebuild and restart on the NAS (SSH into the NAS)
ssh admin@<NAS-IP>
cd /share/Container/mango
docker compose build      # Rebuilds only the changed layers
docker compose up -d      # Recreates the container with the new image
```

> Your data (database, config, manga library) is preserved across rebuilds because it lives in mounted volumes, not in the container image.

---

## 🔧 Configuration

Mango's config is auto-generated at `/share/Container/mango/config/config.yml`. Edit it to customize:

```yaml
# Key options you may want to change:
host: 0.0.0.0
port: 9000
library_path: /root/mango/library
db_path: /root/mango/mango.db       # ⚠️ Must be inside /root/mango volume! Default is ~/mango.db (outside)
scan_interval_minutes: 5           # How often to re-scan the library
thumbnail_generation_interval_hours: 24
disable_login: false               # Set to true + set default_username to skip login
log_level: info                     # debug, info, warn, error
cache_enabled: true
cache_size_mbs: 50
```

> **After editing config, restart the container:**
> ```bash
> docker restart mango
> ```

All config options can also be overridden via **environment variables** (uppercase name), e.g. `SCAN_INTERVAL_MINUTES=10`. See `src/config.cr` in this repo for the full list.

---

## 🗂️ Adding Manga

Simply drop `.cbz`, `.cbr`, `.zip`, or `.rar` files into your manga share folder. Mango will automatically detect new files on the next library scan (default: every 5 minutes).

Organize with nested folders for titles:

```
/share/Multimedia/Manga/
├── One Piece/
│   ├── Vol 01.cbz
│   ├── Vol 02.cbz
│   └── ...
├── Attack on Titan/
│   ├── Vol 01.cbr
│   └── ...
└── Solo Title.zip
```

---

## 🔒 Permissions Troubleshooting

If Mango can't read your manga files or fails to write its database:

1. **Check share permissions** in QNAP:  
   Control Panel → Privilege → Shared Folders → select folder → **Edit** → set Read/Write for the admin user (or "Allow guest access").

2. **Ensure the Docker user can access the path:**  
   QNAP's Docker daemon typically runs as `admin`. The share must be accessible to that user.

3. **Avoid spaces in folder names** — they can cause issues with Docker bind-mounts.

4. **Use the correct QNAP volume path** — if your data is on volume 2, the path might be `/share/CACHEDEV2_DATA/...` instead of `/share/Multimedia/...`. Run `ls /share/` via SSH to see available mount points.

---

## 🐛 Common Issues

| Problem | Solution |
|---|---|
| Build fails with "out of memory" | QNAP NAS may have limited RAM. Try adding swap: `qcli-disk-add -s 2G` or build on a more powerful machine and transfer the image. |
| Container won't start | Check `docker logs mango` for errors. Verify volume paths exist. |
| "The config file does not exist" | This is normal on first run — Mango creates it automatically. |
| Library appears empty | Ensure manga files are in the mounted library path. Check file permissions. |
| Can't access web UI | Verify port 9000 isn't blocked by the QNAP firewall. Try `http://<NAS-IP>:9000`. |
| Thumbnails not generating | The container includes all image libraries; just wait for the scan cycle (24h default). |
| Forgot admin password | Delete `/share/Container/mango/data/mango.db` and restart — Mango will recreate it. ⚠️ This resets all users and reading progress. |
| Database lost after update | Ensure `DB_PATH=/root/mango/mango.db` is set — the default `~/mango.db` lives outside the persisted volume. |

---

## 🐳 Alternative: Build on Dev Machine, Export Image to NAS

If your NAS is too slow for Docker builds (low RAM/CPU), you can build on your dev machine and transfer the image:

```bash
# 1. Build on your dev machine (macOS/Linux)
cd /Users/hju/sources/Mango_cn
docker build -t mango_cn:local .

# 2. Save the image to a tar file
docker save mango_cn:local | gzip > mango_cn-local.tar.gz

# 3. Transfer to NAS
scp mango_cn-local.tar.gz admin@<NAS-IP>:/share/Container/

# 4. On the NAS, load the image
ssh admin@<NAS-IP>
docker load < /share/Container/mango_cn-local.tar.gz

# 5. Update your compose file to use the loaded image instead of build:
#    Change "build:" section to just:  image: mango_cn:local
#    Then:
cd /share/Container/mango
docker compose up -d
```

> **Note:** The image must be built for the **same architecture** as your NAS. Most QNAP NAS are `linux/amd64`. If building on an Apple Silicon Mac, use:
> ```bash
> docker build --platform linux/amd64 -t mango_cn:local .
> ```

---

## 📁 File Structure on Your NAS (After Deployment)

```
/share/
├── Container/
│   ├── mango/
│   │   └── docker-compose.yml       # Your compose file
│   │   └── config/
│   │       └── config.yml           # Mango config (auto-generated)
│   │   └── data/
│   │       ├── mango.db             # User database & reading progress
│   │       ├── queue.db             # Download queue
│   │       ├── library.yml.gz       # Library cache
│   │       ├── uploads/             # Uploaded files
│   │       └── plugins/             # Download plugins
│   └── mango-src/                   # Source code (copied from dev machine)
│       ├── Dockerfile
│       ├── Makefile
│       ├── shard.yml
│       └── src/ ...
└── Multimedia/Manga/               # Your manga library
    ├── Title A/
    │   └── Vol 01.cbz
    └── ...
```

---

## 🎯 Quick-Start Summary

```bash
# === On your dev machine ===

# 1. Sync source code to NAS
rsync -avz --exclude 'node_modules' --exclude '.git' \
  /Users/hju/sources/Mango_cn/ admin@<NAS-IP>:/share/Container/mango-src/

# === On the QNAP (SSH) ===

# 2. Create directories
ssh admin@<NAS-IP>
mkdir -p /share/Container/mango/{config,data}

# 3. Create docker-compose.yml (see Step 3 above)

# 4. Build and deploy
cd /share/Container/mango
docker compose build
docker compose up -d

# 5. Get admin password from logs
docker logs mango | head -20

# 6. Open in browser
# http://<NAS-IP>:9000
```

Happy reading! 📚
