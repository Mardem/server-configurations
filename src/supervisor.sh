#!/bin/bash


# --------------- Configurar o Supervisor de Filas ---------------
echo -e "$c_invert$c_ciano Deseja configurar jobs (filas)? Digite um número abaixo:\n$c_reset"
echo -e "$c_verde 1 - Sim$c_reset"
echo -e "$c_vermelho 2 - Não$c_reset"
echo -e "$c_amarela 0 - Finalizar$c_reset"

read response;

case $response in
1) 
	echo -e "$c_amarela Aguarde enquanto configuro o supervisor"
	wget https://raw.githubusercontent.com/Mardem/server-configurations/master/laravel-worker.conf -P etc/supervisor/conf.d

	sudo supervisorctl reread
	sudo supervisorctl update
	sudo supervisorctl start laravel-worker:*

	echo -e "$c_verde Configuração finalizada, volte sempre."
;;
2) echo -e $c_vermelho$msg_1 ;;
*) echo -e $c_amarela$msg_1;;
esac

echo -e "$c_reset Instalação do servidor concluída com sucesso." 