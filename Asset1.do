*** Highest mean difference in stunting rate (weighted) between regions, with a caveat that the region includes at least 5% (weighted) of the total observations

program define stunted
clear

local run=d
** d, the dataset file path, will be defined separately
use `run', clear

sum hw70
gen ohw=r(mean)

if ohw!=. {
quietly runstunt
}

else if ohw==. {
clear
}

end

program define runstunt

gen wt=v005/1000000
gen HAZ=hw70
replace HAZ=. if HAZ>=9996

gen stunted=.
replace stunted=0 if HAZ ~=.
replace stunted=1 if HAZ<-200
regress stunted [pweight=wt]
 

sum v008 [fweight=v005]
scalar doi_mean=r(mean)
gen doi=1900+(doi_mean-.5)/12
gen year=int(doi)
tostring year, replace
*year = survey year


*** Highest mean difference in stunting rate (weighted) between regions, with a caveat that the region includes at least 5% (weighted) of the total observations

logistic stunted i.v101 [pw=wt], asis 
* v101=region

predict p
egen x=count(1), by (p)
* x: frequecy of values in p
replace x=. if p==.
sum p
gen pc=x/r(N)
* pc: each value's frequecy percentage 
by p, sort:  gen dup = cond(_N==1,0,_n)
replace pc=0 if dup>1
replace pc=. if p==.
* Replace duplicated values by 0, only keep the value in the first observation in each subgroup
sort p
gen pc1=pc[1]
replace pc1=pc[_n]+pc1[_n-1] if _n>1
* pc1: cumulative sum of frequency percentage, added up from the lowest p (stunted rate) to the highest

gen pcbi=pc1-.05
replace pcbi=9999 if pcbi<0
* Observations with pc1<5% - observations before reaching 5% - are coded as 9999
sum pcbi
replace pcbi=0 if pcbi==r(min) | pcbi==9999
replace pcbi=. if pcbi!=0

gen pcbi1=pc1-.95
replace pcbi=1 if pcbi1>0 
rename pcbi regbi
drop p x dup pc pc1 

regress stunted if regbi==0 [pw=wt]
mat p=e(b)
svmat p, name(xx)
regress stunted if regbi==1 [pw=wt]
mat p=e(b)
svmat p, name(yy)
gen srGapreg=yy1-xx1
drop xx1 yy1
