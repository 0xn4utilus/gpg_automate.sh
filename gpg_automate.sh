#! /bin/bash

generate_key(){
    gpg --full-generate-key
    printf "\nSUCCESSFULLY CREATED NEW KEY\n\n"
    printf "COPY THIS INTO GITHUB SETTINGS TO COMPLETE SETTING UP NEW KEY"
    k=$(gpg --list-secret-keys --keyid-format=long|awk '/sec/{if (length($2)>0) print $2}')
    s=${k:${#k}-16:16} 
    gpg --armor --export $s
    main
     
}

main(){
    if gpg --list-secret-keys --keyid-format LONG | grep -q sec
    then
        declare -A array_of_keys
        declare -A array_of_details
        k=0
        for i in $(gpg --list-secret-keys --keyid-format=long|awk '/sec/{if (length($2)>0) print $2}');
        do array_of_keys+=([$k]=${i:8:16})
        ((k++))
        done

        k=0
        for i in $(gpg --list-secret-keys --keyid-format=long|awk '/uid/{if (length($3)>0) print $3 $4 $5}');
        do array_of_details+=([$k]=${i})
        ((k++))
        done
        
        len=${#array_of_keys[@]}
        ((len--))
        
        printf "\n.....These are the existing keys.....\n\n"

        for ((i=0;i<=$len;i++)) 
        do
        echo $i ${array_of_details[$i]}
        done


        printf "\n.....Select the keys using index, enter -1 to generate new key, -2 to exit.......\n"
        read ans
        
        if [ $ans == -2 ]
        then 
            exit
        fi
        
        if [ $ans == -1 ]
        then
            generate_key
        else
            if [ $ans -gt $len ]
            then
                printf "\n....Invalid Option....\n\n"
                main
            else
                git config --global user.signingkey ${array_of_keys[$ans]}
                git config --global commit.gpgsign true
                printf "\n.....Key successfully set....\n"
                main
            fi
        fi

    else 
        printf "No Key Found\nWould you like to create new key[y/n]:"
        read ans
        if [ $ans == "y" ]
        then 
            generate_key
        else
            exit
        fi
    fi
}

main