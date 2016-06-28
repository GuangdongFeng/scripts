#!/bin/sh
#用来计算渠道总 pv/dau 及非渠道 pv/dau 及其占比
source etc/date.conf

function pv_uv()
{
        psql -h 54.222.196.128 -p 2345 -U readonly -d dm_pv_fact -F , --no-align -c "
              SELECT year, month, day, COUNT(DISTINCT(did))
              FROM pv_fact
              WHERE bid = 2
              AND LENGTH(ch)!=0
              AND day >='${day}'
              AND month='${month}'
              AND year='${year}'
              GROUP BY year, month, day
              ORDER BY day;
            " > ../../results/dau_qd.csv

        psql -h 54.222.196.128 -p 2345 -U readonly -d dm_pv_fact -F , --no-align -c "
                  SELECT year, month, day, COUNT(DISTINCT(did))
                  FROM pv_fact
                  WHERE bid = 2
                  AND LENGTH(ch)=0
                  AND day >='${day}'
                  AND month='${month}'
                  AND year='${year}'
                  GROUP BY year, month, day
                  ORDER BY day;
                " > ../../results/dau_noqd.csv

        psql -h 54.222.196.128 -p 2345 -U readonly -d dm_pv_fact -F , --no-align -c "
                  SELECT year, month, day, COUNT(1)
                  FROM pv_fact
                  WHERE bid = 2
                  AND LENGTH(ch)!=0
                  AND day >='${day}'
                  AND month='${month}'
                  AND year='${year}'
                  GROUP BY year, month, day
                  ORDER BY day;
                " > ../../results/pv_qd.csv

        psql -h 54.222.196.128 -p 2345 -U readonly -d dm_pv_fact -F , --no-align -c "
                  SELECT year, month, day, COUNT(1)
                  FROM pv_fact
                  WHERE bid = 2
                  AND LENGTH(ch)=0
                  AND day >='${day}'
                  AND month='${month}'
                  AND year='${year}'
                  GROUP BY year, month, day
                  ORDER BY day;
                " > ../../results/pv_noqd.csv

}

pv_uv
