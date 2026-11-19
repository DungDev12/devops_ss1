#!/usr/bin/env bash
# QuickBite — triển khai User Service vào Development
set -uo pipefail
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; NC='\033[0m'
info(){ printf "${YELLOW}[INFO] %s${NC}\n" "$*"; }
ok(){ printf "${GREEN}[OK] %s${NC}\n" "$*"; }
fail(){ printf "${RED}[ERROR] %s${NC}\n" "$*" >&2; exit 1; }
[[ $EUID -eq 0 ]] || fail 'Chạy bằng: sudo ./deploy-dev.sh user'
[[ ${1:-} == user ]] || fail 'Tham số hợp lệ: user'
PORT=8080
SERVICE_USER=user-svc
SERVICE_GROUP=quickbite-apps
TARGET_DIR=/opt/quickbite/dev/user-service
DEPLOY_USER=${SUDO_USER:-}
[[ -n $DEPLOY_USER && $DEPLOY_USER != root ]] || fail 'Hãy chạy sudo từ tài khoản Linux thông thường.'
DEPLOY_HOME=$(getent passwd "$DEPLOY_USER" | cut -d: -f6)
# Đổi "quickbite" thành tên repository thực tế (hoặc truyền PROJECT_DIR vào sudo -E).
PROJECT_DIR=${PROJECT_DIR:-"$DEPLOY_HOME/workspace/quickbite"}
[[ -d "$PROJECT_DIR/.git" && -f "$PROJECT_DIR/gradlew" ]] || fail "Không tìm thấy dự án Gradle tại $PROJECT_DIR"
info 'Cập nhật Git...'
runuser -u "$DEPLOY_USER" -- git -C "$PROJECT_DIR" pull --ff-only
GIT_STATUS=$?
[[ $GIT_STATUS -eq 0 ]] || fail "git pull thất bại (exit=$GIT_STATUS)"
info 'Build bằng Gradle...'
runuser -u "$DEPLOY_USER" -- bash -c 'cd "$1" && chmod +x gradlew && ./gradlew clean bootJar' _ "$PROJECT_DIR"
BUILD_STATUS=$?
[[ $BUILD_STATUS -eq 0 ]] || fail "BUILD FAILED (exit=$BUILD_STATUS); dừng triển khai"
ok 'BUILD SUCCESSFUL'
JAR_FILE=$(find "$PROJECT_DIR/build/libs" -maxdepth 1 -type f -name '*.jar' ! -name '*-plain.jar' -print -quit)
[[ -n $JAR_FILE ]] || fail 'Không tìm thấy JAR trong build/libs'
mkdir -p "$TARGET_DIR"
chown "$SERVICE_USER:$SERVICE_GROUP" "$TARGET_DIR"
chmod 750 "$TARGET_DIR"
info "Dừng tiến trình đang lắng nghe cổng $PORT (theo yêu cầu đề bài)..."
PIDS=$(lsof -tiTCP:"$PORT" -sTCP:LISTEN || true)
if [[ -n $PIDS ]]; then
  for PID in $PIDS; do
    info "kill -9 PID $PID"
    kill -9 "$PID" || fail "Không dừng được PID $PID"
  done
fi
cp "$JAR_FILE" "$TARGET_DIR/app.jar"
chown "$SERVICE_USER:$SERVICE_GROUP" "$TARGET_DIR/app.jar"
chmod 640 "$TARGET_DIR/app.jar"
info 'Khởi chạy ứng dụng dưới user-svc...'
runuser -u "$SERVICE_USER" -- bash -c 'cd "$1"; nohup java -jar app.jar --spring.profiles.active=dev --server.port="$2" > app.log 2>&1 < /dev/null &' _ "$TARGET_DIR" "$PORT"
START_STATUS=$?
[[ $START_STATUS -eq 0 ]] || fail 'Không gửi được lệnh khởi chạy'
ok "Đã gửi lệnh khởi chạy; kiểm tra sau 10 giây: sudo ss -ltnp | grep :$PORT"
info "Xem log: sudo tail -n 60 $TARGET_DIR/app.log"
