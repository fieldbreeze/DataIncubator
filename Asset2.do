**mean difference in stunting rate (weighted) between the top 10% and bottom 40% wealth groups

program define stuntinggap1040

sum v191
* v191 = wealth index
gen o1040=r(mean)

_pctile v191, nq(10)
local a=r(r4)
local b=r(r9)
gen w1040=cond(v191<=`a', 0, cond(v191>`b', 1,.))
* For variable "w1040", 0 = the lowest 40% by wealth, 1 = highest 10% 

sum w1040 
replace o1040=. if r(sd)==0

if o1040[1]!=. {

regress stunted if w1040==0 [pw=wt]
mat p=e(b)
svmat p, name(xx)
regress stunted if w1040==1 [pw=wt]
mat p=e(b)
svmat p, name(yy)
gen srGap1040=xx1-yy1
drop xx1 yy1
}

end
