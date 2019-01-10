#!/bin/bash


#CHECKS IF ONLY 1 ARGUMENT PASSED TO THE SCRIPT

if [ ! $# -eq 1 ]
then
    echo "minientrega.sh: Error(EX_USAGE), uso incorrecto del mandato. \"Success\""
    echo "minientrega.sh+ El script ha sido invocado con un numero de argumentos distinto de zero."
    exit 64
fi




#CHECKS IF THE ARGUMENT IS THE HELP ARGUMENT

if [ $1 = "-h" ] || [ $1 = "--help" ]
then
    echo minientrega.sh: Uso: ./minientrega.sh ID_PRACTICA
    echo minientrega.sh: Entrega el fichero con id ID_PRACTICA
    exit 0
fi



#CHECKS IF EXISTS THE SOURCE DIRECTORY AND IF ITS A DIRECTORY

if [ ! -d $MINIENTREGA_CONF ] || [ ! -r $MINIENTREGA_CONF ] || [ ! -x $MINIENTREGA_CONF ]
then
    echo minientrega.sh: Error, no se pudo realizar la entrega.
    echo minientrega.sh+ no es accesible el directorio \"$MINIENTREGA_CONF\".
    exit 64
fi



#GETS ALL THE FILES IN THE SOURCE DIRECTORY

contenido=$( ls $MINIENTREGA_CONF)
resultado=0



#CHECKS IF THE ID_PRACTICA EXISTS IN THE SOURCE DIRECTORY

for fichero in $contenido
do
    if [ $1 = $fichero ]
    then
        resultado=1
    fi
done



#IF THE ID DOESNT EXISTS, ENDS

if [ $resultado = 0 ]
then
    echo minientrega.sh: Error, no se pudo realizar la entrega
    echo minientrega.sh+ no es accesible el fichero \"$1\".
    exit 66
fi



#GETS ALL THE INPUT IN THE FILE AND STORES IT, AND WE GET THE NUMBER OF WORDS
#IN THE FILE

configuracion=$( cd $MINIENTREGA_CONF; less $1)
count=1
WORDS=$( echo $configuracion | wc -w)



#WE FILTER THE CONTENT OF THE FILE TO GET THE EXPIRE DATE, THE FILES TO DELIVER
#AND THE PATH WE HAVE TO COPY THE FILES

for word in $configuracion
do
    if [[ $count -eq 1 ]]
    then
        palabra=$(echo "${word#*=}")
        FECHA_LIMITE=$(echo "${palabra//\"/}")
        let count++

    elif [[ $count -lt $WORDS ]]
    then
        palabra=$(echo "${word#*=}")
        FICHEROS="$FICHEROS $(echo "${palabra//\"/}")"
        let count++

    else
        palabra=$(echo "${word#*=}")
        DESTINO=$(echo "${palabra//\"/}")
    fi
done



#CHEKS IF THE EXPIRE DATE HAS A VALID FORMAT

DATE_IN_SECONDS=$(date +"%s")

if [[ ! $FECHA_LIMITE =~ [2][0-1][0-9][0-9]-[0-1][0-9]-[0-3][0-9] ]]
then
    echo minientrega.sh: Error, no se pudo realizar la entrega.
    echo minientrega.sh+ fecha incorrecta "$FECHA_LIMITE"
    exit 65
fi



#CHECKS IF THE EXPIRE DATE IS BEFORE 2100

if [[ $FECHA_LIMITE =~ ^[2][1].* ]]
then
    echo minientrega.sh: Error, no se pudo realizar la entrega.
    echo minientrega.sh+ la fecha limite de entrega no puede ser superior a 2100
    exit 65
fi



#CHANGES THE TIME FORMAT OF THE EXPIRE DATE TO SECONDS AND COMPARES IT TO THE
#ACTUAL DATE

LIMITE_SEGUNDOS=$(date -jf '%Y-%m-%d' $FECHA_LIMITE '+%s')

if [[ $LIMITE_SEGUNDOS -lt $DATE_IN_SECONDS ]]
then
    echo minientrega.sh: Error, no se pudo realizar la entrega
    echo minientrega.sh+ el plazo acababa el $FECHA_LIMITE
    exit 65
fi



#CHECKS IF THE FILES THAT WE HAVE TO DELIVER EXIST IN OUR DIRECTORY AND ARE
#READABLE

for fichero in $FICHEROS
do
    if [[ ! -r $fichero ]]
    then
        echo minientrega.sh: Error, no se pudo realizar la entrega
        echo minientrega.sh+ no es accesible el fichero $fichero
        exit 66
    fi
done



#CHECKS IF THE DELIVERY DIRECTORY EXISTS AND HAS THE PERMISSIONS TO COPY INTO IT

if [ ! -d $DESTINO ] || [ ! -r $DESTINO ] || [ ! -x $DESTINO ]
then
    echo minientrega.sh: Error, no se pudo realizar la entrega
    echo minientrega.sh+ no se puedo crear el subdirectorio de entrenga en \"$DESTINO\"
    exit 73
fi



#CREATES THE END DELIVERY DIRECTORY AND COPIES THE FILES INTO IT

FINAL_DIRECTORY=$(cd $DESTINO; mkdir $USER; cd $USER; pwd)
cp $FICHEROS $FINAL_DIRECTORY

