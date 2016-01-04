
/*****************************************************************************************************
Flow of Funds

list of pdf:
http://www.federalreserve.gov/releases/z1/current/

list of tables (Best thing to start looking):
http://www.federalreserve.gov/apps/fof/FOFTables.aspx
Name of table is same as in pdf, but, contrary to pdf, the code is written

SOmetimes FL exists as a variable but transformed to LM fopr the tables (for instnace FL153064105Q is corp equities but is LM153064105.Q in the table / downloaded data)


explanation of series structure
http://www.federalreserve.gov/apps/fof/SeriesStructure.aspx

a : Flows--seasonally adjusted annual rates
u : Flows--unadjusted quarterly rates
l: Outstandings--unadjusted
b:  Balance sheet
g: Debt growth--adjusted annual rates
s: Supplementary
i : Integrated macroeconomic accounts



a b g l s u. They don't corredspond to the variable code after f


credit is face value, not market value.



owner occupied real estate
FL155035015

credit market instrument
FL154004005.Q

equity
FL153064105.Q * corp equities
FL153064205.Q * mutual fund shares
FL153067005.Q * security credit
FL152090205.Q * equity in noncorporate business



rename FL155035015Q fa_realestate
rename FL154004005Q fa_fixedincome
gen fa_equity = FL153064105Q + FL153064205Q + FL153067005Q + FL152090205Q


everythin in billion


total corporate equities :  total liabilities of corporate, financial business, foreign corporate firms
total mutual fund shares


cay uses log net worth : FL152090005


Instrument tables are stuff by sector. Decomposed into F (for flow) and L (for asset)


list of vintage (format YYYYMMDD)
20150918
20150611
20150312
20141211
20140918
20140605
20140306
20131209
20130925
20130606
20130307
20121206
20120920
20120607
20120308
20111208
20110916
20110609
20110310
20101209
20100917
20100610
20100311
20091210
20090917
20090611
20090312
20081211
20080918
20080605
20080306
20071206
20070917
20070607
20070308
20061207
20060919
20060608
20060309
20051208
20050921
20050609
20050310
20041209
20040916
20040610
20040304
20040115
20030909
20030605
20030306
20021205
20020916
20020606
20020307
20011207
20010918
20010608
20010309
20001208
20000915
20000609
20000310
19991215
19990915
19990611
/* then not working after that */
19990312
19981211
19980911
19980611
19980313
19971211
19970915
19970612
19970314
19961211
19960912

*****************************************************************************************************/


program define fof
	syntax [anything], [clear]


	if "`anything'" == ""{
		local vintage Current
	}
	else{
		local vintage `anything'
	}
	tempfile dirdownload
	cap rmdir "`dirdownload'"
	mkdir "`dirdownload'"
	tempfile dirunzip
	cap rmdir "`dirunzip'"
	mkdir "`dirunzip'"
	foreach x in a b g l s u {
		! wget -q  "http://www.federalreserve.gov/releases/z1/`vintage'/Disk/`x'tabs.zip" -O "`dirdownload'/`x'tabs.zip" && cd "`dirunzip'" && unzip  -jo "`dirdownload'/`x'tabs.zip"
	}

	/* write label as macros */
	_loadcode, `clear'
	forvalues i=1/`=_N' {
		local `=subcode[`i']' = description[`i']
	}

	tempfile data
	local files : dir "`dirunzip'" files `"*.prn"'
	local i = 0
	foreach file of local files {
		di "`file'"
		if inlist("`file'","ltab231d", "ltab231d.prn") | regexm(`"`file'"',`"mtrx"') {
			continue
		}
		local date_reformatted ""
		qui insheet using "`dirunzip'/`file'", delimiter(" ") clear double names case
		capture drop v* 
		*drops variables that appear in multiple tables
		rename DATES dates
		cap replace dates = subinstr(dates, "Q", "0", .)
		cap replace dates = subinstr(dates, "DATES", "", .)
		qui destring dates, replace

		/* vintage before 2006 have multiple variables in the same column. Int his case, divide the file in multiple parts */
		tempvar t
		qui gen `t' = missing(dates)
		qui replace `t' = sum(`t')
		tempfile temp
		qui save `temp'
		qui sum `t'
		foreach sample of numlist 0/`=r(max)' {
			local i = `i'+1
			use `temp' if `t' == `sample' , clear
			drop `t'
			if `sample' >= 1 {
				qui ds dates, not
				foreach v in `=r(varlist)'{
					local newv = subinstr("`=`v'[1]'", ".", "", .)
					cap confirm new variable `newv'
					if _rc{
						drop `v'
					}
					else{
						rename `v' `newv'
					}
				}
			}
			qui drop if missing(dates)
			qui ds dates, not
			foreach var in `=r(varlist)' {
				cap qui destring `var', replace ignore("NA")
				label variable `var' `=regexr(`"`file'"',`"\.prn$"',`""')'
				local filetype: variable label `var'
				local filetype: piece 1 2 of "`file'"
				qui replace `var' = `var' * 10^(-3) 
				*Converts variables into billions.
				if regexm(`"`var'"',`"A$"') & `"`date_reformatted'"'==`""' { 
					*Annual variables
					qui replace dates = dates * 100 + 4
					local date_reformatted yes
				}
			}
			sort dates
			if `i'>1{
				qui merge 1:1 dates using `data', nogenerate sorted
			}
			sort dates
			qui save `data', replace
		}
	}





	use `data', clear
	foreach var of varlist F* {
		local tab: variable label `var'
		local sector = substr(`"`var'"',3,2)
		local description = substr(`"`var'"',5,5)
		qui label variable `var' "`tab': ``description'', ``sector''"
	}
	format F* %16.0fc
	gen dateq = yq(floor(dates/100),  mod(dates, 100))
	tsset dateq, quarterly
	format dateq %tq
	order dateq
	drop dates



	local files : dir "`dirunzip'" files `"*"'
	foreach file in `files'{
		erase "`dirunzip'/`file'"
	}
	rmdir "`dirunzip'"

	local files : dir "`dirdownload'" files `"*"'
	foreach file in `files'{
		erase "`dirdownload'/`file'"
	}
	rmdir "`dirdownload'"
end



program define _loadcode 
	syntax [anything] , [clear]
	tempname postname
	tempfile postfile
	postfile `postname'  subcode str100 description using `postfile'
	post `postname'	(07)	("Price indexes")
	post `postname'	(08)	("Gross domestic product (GDP)/national income")
	post `postname'	(09)	("Corporate business")
	post `postname'	(10)	("Nonfinancial corporate business")
	post `postname'	(11)	("Nonfinancial noncorporate business")
	post `postname'	(13)	("Farm business")
	post `postname'	(14)	("Nonfinancial business (S11)")
	post `postname'	(15)	("Households and nonprofit organizations (S14_S15)")
	post `postname'	(16)	("Nonprofit organizations")
	post `postname'	(17)	("Personal sector")
	post `postname'	(18)	("Corporate farm business")
	post `postname'	(20)	("State and local governments")
	post `postname'	(21)	("State and local governments ex. employee retirement funds (S1312_S1313)")
	post `postname'	(22)	("State and local government employee retirement funds")
	post `postname'	(23)	("Noncorporate farm business")
	post `postname'	(26)	("Rest of the world (S2)")
	post `postname'	(27)	("International banking facilities")
	post `postname'	(31)	("Federal government (S1311)")
	post `postname'	(34)	("Federal government retirement funds")
	post `postname'	(36)	("Consolidated governments (S13)")
	post `postname'	(38)	("Domestic nonfinancial sectors")
	post `postname'	(39)	("Nonfinancial sectors")
	post `postname'	(40)	("Government-sponsored enterprises (GSEs)")
	post `postname'	(41)	("Agency- and GSE-backed mortgage pools")
	post `postname'	(42)	("GSEs and agency- and GSE-backed mortgage pools")
	post `postname'	(44)	("Savings institutions")
	post `postname'	(47)	("Credit unions")
	post `postname'	(50)	("Funding corporations")
	post `postname'	(51)	("Other insurance companies")
	post `postname'	(52)	("Insurance companies (S128)")
	post `postname'	(53)	("Closed-end and exchange-traded funds")
	post `postname'	(54)	("Life insurance companies")
	post `postname'	(55)	("Closed-end funds")
	post `postname'	(56)	("Exchange-traded funds")
	post `postname'	(57)	("Private pension funds")
	post `postname'	(58)	("Insurance companies and pension funds (S128+S129)")
	post `postname'	(59)	("Pension funds (S129)")
	post `postname'	(60)	("Other financial intermediaries except insurance companies (S125)")
	post `postname'	(61)	("Finance companies")
	post `postname'	(62)	("Mortgage companies")
	post `postname'	(63)	("Money market mutual funds (S123)")
	post `postname'	(64)	("Real estate investment trusts")
	post `postname'	(65)	("Mutual funds")
	post `postname'	(66)	("Security brokers and dealers (S126)")
	post `postname'	(67)	("Asset-backed security issuers")
	post `postname'	(68)	("Private financial institutions not elsewhere classified")
	post `postname'	(69)	("Non-MMF investment funds (S124)")
	post `postname'	(70)	("Private depository institutions (S122)")
	post `postname'	(71)	("Monetary authority (S121)")
	post `postname'	(72)	("U.S.-chartered commercial banks")
	post `postname'	(73)	("Holding companies")
	post `postname'	(74)	("Banks in U.S.-affiliated areas")
	post `postname'	(75)	("Foreign banking offices in U.S.")
	post `postname'	(76)	("U.S.-chartered depository institutions")
	post `postname'	(77)	("Captive financial institutions and money lenders (S127)")
	post `postname'	(78)	("Private depository institutions and money market mutual funds")
	post `postname'	(79)	("Financial business (S12)")
	post `postname'	(80)	("Other financial corporations (S124+S125+S126+S127)")
	post `postname'	(81)	("Other financial intermediaries")
	post `postname'	(82)	("Domestic business")
	post `postname'	(83)	("Private domestic sectors")
	post `postname'	(84)	("Monetary authority, private depository institutions, and money market mutual funds")
	post `postname'	(88)	("All domestic sectors (S1)")
	post `postname'	(89)	("All sectors")
	post `postname'	(90)	("Instrument discrepancies")
	post `postname'	(00000)	("Unemployment rate (quarterly average)")
	post `postname'	(20000)	("Total assets")
	post `postname'	(20001)	("Total assets at historical cost")
	post `postname'	(20100)	("Nonfinancial assets")
	post `postname'	(20101)	("Nonfinancial assets at historical cost")
	post `postname'	(20107)	("Revaluation of nonfinancial assets adjusted to exclude disaster-related losses (IMA)")
	post `postname'	(20500)	("Federal funds and security repurchase agreements; asset")
	post `postname'	(20900)	("Net worth")
	post `postname'	(20901)	("Net worth at historical cost")
	post `postname'	(20902)	("Proprietors' equity in noncorporate business")
	post `postname'	(21000)	("Total liabilities and net worth (IMA)")
	post `postname'	(21500)	("Federal funds and security repurchase agreements; liability")
	post `postname'	(21507)	("Federal funds and security repurchase agreements due to U.S.-chartered commercial banks; liability")
	post `postname'	(30110)	("U.S. official reserve assets")
	post `postname'	(30111)	("Monetary gold and SDRs holdings; asset")
	post `postname'	(30112)	("Monetary gold; asset")
	post `postname'	(30113)	("Special drawing rights (SDRs) holdings; asset")
	post `postname'	(30114)	("Reserve position in IMF (net); asset")
	post `postname'	(30115)	("Official foreign currency holdings; asset")
	post `postname'	(30117)	("International reserves; asset")
	post `postname'	(30120)	("Treasury currency; asset")
	post `postname'	(30130)	("Depository institution reserves; asset")
	post `postname'	(30140)	("SDR certificates issued by the federal government; asset")
	post `postname'	(30200)	("Checkable deposits and currency; asset")
	post `postname'	(30202)	("Currency including checkable deposits; asset")
	post `postname'	(30207)	("Checkable deposits due from depository institutions in the U.S.; asset")
	post `postname'	(30220)	("Cash items in process of collection; asset")
	post `postname'	(30230)	("Checkable deposits due to the federal goverment; asset")
	post `postname'	(30240)	("Treasury operating cash; asset")
	post `postname'	(30250)	("Currency; asset")
	post `postname'	(30260)	("Cash and monetary assets other than Treasury operating cash; asset")
	post `postname'	(30270)	("Checkable deposits; asset")
	post `postname'	(30280)	("Checkable deposits due to state and local governments; asset")
	post `postname'	(30292)	("Checkable deposits due to private domestic sectors; asset")
	post `postname'	(30300)	("Total time and savings deposits; asset")
	post `postname'	(30302)	("Other deposits including time and savings deposits; asset (IMA)")
	post `postname'	(30340)	("Money market mutual fund shares; asset")
	post `postname'	(30400)	("Life insurance reserves; asset")
	post `postname'	(30500)	("Pension entitlements; asset")
	post `postname'	(30520)	("Insurance, pension and standardized guarantee schemes; asset (F6)")
	post `postname'	(30522)	("Life insurance and annuity entitlements; asset (F62)")
	post `postname'	(30523)	("Pension entitlements; asset (F63)")
	post `postname'	(30525)	("Entitlements to non-pension benefits; asset")
	post `postname'	(30610)	("Total U.S. government securities; asset")
	post `postname'	(30611)	("Treasury securities; asset")
	post `postname'	(30612)	("NCUA share insurance capitalization deposit; asset")
	post `postname'	(30613)	("Agency-issued commercial mortgage pass-through securities; asset")
	post `postname'	(30614)	("Agency issued commercial CMOs and other structured MBS; asset")
	post `postname'	(30615)	("Treasury securities, including U.S. savings bonds; asset")
	post `postname'	(30616)	("Agency issued residential CMOs and other structured MBS; asset")
	post `postname'	(30617)	("Agency- and GSE-backed securities; asset")
	post `postname'	(30618)	("Agency-issued residential mortgage pass-through securities; asset")
	post `postname'	(30619)	("Agency mortgage-backed securities and other asset-backed agency- and GSE-backed securities; asset")
	post `postname'	(30620)	("Municipal securities and loans; asset")
	post `postname'	(30621)	("Sallie Mae academic facilities financing to public institutions; asset")
	post `postname'	(30622)	("Sallie Mae warehousing advances to public institutions; asset")
	post `postname'	(30630)	("Corporate and foreign bonds; asset")
	post `postname'	(30631)	("Corporate bonds issued by Netherlands Antillean Financial subsidiaries of U.S. corporations; asset")
	post `postname'	(30632)	("Foreign corporate bonds; asset")
	post `postname'	(30636)	("Mortgage-backed securities and other asset-backed bonds; asset")
	post `postname'	(30637)	("Corporate bonds issued by commercial banking under TARP; asset")
	post `postname'	(30638)	("Domestic corporate bonds; asset")
	post `postname'	(30640)	("Corporate equities and mutual fund shares; asset")
	post `postname'	(30641)	("Corporate equities; asset")
	post `postname'	(30642)	("Mutual fund shares; asset")
	post `postname'	(30644)	("Directly and indirectly held corporate equities; asset")
	post `postname'	(30645)	("Corporate equities issued by funding corporations (AIG) under the federal financial stabilization programs; asset")
	post `postname'	(30646)	("Corporate equities issued by bank-holding companies (GMAC) under the federal financial stabilization programs; asset")
	post `postname'	(30647)	("Corporate equities issued by commercial banking under the federal financial stabilization programs; asset")
	post `postname'	(30648)	("Corporate equities issued by GSEs under the federal financial stabilization programs; asset")
	post `postname'	(30649)	("Capital losses calculated by the Treasury Department; asset")
	post `postname'	(30650)	("Total mortgages; asset (F42)")
	post `postname'	(30651)	("Home mortgages, including home equity loans and construction loans on one-to-four family homes; asset")
	post `postname'	(30652)	("Home equity lines of credit; asset")
	post `postname'	(30653)	("Home mortgages secured by junior liens; asset")
	post `postname'	(30654)	("Multifamily residential mortgages; asset")
	post `postname'	(30655)	("Commercial mortgages; asset")
	post `postname'	(30656)	("Farm mortgages; asset")
	post `postname'	(30657)	("Private residential mortgage-backed securities; asset")
	post `postname'	(30659)	("Private commercial mortgage-backed securities; asset")
	post `postname'	(30660)	("Consumer credit; asset")
	post `postname'	(30661)	("Revolving consumer credit; asset")
	post `postname'	(30662)	("Non-revolving consumer credit; asset")
	post `postname'	(30663)	("Consumer leases; asset")
	post `postname'	(30664)	("Consumer credit, auto loans; asset")
	post `postname'	(30665)	("Revolving consumer credit, other than credit cards; asset")
	post `postname'	(30666)	("Consumer loans adjustment for Banc One reclassification")
	post `postname'	(30667)	("Loans to individuals; asset")
	post `postname'	(30670)	("Security credit; asset")
	post `postname'	(30680)	("Bank loans not elsewhere classified; asset")
	post `postname'	(30681)	("Commercial and industrial loans and leases; asset")
	post `postname'	(30682)	("Other bank loans; asset")
	post `postname'	(30683)	("Bank loans not elsewhere classified to households (TALF); asset")
	post `postname'	(30684)	("Bank loans not elsewhere classified to rest of the world; asset")
	post `postname'	(30685)	("Bank loans not elsewhere classified to funding corporations; asset")
	post `postname'	(30686)	("Bank loans not elsewhere classified to brokers and dealers; asset")
	post `postname'	(30687)	("Loans to domestic banks; asset")
	post `postname'	(30688)	("Loans under the AMLF; asset")
	post `postname'	(30690)	("Other loans and advances; asset")
	post `postname'	(30691)	("Open market paper; asset")
	post `postname'	(30692)	("U.S. government loans; asset")
	post `postname'	(30693)	("Government-sponsored enterprise (GSE) loans; asset")
	post `postname'	(30694)	("Policy loans; asset")
	post `postname'	(30695)	("Nonfinancial business loans, excluding U.S. government and GSE loans; asset")
	post `postname'	(30696)	("Bankers' acceptances; asset")
	post `postname'	(30697)	("Customers' liability on acceptances outstanding; asset")
	post `postname'	(30698)	("Syndicated loans to nonfinancial corporate business; asset")
	post `postname'	(30699)	("Open market paper and other loans and advances; asset")
	post `postname'	(30700)	("Trade receivables; asset")
	post `postname'	(30703)	("Trade credit due from the federal government; asset")
	post `postname'	(30706)	("Receivables due from other brokers and dealers and clearing organizations; asset")
	post `postname'	(30730)	("Claims of pension fund on sponsor; asset")
	post `postname'	(30740)	("Pension fund contributions receivable; asset")
	post `postname'	(30750)	("Trade receivables net of trade payables; asset")
	post `postname'	(30760)	("Insurance receivables due from property-casualty insurance companies; asset (F61)")
	post `postname'	(30770)	("Deferred and unpaid life insurance premiums; asset")
	post `postname'	(30780)	("Taxes receivable; asset")
	post `postname'	(30810)	("Equity and investment fund shares; asset (F5)")
	post `postname'	(30811)	("Equity and investment fund shares excluding mutual fund shares and money market fund shares; asset (F51)")
	post `postname'	(30812)	("Mutual fund and money market fund shares; asset (F52)")
	post `postname'	(30900)	("Total miscellaneous assets")
	post `postname'	(30910)	("Private foreign deposits; asset")
	post `postname'	(30911)	("Nonofficial foreign currencies; asset")
	post `postname'	(30917)	("Interbank transactions due from domestic affiliates; asset")
	post `postname'	(30920)	("Direct investment; asset")
	post `postname'	(30921)	("Foreign direct investment in U.S.: Equity; asset")
	post `postname'	(30922)	("Foreign direct investment in U.S.: Reinvested earnings; asset")
	post `postname'	(30923)	("Foreign direct investment in U.S.: Intercompany accounts; asset")
	post `postname'	(30924)	("Equity in government-sponsored enterprises (GSEs); asset")
	post `postname'	(30926)	("Interbank transactions due from foreign affiliates; asset")
	post `postname'	(30928)	("U.S. equity in IRBD, etc.")
	post `postname'	(30930)	("Unidentified miscellaneous assets")
	post `postname'	(30940)	("Equity investment in subsidiaries; asset")
	post `postname'	(30941)	("Equity investment in own subsidiaries by nonfinancial corporations; asset")
	post `postname'	(30943)	("Equity investment through the Public-Private Investment Program (PPIP); asset")
	post `postname'	(30945)	("Equity investment in own subsidiaries by funding corporations; asset")
	post `postname'	(30947)	("Holding companies net transactions with subsidiaries; asset")
	post `postname'	(30954)	("Unallocated insurance contracts; asset")
	post `postname'	(30960)	("Other accounts receivable; asset (F8)")
	post `postname'	(30961)	("Miscellaneous and taxes receivable; asset (IMA)")
	post `postname'	(30962)	("Trade credits and advances; asset (IMA)")
	post `postname'	(30970)	("Securities borrowed (net); asset")
	post `postname'	(30980)	("Financial derivatives; asset")
	post `postname'	(30990)	("Other financial assets")
	post `postname'	(30994)	("Other financial assets, excluding indirectly held equity")
	post `postname'	(31110)	("U.S. official reserve assets; liability")
	post `postname'	(31113)	("SDR allocations; liability")
	post `postname'	(31114)	("Reserve position in IMF (net); liability")
	post `postname'	(31115)	("Official foreign currency holdings; liability")
	post `postname'	(31117)	("International reserves; liability")
	post `postname'	(31120)	("Treasury currency; liability")
	post `postname'	(31130)	("Depository institution reserves; liability")
	post `postname'	(31200)	("Checkable deposits and currency; liability")
	post `postname'	(31202)	("Currency including checkable deposits; liability (IMA)")
	post `postname'	(31207)	("Checkable deposits due to depository institutions in the U.S.; liability")
	post `postname'	(31226)	("Checkable deposits due to rest of world; liability")
	post `postname'	(31230)	("Checkable deposits due to the federal government; liability")
	post `postname'	(31240)	("Checkable deposits due to government-sponsored enterprises; liability")
	post `postname'	(31250)	("Currency; liability")
	post `postname'	(31260)	("Total transaction accounts; liability")
	post `postname'	(31270)	("Checkable deposits; liability")
	post `postname'	(31280)	("Checkable deposits due to state and local governments; liability")
	post `postname'	(31292)	("Checkable deposits due to private domestic sectors; liability")
	post `postname'	(31297)	("Checkable deposits and currency due to private domestic sectors; liability")
	post `postname'	(31299)	("Special cash items bias correction for deposits; liability")
	post `postname'	(31300)	("Total time and savings deposits; liability")
	post `postname'	(31301)	("Total nontransaction deposits; liability")
	post `postname'	(31302)	("Other deposits including time and savings deposits; liabilty (IMA)")
	post `postname'	(31307)	("Time and savings deposits due to depository institutions in the U.S.; liability")
	post `postname'	(31310)	("Small time and savings deposits; liability")
	post `postname'	(31315)	("IRA and Keoghs; liability")
	post `postname'	(31350)	("Large time deposits; liability")
	post `postname'	(31352)	("Large time deposits due to rest of the world; liability")
	post `postname'	(31357)	("Large time deposits due to commercial banking; liability")
	post `postname'	(31390)	("Total deposits; liabilities")
	post `postname'	(31397)	("Retail repurchase agreements; liability")
	post `postname'	(31400)	("Life insurance reserves; liability")
	post `postname'	(31500)	("Pension entitlements; liability")
	post `postname'	(31520)	("Insurance, pension and standardized guarantee schemes; liability (F6)")
	post `postname'	(31523)	("Pension entitlements; liability (F63)")
	post `postname'	(31540)	("Life insurance reserves and pension entitlements; liability")
	post `postname'	(31550)	("Prepayment of insurance premiums and reserves for outstanding claims; liability (IMA)")
	post `postname'	(31610)	("Total U.S. government securities; liability")
	post `postname'	(31611)	("Treasury securities, excluding U.S. savings bonds; liability")
	post `postname'	(31614)	("U.S. savings bonds; liability")
	post `postname'	(31615)	("Treasury securities, including U.S. savings bonds; liability")
	post `postname'	(31617)	("Agency- and GSE-backed securities; liability")
	post `postname'	(31620)	("Municipal securities and loans; liability")
	post `postname'	(31622)	("Long-term municipal securities and loans; liability")
	post `postname'	(31623)	("Corporate bonds and municipal securities; liability")
	post `postname'	(31624)	("Short-term municipal securities and loans; liability")
	post `postname'	(31627)	("Municipal bond offering for refunding; liability")
	post `postname'	(31630)	("Corporate and foreign bonds; liability")
	post `postname'	(31635)	("Corporate and foreign bonds issued by investment banks; liability")
	post `postname'	(31636)	("Private collateralized mortgage obligations (CMOs); liability")
	post `postname'	(31640)	("Corporate equities and mutual fund shares; liability")
	post `postname'	(31641)	("Corporate equities; liability")
	post `postname'	(31642)	("Mutual fund shares; liability")
	post `postname'	(31650)	("Total mortgages; liability (F42)")
	post `postname'	(31651)	("Home mortgages; liability")
	post `postname'	(31652)	("Commercial, multifamily, and farm mortgages; liability")
	post `postname'	(31654)	("Multifamily residential mortgages; liability")
	post `postname'	(31655)	("Commercial mortgages; liability")
	post `postname'	(31656)	("Farm mortgages; liability")
	post `postname'	(31657)	("Mortgage-backed bonds; liability")
	post `postname'	(31658)	("Commercial mortgages and bank loans n.e.c; liability")
	post `postname'	(31660)	("Consumer credit; liability")
	post `postname'	(31661)	("Revolving consumer credit; liability")
	post `postname'	(31662)	("Non-revolving consumer credit; liability")
	post `postname'	(31664)	("Consumer credit, automobile loans; liability")
	post `postname'	(31670)	("Security credit; liability")
	post `postname'	(31680)	("Bank loans not elsewhere classified; liability")
	post `postname'	(31684)	("Bank loans not elsewhere classified to rest of the world; liability")
	post `postname'	(31690)	("Other loans and advances; liability")
	post `postname'	(31691)	("Open market paper; liability")
	post `postname'	(31692)	("U.S. government loans; liability")
	post `postname'	(31693)	("Government-sponsored enterprise (GSE) loans; liability")
	post `postname'	(31694)	("Policy loans; liability")
	post `postname'	(31695)	("Nonfinancial business loans, excluding U.S. government and GSE loans; liability")
	post `postname'	(31696)	("Bankers' Acceptances; liability")
	post `postname'	(31697)	("Customers' liability on acceptances outstanding; liability")
	post `postname'	(31698)	("Syndicated loans; liability")
	post `postname'	(31699)	("Open market paper and other loans and advances; liability")
	post `postname'	(31700)	("Trade payables; liability")
	post `postname'	(31706)	("Payables owed to other brokers and dealers and clearing organizations; liability")
	post `postname'	(31730)	("Claims of pension fund on sponsor; liability")
	post `postname'	(31760)	("Policy payables; liability")
	post `postname'	(31780)	("Taxes payables; liability")
	post `postname'	(31810)	("Equity and investment fund shares; liability (F5)")
	post `postname'	(31811)	("Equity and investment fund shares excluding mutual fund shares and money market fund shares; liability (F51)")
	post `postname'	(31812)	("Mutual fund and money market fund shares; liability (F52)")
	post `postname'	(31900)	("Total miscellaneous liabilities")
	post `postname'	(31910)	("U.S. private deposits; liability")
	post `postname'	(31911)	("Nonofficial U.S. currencies; liability")
	post `postname'	(31917)	("Interbank transactions due to domestic affiliates; liability")
	post `postname'	(31920)	("Direct investment; liability")
	post `postname'	(31921)	("U.S. direct investment abroad: equity; liability")
	post `postname'	(31922)	("U.S. direct investment abroad: Reinvested earnings; liability")
	post `postname'	(31923)	("U.S. direct investment abroad: Intercompany accounts; liability")
	post `postname'	(31924)	("Equity in government-sponsored enterprises (GSEs); liability")
	post `postname'	(31926)	("Interbank transactions due to foreign affiliates; liability")
	post `postname'	(31930)	("Unidentified miscellaneous liabilities")
	post `postname'	(31940)	("Equity investment by parent companies; liability")
	post `postname'	(31943)	("Equity investment through the Public-Private Investment Program (PPIP); liability")
	post `postname'	(31945)	("Equity investment by funding corporations; liability")
	post `postname'	(31947)	("Holding companies net transactions with subsidiaries; liability")
	post `postname'	(31950)	("Other insurance reserves; liability")
	post `postname'	(31951)	("Retiree health care funds; liability")
	post `postname'	(31960)	("Other accounts payable; liability (F8)")
	post `postname'	(31961)	("Miscellaneous and taxes payable; libility (IMA)")
	post `postname'	(31962)	("Trade credits and advances; liability (IMA)")
	post `postname'	(31970)	("Deposits at Federal Home Loan Banks; liability")
	post `postname'	(31980)	("Financial derivatives; liability")
	post `postname'	(31990)	("Other liabilities")
	post `postname'	(40000)	("Total currency and deposits; asset (F2)")
	post `postname'	(40001)	("Change in cash balance; asset")
	post `postname'	(40007)	("Total currency and deposits; asset")
	post `postname'	(40010)	("Liquid assets")
	post `postname'	(40020)	("Credit and equity market instruments; asset")
	post `postname'	(40040)	("Credit market instruments; asset")
	post `postname'	(40100)	("Net interbank transactions; asset")
	post `postname'	(40122)	("Interbank transactions due from U.S. banks; asset")
	post `postname'	(40160)	("Net interbank transactions with banks in foreign countries; asset")
	post `postname'	(40162)	("Deposits at foreign banks; asset")
	post `postname'	(40210)	("Municipal and corporate bonds, corporate equities and mutual fund shares; asset")
	post `postname'	(40220)	("Debt securities; asset (F3)")
	post `postname'	(40222)	("Corporate bonds, municipal securities, and private foreigners holdings of agency- and GSE-backed securities; asset")
	post `postname'	(40224)	("Short-term debt securities; asset (F31)")
	post `postname'	(40226)	("Long-term debt securities; asset (F32)")
	post `postname'	(40230)	("Securities and equities; asset")
	post `postname'	(40350)	("Total loans including security repurchase agreements and federal funds; asset (F4)")
	post `postname'	(40355)	("Federal funds, repurchase agreements, and gross loans and leases exluding loans to state and local governments; asset")
	post `postname'	(40356)	("Total loans adjusted to FOF basis; asset")
	post `postname'	(40357)	("Total loans, including security repurchase agreements and federal funds, to U.S. commercial banks; asset")
	post `postname'	(40410)	("Short-term loans including repurchase agreements; asset (F41)")
	post `postname'	(40900)	("Total financial assets")
	post `postname'	(40901)	("Total assets (QFR input)")
	post `postname'	(40904)	("Total assets (balance sheet)")
	post `postname'	(40905)	("Total assets (balance sheet)")
	post `postname'	(40906)	("Total assets (balance sheet)")
	post `postname'	(40907)	("Total assets (balance sheet)")
	post `postname'	(41000)	("Total currency and deposits; liability (F2)")
	post `postname'	(41007)	("Total currency and deposits; liability")
	post `postname'	(41020)	("Credit and equity market instruments; liability")
	post `postname'	(41040)	("Credit market instruments; liability")
	post `postname'	(41041)	("Financial obligations and debt service ratios")
	post `postname'	(41049)	("Credit market instruments excluding certain items; liability")
	post `postname'	(41100)	("Net interbank transactions; liability")
	post `postname'	(41120)	("Net interbank transactions with U.S. banking; liability")
	post `postname'	(41122)	("Interbank transactions due to U.S. banks; liability")
	post `postname'	(41160)	("Net interbank transactions with banks in foreign countries; liability")
	post `postname'	(41162)	("Net interbank transactions with foreign affiliates including deposits at foreign banks; liability")
	post `postname'	(41200)	("Securities and mortgages; liability")
	post `postname'	(41220)	("Debt securities; liability (F3)")
	post `postname'	(41224)	("Short-term debt securities; liability (F31)")
	post `postname'	(41226)	("Long-term debt securities; liability (F32)")
	post `postname'	(41350)	("Total loans including security repurchase agreements; liability (F4)")
	post `postname'	(41400)	("Short-term debt; liability")
	post `postname'	(41406)	("Securities sold short; liability")
	post `postname'	(41410)	("Short-term loans including security repurchase agreements; liability (F41)")
	post `postname'	(41500)	("Total short-term liabilities")
	post `postname'	(41900)	("Total liabilities")
	post `postname'	(41905)	("Total liabilities (balance sheet)")
	post `postname'	(41907)	("Total liabilities (balance sheet)")
	post `postname'	(41910)	("Total liabilities due to the federal government, excluding official reserve assets; liability")
	post `postname'	(41920)	("Total liabilities due to private domestic sectors; liability")
	post `postname'	(41940)	("Total liabilities and equity")
	post `postname'	(41990)	("Debt other than home mortgages and consumer credit; liability")
	post `postname'	(50000)	("Net lending (+) or borrowing (-) (financial account)")
	post `postname'	(50007)	("Net lending (+) or borrowing (-) (financial account)")
	post `postname'	(50009)	("Net lending (+) or borrowing (-) (capital account)")
	post `postname'	(50053)	("Financing gap")
	post `postname'	(50100)	("Land at market value")
	post `postname'	(50101)	("Vacant land")
	post `postname'	(50107)	("Land with structures on it at book value")
	post `postname'	(50110)	("Consumer durable goods expenditures")
	post `postname'	(50120)	("Gross fixed investment, residential structures and equipment")
	post `postname'	(50121)	("Mobile homes")
	post `postname'	(50122)	("Residential equipment")
	post `postname'	(50126)	("Residential structures")
	post `postname'	(50128)	("Residential structures and equipment")
	post `postname'	(50130)	("Gross fixed investment, nonresidential structures, equipment, and intellectual property products")
	post `postname'	(50131)	("Fixed assets, book value")
	post `postname'	(50132)	("Nonresidential equipment, current cost basis")
	post `postname'	(50133)	("Nonresidential software, current cost basis")
	post `postname'	(50134)	("Nonresidential research and development, current cost basis")
	post `postname'	(50135)	("Nonresidential entertainment, literary, and artistic originals, current cost basis")
	post `postname'	(50136)	("Nonresidential structures, current cost basis")
	post `postname'	(50137)	("Nonresidential intellectual property products, current cost basis")
	post `postname'	(50138)	("Nonresidential structures, equipment, and intellectual property products, current cost basis")
	post `postname'	(50139)	("Nonresidential structures, equipment, and intellectual property products (residual diff. between NIPA and fixed asset accounts)")
	post `postname'	(50140)	("Foreign direct investment in U.S. real estate; asset")
	post `postname'	(50146)	("Total residential and nonresidential structures")
	post `postname'	(50147)	("Total residential and nonresidential structures excluding disaster related losses on structures")
	post `postname'	(50150)	("Structures, equipment, and intellectual property products")
	post `postname'	(50151)	("Total fixed capital (SOI)")
	post `postname'	(50152)	("Equipment, current cost basis")
	post `postname'	(50157)	("Equipment excluding disaster-related losses on equipment")
	post `postname'	(50190)	("Gross fixed investment")
	post `postname'	(50199)	("Gross fixed investment and inventories")
	post `postname'	(50200)	("Inventories")
	post `postname'	(50206)	("Inventory valuation adjustment (IVA)")
	post `postname'	(50327)	("Residential real estate excluding disaster-related losses on residential structures")
	post `postname'	(50337)	("Nonresidential real estate excluding disaster-related losses on nonresidential structures")
	post `postname'	(50350)	("Real estate")
	post `postname'	(50352)	("Owner-occupied real estate (SA)")
	post `postname'	(50354)	("Multi-family real estate (SA)")
	post `postname'	(50355)	("Commercial real estate (SA)")
	post `postname'	(50357)	("Real estate excluding disaster-related losses on structures")
	post `postname'	(50500)	("Capital expenditures")
	post `postname'	(50509)	("Capital formation, net (IMA)")
	post `postname'	(50600)	("Net investment")
	post `postname'	(50610)	("Net physical investment")
	post `postname'	(50800)	("Equity capital")
	post `postname'	(50900)	("Gross investment")
	post `postname'	(50994)	("Assets less liabilities excluding directly and indirectly held corporate equities and owner-occupied housing")
	post `postname'	(51110)	("Consumer durable goods investment")
	post `postname'	(51140)	("U.S. real estate owned by foreigners; liability")
	post `postname'	(54000)	("Capital transfers received")
	post `postname'	(54040)	("Disaster losses")
	post `postname'	(54042)	("Disaster losses on residential fixed assets")
	post `postname'	(54043)	("Disaster losses on nonresidential fixed assets")
	post `postname'	(54100)	("Capital transfers paid")
	post `postname'	(54200)	("Acquisition of nonproduced nonfinancial assets (net)")
	post `postname'	(54300)	("Capital account transactions (net)")
	post `postname'	(54400)	("Net capital transfers paid")
	post `postname'	(60000)	("Balance on current account (net saving)")
	post `postname'	(60001)	("Gross saving")
	post `postname'	(60060)	("Net saving")
	post `postname'	(60063)	("Net saving less net capital transfers paid")
	post `postname'	(60064)	("Undistributed corporate profits")
	post `postname'	(60070)	("Personal saving")
	post `postname'	(60100)	("National income/personal income")
	post `postname'	(60101)	("Current receipts, NIPA basis")
	post `postname'	(60120)	("Disposable income, net")
	post `postname'	(60200)	("Wages and salaries paid (IMA)")
	post `postname'	(60201)	("Wages and salaries received (IMA)")
	post `postname'	(60250)	("Compensation of employees paid")
	post `postname'	(60251)	("Compensation of employees received")
	post `postname'	(60600)	("Corporate profits")
	post `postname'	(60613)	("Deficit/surplus")
	post `postname'	(61100)	("Income")
	post `postname'	(61111)	("Proprietors' income with IVA and CCAdj")
	post `postname'	(61120)	("Rents paid (IMA)")
	post `postname'	(61121)	("Rents received (IMA)")
	post `postname'	(61200)	("Distributed income of corporations, paid (IMA)")
	post `postname'	(61201)	("Distributed income of corporations, received (IMA)")
	post `postname'	(61210)	("Dividends paid (IMA)")
	post `postname'	(61211)	("Dividends received (IMA)")
	post `postname'	(61220)	("Withdrawals from income of quasi-corporations, paid (IMA)")
	post `postname'	(61221)	("Withdrawals from income of quasi-corporations, received (IMA)")
	post `postname'	(61300)	("Interest paid (IMA)")
	post `postname'	(61301)	("Interest received (IMA)")
	post `postname'	(61400)	("Net national income/balance of primary incomes, net (IMA)")
	post `postname'	(61500)	("Uses of property income (paid) (IMA)")
	post `postname'	(61501)	("Property income (received) (IMA)")
	post `postname'	(62100)	("Personal current taxes")
	post `postname'	(62200)	("Current taxes on income; wealth; etc. (IMA)")
	post `postname'	(62310)	("Taxes on corporate income")
	post `postname'	(62331)	("Business tax receipts (MTS)")
	post `postname'	(62400)	("Taxes on production and imports, receivable")
	post `postname'	(62401)	("Taxes on production and imports less subsidies, payable")
	post `postname'	(63000)	("Consumption of fixed capital, structures, equipment, and intellectual property products, current cost basis")
	post `postname'	(63001)	("Consumption of fixed capital, consumer durables")
	post `postname'	(63100)	("Capital consumption adjustment (CCAdj.)")
	post `postname'	(63200)	("Consumption of fixed capital, residential equipment and structures, current cost basis")
	post `postname'	(63300)	("Consumption of fixed capital, nonresidential structures, equipment, and intellectual property products, current cost basis")
	post `postname'	(64001)	("Current taxes and transfer payments received")
	post `postname'	(64010)	("Employers' social contributions paid (IMA)")
	post `postname'	(64011)	("Employers' social contributions received (IMA)")
	post `postname'	(64020)	("Subsidies")
	post `postname'	(64021)	("Operating surplus, net")
	post `postname'	(64022)	("Non-operating income (QFR)")
	post `postname'	(64030)	("Other current transfers paid")
	post `postname'	(64031)	("Other current transfers received")
	post `postname'	(64040)	("Social contributions paid")
	post `postname'	(64041)	("Social benefits received")
	post `postname'	(66000)	("Contributions for government social insurance paid")
	post `postname'	(66010)	("Contributions for government social insurance received")
	post `postname'	(69000)	("Current expenditures/outlays")
	post `postname'	(69010)	("Consumption expenditures")
	post `postname'	(69011)	("Personal interest payments")
	post `postname'	(69012)	("Personal current transfer payments to rest of the world")
	post `postname'	(69020)	("Gross domestic product")
	post `postname'	(69021)	("Gross national product")
	post `postname'	(69025)	("Gross value added (IMA)")
	post `postname'	(69026)	("Net value added (IMA)")
	post `postname'	(69030)	("Imports/exports")
	post `postname'	(69040)	("Income payments to the U.S.")
	post `postname'	(69041)	("Income receipts from the U.S.")
	post `postname'	(69050)	("Foreign income to U.S.")
	post `postname'	(70050)	("Statistical discrepancy")
	post `postname'	(70059)	("Gross domestic product (GDP); statistical discrepancy")
	post `postname'	(80000)	("Holding gains on assets at market value")
	post `postname'	(80007)	("Holding gains on assets at market value excluding disaster-related losses on fixed assets")
	post `postname'	(80800)	("Financial assets with revaluations (IMA)")
	post `postname'	(80900)	("Other volume changes")
	post `postname'	(80901)	("Total other volume changes (IMA)")
	post `postname'	(81000)	("Holding gains on assets at current cost")
	post `postname'	(81007)	("Holding gains on assets at current cost excluding disaster-related losses on fixed assets")
	post `postname'	(82000)	("Changes in net worth due to nominal holding gains/losses (IMA)")
	post `postname'	(82007)	("Changes in net worth due to nominal holding gains/losses excluding disaster-related losses on fixed assets (IMA)")
	use `postfile', `clear'
end


