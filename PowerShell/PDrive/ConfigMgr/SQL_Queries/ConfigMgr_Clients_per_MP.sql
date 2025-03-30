select LastMPServerName, count(*)
from v_CH_ClientSummary
group by LastMPServerName
order by count(*) DESC