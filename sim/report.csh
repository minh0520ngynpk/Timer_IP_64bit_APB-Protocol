#!/bin/csh 

set log = "rep.log"
if (-f $log) then
    rm -rf $log
endif

touch $log

@ count = 0
@ total = 0
@ remain = 0

printf "|-----------------------------------------------------------------------------------------------|\n" >> $log
printf "|%-40s |%-30s |%-20s |\n" " PAT_NAME" " RUN_DATE" " RESULT"                                             >> $log
printf "|-----------------------------------------------------------------------------------------------|\n" >> $log
foreach pat (`cat pat.list | sed '\/\//d'`)
    echo $pat
    set sim_log = "log/${pat}.log"
    set res = "NA"
    set tm = "NA"
    
    if( !(-f $sim_log)) then
        echo "can not find $sim_log"
    else
        set tm = `grep "End time" $sim_log | awk -F"[ :,]" '{print $5 ":" $6 ":" $7 " " $9 " " $10 " " $11}'`
        if ( `grep -c "TEST PASSED" $sim_log` != 0 ) then
		set res = "PASSED"
	else if ( `grep -c "TEST FAILED" $sim_log` != 0 ) then
		set res = "FAILED"
	else
		set res = "UNKNOWN"
	endif
        #echo "DBG $tm $res"
    endif
    printf "|%-40s |%-30s |%-20s |\n" " $pat" " $tm" " $res"                                             >> $log
    printf "|-----------------------------------------------------------------------------------------------|\n" >> $log
    if( $res == "PASSED" ) then
        @ count++
    endif

    @ total++
end

set remain = `expr $total \- $count`

echo "TOTAL/PASSED/REMAIN:${total}/${count}/${remain}" >> $log
cat $log

