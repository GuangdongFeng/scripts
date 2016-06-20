#!/bin/bash
source etc/qd.conf
date=${1}
psql -h 10.100.5.43 -p 2345 -U mf_readonly -d dm_pv_fact -F , --no-align -c "
        SELECT p.site AS refsite, count(1) AS pv FROM (
            SELECT FIRST_VALUE(site)
            OVER (
                PARTITION BY sid
                ORDER BY hour, ms) AS site
                FROM pv_fact_hour_pcweb_${date}
        ) AS p
        WHERE site IN ${refsite}
        GROUP BY site
    " > ../../results/${date}_qd_pv.csv
