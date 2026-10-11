#!/usr/bin/env bash
# monitor.sh: проверка статуса сервиса и подсчёт ошибок в syslog за последний час.
# Использование: ./monitor.sh <имя-сервиса>

set -u

SERVICE="${1:-}"
SYSLOG="/var/log/syslog"

if [[ -z "$SERVICE" ]]; then
    echo "Использование: $0 <имя-сервиса>" >&2
    exit 2
fi

echo "=== Мониторинг: $SERVICE ($(date '+%F %T')) ==="

# 1. Существует ли такой сервис
if ! systemctl list-unit-files "${SERVICE}.service" 2>/dev/null | grep -q "^${SERVICE}.service"; then
    echo "ОШИБКА: сервис '$SERVICE' не найден" >&2
    exit 3
fi

# 2. Статус сервиса
STATUS="$(systemctl is-active "$SERVICE" 2>/dev/null)"
echo "Статус: $STATUS"

# 3. Если не active, показать последние 10 строк журнала
if [[ "$STATUS" != "active" ]]; then
    echo "--- Последние 10 строк журнала ($SERVICE) ---"
    LOG="$(journalctl -u "$SERVICE" -n 10 --no-pager 2>/dev/null)"
    if [[ -z "$LOG" ]]; then
        echo "(журнал пуст или недоступен; попробуйте запуск с sudo)"
    else
        echo "$LOG"
    fi
fi

# 4. Ошибки в syslog за последний час
echo "--- Ошибки в $SYSLOG за последний час ---"
if [[ ! -r "$SYSLOG" ]]; then
    echo "(файл $SYSLOG недоступен для чтения; попробуйте sudo)"
else
    FIRST="$(head -n 1 "$SYSLOG" | awk '{print $1}')"
    if [[ -z "$FIRST" ]]; then
        echo "Лог пуст, ошибок: 0"
    elif [[ "$FIRST" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T ]]; then
        SINCE="$(date -d '1 hour ago' '+%Y-%m-%dT%H:%M:%S')"
        COUNT="$(awk -v since="$SINCE" '$1 >= since' "$SYSLOG" | grep -ci 'error')"
        echo "Ошибок за последний час: $COUNT"
    else
        echo "(неизвестный формат времени в syslog: '$FIRST'; подсчёт пропущен)"
    fi
fi
