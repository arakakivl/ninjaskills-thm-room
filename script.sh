#!/bin/bash

# Printing with red colors and bold styled.
rbprint () {
        echo -e "\e[1;91m$1\e[0m"
}

# All files
FILES=("8V2L" "bny0" "c4ZX" "D8B3" "FHl1" "oiMO" "PFbD" "rmfX" "SRSq" "uqyw" "v2Vb" "X1Uy")
echo -e "\e[1;93mThis script needs echo, find, grep, read, sha1sum, stat, sed and wc installed. They're generally present, but if one of them isn't, this script won't work. \e[0m"

# Iterating over each file
for f in ${FILES[@]};
do
        # Trying to find file "f" by its name and redirecting stderr to /dev/null
        FILE=$(find / -name "$f" 2> /dev/null)

        # If "FILE" isn't empty (meaning that 'find' could find the file -- maybe we do not have the right permission to check a certain directory)
        if ! [ -z $FILE ]; then
                # Setting IFS variables (one of its utilities is to set a string delimiter then it's possible to split a string into an array)
                IFS=" "

                # Reading sha1sum of $FILE and splitting its output into "shaoutarr" variable (output of sha1sum is formatted as "HASH FILE_PATH")
                # Another way of doing it would be using stdin to automatically don't print file's relative path. But a hyphen is being printed too so using grep or sed w/ regex would be neccessary and I really wanted to try w/ IFS
                # The alternative technique is being used for displaying only the file's number of lines; "wc -l < $FILE"
                read -a shaoutarr <<< $(sha1sum $FILE) # alternative: (sha1sum - < $FILE) | sed "s/[-]//"

                # Displaying information
                echo -e $"\e[1;92mFullPath: User : UserId : Group : GroupId : sha1 : nlines ->\e[94m ${FILE} : $(stat -c "%U : %u : %G : %g" $FILE) : ${shaoutarr[0]} : $(wc -l < $FILE)\e[0m"

                # Looking for regex pattern of an IP Address and redirecting stdout and stderr into /dev/null (this is a simple regex for ip address, sufficient only for this task)
                grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" $FILE 1>/dev/null 2>1

                # Maybe there's a better way to say "yes, there's an IP address!" with grep.
                if [ $? -eq 0 ]; then
                        rbprint "Looks like there's an IP address in file $FILE."
                fi

                # Checking if the file is executable by everyone (using regex) and redirecting any error and output into /dev/null
                ls -al $FILE | grep -E "^(-).{8}(x)" 1>/dev/null 2>1
                if [ $? -eq 0 ]; then
                        rbprint "Looks like file $FILE is executable by everyone."
                fi
        fi
done
