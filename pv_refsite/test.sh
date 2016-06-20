#/bin/bash
a="('1456549200426', '1456541692671')"
psql -h 10.100.5.43 -p 2345 -U mf_readonly -d dm_pv_fact -F , --no-align -c "
SELECT site, sid FROM pv_fact_hour WHERE year=2016 AND month='02' AND day='27' AND hour='13' AND sid IN ${a}
"
