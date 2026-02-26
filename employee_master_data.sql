SELECT  T0."empID", T0."ExtEmpNo",  T0."firstName", T0."middleName", T0."lastName",  T0."Active", T0."sex", T2."name" as Status, T0."U_JobTitle", T0."type",  T4."Name", 
/*T0."BPLId",T0."branch", */ 
(SELECT A1."BPLName" FROM OBPL  A1 WHERE A1."BPLId" = T0."BPLId") AS "Branch",
T0."manager",
(SELECT A2."firstName" FROM OHEM A2 WHERE A2."Code" = T0."manager") AS "Manager Name",
 T0."officeTel", T0."mobile", T0."pager", T0."homeTel", T0."email", T0."startDate", T0."termDate", T3."descriptio", T0."bankCode", 

(Select M."BankName" FROM ODSC M where M."BankCode" = T0."bankCode" and M."CountryCod" ='AE' ) AS "BankName",

T0."bankBranch", T0."bankAcount", T0."birthDate", T0."martStatus", T0."govID", T0."citizenshp", 
(SELECT A."Name" FROM OCRY A WHERE A."Code" =  T0."citizenshp") "citizenshp", 

(SELECT A."Name" FROM OCRY A WHERE A."Code" =  T0."brthCountr" ) "Country",

T0."passportNo", T0."passportEx", T1."name" as Position, T0."BPLId", T0."PassIssue",

T0."U_PayMode", T0."U_EType", T0."U_CntHr", T0."U_PRPDDT", T0."U_PRPSTS", T0."U_DOB", T0."U_EmpType", T0."U_NPF", T0."U_VType", T0."U_InDate", T0."U_VIDate", T0."U_EmirId", T0."U_EmDate", T0."U_LbDate", T0."U_CostCntr",  T0."U_UId", T0."U_NoPer", T0."U_LaWoDa", T0."U_VFno", T0."U_Rgn", T0."U_Insur", T0."U_Spnsr2", T0."U_PEmail", T0."U_SprdDep", T0."U_EosTyo", T0."U_Benif", T0."U_VisaSts", T0."U_InTy", T0."U_EmpTy", T0."U_WPno", T0."U_ViExDa", T0."U_Dptmt", T0."U_LbrId", T0."U_OffLtrCd", T0."U_EmployeeBank", T0."U_INPROBIN", T0."U_STATUS", T0."U_CCODE", T0."U_Ticket", T0."U_Type", T0."U_NPDT", T0."U_MOLExp", T0."U_ECNo", T0."U_ECPer", T0."U_InProv", T0."U_InIssD", T0."U_EmpTT", T0."U_PassCur", T0."U_FZExp", T0."U_LabComDate", T0."U_LabConExDate", T0."U_JobTitle",  T0."U_Accom",
(SELECT A."Name" FROM "@SBO_CAT" A WHERE A."Code" = T0."U_Cat" ) As "Employee Category"

--T0."U_PersonalEmail", 
--T0."U_EmerContact", 
--T0."U_EmerRelation", T0."U_EmerContact1", T0."U_EmerContact2", 
--T0."U_VisaNo", 
--T0."U_VisaIssueDate", T0."U_VisaExpiryDate", 
--T0."U_FatherName", T0."U_MotherName", T0."U_SocialInsuranceNo", T0."U_SIExpiryDate", T0."U_DrivingLicense", T0."U_LicenseType", T0."U_DLIssueDate", T0."U_DLExpiryDate", T0."U_IBANNo", T0."U_CompanyNo" 
FROM OHEM T0
LEFT OUTER  JOIN OHPS T1 ON T0."position" = T1."posID"
LEFT OUTER  JOIN OHST T2 ON T0."status" = T2."statusID"
LEFT OUTER JOIN OHTR T3 ON T0."termReason" = T3."reasonID"
LEFT OUTER JOIN OUDP T4 ON T4."Code" = T0."dept"

where T0."Active" ='Y'

ORDER BY T0."empID"