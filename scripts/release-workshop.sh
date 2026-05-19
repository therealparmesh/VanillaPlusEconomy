#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MOD_DIR="$ROOT_DIR/VanillaPlusEconomy"
PACKAGE="$ROOT_DIR/VanillaPlusEconomy.rwmod"
GAME_DIR="${RW_GAME_DIR:-$HOME/Library/Application Support/Steam/steamapps/common/Rusted Warfare}"
GAME_MOD_DIR="$GAME_DIR/mods/units/VanillaPlusEconomy"
GAME_PACKAGE="$GAME_DIR/mods/units/VanillaPlusEconomy.rwmod"
WORKSHOP_ID="${WORKSHOP_ID:-3728251918}"
MOD_NAME="${MOD_NAME:-VanillaPlusEconomy}"
CHANGE_NOTE="Update Vanilla+ Economy Extension."
BUILD_ONLY=0
CLEAN_LOCAL=0
LOG_FILE="${LOG_FILE:-/tmp/rw_workshop_release.log}"
AGENT_DIR="${AGENT_DIR:-/tmp/rw-workshop-agent}"
AGENT_JAR="$AGENT_DIR/rw-workshop-agent.jar"
REFRESH_CLASSES="$AGENT_DIR/refresh-classes"

usage() {
  echo "Usage: $0 [--build-only] [--remove-local-after-publish] [--note \"Workshop change note\"]"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --build-only)
      BUILD_ONLY=1
      shift
      ;;
    --remove-local-after-publish)
      CLEAN_LOCAL=1
      shift
      ;;
    --note)
      CHANGE_NOTE="${2:?Missing value for --note}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

need() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

log() {
  printf '[release] %s\n' "$*"
}

need zip
need unzip
need rsync
need javac
need jar
need curl
need diff

refresh_workshop_subscription() {
  local workshop_content="$HOME/Library/Application Support/Steam/steamapps/workshop/content/647960/$WORKSHOP_ID"
  local refresh_source="$AGENT_DIR/RefreshWorkshop.java"

  if [[ -d "$workshop_content" ]] && diff -qr "$MOD_DIR" "$workshop_content" >/dev/null 2>&1; then
    log "Workshop subscription content is current: $workshop_content"
    return 0
  fi

  log "refreshing Workshop subscription download"
  rm -rf "$REFRESH_CLASSES"
  mkdir -p "$REFRESH_CLASSES"

  cat > "$refresh_source" <<'JAVA'
import com.codedisaster.steamworks.SteamAPI;
import com.codedisaster.steamworks.SteamPublishedFileID;
import com.codedisaster.steamworks.SteamResult;
import com.codedisaster.steamworks.SteamUGC;
import com.codedisaster.steamworks.SteamUGC$ItemDownloadInfo;
import com.codedisaster.steamworks.SteamUGC$ItemInstallInfo;
import com.codedisaster.steamworks.SteamUGCCallback;
import com.codedisaster.steamworks.SteamUGCDetails;
import com.codedisaster.steamworks.SteamUGCQuery;

public class RefreshWorkshop implements SteamUGCCallback {
    private volatile boolean done;
    private volatile SteamResult result;

    public static void main(String[] args) throws Exception {
        if (args.length != 1) {
            throw new IllegalArgumentException("Usage: RefreshWorkshop <publishedFileId>");
        }
        new RefreshWorkshop().run(Long.parseLong(args[0]));
    }

    private void run(long itemId) throws Exception {
        if (!SteamAPI.init()) {
            throw new IllegalStateException("SteamAPI.init failed");
        }

        SteamPublishedFileID id = new SteamPublishedFileID(itemId);
        SteamUGC ugc = new SteamUGC(this);
        logState(ugc, id, "before");

        if (!ugc.downloadItem(id, true)) {
            throw new IllegalStateException("downloadItem returned false");
        }

        long deadline = System.currentTimeMillis() + 180000L;
        while (System.currentTimeMillis() < deadline && !done) {
            SteamAPI.runCallbacks();
            logState(ugc, id, "tick");
            if (isInstalledAndCurrent(ugc, id)) {
                done = true;
                result = SteamResult.OK;
                break;
            }
            Thread.sleep(1000L);
        }

        logState(ugc, id, "after");
        ugc.dispose();
        SteamAPI.shutdown();

        if (result != SteamResult.OK) {
            throw new IllegalStateException("Workshop download did not finish OK: " + result);
        }
    }

    private static boolean isInstalledAndCurrent(SteamUGC ugc, SteamPublishedFileID id) {
        String state = String.valueOf(ugc.getItemState(id));
        return state.contains("Installed")
                && !state.contains("NeedsUpdate")
                && !state.contains("Downloading")
                && !state.contains("DownloadPending");
    }

    private static void logState(SteamUGC ugc, SteamPublishedFileID id, String label) {
        SteamUGC$ItemInstallInfo install = new SteamUGC$ItemInstallInfo();
        SteamUGC$ItemDownloadInfo download = new SteamUGC$ItemDownloadInfo();
        boolean hasInstall = ugc.getItemInstallInfo(id, install);
        boolean hasDownload = ugc.getItemDownloadInfo(id, download);
        System.out.println("[RefreshWorkshop] " + label
                + " state=" + ugc.getItemState(id)
                + " install=" + hasInstall
                + " folder=" + install.getFolder()
                + " size=" + install.getSizeOnDisk()
                + " download=" + hasDownload
                + " bytes=" + download.getBytesDownloaded() + "/" + download.getBytesTotal());
    }

    public void onDownloadItemResult(int appID, SteamPublishedFileID publishedFileID, SteamResult result) {
        System.out.println("[RefreshWorkshop] onDownloadItemResult app=" + appID + " result=" + result);
        this.result = result;
        this.done = true;
    }

    public void onUGCQueryCompleted(SteamUGCQuery query, int numResultsReturned, int totalMatchingResults, boolean isCachedData, SteamResult result) {}
    public void onSubscribeItem(SteamPublishedFileID publishedFileID, SteamResult result) {}
    public void onUnsubscribeItem(SteamPublishedFileID publishedFileID, SteamResult result) {}
    public void onRequestUGCDetails(SteamUGCDetails details, SteamResult result) {}
    public void onCreateItem(SteamPublishedFileID publishedFileID, boolean needsToAcceptWLA, SteamResult result) {}
    public void onSubmitItemUpdate(boolean needsToAcceptWLA, SteamResult result) {}
    public void onUserFavoriteItemsListChanged(SteamPublishedFileID publishedFileID, boolean wasAddRequest, SteamResult result) {}
    public void onSetUserItemVote(SteamPublishedFileID publishedFileID, boolean voteUp, SteamResult result) {}
    public void onGetUserItemVote(SteamPublishedFileID publishedFileID, boolean voted, boolean voteUp, boolean voteSkipped, SteamResult result) {}
    public void onStartPlaytimeTracking(SteamResult result) {}
    public void onStopPlaytimeTracking(SteamResult result) {}
    public void onStopPlaytimeTrackingForAllItems(SteamResult result) {}
}
JAVA

  javac --release 8 -cp "$GAME_DIR/game-lib.jar" -d "$REFRESH_CLASSES" "$refresh_source"

  local refresh_ok=0
  for attempt in 1 2 3 4 5 6; do
    if env \
      SteamAppId=647960 \
      SteamGameId=647960 \
      DYLD_FALLBACK_LIBRARY_PATH="$GAME_DIR" \
      "$GAME_DIR/jvm-mac/Contents/Home/bin/Rusted Warfare" \
      -Djava.library.path="$GAME_DIR" \
      -cp "$REFRESH_CLASSES:$GAME_DIR/game-lib.jar" \
      RefreshWorkshop "$WORKSHOP_ID"; then
      refresh_ok=1
      break
    fi

    log "Workshop subscription refresh attempt $attempt failed; retrying"
    sleep 5
  done

  if [[ "$refresh_ok" -ne 1 ]]; then
    echo "Workshop subscription refresh failed after 6 attempts." >&2
    exit 1
  fi

  if [[ ! -d "$workshop_content" ]]; then
    echo "Workshop subscription content was not downloaded: $workshop_content" >&2
    exit 1
  fi

  if ! diff -qr "$MOD_DIR" "$workshop_content" >/dev/null 2>&1; then
    echo "Workshop subscription content does not match the published mod source." >&2
    diff -qr "$MOD_DIR" "$workshop_content" >&2 || true
    exit 1
  fi

  log "Workshop subscription content is current: $workshop_content"
}

[[ -d "$MOD_DIR" ]] || { echo "Missing mod folder: $MOD_DIR" >&2; exit 1; }
[[ -d "$GAME_DIR" ]] || { echo "Missing Rusted Warfare folder: $GAME_DIR" >&2; exit 1; }
[[ -x "$GAME_DIR/jvm-mac/Contents/Home/bin/Rusted Warfare" ]] || {
  echo "Missing Rusted Warfare Java launcher in: $GAME_DIR" >&2
  exit 1
}

log "building $PACKAGE"
rm -f "$PACKAGE"
(cd "$MOD_DIR" && zip -X -r "$PACKAGE" .)
unzip -t "$PACKAGE" >/dev/null

log "syncing mod source and package into Rusted Warfare"
mkdir -p "$GAME_DIR/mods/units"
rsync -a --delete "$MOD_DIR/" "$GAME_MOD_DIR/"
cp "$PACKAGE" "$GAME_PACKAGE"
cmp -s "$PACKAGE" "$GAME_PACKAGE"

if [[ "$BUILD_ONLY" -eq 1 ]]; then
  log "build-only complete"
  exit 0
fi

if pgrep -f 'com.corrodinggames.rts.java.Main' >/dev/null 2>&1; then
  echo "Close Rusted Warfare before publishing to Workshop." >&2
  exit 1
fi

log "preparing Workshop publisher helper"
rm -rf "$AGENT_DIR/classes"
mkdir -p "$AGENT_DIR/classes"
cat > "$AGENT_DIR/manifest.mf" <<'MANIFEST'
Premain-Class: RwWorkshopAgent
Agent-Class: RwWorkshopAgent
MANIFEST

cat > "$AGENT_DIR/RwWorkshopAgent.java" <<'JAVA'
import java.io.File;
import java.lang.instrument.Instrumentation;
import java.lang.reflect.Field;
import java.util.ArrayList;

public class RwWorkshopAgent {
    public static void premain(String args, Instrumentation inst) {
        agentmain(args, inst);
    }

    public static void agentmain(final String args, Instrumentation inst) {
        Thread worker = new Thread(new Runnable() {
            public void run() {
                try {
                    publish(args == null ? "" : args.trim());
                } catch (Throwable t) {
                    log("ERROR: " + t);
                    t.printStackTrace();
                }
            }
        }, "rw-workshop-upload-agent");
        worker.setDaemon(false);
        worker.start();
    }

    private static void publish(String requested) throws Exception {
        log("agent started, requested=" + requested);

        Class<?> engineClass = Class.forName("com.corrodinggames.rts.gameFramework.l");
        Object engine = null;
        Object modManager = null;
        Field modsField = null;

        for (int i = 0; i < 240; i++) {
            engine = engineClass.getMethod("B").invoke(null);
            if (engine != null) {
                modManager = engineClass.getField("bZ").get(engine);
                if (modManager != null) {
                    modsField = modManager.getClass().getDeclaredField("e");
                    modsField.setAccessible(true);
                    ArrayList<?> mods = (ArrayList<?>) modsField.get(modManager);
                    if (mods != null && !mods.isEmpty()) {
                        break;
                    }
                }
            }
            if (i % 10 == 0) {
                log("waiting for game/mod manager init: " + i);
            }
            Thread.sleep(500L);
        }

        if (engine == null || modManager == null || modsField == null) {
            throw new IllegalStateException("game/mod manager did not initialize");
        }

        Object target = null;
        for (int attempt = 0; attempt < 120 && target == null; attempt++) {
            ArrayList<?> mods = (ArrayList<?>) modsField.get(modManager);
            for (Object mod : mods) {
                String id = strField(mod, "e");
                String title = strField(mod, "s");
                String source = callString(mod, "i");
                long workshopId = longField(mod, "k");
                boolean disabled = booleanField(mod, "f");
                if (attempt == 0 || attempt % 10 == 0) {
                    log("mod: id=" + id + " title=" + title + " source=" + source + " workshopId=" + workshopId + " disabled=" + disabled);
                }

                boolean isRequested = requested.length() > 0 && requested.equals(id);
                boolean isVanillaPlus = "Vanilla+ Economy Extension".equals(title)
                        || (source != null && source.indexOf("VanillaPlusEconomy") >= 0)
                        || (id != null && id.indexOf("VanillaPlusEconomy") >= 0);
                boolean isFolder = source != null && source.indexOf("VanillaPlusEconomy") >= 0 && source.indexOf(".rwmod") < 0;

                if ((isRequested || isVanillaPlus) && isFolder) {
                    target = mod;
                    break;
                }
            }
            if (target == null) {
                if (attempt % 10 == 0) {
                    log("waiting for local VanillaPlusEconomy folder mod: " + attempt);
                }
                Thread.sleep(500L);
            }
        }

        if (target == null) {
            throw new IllegalStateException("Could not find local VanillaPlusEconomy folder mod");
        }

        String targetId = strField(target, "e");
        String targetTitle = strField(target, "s");
        String contentPath = callString(target, "i");
        String thumbnailPath = callString(target, "p");
        String tags = callStringArg(target, "c", "tags");
        long workshopId = longField(target, "k");

        log("target id=" + targetId);
        log("target title=" + targetTitle);
        log("target contentPath=" + contentPath + " exists=" + exists(contentPath));
        log("target thumbnailPath=" + thumbnailPath + " exists=" + exists(thumbnailPath));
        log("target tags=" + tags);
        log("target workshopId=" + workshopId);

        Class<?> steamBase = Class.forName("com.corrodinggames.rts.gameFramework.o.a");
        Object steam = null;
        for (int i = 0; i < 120; i++) {
            steam = steamBase.getMethod("a").invoke(null);
            if (steam != null) {
                boolean enabled = ((Boolean) steam.getClass().getMethod("e").invoke(steam)).booleanValue();
                if (enabled) {
                    break;
                }
            }
            if (i % 10 == 0) {
                log("waiting for Steam init: " + i);
            }
            Thread.sleep(500L);
        }
        if (steam == null) {
            throw new IllegalStateException("steam engine is null");
        }

        boolean steamEnabled = ((Boolean) steam.getClass().getMethod("e").invoke(steam)).booleanValue();
        boolean steamDisabled = ((Boolean) steam.getClass().getMethod("f").invoke(steam)).booleanValue();
        log("steam enabled=" + steamEnabled + " disabled=" + steamDisabled);
        if (!steamEnabled) {
            throw new IllegalStateException("Steam API is not enabled in the running game process");
        }

        String changeNote = System.getenv("RW_WORKSHOP_CHANGE_NOTE");
        if (changeNote == null || changeNote.trim().length() == 0) {
            changeNote = "Update Vanilla+ Economy Extension.";
        }

        if (workshopId == 0L) {
            log("publishing new workshop item");
            steam.getClass().getMethod("b", target.getClass()).invoke(steam, target);
        } else {
            log("updating existing workshop item");
            steam.getClass().getMethod("a", target.getClass(), Boolean.TYPE, String.class)
                    .invoke(steam, target, Boolean.TRUE, changeNote);
        }
        log("publish call returned; waiting for Steam callback in game log");
    }

    private static String strField(Object target, String name) throws Exception {
        Object value = field(target, name).get(target);
        return value == null ? null : value.toString();
    }

    private static long longField(Object target, String name) throws Exception {
        return field(target, name).getLong(target);
    }

    private static boolean booleanField(Object target, String name) throws Exception {
        return field(target, name).getBoolean(target);
    }

    private static Field field(Object target, String name) throws Exception {
        Field field = target.getClass().getDeclaredField(name);
        field.setAccessible(true);
        return field;
    }

    private static String callString(Object target, String methodName) {
        try {
            Object value = target.getClass().getMethod(methodName).invoke(target);
            return value == null ? null : value.toString();
        } catch (Throwable t) {
            return "<error:" + t.getClass().getSimpleName() + ">";
        }
    }

    private static String callStringArg(Object target, String methodName, String arg) {
        try {
            Object value = target.getClass().getMethod(methodName, String.class).invoke(target, arg);
            return value == null ? null : value.toString();
        } catch (Throwable t) {
            return "<error:" + t.getClass().getSimpleName() + ">";
        }
    }

    private static boolean exists(String path) {
        return path != null && new File(path).exists();
    }

    private static void log(String message) {
        System.out.println("[RwWorkshopAgent] " + message);
    }
}
JAVA

javac --release 8 -d "$AGENT_DIR/classes" "$AGENT_DIR/RwWorkshopAgent.java"
jar cfm "$AGENT_JAR" "$AGENT_DIR/manifest.mf" -C "$AGENT_DIR/classes" .

if ! pgrep -f '/Steam.AppBundle/Steam/Contents/MacOS/ipcserver' >/dev/null 2>&1; then
  log "opening Steam"
  open -a Steam
fi

for _ in $(seq 1 60); do
  if pgrep -f '/Steam.AppBundle/Steam/Contents/MacOS/ipcserver' >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

if ! pgrep -f '/Steam.AppBundle/Steam/Contents/MacOS/ipcserver' >/dev/null 2>&1; then
  echo "Steam IPC server did not start. Open Steam, log in, and rerun." >&2
  exit 1
fi

log "publishing Workshop item $WORKSHOP_ID"
rm -f "$LOG_FILE"
touch "$LOG_FILE"

(
  cd "$GAME_DIR"
  env \
    SteamAppId=647960 \
    SteamGameId=647960 \
    RW_WORKSHOP_CHANGE_NOTE="$CHANGE_NOTE" \
    DYLD_FALLBACK_LIBRARY_PATH="$GAME_DIR" \
    "$GAME_DIR/jvm-mac/Contents/Home/bin/Rusted Warfare" \
    "-javaagent:$AGENT_JAR=$MOD_NAME" \
    -Xdock:name='Rusted Warfare' \
    -Xdock:icon=res/drawable/icon_window.png \
    -Dfile.encoding=UTF-8 \
    -Djava.library.path=. \
    -cp 'game-lib.jar:libs/*' \
    com.corrodinggames.rts.java.Main \
    -steam \
    -log "$LOG_FILE"
) &
GAME_PID=$!

cleanup() {
  if kill -0 "$GAME_PID" >/dev/null 2>&1; then
    kill "$GAME_PID" >/dev/null 2>&1 || true
    wait "$GAME_PID" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

deadline=$((SECONDS + 240))
published=0
while kill -0 "$GAME_PID" >/dev/null 2>&1; do
  if grep -q 'Got workshop callback: onSubmitItemUpdate (OK)' "$LOG_FILE"; then
    log "Workshop update callback OK"
    published=1
    cleanup
    break
  fi

  if grep -Eq 'Steam API is not enabled|Error\. Workshop|ERROR: java|Exception' "$LOG_FILE"; then
    tail -n 80 "$LOG_FILE" >&2
    exit 1
  fi

  if [[ "$SECONDS" -ge "$deadline" ]]; then
    tail -n 120 "$LOG_FILE" >&2
    echo "Timed out waiting for Workshop update callback." >&2
    exit 1
  fi

  sleep 2
done

if [[ "$published" -ne 1 ]]; then
  tail -n 120 "$LOG_FILE" >&2
  echo "Rusted Warfare exited before the Workshop update callback." >&2
  exit 1
fi

log "verifying Workshop API metadata"
api_response="$(curl -s -X POST 'https://api.steampowered.com/ISteamRemoteStorage/GetPublishedFileDetails/v1/' \
  -d 'itemcount=1' \
  -d "publishedfileids[0]=$WORKSHOP_ID")"

if command -v jq >/dev/null 2>&1; then
  result="$(printf '%s' "$api_response" | jq -r '.response.publishedfiledetails[0].result')"
  visibility="$(printf '%s' "$api_response" | jq -r '.response.publishedfiledetails[0].visibility')"
  updated="$(printf '%s' "$api_response" | jq -r '.response.publishedfiledetails[0].time_updated')"
  title="$(printf '%s' "$api_response" | jq -r '.response.publishedfiledetails[0].title')"
  description="$(printf '%s' "$api_response" | jq -r '.response.publishedfiledetails[0].description')"
  [[ "$result" == "1" ]] || { echo "$api_response" >&2; exit 1; }
  [[ "$visibility" == "0" ]] || { echo "Workshop item is not public. visibility=$visibility" >&2; exit 1; }
  log "Workshop title: $title"
  log "Workshop updated: $(date -r "$updated" '+%Y-%m-%d %H:%M:%S %Z')"
  log "Workshop description: $description"
else
  printf '%s\n' "$api_response"
fi

if [[ "$CLEAN_LOCAL" -eq 1 ]]; then
  log "removing side-loaded local mod copy"
  rm -rf "$GAME_MOD_DIR" "$GAME_PACKAGE"
  refresh_workshop_subscription
fi

log "release complete"
