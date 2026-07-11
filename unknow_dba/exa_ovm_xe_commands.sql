console {domain-id}
Attaches to a domain's console.

# xm console mydomain
create [-c] {config-file [name=value ...]}
Creates a domain based on the entries in the config-file.

Entering the -c parameter attaches to the domain's console when the domain is created and started.

You can also enter name value pairs to override variables in the config-file using the name=value parameter.

# xm -c /home/myhome/myconfig
destroy {domain-id}
Immediately terminates a domain.

# xm destroy mydomain
dmesg [--clear]
Displays message buffer logs similar in format to the equivalent to the dmesg command in the Linux kernel.

The --clear parameter clears the message buffer.

help [--long] [option]
Displays help on the xm command, and its options.

The --long option displays full help on xm commands, grouped by function.

Enter a command name as an option to the xm command to get help only on that command.

# xm help --long create
info
Displays information about the host computer.

# xm info
list [--long | --label] [domain-id, ...]
Displays information on all the running domains.

The --long option displays full information on running domains.

Enter the domain-id as an option to the xm command to get information on only that domain, or a set of domains.

# xm list --long mydomain
log
Displays logs similar in format to the equivalent for the Linux kernel. The log file is located at /var/log/xend.log.

# xm log
migrate {domain-id} {host} [-l | --live] [-r=MB | --resource=MB]
Migrates a domain to another computer.

The domain-id parameter is the domain to migrate.

The host parameter is the target computer.

The --live parameter migrates the domain without shutting down the domain.

The --resource parameter sets the maximum amount of Megabytes to be used.

# xm migrate mydomain example.com --live
new [config-file] [option ...] [name-=value ...]
Adds a domain to Oracle VM Server domain management.

You can set domain creation parameters with a number of command-line options, a Python script (with the --defconfig parameter), or an SXP configuration file (the --config parameter).

You can set configuration variables with name=value pairs, for example vmid=3 sets vmid to 3.

The config-file parameter is the location of the domain configuration file.

The option parameter is one or more of the following:

[-h | --help]

Displays help on the command.

[--help-config]

Prints the available configuration variables for the configuration script.

[-q | --quiet]

Quiet.

[--path=path]

Searches the location given in path for configuration scripts. The value of path is a colon-separated directory list.

[-f=file | --defconfig=file]

Uses the given Python configuration script. The script is loaded after arguments have been processed. Each command-line option sets a configuration variable named after its long option name, and these variables are placed in the environment of the script before it is loaded. Variables for options that may be repeated have list values. Other variables can be set using name=value on the command-line. After the script is loaded, values that were not set on the command-line are replaced by the values set in the script.

[-F=file | --config=file]

Sets the domain configuration to use SXP. SXP is the underlying configuration format used by Xen. SXP configurations can be hand-written or generated from Python configuration scripts, using the --dryrun option to print the configuration.

[-n | --dryrun]

Prints the resulting configuration in SXP, but does not create the domain.

[-x | --xmldryrun]

Prints the resulting configuration in XML, but does not create the domain.

[-s | --skipdtd]

Skips DTD checking and XML checks before domain creation. This option is experimental and may slow down the creation of domains.

[-p | --paused]

Leaves the domain paused after it is created.

[-c | --console_autoconnect]

Connects to the console after the domain is created.

# xm new /home/myhome/myconfig
pause {domain-id}
Pauses the execution of a domain.

# xm pause mydomain
reboot [--all] [--wait] [domain-id]
Reboots a domain.

The --all parameter reboots all domains.

The --wait parameter waits for the domain to reboot before returning control to the console.

# xm reboot --wait mydomain
restore {statefile}
Restores a domain from a saved state.

# xm restore /home/myhome/statefile
save {domain-id} {statefile}
Saves a domain state so it can be restored at a later date.

# xm save mydomain /home/myhome/statefile
shutdown [-a] [-w] [domain-id]
Shuts down a domain gracefully.

The -a parameter shuts down all domains.

The -w parameter waits for the domain to shut down before returning control to the console.

# xm shutdown -w mydomain
top
Displays real time monitoring information of the host and domains.

# xm top
unpause {domain-id}
Unpauses a paused domain.

# xm unpause mydomain