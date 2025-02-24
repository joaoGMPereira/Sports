#!/bin/sh

# ÚLTIMO PASSO - Abre o projeto após finalizar o comando
if [ "$open" != "no" ]
then
    echo "\nOpening project..."
	open App.xcworkspace
fi

exit 0
