#!/bin/sh

# ÚLTIMO PASSO - Abre o projeto após finalizar o comando
if [ "$open" != "no" ]
then
    echo "\nOpening project..."
	open Sports.xcodeproj
fi

exit 0
