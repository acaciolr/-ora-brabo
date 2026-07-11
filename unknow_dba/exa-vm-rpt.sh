#!/bin/bash
# Franky Weber Faust -- July 2025 -- weber08weber@gmail.com -- https://loredata.com.br
# Copyright (C) 2025 Franky Faust
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
#
# More info and git repo: https://github.com/FrankyWeber/golden-scripts
#
# The current script version is 20250722
#
# History :
#
# 20250722 - Franky Faust - Initial release with argument $1 for search path or default to /EXAVMIMAGES/GuestImages, colored output and summarized and detailed outputs.
#
# ==============================================================================
# Script: exa-vms-report.sh
#
# Description: Scans for valid Exadata VM configs and generates a color-coded
#              report. Supports summary/detail modes and light/dark themes.
#              Calculates actual disk sizes in all reporting modes.
#
# Usage: ./exa-vm-rpt.sh [-detail] [-theme light|dark] [optional_path]
#        If no path is provided, it defaults to /EXAVMIMAGES/GuestImages.
# ==============================================================================

# --- Argument and Theme Defaults ---
DETAIL_MODE=false
THEME="dark" # Default theme
USER_PATH=""

# --- Robust Argument Parsing ---
while (( "$#" )); do
  case "$1" in
    -detail)
      DETAIL_MODE=true
      shift
      ;;
    -theme)
      if [[ -n "$2" && ("$2" == "light" || "$2" == "dark") ]]; then
        THEME="$2"
        shift 2 # Consume flag and its value
      else
        echo "Error: -theme option requires 'light' or 'dark' as an argument." >&2
        exit 1
      fi
      ;;
    -*) # Handle unknown flags
      echo "Error: Unknown flag $1" >&2
      exit 1
      ;;
    *) # Assume it's the path
      USER_PATH="$1"
      shift
      ;;
  esac
done

# --- Define Color Palette Based on Theme ---
C_RESET='\033[0m'
C_BOLD='\033[1m'

if [[ "$THEME" == "light" ]]; then
  # Palette for light backgrounds
  C_HEADER_DIV='\033[1;34m'; C_VM_SEP='\033[1;32m'; C_HOSTNAME='\033[1;30m'
  C_CPU='\033[0;31m'; C_MEM='\033[0;32m'; C_IP_PUB='\033[0;34m'
  C_IP_PRIV='\033[0;35m'; C_DISK='\033[0;36m'; C_ERR='\033[0;31m'
else
  # Palette for dark backgrounds
  C_HEADER_DIV='\033[1;34m'; C_VM_SEP='\033[1;33m'; C_HOSTNAME='\033[1;37m'
  C_CPU='\033[0;32m'; C_MEM='\033[0;33m'; C_IP_PUB='\033[0;36m'
  C_IP_PRIV='\033[0;35m'; C_DISK='\033[0;96m'; C_ERR='\033[0;31m'
fi


# --- Functions ---
print_detailed_header() {
    echo ""
    printf -- '-%.0s' {1..70}; echo ""
    printf "${C_HEADER_DIV} %-68s ${C_RESET}\n" "$1"
    printf -- '-%.0s' {1..70}; echo ""
}

# --- Main Logic ---
SEARCH_DIR=${USER_PATH:-/EXAVMIMAGES/GuestImages}
if [[ ! -d "$SEARCH_DIR" ]]; then
    echo -e "${C_ERR}Error: Search path '$SEARCH_DIR' is not a valid directory.${C_RESET}" >&2
    exit 1
fi

VM_COUNT=0
FOOTER_NOTE_NEEDED=false

# --- Find and Loop Through Config Files ---
# This still needs improvement since it's relying only on config files instead of running VMs.
# For future releases I have to parse the running VMs and try to extract the details from vm_maker, virsh, or some other tool.
while read -r config_file; do
    if ! grep -q '<virtualMachine' "$config_file"; then continue; fi
    VM_COUNT=$((VM_COUNT + 1))

    if [ "$DETAIL_MODE" = true ]; then
        #============================#
        # --- DETAILED REPORT MODE ---
        #============================#
        printf "\n\n"
        printf "${C_VM_SEP}###########################################################################${C_RESET}\n"
        printf "${C_VM_SEP}### Starting Detailed Report for VM: $(basename "$config_file")${C_RESET}\n"
        printf "${C_VM_SEP}###########################################################################${C_RESET}\n"

        # A. VM Details
        print_detailed_header "Virtual Machine Core Configuration"
        HOSTNAME=$(grep '<domuName>' "$config_file" | sed -e 's,.*<domuName>\(.*\)</domuName>.*,\1,')
        CPU=$(awk '/<virtualMachine /,/<\/virtualMachine>/' "$config_file" | grep -m 1 '<cpu>' | sed -e 's,.*<cpu>\(.*\)</cpu>.*,\1,' | tr -d '[:space:]')
        MEMORY=$(grep '<memorySize>' "$config_file" | sed -e 's,.*<memorySize>\(.*\)</memorySize>.*,\1,')
        VM_TYPE=$(grep '<virtualMachineType>' "$config_file" | sed -e 's,.*<virtualMachineType>\(.*\)</virtualMachineType>.*,\1,')
        NODE_TYPE=$(grep '<Node_type>' "$config_file" | head -n1 | sed -e 's,.*<Node_type>\(.*\)</Node_type>.*,\1,' | tr '[:lower:]' '[:upper:]')
        printf "%-20s : ${C_HOSTNAME}%s${C_RESET} (%s Node)\n" "Hostname" "$HOSTNAME" "$NODE_TYPE"
        printf "%-20s : %s\n" "Virtualization Type" "$VM_TYPE"
        printf "%-20s : ${C_CPU}%s Cores${C_RESET}\n" "CPU Allocated" "$CPU"
        printf "%-20s : ${C_MEM}%s${C_RESET}\n" "Memory Size" "$MEMORY"

        # B. Public Network
        print_detailed_header "Network Interfaces (Public/Backup)"
        awk -v c_ip_pub="$C_IP_PUB" -v c_reset="$C_RESET" '
        BEGIN { RS="</Interfaces>"; FS="\n" } !/<QinQStructure>/ { if ($0 ~ /<Name>/ && $0 !~ /re0|re1/) {
        name=""; ip=""; vlan=""; slaves=""; net_type=""; bridge=""; gateway="";
        for(i=1; i<=NF; i++) { if ($i~/<Name>/)name=$i; if($i~/<IP_address>/)ip=$i; if($i~/<Vlan_id>/)vlan=$i; if($i~/<Net_type>/)net_type=$i; if($i~/<Slaves>/)slaves=slaves $i", "; if($i~/<Bridge>/)bridge=$i; if($i~/<Gateway>/)gateway=$i }
        gsub(/.*<Name>|<\/Name>.*/,"",name); gsub(/.*<IP_address>|<\/IP_address>.*/,"",ip); gsub(/.*<Vlan_id>|<\/Vlan_id>.*/,"",vlan); gsub(/.*<Net_type>|<\/Net_type>.*/,"",net_type); gsub(/.*<Bridge>|<\/Bridge>.*/,"",bridge); gsub(/.*<Gateway>|<\/Gateway>.*/,"",gateway); gsub(/.*<Slaves>|<\/Slaves>.*/,"",slaves); gsub(/, $/,"",slaves);
        printf "\n▶ Interface: %-15s [Type: %s, VLAN: %s]\n",name,net_type,(vlan?vlan:"N/A"); if(ip)printf "    %-18s : "c_ip_pub"%s"c_reset"\n","IP Address",ip; if(gateway)printf "    %-18s : %s\n","Gateway",gateway; if(bridge)printf "    %-18s : %s\n","Bridge",bridge; if(slaves)printf "    %-18s : %s\n","Slaves",slaves }}' "$config_file"

        # C. Private Network
        print_detailed_header "Private Network (QinQ)"
        awk -v c_ip_priv="$C_IP_PRIV" -v c_reset="$C_RESET" '
        BEGIN { RS="</Interfaces>"; FS="\n" } /<QinQStructure>/,/\/QinQStructure>/ { if ($0 ~ /<Intname>/) {
        intname=""; ip=""; vlan=""; physdev=""; membership="";
        for(i=1; i<=NF; i++) { if($i~/<Intname>/)intname=$i; if($i~/<IP_address>/)ip=$i; if($i~/<Vlan_id>/)vlan=$i; if($i~/<Physdev>/)physdev=$i; if($i~/<Membership>/)membership=$i }
        gsub(/.*<Intname>|<\/Intname>.*/,"",intname); gsub(/.*<IP_address>|<\/IP_address>.*/,"",ip); gsub(/.*<Vlan_id>|<\/Vlan_id>.*/,"",vlan); gsub(/.*<Physdev>|<\/Physdev>.*/,"",physdev); gsub(/.*<Membership>|<\/Membership>.*/,"",membership);
        printf "\n▶ Private Interface: %-15s [VLAN: %s, Physical: %s]\n",intname,vlan,physdev; printf "    %-18s : "c_ip_priv"%s"c_reset"\n","IP Address",ip; printf "    %-18s : %s\n","Membership",membership }}' "$config_file"

        # D. Disks
        print_detailed_header "Virtual Disks Layout"
        printf "${C_DISK}%-28s | %-45s | %-12s${C_RESET}\n" "Image File" "Mount Path / Target" "Size"
        printf "${C_DISK}---------------------------- | --------------------------------------------- | ------------${C_RESET}\n"
        disk_info_stream=$(awk 'BEGIN{RS="</disk>";FS="\n";OFS="|"} /<disk / { filename=""; path=""; size="N/A"; for(i=1;i<=NF;i++) { if($i~/<imageFileName>/) filename=$i; if($i~/<diskPath>/) path=$i; if($i~/<imageSize>/) size=$i; } gsub(/.*<imageFileName>|<\/imageFileName>.*/,"",filename); gsub(/.*<diskPath>|<\/diskPath>.*/,"",path); gsub(/.*<imageSize>|<\/imageSize>.*/,"",size); if(filename){ print filename, path, size } }' "$config_file")
        if [ -n "$disk_info_stream" ]; then
            echo "$disk_info_stream" | while IFS='|' read -r filename path size; do
                display_size="[${size} GB]"; if [[ "$size" == "default" || "$size" == "N/A" ]]; then
                    config_dir=$(dirname "$config_file"); image_path="$config_dir/$filename"
                    if [[ -f "$image_path" ]]; then
                        size_bytes=$(stat -c%s "$image_path"); size_gb=$((size_bytes/1024/1024/1024)); display_size="[${size_gb} GB]*"; FOOTER_NOTE_NEEDED=true
                    else display_size="[N/A]"; fi
                fi; printf "${C_DISK}%-28s${C_RESET} | %-45s | %-12s\n" "$filename" "$path" "$display_size";
            done
        fi

    else
        #===========================#
        # --- SUMMARY REPORT MODE ---
        #===========================#
        if [[ "$VM_COUNT" -gt 1 ]]; then printf "\n"; fi
        printf -- '-%.0s' {1..140}; echo ""

        HOSTNAME=$(grep '<domuName>' "$config_file" | sed -e 's,.*<domuName>\(.*\)</domuName>.*,\1,')
        CPU=$(awk '/<virtualMachine /,/<\/virtualMachine>/' "$config_file" | grep -m 1 '<cpu>' | sed -e 's,.*<cpu>\(.*\)</cpu>.*,\1,' | tr -d '[:space:]')
        MEMORY=$(grep '<memorySize>' "$config_file" | sed -e 's,.*<memorySize>\(.*\)</memorySize>.*,\1,')
        IP_INFO=$(awk 'BEGIN{RS="</Interfaces>";FS="\n";OFS=";"} !/<QinQStructure>/&&/<Name>bondeth0<\/Name>/{for(i=1;i<=NF;i++)if($i~/<IP_address>/){gsub(/.*<IP_address>|<\/IP_address>.*/,"",$i);client_ip=$i}} !/<QinQStructure>/&&/<Name>bondeth1<\/Name>/{for(i=1;i<=NF;i++)if($i~/<IP_address>/){gsub(/.*<IP_address>|<\/IP_address>.*/,"",$i);backup_ip=$i}} /<QinQStructure>/,/\/QinQStructure>/{if($0~/<Intname>clre0<\/Intname>/){for(i=1;i<=NF;i++)if($i~/<IP_address>/){gsub(/.*<IP_address>|<\/IP_address>.*/,"",$i);priv_ip=$i}}} END{print (client_ip?client_ip:"N/A") OFS (backup_ip?backup_ip:"N/A") OFS (priv_ip?priv_ip:"N/A")}' "$config_file")
        CLIENT_IP=$(echo "$IP_INFO" | cut -d';' -f1); BACKUP_IP=$(echo "$IP_INFO" | cut -d';' -f2); PRIVATE_IP=$(echo "$IP_INFO" | cut -d';' -f3)

        printf "${C_BOLD}VM Hostname:${C_RESET} ${C_HOSTNAME}%-35s${C_RESET} | ${C_BOLD}CPU:${C_RESET} ${C_CPU}%-2s Cores${C_RESET} | ${C_BOLD}Memory:${C_RESET} ${C_MEM}%-8s${C_RESET}\n" \
            "${HOSTNAME:-N/A}" "${CPU:-N/A}" "${MEMORY:-N/A}"
        printf "${C_BOLD}IPs -> Client:${C_RESET} ${C_IP_PUB}%-18s${C_RESET} | ${C_BOLD}Backup:${C_RESET} ${C_IP_PUB}%-18s${C_RESET} | ${C_BOLD}Private:${C_RESET} ${C_IP_PRIV}%-18s${C_RESET}\n" \
            "${CLIENT_IP:-N/A}" "${BACKUP_IP:-N/A}" "${PRIVATE_IP:-N/A}"
        
        printf "  ${C_BOLD}Disks:${C_RESET}\n"
        printf "    ${C_DISK}%-30s | %-45s | %-12s${C_RESET}\n" "Image File" "Mount Path" "Size"
        printf "    ${C_DISK}------------------------------ | --------------------------------------------- | ------------${C_RESET}\n"
        
        disk_info_stream=$(awk 'BEGIN{RS="</disk>";FS="\n";OFS="|"} /<disk / { filename=""; path=""; size="N/A"; for(i=1;i<=NF;i++) { if($i~/<imageFileName>/) filename=$i; if($i~/<diskPath>/) path=$i; if($i~/<imageSize>/) size=$i; } gsub(/.*<imageFileName>|<\/imageFileName>.*/,"",filename); gsub(/.*<diskPath>|<\/diskPath>.*/,"",path); gsub(/.*<imageSize>|<\/imageSize>.*/,"",size); if(filename){ print filename, path, size } }' "$config_file")
        if [ -n "$disk_info_stream" ]; then
            echo "$disk_info_stream" | while IFS='|' read -r filename path size; do
                display_size="[${size} GB]"; if [[ "$size" == "default" || "$size" == "N/A" ]]; then
                    config_dir=$(dirname "$config_file"); image_path="$config_dir/$filename"
                    if [[ -f "$image_path" ]]; then
                        size_bytes=$(stat -c%s "$image_path"); size_gb=$((size_bytes/1024/1024/1024)); display_size="[${size_gb} GB]*"; FOOTER_NOTE_NEEDED=true
                    else display_size="[N/A]"; fi
                fi
                printf "    ${C_DISK}%-30s${C_RESET} | %-45s | %-12s\n" "$filename" "$path" "$display_size"
            done
        fi
    fi
done < <(find "$SEARCH_DIR" -type f -name "*.xml" ! -name "*.orig" ! -name "*backupbyExadata*")

# --- Footer ---
if [ "$DETAIL_MODE" = false ]; then
   printf -- '-%.0s' {1..140}; echo ""
fi

if [[ "$FOOTER_NOTE_NEEDED" = true ]]; then
    echo -e "${C_DISK}* Size calculated from filesystem file${C_RESET}"
fi

if [[ "$VM_COUNT" -eq 0 ]]; then
    echo -e "\n${C_ERR}No valid VM configuration files were found in '$SEARCH_DIR'${C_RESET}"
else
    echo -e "\n${C_BOLD}### Report Complete. Processed $VM_COUNT valid VM(s). ###${C_RESET}\n"
fi

exit 0
#*********************************************************************************************************
#                               E N D     O F      S O U R C E
#*********************************************************************************************************
