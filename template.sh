#!/bin/sh 

# set -vx

###############################################################################
#                                                                             #
#                   Program      :    template.sh                             #
#                   Author       :    itachi                                  #
#                   Publish      :    29-Jan-2020                             #
#                   Version      :    1.0                                     #
#                                                                             #
###############################################################################
#                                                                             #
#   Functions:-                                                               #
#                                                                             #
#     1.                                                                      #
#     2.                                                                      #
#     3.                                                                      #
#                                                                             #
###############################################################################
#                                                                             #
#   Version History:-                                                         #
#                                                                             #
#     -------     -----         ------        ------------------              #
#     Version     Dated         Author        Change Description              #
#     -------     -----         ------        ------------------              #
#       1.0   29-Jan-2020       itachi        Script Initialization           #
#                                                                             #
###############################################################################

machine=`uname -n`
sysdate=`date +%Y%m%d`

starline=`printf "%*s\n" 79 " "|tr " " "#"`

_select_title(){

    # Get the user input.
    printf "Enter a title: " ; read -r title

    # Remove the spaces from the title if necessary.
    title=${title// /_}

    # Convert uppercase to lowercase.
    title=${title,,}

    # Add .sh to the end of the title if it is not there already.
    [ "${title: -3}" != '.sh' ] && title=${title}.sh

    # Check to see if the file exists already.
    if [ -e $title ] ; then 
        printf "\n%s\n%s\n\n" "The script \"${title}\" already exists." \
        "Please select another title."
        _select_title
    fi
}

_select_title


printf "Enter your author: " ; read -r author
printf "Enter the version number: " ; read -r vnum

published=`date +%d-%b-%Y`

title_offset=$((79 - 38 - ${#title}))
author_offset=$((79 - 38 - ${#author}))
vnum_offset=$((79 - 38 - ${#vnum}))
publish_offset=$((79 - 38 - ${#published}))


printf "%-10s\n\n\
%-7s\n\n\
%-79s\n\
%-s%78s\n\
%-20s%-13s%-5s%-${#title}s%${title_offset}s\n\
%-20s%-13s%-5s%-${#author}s%${author_offset}s\n\
%-20s%-13s%-5s%-${#published}s%${publish_offset}s\n\
%-20s%-13s%-5s%-${#vnum}s%${vnum_offset}s\n\
%-s%78s\n\
%-79s\n\
%-s%78s\n\
%-4s%-12s%63s\n\
%-s%78s\n\
%-6s%-5s%68s\n\
%-6s%-5s%68s\n\
%-6s%-5s%68s\n\
%-s%78s\n\
%-79s\n\
%-s%78s\n\
%-4s%-16s%58s\n\
%-s%78s\n\
%-6s%-12s%-14s%-14s%-18s%15s\n\
%-6s%-12s%-14s%-14s%-18s%15s\n\
%-6s%-12s%-14s%-14s%-18s%15s\n\
%-8s%-6s%-18s%-14s%-29s%4s\n\
%-s%78s\n\
%-79s\n\n"  "#!/bin/sh" "set -vx" \
"${starline}" "#" "#" \
"#" "Program" ":" "${title}" "#" \
"#" "Author" ":" "${author}" "#" \
"#" "Publish" ":" "${published}" "#" \
"#" "Version" ":" "${vnum}" "#" \
"#" "#" "${starline}" "#" "#" \
"#" "Functions:-" "#" "#" "#" \
"#" "1.  " "#" \
"#" "2. " "#" \
"#" "3. " "#" \
"#" "#" "${starline}" "#" "#" \
"#" "Version History:-" "#" "#" "#" \
"#" "-------" "-----" "------" "------------------" "#" \
"#" "Version" "Dated" "Author" "Change Description" "#" \
"#" "-------" "-----" "------" "------------------" "#" \
"#" "1.0" "${published}" "${author}" "Script Initialization" "#" \
"#" "#" "${starline}" > ${title}

echo "machine=\`uname -n\`" >> ${title}
echo "sysdate=\`date +%Y%m%d\`" >> ${title}

# Make the file executable.
chmod +x ${title}

/usr/bin/clear

_select_editor(){

    # Select between Vim or Emacs.
    printf "%s\n%s\n%s\n%s\n%s\n\n" "Select an editor." "1 for Vim." "2 for Sublime." "3 for VS Code" "4 for Vi"  
    read -r editor

    # Open the file with the cursor on the twelth line.
    case ${editor} in
        1) vim +32 ${title}
            ;;
        2) subl +32 ${title}
            ;;
        3) code +32 ${title}
            ;;
        4) vi +32 ${title}
            ;;
       *) /usr/bin/clear
           printf "%s\n%s\n\n" "I did not understand your selection." \
               "Press <Ctrl-c> to quit."
           _select_editor
            ;;
    esac

}

_select_editor
