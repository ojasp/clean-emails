#!/bin/bash

if [ "$#" == "0" ]; then
    echo "Please specify dropped email csv!"
    exit 1
fi

cut -d "," -f1,2,4 ./$@ | fgrep -i -f unknown.csv > invalidemails.txt | tee >(wc -l)
cut -d "," -f1,2,4 ./$@ | fgrep -i -f spam.txt > spamemails.txt | tee >(wc -l)
cut -d "," -f1,2,4 ./$@ | fgrep -iv -f unknown.csv | fgrep -iv -f spam.txt | tee >(wc -l) > questionable.csv
cut -d "," -f2 questionable.csv | tr -d '"' | sort | uniq | tee >(wc -l) > questionable-cleaned.csv

#cp invalidemails.txt invalidemails.txt.bak

echo "[**] Firing the second script: sweepdomains.sh"

#IFS=","

cut -d "@" -f2 ./questionable-cleaned.csv | sort | uniq > ./domainstocheck.txt

while read f1
do
 #./email-verify.sh $f1
 ./webpage-exists.sh $f1 &
done < ./domainstocheck.txt

echo " Waiting for background tasks to finish..."
time wait < <(jobs -p)

echo " Background tasks finished, moving on"

cat ./questionable-cleaned.csv | fgrep -if ./baddomains.txt > ./questionable-bademails.txt
cat ./questionable-cleaned.csv | awk NF | fgrep -ivf ./baddomains.txt > ./EmailstoCheck2.txt
rm ./domainstocheck.txt
#rm /root/Desktop/baddomains.txt

echo "[**] Firing the third script: final-cleanup.sh"

cat invalidemails.txt | cut -d "," -f2 | tr -d '"' > invalidemails-cleaned.txt
cat invalidemails-cleaned.txt questionable-bademails.txt | sort | uniq >./results/BadEmails.txt
cat spamemails.txt | cut -d "," -f1 | tr -d '"' | sort | uniq | tee >(wc -l) > ./results/Spamemails.txt
mv EmailstoCheck2.txt ./results/
cat ./$@ | fgrep -if ./results/EmailstoCheck2.txt > ./results/EmailstoCheckwErrors.csv

echo "Here is the count: "; wc -l ./results/BadEmails.txt; wc -l ./results/Spamemails.txt; wc -l ./results/EmailstoCheck2.txt;

rm ./invalidemails-cleaned.txt
rm ./invalidemails.txt
rm ./spamemails.txt
rm ./questionable.csv
rm ./questionable-cleaned.csv
rm ./questionable-bademails.txt

echo "The results are saved in these files: ./results/BadEmails.txt, ./results/Spamemails.txt, and ./results/EmailstoCheck2.txt"
