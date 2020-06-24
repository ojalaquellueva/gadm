select a.gid_0, a.name_0, a.name_1, b.adm0_a3, b.admin, b.name, a.hasc_1, b.code_hasc 
from gadm_admin_1 a join admin1_crosswalk b
on a.gid_0=b.adm0_a3
AND (a.name_1_ascii=b.name_ascii OR a.hasc_1=b.code_hasc)
;


select a.country_iso_alpha3, a.country, a.state_province, b.adm0_a3, b.admin, b.name, a.hasc_full, b.code_hasc 
from geonames_state_province a join admin1_crosswalk b
on a.country_iso_alpha3=b.adm0_a3
AND a.state_province_id=b.gn_id
LIMIT 12;

select * from gadm_admin_1 where admin_0_geonameid is null limit 12;

select * 
from gadm_admin_1 a JOIN gadm_country b
ON a.gid_0=
where admin_0_geonameid is null 
limit 12;