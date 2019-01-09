#!/bin/bash

if [ ! $# -eq 1 ]
then
    echo "minientrega.sh: Error(EX_USAGE), uso incorrecto del mandato. \"Success\""
    echo "minientrega.sh+ El script ha sido invocado con un numero de argumentos distinto de zero."
    exit 64
fi


if [ $1 = "-h" ] || [ $1 = "--help" ]
then
    echo minientrega.sh: Uso: ./minientrega.sh ID_PRACTICA
    echo minientrega.sh: Entrega el fichero con id ID_PRACTICA
    exit 0
fi

if [ ! -d "$MINIENTREGA_CONF" ]
then
    echo minientrega.sh: Error, no se pudo realizar la entrega.
    echo minientrega.sh+ no es accesible el directorio \"$MINIENTREGA_CONF\".
    exit 64
fi

contenido=$( ls $MINIENTREGA_CONF)
resultado=0

for fichero in $contenido
do
    if [ $1 = $fichero ]
    then
        resultado=1
    fi
done

if [ $resultado = 0 ]
then
    echo minientrega.sh: Error, no se pudo realizar la entrega
    echo minientrega.sh+ no es accesible el fichero \"$1\".
    exit 66
fi

configuracion=$( cd $MINIENTREGA_CONF; less $1)
count=0
WORDS=$( echo $configuracion | wc -w)

for word in $configuracion
do
    if [[ count -eq 0 ]]
    then
        palabra=$(echo "${word#*=}")
        FECHA_LIMITE=$(echo "${palabra//\"/}")
        let count++

    elif [[ count -lt WORDS ]]
    then
        palabra=$(echo "${word#*=}")
        FICHEROS="$FICHEROS $(echo "${palabra//\"/}")"
        let count++

    else
        palabra=$(echo "${word#*=}")
        DESTINO=$(echo "${palabra//\"/}")
    fi
done

echo $FECHA_LIMITE $FICHEROS $DESTINO

