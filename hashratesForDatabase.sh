﻿#!/bin/bash
set -o functrace
clear

### heres the curl to add chit to my database:
# curl 'http://localhost:3000/employees/save' -H 'Origin: http://localhost:3000' -H 'Accept-Encoding: gzip, deflate, br' -H 'Accept-Language: en-US,en;q=0.9,es-419;q=0.8,es;q=0.7,ru;q=0.6' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' -H 'Cache-Control: max-age=0' -H 'Referer: http://localhost:3000/employees/create' -H 'Connection: keep-alive' --data 'name=ipGoesHere&type=MinerTypeHere&position=Positions1-1-1-1&hashrate=44.55' --compressed
# importatnt part of curl:
#-H 'Connection: keep-alive' --data 'name=ipGoesHere&type=MinerTypeHere&position=Positions1-1-1-1&hashrate=44.55' --compressed

### echo -n "gpurestart|1" will restart gpu 1!!	## in DEVS: Msg=6 GPU(s)
function grab_Hashrates_Genesis {
	for server in $(cat genList.txt); do
	apistats=`echo -n "summary+gpucount" | nc -w 1 $server 4028 2>/dev/null`
	HASHRATE=`echo $apistats | sed -e 's/,/\n/g' | grep "MHS av" | cut -s -d "=" -f2`
	GPUCOUNT=`echo $apistats | sed -e 's/,/\n/g' | grep "Count" | cut -d "=" -f2`
	POOLS=`echo $apiStats | sed -e 's/,/\n/g' | grep "URL" | cut -d "=" -f2`
	TYPE=`echo $apiStats | sed -e 's/,/\n/g' | grep "Description" | cut -d "=" -f2`
	BLADECOUNT=`echo $apiStats | sed -e 's/,/\n/g' | grep "miner_count=" | cut -d "=" -f2`
	mType="GPU_Miner"
	zeros="0"
	ninety="90"
	if [[ $(echo "$HASHRATE > $ninety" | bc -l) -eq 0 ]]; then
# min=$(echo 12.45 10.35 | awk '{if ($1 < $2) print $1; else print $2}')
		LOW="HASHRATE IS LOW"
	else
		LOW=""
	fi
	echo "$server is $mType at: $HASHRATE GH/s and $GPUCOUNT Gpus $LOW" >> hashratesGenesis.txt
	beginString="curl 'http://zoomhashftp.ddns.net:3000/employees/save' -H 'Origin: http://zoomhashftp.ddns.net:3000' -H 'Accept-Encoding: gzip, deflate, br' -H 'Accept-Language: en-US,en;q=0.9,es-419;q=0.8,es;q=0.7,ru;q=0.6' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' -H 'Cache-Control: max-age=0' -H 'Referer: http://zoomhashftp.ddns.net:3000/employees/create' -H 'Connection: keep-alive' --data 'name=$server&type=$mType&position=Positions1-1-1-1&hashrate=$HASHRATE' --compressed"
	eval $(echo $beginString)
	done
}
function grab_Hashrates_Mgt {
	for server in $(cat mgtList.txt); do
	apistats=`echo -n "stats" | nc -w 1 $server 4028 2>/dev/null`
	HASHRATE=`echo $apistats | sed -e 's/,/\n/g' | grep "GHS av" | cut -d "=" -f2`
	BLADECOUNT=`echo $apistats | sed -e 's/,/\n/g' | grep "miner_count=" | cut -d "=" -f2`
	POOLS=`echo $apiStats | sed -e 's/,/\n/g' | grep "URL" | cut -d "=" -f2`
	TYPE=`echo $apiStats | sed -e 's/,/\n/g' | grep "Description" | cut -d "=" -f2`
	mType="S9_Miner"
	gHASHRATE=$(bc -l <<< "$HASHRATE/1000")
	hashes=$(echo $gHASHRATE | head -c 4)
	if [[ "$BLADECOUNT" -lt "3" ]]; then
		LOW="LOW HASHRATE -- 1 OR MORE CARDS DOWN"
	else
		LOW=""
	fi
	echo "$server is $mType at: $hashes TH/s with $BLADECOUNT cards mining $LOW" >> hashratesMgt.txt
#### EVENTUALLY WE WILL MAKE THIS CONVERT GH INTO TH FOR READABILITy
	beginString="curl 'http://zoomhashftp.ddns.net:3000/employees/save' -H 'Origin: http://zoomhashftp.ddns.net:3000' -H 'Accept-Encoding: gzip, deflate, br' -H 'Accept-Language: en-US,en;q=0.9,es-419;q=0.8,es;q=0.7,ru;q=0.6' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' -H 'Cache-Control: max-age=0' -H 'Referer: http://zoomhashftp.ddns.net:3000/employees/create' -H 'Connection: keep-alive' --data 'name=$server&type=$mType&position=Positions1-1-1-1&hashrate=$HASHRATE' --compressed"
	eval $(echo $beginString)
	done
}
function line_Count {
	wc -l $1
}

rm -f mgtList.txt 2>/dev/null
touch mgtList.txt
rm -f hashratesMgt.txt 2>/dev/null
touch hashratesMgt.txt
rm -f hashratesGenesis.txt 2>/dev/null
touch hashratesGenesis.txt
rm -f notMiner.txt 2>/dev/null
touch notMiner.txt
rm -f genList.txt 2>/dev/null
touch genList.txt
rm -f defaultWorkers.txt 2>/dev/null
touch defaultWorkers.txt
rm -f errorList.txt 2>/dev/null
touch errorList.txt
#rm -f ipList.txt 2>/dev/null
touch ipList.txt
rm -f moHashratesMgt.txt 2>/dev/null
touch moHashratesMgt.txt
rm -f moHashratesGen.txt 2>/dev/null
touch moHashratesGen.txt

echo "Running Fping Scan To Gather IPs"
#fping -a -g 192.168.0.11 192.168.0.254 2>/dev/null > ipList.txt       #Uncomment this line for a 192.* network
#fping -a -g 10.2.0.0 10.2.3.255 2>/dev/null > ipList.txt           #Uncomment this line for a 10.* network 
echo "Done With Fping, Starting To Gather Worker Names"

for checks in $(cat ipList.txt);
do
	APISTATS=`echo -n "pools" | nc -w 1 $checks 4028`
	BM="bm"
	SG="sg"
	POOLS=`echo $APISTATS | sed -e 's/,/\n/g' | grep "URL" | cut -d "=" -f2`
	DESCR=`echo $APISTATS | sed -e 's/,/\n/g' | grep "Description" | cut -d "=" -f2`
	WORKER=`echo $APISTATS | sed -e 's/,/\n/g' | grep "User" | cut -d "=" -f2`
	if [[ $DESCR = $BM* ]]; then
		echo "$checks" >> mgtList.txt
#		grab_Hashrates_Mgt $checks
	elif [[ $DESCR = $SG* ]]; then
		echo "$checks" >> genList.txt
#		grab_Hashrates_Genesis $checks
	else
		echo "$checks is NOT a miner" >> notMiner.txt
	fi
done
grab_Hashrates_Mgt
grab_Hashrates_Genesis
echo ""
wc -l ipList.txt
wc -l mgtList.txt
wc -l genList.txt
wc -l notMiner.txt
echo "cat hashratesMgt.txt -OR- cat hashratesGenesis.txt "

