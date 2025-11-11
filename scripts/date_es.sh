#!/usr/bin/env bash
# ~/.config/polybar/scripts/date_es.sh
# Muestra: "Martes 11 Noviembre" y envuelve con %{A1:gsimplecal:}...%{A}

# Arrays con nombres en español (primera letra mayúscula)
week=(Lunes Martes Miércoles Jueves Viernes Sábado Domingo)
months=(Enero Febrero Marzo Abril Mayo Junio Julio Agosto Septiembre Octubre Noviembre Diciembre)

# índices (date +%u = 1..7, date +%m may have leading zero)
dow=$(date +%u)                # 1..7
daynum=$(date +%-d)            # día sin ceros a la izquierda
mon=$(date +%m)                # 01..12

# arithmetic with base to avoid octal problems
w=${week[$((dow-1))]}
m=${months[$((10#$mon-1))]}

# Imprime con el wrapper de click de polybar para abrir gsimplecal con click izquierdo
printf '%%{A1:gsimplecal:}%s %s %s%%{A}\n' "$w" "$daynum" "$m"
