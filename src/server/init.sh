#! /bin/sh

if [ `id -u` = 0 ]; then
    echo "Do not run this as root; run it as mhucka"
fi

RETVAL=0

case "$1" in
  start)
        (. /home/mhucka/hamocs/venv/bin/activate; /home/mhucka/hamocs/flask-server.py &)
        RETVAL=$?
        ;;
  stop)
        killall flask-server.py
        RETVAL=$?
        ;;
  restart)
        $0 stop
        sleep 5
        $0 start
        RETVAL=$?
        ;;
  *)
        echo "Usage: $NAME {start|stop|restart}" >&2
        exit 3
        ;;
esac

exit $RETVAL
