
#!/bin/bash
#Este script me permitira saber cuantos dias faltan para que se venza el certificado ssl.
#Ademas enviara un correo indicando la informacion. Si el periodo es menor a 30 dias renovara el certificado

#En este bloque se optiene la fecha en la cual expirara el certificado

        FECHA_STRING=$(echo | openssl s_client -connect localhost:443 2>/dev/null | openssl x509 -noout -dates | grep "notAfter")
        FECHA_FIN_SEG=$(date -d "${FECHA_STRING:9:20}" +%s)
        FECHA_ACTUAL=$(date +%s)
        DIAS=$(((FECHA_FIN_SEG - FECHA_ACTUAL)/(60*60*24)))


#Crea el archivo de log
        dt=`date +%y%m%d`
        host=$(cat /etc/hostname)
        echo -e "Subject: El certificado de $host tiene $DIAS dias de vigencia \n" > cert-renew-$dt

#Ejecuta  el bot  de renovacion. Actualiza cerbot y renueva los certificados que esten por vencer.
        sudo letsencrypt renew >> cert-renew-$dt

#si se quiere enviar el correo solo si se realizo la renovacion se descomente las lineas 23,24 y 29.
#        verf=$(grep -c "No" cert-renew-$dt)
#        if [ $verf = 0 ];then
             sendmail correo < cert-renew-$dt
#            sendmail correo < cert-renew-$dt # se pueden enviar a varas cuentas
        #Reinicia el servidor apache
             service apache2 restart
#        fi