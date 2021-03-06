-- To reupload on git (2019-July-26) for loading file error
/****** Object:  StoredProcedure [dbo].[PRO_ClientInfo]    Script Date: 1/7/2019 10:16:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PRO_ClientInfo]
(
	@P_FROMDate date = '1900-01-01',
	@P_ToDate date = '1900-01-01'
)
AS

BEGIN

	--SET @P_FROMDate = ''
	--SET @P_ToDate = ''

(SELECT  ind.SurName FirstName, isnull(Replace(ind.GivName,'  ',' '),'MISSING') LastName, '' MiddleName, 
	tb4.Branch OfficeName , 
	tb4.StaffName StaffName, ind.ClientID ExternalID, tb4.ActivationDate ActivationDate,	
	'TRUE' Active, '' MobileNumber, isnull(ind.BirthDt,'01-Jan-1970') DateOfBirth, 
	ISNULL((SELECT Case when StrValue='F' then 'Female' else 'Male' end FROM tblList WHERE ListID=ind.Gender),'Male') Gender,
	ISNULL(cl.GroupID,'') AS GroupName, '' ClientRoleInGroup,	
	ISNULL((SELECT StrValue FROM tblList WHERE ListID=ind.MarStat),'') AS MaritalStatus, 	
	ISNULL((SELECT StrValue FROM tblListUser WHERE ListID=ind.IndivLkp1),'') AS EducationLevel,
	ISNULL(cl.Street ,'') AS [Address],ISNULL(cl.City,'') AS Village, 
	ISNULL((SELECT StrValue FROM tblListUser WHERE ListID=cl.StMun),'') AS WardVillageTrack,	
	ISNULL((SELECT StrValue FROM tblListUser WHERE ListID=cl.Region),'') AS Township,
	ISNULL((SELECT StrValue FROM tblListUser WHERE ListID=cl.RegionC),'') AS  StateDistrict,	
	Case when (SELECT StrValue FROM dbo.tblListUser WHERE ListID = Ind.IndivLkp2) = '1-Yes' then ISNULL((SELECT BrchName FROM V_Branch WHERE BranchID = cl.Branch),'')
	else ISNULL((SELECT StrValue FROM dbo.tblListUser WHERE ListID = Ind.IndivLkp2),'') end ADPYesNo, 
	--(SELECT StrValue FROM dbo.tblListUser WHERE ListID = Ind.IndivLkp2) ADPYesNo,
	ISNULL((SELECT StrValue FROM tblList WHERE ListID=cl.UrbRur),'') AS RuralUrban, 	
	'' NumberOfDependentChildren, ISNULL(ind.PartName,'') AS SpousName, 
	ISNULL((SELECT StrValue FROM tblListUser WHERE ListID=ind.IndivLkp3),'') AS SponseredFamily, 	
	ISNULL((SELECT StrValue FROM tblListUser WHERE ListID=ind.IndivLkp6),'') AS BlackList, 
	ISNULL((SELECT StrValue FROM tblListUser WHERE ListID=ind.IndivLkp7),'') AS EthnicRace, 	
	ISNULL((SELECT StrValue FROM tbllist WHERE ListID = cl.ClientType),'') AS ClientType, 
	LnOfcrID 	
	--Case when (SELECT Case when StrValue='F' then 'Female' else 'Male' end FROM tblList WHERE ListID=ind.Gender) is null then 'Missing Gender filled with (Male)' end GenderStatus,
	--Case when year(tb4.ActivationDate) < 2003 then 'Issue' end ActivationDateStatus
	FROM tblIndiv ind right join tblClient cl on ind.ClientID = cl.ClientID
	INNER JOIN 
	(
	SELECT m.ClientID, m.LnName StaffName, m.LnOfcrID, m.Branch, lch.ActivationDate FROM Tmp_ClientMappingCam m INNER JOIN  
		(
			SELECT Min(DisbDt) AS  ActivationDate, left(LoanID,11) ClientID FROM tblLnChar 
			WHERE LnAmt>0 
			AND DisbDt BETWEEN @P_FROMDate AND @P_ToDate
			GROUP BY left(LoanID,11)
		) lch on m.ClientID = lch.ClientID
	)
	 tb4 on tb4.ClientID=ind.ClientID
	WHERE cl.ClientType <> 113896.5555 -- ClientType <> Group
	--and cl.ClientID in (SELECT ClientID FROM Tmp_ClientMappingCam)
	)

END