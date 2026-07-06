#!/system/bin/sh
# VORTEX-exchange v4.0.2 customize.sh

ui_print "- VORTEX-exchange v4.0.2"
ui_print "- Verificando instalaciones previas..."

# Eliminar solo directorios en modules/ con BOM o nombre corrupto
# (NO tocar modules_update/ - es donde se instala este modulo ahora mismo)
for D in /data/adb/modules/vortex_exchange /data/adb/modules/vortex-exchange; do
  [ -d "$D" ] && rm -rf "$D" 2>/dev/null && ui_print "  Limpiado: $D"
done

ui_print "- OK. Reinicia para activar."
