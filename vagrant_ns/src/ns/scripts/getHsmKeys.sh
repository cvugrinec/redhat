/opt/nfast/bin/nfkminfo -l | grep -v "Keys protected by softcards:" | sed -e 's/ `/,/g' -e "s/'/$/"

