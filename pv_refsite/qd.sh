#!/bin/bash
#Auther:guangdong
#fenqtsingyang@gmail.com

#接收第一个参数: 渠道名称
ch=${1}
#source etc/qd.conf

#导入日期配置
source etc/date.conf

#将渠道名称中的"/"替换为"_"
chfile_name=$(echo ${ch} | sed 's/\//_/g')

#根据渠道名称获取到渠道 id
chid=$(mysql --defaults-file=/Users/guangdong/.dispy.my.cnf -D dispy -e "
        SELECT id FROM dispy_mpp_vender
            WHERE vender_name = '${ch}';
" | grep -v 'id')

#根据渠道名称获取渠道标识
chchar=$(mysql --defaults-file=/Users/guangdong/.dispy.my.cnf -D dispy -e "
        SELECT vender_source FROM dispy_mpp_vender
            WHERE vender_name = '${ch}';
" | grep -v 'vender_source')
#echo ${chfile_name}
#echo ${chid}

#去亚马逊 GP的dm_pv_fact中计算出渠道各个 ref 每天的 pv, 并返回 pv >= 2000 的记录数
function qd_ref_pv()
{
        psql -h 54.222.196.128 -p 2345 -U readonly -d dm_pv_fact -F , --no-align -c "
                SELECT year, month, day, ref, COUNT(1)
                    FROM pv_fact
                    WHERE bid=2
                    AND day >='${day}'
                    AND month='${month}'
                    AND year='${year}'
                    AND ch='${chid}'
                    GROUP BY year, month, day, ref
                    HAVING COUNT(1) >= 2000
                    ORDER BY day, count DESC
            " > ../../results/${chfile_name}_meta_ref_pv.csv

        #将计算出的渠道 ref 每天的 pv 提取出 pv>1000 的记录, 并整理成可用 excel 作数据透视图的数据格式
        cat ../../results/${chfile_name}_meta_ref_pv.csv | awk -F',' '{if ($5 >= 1000) print $1$2$3","$4","$5}' > ../../results/${chfile_name}_ref_pv.csv
}

#去云谷 GP 的 dm_result 中查询出该渠道落地页 PV 数大于 1000 的数据, 并限制查询条数为 50
function qd_url_pv()
{
        psql -h 10.100.5.43 -p 2345 -U mf_readonly -d dm_result -F , --no-align -c "
                SELECT date, url, pv, refpv
                    FROM url_pv_day
                    WHERE bid=2
                    AND date >= ${year}${month}${day}
                    AND url LIKE '%${chchar}%'
                    AND pv>=1000
                    ORDER BY pv DESC, date
        " > ../../results/${chfile_name}_url_pv.csv
}
#计算人均 PV
function qd_average_pv()
{
        psql -h 10.100.5.43 -p 2345 -U mf_readonly -d dm_result -F , --no-align -c "
                SELECT date, pv, uv, ROUND((pv::numeric)/(uv::numeric),2) AS average_pv
                    FROM dau_ch_day
                    WHERE bid=2
                    AND date >= ${year}${month}${day}
                    AND ch='${chid}'
                    ORDER BY date
        " > ../../results/${chfile_name}_average_pv.csv
}

function execute_all()
{
      #qd_url_pv
      #qd_average_pv
      #qd_ref_pv
      #cat ../../results/${chfile_name}_meta_ref_pv.csv | awk -F',' '{if ($5 >= 1000) print $1$2$3","$4","$5}' > ../../results/${chfile_name}_ref_pv.csv
}

execute_all
