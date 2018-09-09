<cfcomponent displayname="OP">

	<cfobject name="appObj" component="application">

	<cffunction name="getList" access="remote" returnType="query" returnformat="json">
		<cfargument name="term">
		<cfquery name="data">
			with
			VALID_CREDIT_CLASSES AS (
			select sfrstcr_pidm, sfrstcr_term_code, sfrstcr_credit_hr
			from sfrstcr --student course registration table, by student
			    join stvrsts --Course Registration Status Code Validation Form
			        on sfrstcr_rsts_code = stvrsts_code -- joined by course status code
			where sfrstcr_levl_code = 'CR' --taking credit classes
			    and stvrsts_incl_Sect_enrl = 'Y' --student registered in the enrolled section
			)
			, PIDM_LIST as (
			select rprawrd_pidm PIDM
			     , max(rprawrd_aidy_code) LAST_AWARDED_AIDY
			     , max(VALID_CREDIT_CLASSES.sfrstcr_term_code) LAST_ATTENDED_TERM
			     , min(VALID_CREDIT_CLASSES.SFRSTCR_TERM_CODE) FIRST_ENRL_TERM
			from rprawrd --applicant award table, by student
			    left outer join VALID_CREDIT_CLASSES
			        on rprawrd_pidm = VALID_CREDIT_CLASSES.sfrstcr_pidm
			where rprawrd_fund_code = 'OPG' --OP award grant code
			group by rprawrd_pidm
			)
			, STU as (
			select SGBSTDN_PIDM ST_PIDM
			     , SGBSTDN_DEGC_CODE_1 ST_DEGC
			     , SGBSTDN_MAJR_CODE_1 ST_MAJR
			     , SGBSTDN_CAMP_CODE ST_CAMP
			     , '(' || SPRTELE_PHONE_AREA || ') ' || SUBSTR(SPRTELE_PHONE_NUMBER,2,3) || '-' || SUBSTR(SPRTELE_PHONE_NUMBER,4,4) PHONE
			from SGBSTDN -- student base table
			    join PIDM_LIST on SGBSTDN_PIDM = PIDM_LIST.PIDM
			    left outer join SPRTELE
			      on PIDM_LIST.PIDM = SPRTELE_PIDM
			        and SPRTELE.rowid = f_get_address_telephone_rowid(PIDM_LIST.PIDM,'STDNADDR','A',SYSDATE,1,'S',NULL)
			where SGBSTDN_TERM_CODE_EFF =
			       (select max(SGBSTDN_TERM_CODE_EFF)
			          from SGBSTDN
			         where SGBSTDN_PIDM = PIDM
			           and SGBSTDN_TERM_CODE_EFF <= PIDM_LIST.LAST_ATTENDED_TERM)
			)
			, BIO as (
			select SPBPERS_PIDM BI_PIDM
			     , SPBPERS_SEX BI_GENDER
			     , trunc(months_between(STVTERM_START_DATE,SPBPERS_BIRTH_DATE)/12) BI_AGE
			     , SPBPERS_CITZ_CODE BI_CITZ
			     , SPBPERS_CITZ_CODE ||' - '||STVCITZ_DESC BI_CITZ_DESC
			  from SPBPERS
			     join PIDM_LIST on SPBPERS_PIDM = PIDM_LIST.PIDM
			     join STVTERM on STVTERM_CODE = PIDM_LIST.LAST_ATTENDED_TERM
			     left outer join STVCITZ
			        on SPBPERS_CITZ_CODE = STVCITZ.STVCITZ_CODE
			)

			-- Race - Separated Ethnicity/Race data from Banner
			, RACE as (
			-- Hispanic/Latino Ethnicity
			select spbpers_pidm RC_PIDM
			     , 'HIS' RC_RACE
			  from spbpers
			     join PIDM_LIST on SPBPERS_PIDM = PIDM_LIST.PIDM
			 where spbpers_ethn_cde = '2'
			union
			-- Self-Reported Races
			select GORPRAC_PIDM RC_PIDM
			     , GORPRAC_RACE_CDE RC_RACE
			  from GORPRAC
			     join PIDM_LIST on GORPRAC_PIDM = PIDM_LIST.PIDM
			)

			-- Reporting Race - Aggregation based on Department of Ed. Ethn/Race categories:
			-- (as per http://nces.ed.gov/ipeds/reic/resource.asp)
			-- Hispanic or Latino (any)
			-- American Indian or Alaska Native (non-Hispanic)
			-- Asian (non-Hispanic)
			-- Black (non-Hispanic)
			-- Native Hawaiian or Other Pacific Islander (non-Hispanic)
			-- White (non-Hispanic)
			-- Two-or-More races (non-Hispanic)
			-- Non-Resident Alien (calculated after the fact)
			-- Not Reported (calculated after the fact)

			, REP_RACE as (
			select RC_PIDM RR_PIDM
			     , RC_RACE RR_RACE
			  from RACE
			 where RC_RACE = 'HIS'
			union
			select RC_PIDM RR_PIDM
			     , RC_RACE RR_RACE
			  from RACE a
			 where not exists
			       (select 1
			          from SPBPERS
			         where SPBPERS_PIDM = RC_PIDM
			           and SPBPERS_ETHN_CDE = 2)
			    and 1 = (select count(*) from GORPRAC where GORPRAC_PIDM = RC_PIDM)
			union
			select RC_PIDM  RR_PIDM
			     , 'MLT' RR_RACE
			from RACE a
			where not exists
			       (select 1 from SPBPERS
			         where SPBPERS_PIDM = RC_PIDM
			           and SPBPERS_ETHN_CDE = 2)
			   and 1 < (select count(*) from GORPRAC where GORPRAC_PIDM = RC_PIDM)
			)
			, SAPPrep AS
			(select shrttrm_pidm SP_PIDM
			     , nvl2(sgbstdn_cast_code
			           ,sgbstdn_cast_code||' (Ovr: '||shrttrm_cast_code||')'
			           ,shrttrm_cast_code) SP_CAST
			     , nvl2(sgbstdn_astd_code
			           ,sgbstdn_astd_code||' (Ovr: '||shrttrm_astd_code_end_of_term||')'
			           ,shrttrm_astd_code_end_of_term) SP_ASTD
			     , nvl2(sgbstdn_prev_code
			           ,sgbstdn_prev_code||' (Ovr: '||shrttrm_prev_code||')'
			           ,shrttrm_prev_code) SP_PREV
			  from PIDM_LIST
			     left outer join SGBSTDN --Student base table
			        on PIDM_LIST.LAST_ATTENDED_TERM = SGBSTDN_TERM_CODE_EFF
			            and PIDM_LIST.PIDM = SGBSTDN_PIDM
			     join SHRTTRM --Institutional Course Maintenance Term Header Repeating Table
			        on SHRTTRM_PIDM = PIDM_LIST.PIDM
			 where SHRTTRM_TERM_CODE =
			       (select max(SFRSTCR_TERM_CODE)
			          from SFRSTCR --student course registration table, by student
			            join STVRSTS --Course Registration Status Code Validation Form
			              on SFRSTCR_RSTS_CODE = STVRSTS_CODE
			          where SFRSTCR_PIDM = PIDM_LIST.PIDM
			            and SFRSTCR_LEVL_CODE = 'CR'
			            and SFRSTCR_TERM_CODE < PIDM_LIST.LAST_ATTENDED_TERM
			            and STVRSTS_INCL_SECT_ENRL = 'Y')
			)
			, SAP as (
			select SAPPrep.*
			        ,SP_PREV||'-'||STVPREV_DESC SP_PREV_DESC
			        ,SP_ASTD||'-'||STVASTD_DESC SP_ASTD_DESC
			    FROM SAPPrep
			    left outer join STVPREV
			        on SAPPrep.SP_PREV = STVPREV.STVPREV_CODE
			    left outer join STVASTD
			        on SAPPrep.SP_ASTD = STVASTD.STVASTD_CODE
			)
			, ADVR as (
			select PIDM AD_PIDM
			     , f_format_name(SGRADVR_ADVR_PIDM,'LPMI') ADVISOR
			  from PIDM_LIST
			    join SGRADVR
			      on SGRADVR_PIDM = PIDM_LIST.PIDM
			 where SGRADVR_ADVR_CODE = 'A'
			   and SGRADVR_TERM_CODE_EFF =
			       (select max(SGRADVR_TERM_CODE_EFF)
			          from SGRADVR
			         where SGRADVR_TERM_CODE_EFF <= PIDM_LIST.LAST_ATTENDED_TERM
			           and SGRADVR_PIDM = PIDM)
			)
			, HS as (
			select distinct
			       PIDM HS_PIDM
			     , count(*) over (partition by PIDM) HS_CNT
			     , STVSBGI_CODE  HS_CODE
			     , STVSBGI_DESC  HS_NAME
			     , SOBSBGI_CITY  HS_CITY
			     , SOBSBGI_STAT_CODE HS_STATE
			     , SORHSCH_GRADUATION_DATE HS_GRAD_DATE
			     , STVDPLM_CODE||' - '||STVDPLM_DESC HS_DPLM
			     , SORHSCH_GPA HS_GPA
			  from PIDM_LIST
			     join SORHSCH
			        on SORHSCH_PIDM = PIDM_LIST.PIDM
			      left outer join STVSBGI
			        on SORHSCH_SBGI_CODE = STVSBGI_CODE
			      left outer join SOBSBGI
			        on SORHSCH_SBGI_CODE = SOBSBGI_SBGI_CODE
			      left outer join STVDPLM
			        on SORHSCH_DPLM_CODE = STVDPLM_CODE
			 where SORHSCH.rowid =
			       (select distinct
			               first_value(SORHSCH.rowid)
			               over (partition by NULL
			                     order by SORHSCH_GRADUATION_DATE desc NULLS last
			                            , decode(SORHSCH_DPLM_CODE,'D',1,'G',2,'P',3
			                                                      ,'N',4,'S',5,6))
			          from SORHSCH
			         where SORHSCH_PIDM = PIDM)
			),
			FinalData AS
			(select PIDM_LIST.PIDM
			     , gb_common.f_get_id(PIDM)  STU_ID
			     , f_format_name(PIDM,'LFMI') STU_NAME
			     , GOREMAL_EMAIL_ADDRESS EMAIL
			     , PHONE
			     , PIDM_LIST.LAST_ATTENDED_TERM
			     , PIDM_LIST.FIRST_ENRL_TERM
			     , (select min(rpratrm_term_code)
			          from RPRATRM
			         where RPRATRM_PIDM = PIDM
			           and RPRATRM_FUND_CODE = 'OPG'
			           and RPRATRM_PAID_AMT > 0) FIRST_OPG_TERM
			     , nvl((select sum(RPRATRM_OFFER_AMT)
			              from RPRATRM
			             where RPRATRM_PIDM = PIDM
			               and RPRATRM_TERM_CODE = PIDM_LIST.LAST_ATTENDED_TERM
			               and RPRATRM_FUND_CODE = 'OPG'),0) AWARD_TERM
			     , nvl((select sum(RPRATRM_PAID_AMT)
			              from RPRATRM
			             where RPRATRM_PIDM = PIDM
			               and RPRATRM_TERM_CODE = PIDM_LIST.LAST_ATTENDED_TERM
			               and RPRATRM_FUND_CODE = 'OPG'),0) PAID_TERM
			     , nvl((select sum(RPRAWRD_PAID_AMT)
			              from RPRAWRD
			             where RPRAWRD_PIDM = PIDM
			               and RPRAWRD_AIDY_CODE = PIDM_LIST.LAST_AWARDED_AIDY
			               and RPRAWRD_FUND_CODE = 'OPG'),0) PAID_AIDY
			     , (select listagg(CHRT,', ') within group (order by CHRT)
			          from (select distinct SGRCHRT_CHRT_CODE CHRT
			                  from SGRCHRT
			                 where SGRCHRT_PIDM = PIDM
			                   and SGRCHRT_CHRT_CODE like 'OP%')) CHRTS
			     , ADVISOR
			     , coalesce(
			         (select distinct 'Passed'
			            from SHRTCKN
			                join SHRTCKG
			                    on SHRTCKN_PIDM = SHRTCKG_PIDM
			           where SHRTCKN_PIDM = PIDM
			             and SHRTCKN_SUBJ_CODE = 'CG'
			             and SHRTCKN_CRSE_NUMB = '100'
			             and SHRTCKN_TERM_CODE < PIDM_LIST.LAST_ATTENDED_TERM
			             and SHRTCKN_TERM_CODE = SHRTCKG_TERM_CODE
			             and SHRTCKN_SEQ_NO = SHRTCKG_TCKN_SEQ_NO
			             and SHRTCKG_SEQ_NO =
			                 (select max(SHRTCKG_SEQ_NO)
			                    from SHRTCKG
			                   where SHRTCKG_PIDM = SHRTCKN_PIDM
			                     and SHRTCKG_TERM_CODE = SHRTCKN_TERM_CODE
			                     and SHRTCKG_TCKN_SEQ_NO = SHRTCKN_SEQ_NO)
			             and SHRTCKG_GRDE_CODE_FINAL in ('A','B','C','D','P','TA','TB','TC','TD','TP'))
			        ,(select case
			                   when min(SFRSTCR_TERM_CODE) = PIDM_LIST.LAST_ATTENDED_TERM then 'Enrolled'
			                   when min(SFRSTCR_TERM_CODE) > PIDM_LIST.LAST_ATTENDED_TERM then 'Future'||'-'||min(SFRSTCR_TERM_CODE)
			                 end
			            from SFRSTCR
			                join SSBSECT
			                    on SFRSTCR_TERM_CODE = SSBSECT_TERM_CODE
			                join STVRSTS
			                    on SFRSTCR_RSTS_CODE = STVRSTS_CODE
			           where SFRSTCR_PIDM = PIDM_LIST.PIDM
			             and SSBSECT_SUBJ_CODE = 'CG'
			             and SSBSECT_CRSE_NUMB = '100'
			             and SSBSECT_TERM_CODE >= PIDM_LIST.LAST_ATTENDED_TERM
			             and SFRSTCR_CRN = SSBSECT_CRN
			             and STVRSTS_INCL_SECT_ENRL = 'Y')
			        ,'None')   CG100
			     , ST_DEGC
			     , ST_MAJR||'-'||STVMAJR_DESC ST_MAJR
			     , ST_CAMP||'-'||STVCAMP_DESC ST_CAMP
			     , trunc(SHRLGPA_GPA,3) CR_GPA
			     , SHRLGPA_HOURS_ATTEMPTED  CR_ATTEMPTED
			     , case
			         when SHRLGPA_HOURS_ATTEMPTED < 15 then 'a) 0-14.9'
			         when SHRLGPA_HOURS_ATTEMPTED < 30 then 'b) 15-29.9'
			         when SHRLGPA_HOURS_ATTEMPTED < 45 then 'c) 30-44.9'
			         when SHRLGPA_HOURS_ATTEMPTED < 60 then 'd) 45-59.9'
			         when SHRLGPA_HOURS_ATTEMPTED < 75 then 'e) 60-74.9'
			         when SHRLGPA_HOURS_ATTEMPTED < 90 then 'f) 75-89.9'
			         when SHRLGPA_HOURS_ATTEMPTED >= 90 then 'g) 90+'
			       end CR_ATTEMPTED_CAT
			/*     , case
			         when ENRL >= 12 then 'FT'
			         when ENRL >= 9 then '3QT'
			         when ENRL >= 6 then 'HT'
			         when ENRL > 0 then 'PT'
			         else '-'
			       end  ENROLLMENT_STATUS*/
			     ,nvl((select sum(sfrstcr_credit_hr)
			            from SFRSTCR
			                join STVRSTS
			                    on SFRSTCR_RSTS_CODE = STVRSTS_CODE
			           where SFRSTCR_PIDM = PIDM_LIST.PIDM
			             and SFRSTCR_LEVL_CODE = 'CR'
			             and STVRSTS_INCL_SECT_ENRL = 'Y')
			        ,0) ENRL
			     , SP_CAST||'-'||STVCAST_DESC SP_CAST
			     , SP_ASTD_DESC SP_ASTD
			     , SP_PREV_DESC SP_PREV
			     , BI_GENDER
			     , BI_AGE
			     , case
			         when BI_AGE < 20 then 'a) Under 20'
			         when BI_AGE < 25 then 'b) 20-24'
			         when BI_AGE < 30 then 'c) 25-29'
			         when BI_AGE < 40 then 'd) 30-39'
			         when BI_AGE < 50 then 'e) 40-49'
			         else                  'f) 50+'
			       end  BI_AGE_CAT
			     , BI_CITZ_DESC BI_CITZ
			     , case
			         when BI_CITZ = 'NA' then 'Non-Resident Alien'
			         when RR_RACE is NULL then 'Race and Ethnicity Unknown'
			         when RR_RACE = 'HIS' then 'Hispanic/Latino'
			         when RR_RACE = 'MLT' then 'Multi-racial (non Hispanic)'
			         else (select GORRACE_DESC from GORRACE where GORRACE_RACE_CDE = RR_RACE)
			       end                                                             BI_REP_RACE
			     , nvl2(ASI.RC_PIDM,1,NULL) ASIAN
			     , nvl2(AIN.RC_PIDM,1,NULL) NATIVE
			     , nvl2(BAA.RC_PIDM,1,NULL) BLACK
			     , nvl2(HIS.RC_PIDM,1,NULL) HISPANIC
			     , nvl2(HPI.RC_PIDM,1,NULL) ISLANDER
			     , nvl2(WHI.RC_PIDM,1,NULL) WHITE
			     , HS_CODE
			     , HS_NAME
			     , HS_CITY
			     , HS_STATE
			     , HS_GRAD_DATE
			     , HS_DPLM
			  from PIDM_LIST
			      left outer join STU
			        on PIDM_LIST.PIDM = STU.ST_PIDM
			      left outer join STVCAMP
			        on STU.ST_CAMP = STVCAMP.STVCAMP_CODE
			     left outer join STVMAJR
			        on STU.ST_MAJR = STVMAJR.STVMAJR_CODE
			     left outer join ADVR
			        on PIDM_LIST.PIDM = ADVR.AD_PIDM
			     left outer join SHRLGPA
			        on PIDM_LIST.PIDM = SHRLGPA.SHRLGPA_PIDM
			            and SHRLGPA.SHRLGPA_LEVL_CODE = 'CR'
			            and SHRLGPA.SHRLGPA_GPA_TYPE_IND =  'I'
			            and SHRLGPA.SHRLGPA_GPA_HOURS > 0
			     left outer join SAP
			        on PIDM_LIST.PIDM = SAP.SP_PIDM
			     left outer join BIO
			        on PIDM_LIST.PIDM = BIO.BI_PIDM
			     left outer join REP_RACE
			        on PIDM_LIST.PIDM = REP_RACE.RR_PIDM
			     left outer join RACE ASI
			        on PIDM_LIST.PIDM = ASI.RC_PIDM and ASI.RC_RACE = 'AS'
			     left outer join  RACE AIN
			        on PIDM_LIST.PIDM = AIN.RC_PIDM and AIN.RC_RACE = 'AI'
			     left outer join RACE BAA
			        on PIDM_LIST.PIDM = BAA.RC_PIDM and BAA.RC_RACE = 'BAA'
			     left outer join RACE HIS
			        on PIDM = HIS.RC_PIDM and HIS.RC_RACE = 'HIS'
			     left outer join RACE HPI
			        on PIDM = HPI.RC_PIDM and HPI.RC_RACE = 'HPI'
			     left outer join RACE WHI
			        on PIDM = WHI.RC_PIDM and WHI.RC_RACE= 'WHI'
			     left outer join STVCAST
			        on SAP.SP_CAST = STVCAST.STVCAST_CODE
			     left outer join HS
			        on PIDM_LIST.PIDM = HS.HS_PIDM
			     left outer join GOREMAL
			        on PIDM_LIST.PIDM = GOREMAL.GOREMAL_PIDM
			            and GOREMAL_EMAL_CODE = 'PCC'
			)
			SELECT STU_NAME
			    ,STU_ID
			    ,CHRTS
			    ,FIRST_OPG_TERM
			    ,SP_CAST
			    ,CR_ATTEMPTED
			    ,CG100
			    ,EMAIL
			    ,PHONE
			    ,LAST_ATTENDED_TERM
			    ,FIRST_ENRL_TERM
			    ,AWARD_TERM
			    ,PAID_TERM
			    ,PAID_AIDY
			    ,ADVISOR
			    ,ST_DEGC
			    ,ST_MAJR
			    ,ST_CAMP
			    ,CR_GPA
			    ,CR_ATTEMPTED_CAT
			    , case
			         when ENRL >= 12 then 'FT'
			         when ENRL >= 9 then '3QT'
			         when ENRL >= 6 then 'HT'
			         when ENRL > 0 then 'PT'
			         else '-'
			       end ENROLLMENT_STATUS
			    ,ENRL
			    ,SP_ASTD
			    ,SP_PREV
			    ,BI_GENDER
			    ,BI_AGE
			    ,BI_AGE_CAT
			    ,BI_CITZ
			    ,BI_REP_RACE
			    ,ASIAN
			    ,NATIVE
			    ,BLACK
			    ,HISPANIC
			    ,ISLANDER
			    ,WHITE
			    ,HS_CODE
			    ,HS_NAME
			    ,HS_CITY
			    ,HS_STATE
			    ,HS_GRAD_DATE
			    ,HS_DPLM
			FROM FinalData
	</cfquery>
	<cfreturn data>
</cffunction>

<cffunction name="getTerms" access="remote">
	<cfquery name="terms">
		select STVTERM.STVTERM_CODE "TermCode",
       		STVTERM.STVTERM_CODE||' - '||STVTERM.STVTERM_DESC "TermDisplay",
       		STVTERM.STVTERM_DESC "TermDesc"
  		from SATURN.STVTERM STVTERM
	 	where STVTERM.STVTERM_CODE not in ('000000','999999')
	 		and STVTERM.STVTERM_CODE >= 201604
	 		and STVTERM.STVTERM_START_DATE <= SYSDATE
	 	order by STVTERM.STVTERM_CODE desc
	</cfquery>
	<cfreturn terms>
</cffunction>

<cffunction name="getCurrentTerm" acess="remote">
	<cfquery name="term">
		select Max( STVTERM.STVTERM_CODE ) "MaxTerm"
		from SATURN.STVTERM STVTERM
		where STVTERM.STVTERM_START_DATE <= SYSDATE
		    and STVTERM.STVTERM_CODE <> '999999'
	</cfquery>
	<cfreturn term.MaxTerm>
</cffunction>

</cfcomponent>