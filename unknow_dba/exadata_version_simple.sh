#!/bin/bash

# Altera o diretório para /opt/oracle.SupportTools/onecommand
cd /opt/oracle.SupportTools/onecommand

# Busca o modelo do Exadata no arquivo databasemachine.xml
modelo=$(grep -i "<MACHINETYPES>" databasemachine.xml | sed -e 's/.*<MACHINETYPES>\(.*\)<\/MACHINETYPES>.*/\1/')

# Obtém informações de CPU
cpu_info=$(lscpu | grep -E '^CPU\(s\):' | awk '{print $2}')

# Obtém informações de Memória Total em GB
mem_total=$(free -g | awk '/^Mem:/{print $2}')

# Define cores para o output
blink='\033[5m'
green='\033[32m'
reset='\033[0m'

# Exibe o modelo, CPU e Memória Total formatados
echo -e "${blink}${green}Modelo do Exadata: ${modelo}${reset}"
echo -e "${green}CPU(s): ${cpu_info}${reset}"
echo -e "${green}Memória Total: ${mem_total} GB${reset}"