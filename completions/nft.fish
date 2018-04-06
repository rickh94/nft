# Completions for nft command line interface to nftables
# Based heavily on the built in git completion in fish shell
#

set -gu __nft_choices "chain" "table" "rule" "set" "element" "map"
set -gu __nft_families "ip" "ip6" "inet" "arp" "bridge" "netdev"

# check if nft is waiting for a command
function __nft_needs_command
    set cmd (commandline -opc)
    set -l skip_next 1
    set -l dropwords 1
    set -q cmd[2]
    or return 0
    for c in $cmd[2..-1]
        test $skip_next -eq 0
        and set skip_next 1
        and continue
        switch $c
            case "-h" "--help" "-v" "--version" "-f" "--filename" "-i" "--interactive"
                return 1
            case "-n" "--numeric" "-N" "--reversedns" "-s" "--stateless" "-c" "--check" "-a" "--handle" "-e" "--echo"
                continue
            case "*"
                echo $c
                return 1
        end
    end
end

# check what command nft is using
function __nft_using_command
  set -l cmd (__nft_needs_command)
  test -z "$cmd"
  and return 1
  contains -- $cmd $argv
  and return 0
end


# check whether nft is has a chain/table/rule choice
function __nft_has_choice
  set -l cmd (commandline -opc)
  for word in $__nft_choices
    if contains -- $word $cmd
      return 0
    end
  end
  return 1
end

# check whether chain/table/rule/etc is needed
function __nft_needs_choice
  set -l cmd (commandline -opc)
  if __nft_has_choice
    return 1
  end
  return (__nft_using_command $argv)
end


# check whether a family is needed
function __nft_needs_family
  set -l cmd (commandline -opc)
  for choice in $__nft_choices
    if [ $cmd[-1] = $choice ]
      return 0
    end
  end
  return 1
end

# check whether a table is needed
function __nft_needs_table
  set -l cmd (commandline -opc)
  for word in $__nft_choices $__nft_families
    if [ $cmd[-1] = $word ]
      return 0
    end
  end
  return 1
end

# check whether nft needs chain
function __nft_needs_chain
  set -l cmd (commandline -opc)
  if not contains -- chain $cmd; and not contains -- rule $cmd
    return 1
  end
  # what will be in the command line is unknown, but it must be at minimum:
  # "nft <command> <chain/rule> <table>" which is 4 words long. This will
  # determine whether it needs a chain
  set -l min_len (__modify_min_length $cmd 4)
  if test (count $cmd) -eq $min_len
    return 0
  end
  return 1
end

# some completions will use the length of the command. This adjust that length for
# optional arguments
function __modify_min_length
  set -l cmd $argv[1]
  set -l min_len $argv[2]
  # If it has sudo, it should be one longer.
  if contains -- sudo $cmd
    set min_len (math $min_len+1)
  end
  # If it has a family (optional argument) it will be one longer
  for word in $__nft_families
    if contains -- $word $cmd
      set min_len (math $min_len+1)
    end
  end
  return min_len
end

## check whether nft needs rule suggestions
#function __nft_needs_rule_statement
#  set -l cmd (commandline -opc)
#  # need to be using add rule
#  if not __nft_using_command add
#    or not contains -- "rule" $cmd
#    return 1
#  end
#  set -l min_len 5
#  if contains -- sudo $cmd
#  for word in $__nft_families
#    if contains -- $word $cmd
#      set min_len (math $min_len+1)
#    end
#  end




# nft must take a subcommand or a switch, file completions are useless here
complete -c nft -f

# Switches
complete -c nft -s h -l help -x -d "Show help message and all options"
complete -c nft -s v -l version -x -d "Show version"
complete -c nft -s n -l numeric -d "Show data numerically"
complete -c nft -s N -l reversedns -d "Translate IP addresses to names. Usually requires network traffic for DNS lookup."
complete -c nft -s s -l stateless -d "Omit stateful information of rules and stateful objects."
complete -c nft -s c -l check -d "Check commands validity without actually applying the changes."
complete -c nft -s a -l handle -d "Show rule hanldes in output"
complete -c nft -s e -l echo -d "When inserting items into the ruleset, print notifications. (not in older versions)"
complete -c nft -s I -l includepath -r -d "Add directory to the list of directories to be searched for included files."
complete -c nft -s f -l file -r -d "Read input from a file"
complete -c nft -s i -l interactive -x -d "Read input from an interactive readline CLI"

# Subcommands
complete -c nft -n "__nft_needs_command" -a add -d "Add a table, chain, rule, set, map, or object"
complete -c nft -n "__nft_needs_command" -a list -d "List a ruleset, table, chain, set, map, or object"
complete -c nft -n "__nft_needs_command" -a flush -d "Flush (delete everything from) a ruleset, table, chain, set, or map"
complete -c nft -n "__nft_needs_command" -a export -d "Print the ruleset in a machine readable format (json or xml)"
complete -c nft -n "__nft_needs_command" -a delete -d "Delete a table, chain, rule, set, element, map, or object."
complete -c nft -n "__nft_needs_command" -a create -d "Similar to add but returns an error for existing chain."
complete -c nft -n "__nft_needs_command" -a rename -d "Rename the specified chain"
complete -c nft -n "__nft_needs_command" -a insert -d "Similar to the add command, but the rule is prepended to the beginning of the chain or before the rule at the given position."
complete -c nft -n "__nft_needs_command" -a replace -d "Similar to the add command, but replaces the specified rule."
complete -c nft -n "__nft_needs_command" -a reset -d "List-and-reset stateful object."
complete -c nft -n "__nft_needs_command" -a chain -d "Edit an existing chain."

# command groups(ish). table/chain/rule/etc
complete -c nft -n "__nft_needs_choice add delete" -a "table chain set rule map element"
complete -c nft -n "__nft_needs_choice list" -a "ruleset tables chains sets maps table chain set map"
complete -c nft -n "__nft_needs_choice flush" -a "ruleset table chain set map"
complete -c nft -n "__nft_needs_choice export" -a "ruleset"
complete -c nft -n "__nft_needs_choice create rename" -a "chain"
complete -c nft -n "__nft_needs_choice insert replace" -a "rule"

# after command groups
complete -c nft -n "__nft_needs_family" -a "$__nft_families" -d "family (optional)"
complete -c nft -n "__nft_needs_table" -a "filter nat raw mangle security" -d "common table name"
complete -c nft -n "__nft_needs_chain" -a "input output prerouting postrouting tcp udp forward" -d "common chain name"
