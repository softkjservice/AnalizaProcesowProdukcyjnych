bz1_tworz()
return

FUNCTION BZ1_TWORZ()
create nowa
append blank
replace field_name with "nmag"
replace field_type with "N"
replace field_len with 14
replace field_dec with 4
create bz1 from nowa
erase nowa.dbf
RETURN nil