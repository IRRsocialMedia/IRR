* Program: 5000Test_Interracial_Intimate_Relationships
* Author: Maymay
* Original Date: Sept 27th, 2023
* Version: Stata/SE 17.0
* ============================================================================ *

clear all
set more off
capture log close

global path = "/Users/maymay/Desktop/Research_HKUST/www black people"

*** Step 1: Construct Variables
import excel using "$path/Working_data/modified.xlsx", first sheet(Sheet1) clear
* import excel using "$path/Working_data/50wData.xlsx", first sheet(50wData) clear
rename label relationship_type
label de relationship_type 0 "Black man&Chinese woman" 1 "Black woman&Chinese man" ///
2 "White man&Chinese woman" 3 "White woman&Chinese man", modify
la var relationship_type "Four interracial intimate relationship types"
label val relationship_type relationship_type

label de sentiment 0 "No Hate" 1 "Hate"
la var sentiment "Sentiments towards interracial intimate relationships"
la val sentiment sentiment

label de dimension 0 "Chinese Patriarchal Racism" 1 "Marital Exchange Theory" ///
	2 "Immigration Theory" 3 "Chinese Patriarchal Racism/Marital Exchange Theory" ///
	4 "Chinese Patriarchal Racism/Immigration Theory" ///
	5 "Marital Exchange Theory/Chinese Patriarchal Racism/Immigration Theory"
la var dimension "Interracial Intimacy Triangle"
la val dimension dimension

ta dimension 
ta relationship_type 
ta sentiment

save "$path/Logfiles/50wData_modified.dta", replace

** Merge control variables
import excel using "$path/Working_data/50wData.xlsx", first sheet(ControlVariables) clear
ta 地区
ren 地区 ip_location
merge 1:m ip_location ///
	using "$path/Logfiles/50wData_modified.dta"
keep if _merge == 3
drop _merge

encode ip_location, generate(IP_Geolocation)
label list IP_Geolocation

label define IP_Geolocation 1 "Shanghai" ///
2 "Yunnan" ///
3 "Inner Mongolia" ///
4 "Beijing" ///
5 "Jilin" ///
6 "Sichuan" ///
7 "Tianjin" ///
8 "Ningxia" ///
9 "Anhui" ///
10 "Shandong" ///
11 "Shanxi" ///
12 "Guangdong" ///
13 "Guangxi" ///
14 "Xinjiang" ///
15 "Jiangsu" ///
16 "Jiangxi" ///
17 "Hebei" ///
18 "Henan" ///
19 "Zhejiang" ///
20 "Hainan" ///
21 "Hubei" ///
22 "Hunan" ///
23 "Gansu" ///
24 "Fujian" ///
25 "Tibet" ///
26 "Guizhou" ///
27 "Liaoning" ///
28 "Chongqing" ///
29 "Shaanxi" ///
30 "Qinghai" ///
31 "Heilongjiang", modify
la val IP_Geolocation IP_Geolocation

/*12 "广东" "Guangdong" 20 "海南" "Hainan" 13 "广西" "Guangxi" /// 
22 "湖南" "Hunan" 21 "湖北" "Hubei" 18 "河南" "Henan" ///
4 "北京" "Beijing" 7 "天津" "Tianjin" 17 "河北" "Hebei" 11 "山西" "Shanxi" 3 "内蒙古" "Neimenggu" ///
28 "重庆" "Chongqing" 6 "四川" "Sichuan" 26 "贵州" "Guizhou" 2 "云南" "Yunnan" 25 "西藏" "Xizang" ///
27 "辽宁" "Liaoning" 5 "吉林" "Jilin" 31 "黑龙江" "Heilongjiang" ///
29 "陕西" "Shanxi" 23 "甘肃" "Gansu" 30 "青海" "Qinghai" 23 "宁夏" "Ningxia" 14 "新疆" "Xinjiang" ///
15 "江苏" "Jiangsu" 19 "浙江" "Zhejiang" 9 "安徽" "Anhui" 24 "福建" "Fujian" 16 "江西" "Jiangxi" ///
10 "山东" "Shandong" 1 "上海" "Shanghai", modify*/


*** Step 2: descriptive analysis
ta relationship_type sentiment, row
ta relationship_type sentiment, chi2
ta relationship_type dimension, row
summtab, by(relationship_type) ///
	cat_vars(sentiment dimension) ///
	word wordname(summary_table1_modified) ///
    title(SummaryTable1)
	
bysort relationship_type: ta IP_Geolocation sentiment, row
/*Need adjustment of this doc*/
summtab, by(IP_Geolocation) ///
	cat_vars(relationship_type sentiment) ///
	word wordname(summarytable2) ///
    title(SummaryTable2)


/*outreg2 using "/Users/maymay/Desktop/Research_HKUST/www black people/Results/descriptive analysis.doc", sum(log) title(descriptive analysis)
bysort relationship_type: outreg2 using "/Users/maymay/Desktop/Research_HKUST/www black people/Results/descriptive analysis.doc", sum(log) title(descriptive analysis)*/

/*graph box sentiment, over(IP_Geolocation) title(Distribution of Sentiments by Province)
bysort IP_Geolocation: summarize sentiment*/

*** Step 3: macro variables
destring 出生人口性别比, replace
gen GDP_per_capita = 人均GDP/100000
gen GNI_per_capita = 人均GNI/100000
gen Sex_ratio = 人口性别比/10
gen Human_Development_Index = 人类发展指数HDI
*gen population_density = 人口密度人万平方千米/1000000
gen Population_Size = log(人口数人)/10
gen Foreign_people = log(外籍人员)/10
gen Starbucks = 星巴克门店数量占比/100

global macro GDP_per_capita /*GNI_per_capita*/ Sex_ratio Human_Development_Index Population_Size Foreign_people Starbucks /*出生人口性别比*/

/*global macro Sex_ratio
reg sentiment $macro if relationship_type == 0
global macro Foreign_people
reg sentiment $macro if relationship_type == 0
global macro GDP_per_capita
reg sentiment $macro if relationship_type == 0
global macro GNP_per_capita
reg sentiment $macro if relationship_type == 0
global macro population_density
reg sentiment $macro if relationship_type == 0
global macro HDI 
reg sentiment $macro if relationship_type == 0
global macro Starbucks
reg sentiment $macro if relationship_type == 0

reg sentiment $macro if relationship_type == 0*/

*** Step 4: FE Model 1
**Guangdong as base
probit sentiment i.relationship_type ib12.IP_Geolocation

* For relationship_type == 0:
qui: probit sentiment ib12.IP_Geolocation if relationship_type == 0
eststo type0

* For relationship_type == 1:
qui: probit sentiment ib12.IP_Geolocation if relationship_type == 1
eststo type1

* For relationship_type == 2:
qui: probit sentiment ib12.IP_Geolocation if relationship_type == 2
eststo type2

* For relationship_type == 3:
qui: probit sentiment ib12.IP_Geolocation if relationship_type == 3
eststo type3

* OUtput
* esttab type0 type1 type2 type3 using "/Users/maymay/Desktop/Research_HKUST/www black people/Results_50w/FE1results.txt", label replace
esttab type0 type1 type2 type3 using "/Users/maymay/Desktop/Research_HKUST/www black people/Results_50w/FE1results_Guangdong.txt", label mtitle("Black man&Chinese woman" "Black woman&Chinese man" "White man&Chinese woman" "White woman&Chinese man") replace

**Guizhou as base
probit sentiment i.relationship_type ib26.IP_Geolocation

* For relationship_type == 0:
qui: probit sentiment ib26.IP_Geolocation if relationship_type == 0
eststo type0

* For relationship_type == 1:
qui: probit sentiment ib26.IP_Geolocation if relationship_type == 1
eststo type1

* For relationship_type == 2:
qui: probit sentiment ib26.IP_Geolocation if relationship_type == 2
eststo type2

* For relationship_type == 3:
qui: probit sentiment ib26.IP_Geolocation if relationship_type == 3
eststo type3
esttab type0 type1 type2 type3 using "/Users/maymay/Desktop/Research_HKUST/www black people/Results_50w/FE1results_Guizhou.txt", label mtitle("Black man&Chinese woman" "Black woman&Chinese man" "White man&Chinese woman" "White woman&Chinese man") replace

*** Step 5: FE Model 2

recode IP_Geolocation (3 6 7 9 10 13 16 17 20 21 22 23 24 26 27 28 30 31=1 "Hate Type one") ///
(1 5 8 11 12 15 18 19 29=2 "Hate Type two") ///
(4 2 14 25=3 "Hate Type three"), gen(Region)

label define Region 1 "Hate Type one" 2 "Hate Type two" 3 "Hate Type three", modify
la var Region "Three regions in China divided by hate levels"
label val Region Region

la list Region
bysort relationship_type: ta Region sentiment, row

** Linear Probability Model
**1
areg sentiment $macro ib3.Region if relationship_type == 0, absorb(aweme_id)
outreg2 using "/Users/maymay/Desktop/Research_HKUST/www black people/Results_50w/Linear Probability Model1.doc", replace tstat bdec(3) tdec(2) ctitle(y)

areg sentiment $macro ib3.Region if relationship_type == 1, absorb(aweme_id)
outreg2 using "/Users/maymay/Desktop/Research_HKUST/www black people/Results_50w/Linear Probability Model1.doc", append tstat bdec(3) tdec(2) ctitle(y)

areg sentiment $macro ib3.Region if relationship_type == 2, absorb(aweme_id)
outreg2 using "/Users/maymay/Desktop/Research_HKUST/www black people/Results_50w/Linear Probability Model1.doc", append tstat bdec(3) tdec(2) ctitle(y)

areg sentiment $macro ib3.Region if relationship_type == 3, absorb(aweme_id)
outreg2 using "/Users/maymay/Desktop/Research_HKUST/www black people/Results_50w/Linear Probability Model1.doc", append tstat bdec(3) tdec(2) ctitle(y)

*No macro
areg sentiment ib3.Region if relationship_type == 0, absorb(aweme_id)
outreg2 using "/Users/maymay/Desktop/Research_HKUST/www black people/Results_50w/Linear Probability Model1_Nomacro.doc", replace tstat bdec(3) tdec(2) ctitle(y)

areg sentiment ib3.Region if relationship_type == 1, absorb(aweme_id)
outreg2 using "/Users/maymay/Desktop/Research_HKUST/www black people/Results_50w/Linear Probability Model1_Nomacro.doc", append tstat bdec(3) tdec(2) ctitle(y)

areg sentiment ib3.Region if relationship_type == 2, absorb(aweme_id)
outreg2 using "/Users/maymay/Desktop/Research_HKUST/www black people/Results_50w/Linear Probability Model1_Nomacro.doc", append tstat bdec(3) tdec(2) ctitle(y)

areg sentiment ib3.Region if relationship_type == 3, absorb(aweme_id)
outreg2 using "/Users/maymay/Desktop/Research_HKUST/www black people/Results_50w/Linear Probability Model1_Nomacro.doc", append tstat bdec(3) tdec(2) ctitle(y)

** No regions **
areg sentiment $macro if relationship_type == 0, absorb(aweme_id)
outreg2 using "/Users/maymay/Desktop/Research_HKUST/www black people/Results_50w/Linear Probability Model1_NoRegion.doc", replace

areg sentiment $macro if relationship_type == 1, absorb(aweme_id)
outreg2 using "/Users/maymay/Desktop/Research_HKUST/www black people/Results_50w/Linear Probability Model1_NoRegion.doc", append

areg sentiment $macro if relationship_type == 2, absorb(aweme_id)
outreg2 using "/Users/maymay/Desktop/Research_HKUST/www black people/Results_50w/Linear Probability Model1_NoRegion.doc", append

areg sentiment $macro if relationship_type == 3, absorb(aweme_id)
outreg2 using "/Users/maymay/Desktop/Research_HKUST/www black people/Results_50w/Linear Probability Model1_NoRegion.doc", append

**2
egen aweme_id_uni = group(aweme_id)
describe aweme_id_uni
reg sentiment $macro ib3.Region i.aweme_id_uni if relationship_type == 0
outreg2 using "/Users/maymay/Desktop/Research_HKUST/www black people/Results_50w/Linear Probability Model2.doc", replace tstat bdec(3) tdec(2) ctitle(y)
reg sentiment $macro ib3.Region i.aweme_id_uni if relationship_type == 1
outreg2 using "/Users/maymay/Desktop/Research_HKUST/www black people/Results_50w/Linear Probability Model2.doc", append tstat bdec(3) tdec(2) ctitle(y)
reg sentiment $macro ib3.Region i.aweme_id_uni if relationship_type == 2
outreg2 using "/Users/maymay/Desktop/Research_HKUST/www black people/Results_50w/Linear Probability Model2.doc", append tstat bdec(3) tdec(2) ctitle(y)
reg sentiment $macro ib3.Region i.aweme_id_uni if relationship_type == 3
outreg2 using "/Users/maymay/Desktop/Research_HKUST/www black people/Results_50w/Linear Probability Model2.doc", append tstat bdec(3) tdec(2) ctitle(y)

*No macro
reg sentiment ib3.Region i.aweme_id_uni if relationship_type == 0
outreg2 using "/Users/maymay/Desktop/Research_HKUST/www black people/Results_50w/Linear Probability Model2_Nomacro.doc", replace tstat bdec(3) tdec(2) ctitle(y)
reg sentiment ib3.Region i.aweme_id_uni if relationship_type == 1
outreg2 using "/Users/maymay/Desktop/Research_HKUST/www black people/Results_50w/Linear Probability Model2_Nomacro.doc", append tstat bdec(3) tdec(2) ctitle(y)
reg sentiment ib3.Region i.aweme_id_uni if relationship_type == 2
outreg2 using "/Users/maymay/Desktop/Research_HKUST/www black people/Results_50w/Linear Probability Model2_Nomacro.doc", append tstat bdec(3) tdec(2) ctitle(y)
reg sentiment ib3.Region i.aweme_id_uni if relationship_type == 3
outreg2 using "/Users/maymay/Desktop/Research_HKUST/www black people/Results_50w/Linear Probability Model2_Nomacro.doc", append tstat bdec(3) tdec(2) ctitle(y)


**3
xtset aweme_id
*No macro
xtreg sentiment ib3.Region if relationship_type == 0
outreg2 using "/Users/maymay/Desktop/Research_HKUST/www black people/Results_50w/Linear Probability Model3_Nomacro.doc", replace tstat bdec(3) tdec(2) ctitle(y)
xtreg sentiment ib3.Region if relationship_type == 1
outreg2 using "/Users/maymay/Desktop/Research_HKUST/www black people/Results_50w/Linear Probability Model3_Nomacro.doc", append tstat bdec(3) tdec(2) ctitle(y)
xtreg sentiment ib3.Region if relationship_type == 2
outreg2 using "/Users/maymay/Desktop/Research_HKUST/www black people/Results_50w/Linear Probability Model3_Nomacro.doc", append tstat bdec(3) tdec(2) ctitle(y)
xtreg sentiment ib3.Region if relationship_type == 3
outreg2 using "/Users/maymay/Desktop/Research_HKUST/www black people/Results_50w/Linear Probability Model3_Nomacro.doc", append tstat bdec(3) tdec(2) ctitle(y)

xtreg sentiment $macro ib3.Region if relationship_type == 0
outreg2 using "/Users/maymay/Desktop/Research_HKUST/www black people/Results_50w/Linear Probability Model3.doc", replace tstat bdec(3) tdec(2) ctitle(y)

xtreg sentiment $macro ib3.Region if relationship_type == 1
outreg2 using "/Users/maymay/Desktop/Research_HKUST/www black people/Results_50w/Linear Probability Model3.doc", append tstat bdec(3) tdec(2) ctitle(y)

xtreg sentiment $macro ib3.Region if relationship_type == 2
outreg2 using "/Users/maymay/Desktop/Research_HKUST/www black people/Results_50w/Linear Probability Model3.doc", append tstat bdec(3) tdec(2) ctitle(y)

xtreg sentiment $macro ib3.Region if relationship_type == 3
outreg2 using "/Users/maymay/Desktop/Research_HKUST/www black people/Results_50w/Linear Probability Model3.doc", append tstat bdec(3) tdec(2) ctitle(y)

**IP_geo changed to Region in regression analysis with macro variables
recode IP_Geolocation (4 7 17 11 3=1 "North China") (27 5 31=2 "Northeast China") ///
(1 15 19 9 24 16 10=3 "East China") ///
(12 13 20 22 21 18=4 "Central South China") ///
(2 26 6 28 25=5 "Southwest China") (29 23 30 8 14=6 "Northwest China"), gen(Region)

label define Region 1 "North China" 2 "Northeast China" 3 "East China" ///
4 "Central South China" 5 "Southwest China" 6 "Northwest China", modify
la var Region "Six regions in China"
label val Region Region

la list Region
bysort relationship_type: ta Region sentiment, row

*** Main model
probit sentiment ib12.IP_Geolocation if relationship_type == 0

**FE for the four relationship_type**
probit sentiment $macro if relationship_type == 0
probit sentiment $macro if relationship_type == 1
probit sentiment $macro if relationship_type == 2
probit sentiment $macro if relationship_type == 3

**Linear Probability Model**
reg sentiment $macro if relationship_type == 0
reg sentiment IP_Geolocation
est sto m0

probit sentiment $macro if relationship_type == 0
*outreg2 using myresults.doc, replace
est sto m1

probit sentiment $macro if relationship_type == 1
est sto m2

probit sentiment $macro if relationship_type == 2
est sto m3

probit sentiment $macro if relationship_type == 3
est sto m4

esttab m0 m1 m2 m3 m4 using "/Users/maymay/Desktop/Research_HKUST/www black people/Results_50w/FE2probit_region.csv", replace ///
star(* 0.1 ** 0.05 *** 0.01)


*** Divide Region
probit sentiment ib3.Region if relationship_type == 0

**FE for the four relationship_type
probit sentiment $macro if relationship_type == 0
probit sentiment $macro if relationship_type == 1
probit sentiment $macro if relationship_type == 2
probit sentiment $macro if relationship_type == 3

///
probit sentiment ib3.Region if relationship_type == 0
estimates store RegionModel

probit sentiment $macro if relationship_type == 0
estimates store type0

probit sentiment $macro if relationship_type == 1
estimates store type1

probit sentiment $macro if relationship_type == 2
estimates store type2

probit sentiment $macro if relationship_type == 3
estimates store type3

**Output
esttab RegionModel type0 type1 type2 type3 using "/Users/maymay/Desktop/Research_HKUST/www black people/Results_50w/FE2probit_region.txt", replace star(* 0.05 ** 0.01 *** 0.001)
///







