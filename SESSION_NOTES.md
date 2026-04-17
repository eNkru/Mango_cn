# Mango_cn Build Fix Session Notes

## Project Overview
- **Project**: Mango_cn — Chinese fork of [getmango/Mango](https://github.com/getmango/Mango), a self-hosted manga server
- **Language**: Crystal (with Kemal web framework), Node.js/Gulp for frontend
- **Crystal version**: 1.19.1 (local dev) / 1.20.0 (Docker)
- **Project path**: `/Users/hju/sources/Mango_cn`

---

## ✅ All Fixes Applied

### 1. `shard.yml` — Removed ameba, updated Crystal version
- Removed `ameba` from dependencies (incompatible with newer Crystal)
- Changed `crystal: 1.0.0` → `crystal: '>= 1.14.0'`
- Deleted stale `shard.lock`, regenerated with new versions

### 2. `shard.lock` — Fresh lock file
- Pins new versions: kemal 1.11.0, db 0.14.0, http_proxy 0.14.0, sqlite3 0.23.0
- **Critical for Docker**: ensures consistent shard versions across builds

### 3. `Dockerfile` — Updated for Crystal 1.20.0
- Base image: `crystallang/crystal:1.0.0-alpine` → `crystallang/crystal:1.20.0-alpine`
- Supports both **amd64** and **arm64** (Synology NAS compatible)
- Added packages: `ca-certificates`, `make`, `wget`, `gcc`, `musl-dev`, `gmp-static`, `sqlite-dev`, `libwebp-dev`, `libwebp-static`
- Build flow: `make static` triggers `libs` → `patch-libs` + `build-image-size` → `crystal build --static`
- **✅ Docker build tested and passes**
- **✅ Container starts and serves HTTP 302 on port 9000**

### 4. `Makefile` — Major updates
- **`PKG_CONFIG_PATH` auto-detection**: Uses `brew --prefix` on macOS (Intel + Apple Silicon), skipped entirely on Linux/Docker (guarded by `HAS_BREW`)
- **`patch-libs` target**: Auto-patches `lib/mg` and `lib/archive` after `shards install`
  - Platform-aware `SEDI` (`sed -i ''` on macOS, `sed -i` on Linux)
  - Idempotent `require "file"` insertion via `grep` guard + `cat/mv`
- **`build-image-size` target**: Builds libwebp and stbi native extensions (skipped by `shards install --production`)
  - Downloads libwebp v1.1.0 source if missing
  - Uses `$(MAKE) -C` for idiomatically correct sub-make calls
- **`libs` target**: Now calls `patch-libs` + `build-image-size` after `shards install --production`
- **`CRYSTAL_FLAGS`**: Override-able variable for extra crystal flags

### 5. `lib/mg/src/mg/migration.cr` — crystal-db 0.14+ compatibility (ephemeral, patched by Makefile)
- Replaced `@db.driver.class.to_s == "SQLite3::Driver"` with `true`
- Updated comment: "Mango always uses SQLite, so this always returns true."

### 6. `lib/archive/src/archive.cr` — Crystal 1.19 FileInfo compatibility (ephemeral, patched by Makefile)
- Added `require "file"` at top of file
- Changed `Crystal::System::FileInfo` → `::File::Info` (2 occurrences)
- Used `::File::Info` (global scope) because Archive module defines its own `File` class

### 7. `src/handlers/log_handler.cr` — Kemal 1.11 parameter names
- Renamed `env` → `context` and `msg` → `message` to match overridden method signatures

### 8. `src/util/proxy.cr` — HTTP::Client proxy API change
- Changed `client.set_proxy get_proxy uri` → `client.proxy = proxy if proxy`
- `set_proxy` was removed; `http_proxy` shard provides `proxy=` setter

### 9. `src/server.cr` — Kemal static_headers signature change
- Changed `static_headers do |response|` → `static_headers do |env, _path, _fileinfo|`
- Changed `response.headers` → `env.response.headers`

### 10. `src/routes/api.cr` — Koa shard union type crash
- Changed `"value" => String | Int32 | Int64 | Float32` → `"value" => String`
- Koa v0.9.0 doesn't support Crystal union types in schema definitions

### 11. `src/library/archive_entry.cr`, `dir_entry.cr`, `entry.cr`, `title.cr` — URI.encode deprecation
- Changed `URI.encode` → `URI.encode_path` (7 occurrences across 4 files)
- Both produce identical output for path strings; `encode_path` is the non-deprecated API
- `File.readable?` was NOT changed — it still works fine in Crystal 1.19

---

## ✅ Verified Working

| Environment | Status | How to run |
|---|---|---|
| Local dev (macOS, Crystal 1.19.1) | ✅ HTTP 302 on port 9000 | `make run` |
| Docker (Crystal 1.20.0-alpine) | ✅ HTTP 302 on port 9000 | `docker build -t mango_cn . && docker run -p 9000:9000 -v /path/to/manga:/root/mango/library mango_cn` |

---

## 📋 How to Build from Scratch (New Machine)

### Local Development
```bash
# 1. Install prerequisites
brew install crystal libarchive webp sqlite3 wget node yarn

# 2. Clone and enter project
cd /Users/hju/sources/Mango_cn

# 3. Install dependencies, apply patches, build native extensions
make libs

# 4. Run the app
make run
```

### Docker / NAS
```bash
# Build the Docker image
docker build -t mango_cn .

# Run on NAS (mount your manga library)
docker run -d \
  -p 9000:9000 \
  -v /path/to/your/manga:/root/mango/library \
  -v /path/to/mango/config:/root/.config/mango \
  --name manga-server \
  mango_cn
```

---

## 📁 Files Modified (Summary)

| File | Change | Ephemeral? |
|------|--------|-----------|
| `shard.yml` | Removed ameba, crystal >= 1.14.0, image_size source | No |
| `shard.lock` | Regenerated with new versions (kemal 1.11, db 0.14, http_proxy 0.14) | Auto-regenerated |
| `Dockerfile` | Crystal 1.20.0-alpine, added gmp/webp/make/wget/gcc packages | No |
| `Makefile` | PKG_CONFIG_PATH auto-detect, patch-libs, build-image-size, CRYSTAL_FLAGS | No |
| `src/handlers/log_handler.cr` | Param renames for Kemal 1.11 | No |
| `src/util/proxy.cr` | `set_proxy` → `proxy=` with nil guard | No |
| `src/server.cr` | `static_headers` 3-arg signature fix | No |
| `src/routes/api.cr` | Filter schema union type → String | No |
| `src/library/archive_entry.cr` | `URI.encode` → `URI.encode_path` | No |
| `src/library/dir_entry.cr` | `URI.encode` → `URI.encode_path` | No |
| `src/library/entry.cr` | `URI.encode` → `URI.encode_path` | No |
| `src/library/title.cr` | `URI.encode` → `URI.encode_path` | No |
| `lib/mg/src/mg/migration.cr` | `@db.driver` → `true` | ⚠️ Yes (patch-libs) |
| `lib/archive/src/archive.cr` | `Crystal::System::FileInfo` → `::File::Info` + require | ⚠️ Yes (patch-libs) |

---

## 🔑 Default Credentials (auto-created on first run)
- **Username**: `admin`
- **Password**: `9935fd34973f4403b91c24e57bcbf849`
- **Config file**: `~/.config/mango/config.yml`
- **Port**: 9000
