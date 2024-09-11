
/*
DATA CLEANING PORTFOLIO PROJECT
*/

SELECT *
FROM PortfolioProject.dbo.NashvilleHousingData_V3

--Populate Property Address Data
SELECT *
FROM PortfolioProject..NashvilleHousingData
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


--COUNT command
SELECT COUNT (PropertyAddress) as SingleFamOver400k	
FROM PortfolioProject..NashvilleHousingData
WHERE LandUse = 'Single Family'
AND SalePrice > 400000

--We want to get all the property addresses that are null and have the same parcel ID
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousingData a
JOIN PortfolioProject..NashvilleHousingData b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

--when using "update" function, must use the alias
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousingData a
JOIN PortfolioProject..NashvilleHousingData b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

--Extracting the city from Property Address
SELECT PropertyAddress,
CityExtracted = SUBSTRING(PropertyAddress, LEN(PropertyAddress),CHARINDEX(' ', PropertyAddress, 4))
--CHARINDEX(' ',PropertyAddress), -10))
FROM PortfolioProject..NashvilleHousingData


--After Trimming Property Address, seperate out the City to a new column
SELECT TrimmedPropAddress,
CityExtracted = SUBSTRING(TrimmedPropAddress, CHARINDEX(',', TrimmedPropAddress)+1, LEN(TrimmedPropAddress))
FROM PortfolioProject.dbo.NashvilleHousingData_V3


SELECT TrimmedPropAddress,
CityExtracted = SUBSTRING(TrimmedPropAddress, CHARINDEX(',', TrimmedPropAddress)+1, LEN(TrimmedPropAddress)), 
PropertySplitAddress = LEFT (TrimmedPropAddress, CHARINDEX(',', TrimmedPropAddress,1))
FROM PortfolioProject.dbo.NashvilleHousingData_V3

--After trimming the quotes off, now split out Address and City
SELECT TrimmedPropAddress,
PropCityExtracted = SUBSTRING(TrimmedPropAddress, CHARINDEX(',', TrimmedPropAddress)+1, LEN(TrimmedPropAddress)), 
PropAddressExtracted = LEFT (TrimmedPropAddress, CHARINDEX(',', TrimmedPropAddress,1))
FROM PortfolioProject.dbo.NashvilleHousingData_V3

--Length of PropertyAddress

SELECT lengthofcolumn = LEN(PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousingData_V3

--Trim the quotes off of OwnerAddress
SELECT OwnerAddress, TRIM('"' FROM OwnerAddress) as TrimmedOwnerAddress
FROM PortfolioProject.dbo.NashvilleHousingData_V3

--Add a column to table for trimmed values for OwnerAddress
ALTER TABLE NashvilleHousingData_V3
ADD TrimmedOwnerAddress nvarchar(255)

UPDATE NashvilleHousingData_V3
SET TrimmedOwnerAddress = TRIM('"' FROM OwnerAddress)

SELECT *
FROM PortfolioProject.dbo.NashvilleHousingData_V3
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

--Replacing empty PropertyAddress with addresses found elsewhere in the data 
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousingData_V3 a
JOIN PortfolioProject.dbo.NashvilleHousingData_V3 b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL	


--Add PropCityExtracted column
ALTER TABLE NashvilleHousingData_V3
ADD PropCityExtracted nvarchar(255)

--Insert data
UPDATE NashvilleHousingData_V3
SET PropCityExtracted = SUBSTRING(TrimmedPropAddress, CHARINDEX(',', TrimmedPropAddress)+1, LEN(TrimmedPropAddress))

--Check to make sure it came through correctly
SELECT PropCityExtracted
FROM PortfolioProject.dbo.NashvilleHousingData_V3

--Add PropAddressExtracted column
ALTER TABLE NashvilleHousingData_V3
ADD PropAddressExtracted nvarchar(255)

----Insert data
UPDATE NashvilleHousingData_V3
SET PropAddressExtracted = LEFT (TrimmedPropAddress, CHARINDEX(',', TrimmedPropAddress,1))

--Check to make sure it came through correctly
SELECT PropAddressExtracted
FROM PortfolioProject.dbo.NashvilleHousingData_V3

--Look at the whole new data set now. 
SELECT *
FROM PortfolioProject.dbo.NashvilleHousingData_V3

--Break the date out into different text and numerical fields for better usage
SELECT SaleDate, dayofweeksaledate = DAY(SaleDate), weekdaysaledate = datename( W, SaleDate), numericmonthsaledate = MONTH(SaleDate), textmonthsaledate = datename( MONTH, SaleDate),
parsedyear = DATENAME(yyyy, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousingData_V3
ORDER BY parsedyear desc

--Now I want to do the same thing with OwnerAddress (extract the street address, city & state) but I'll try a different way --PARSENAME
SELECT TrimmedOwnerAddress,
PARSENAME(REPLACE (TrimmedOwnerAddress, ',','.'),1) as OwnerAddressState,
PARSENAME(REPLACE (TrimmedOwnerAddress, ',','.'),2) as OwnerAddressCity,
PARSENAME(REPLACE (TrimmedOwnerAddress, ',','.'),3) as OwnerAddressExtracted
FROM PortfolioProject.dbo.NashvilleHousingData_V3
ORDER BY OwnerAddressCity desc


--Since that looks good, add the new columns to our table

--Add OwnerAddressState column
ALTER TABLE NashvilleHousingData_V3
ADD OwnerAddressState nvarchar(255)

--Insert data
UPDATE NashvilleHousingData_V3
SET OwnerAddressState = PARSENAME(REPLACE (TrimmedOwnerAddress, ',','.'),1)


--Add OwnerAddressCity column
ALTER TABLE NashvilleHousingData_V3
ADD OwnerAddressCity nvarchar(255)

--Insert data
UPDATE NashvilleHousingData_V3
SET OwnerAddressCity = PARSENAME(REPLACE (TrimmedOwnerAddress, ',','.'),2)

--Add OwnerAddressExtracted column
ALTER TABLE NashvilleHousingData_V3
ADD OwnerAddressExtracted nvarchar(255)

--Insert data
UPDATE NashvilleHousingData_V3
SET OwnerAddressExtracted = PARSENAME(REPLACE (TrimmedOwnerAddress, ',','.'),3)

--Next, remove duplicates using ROW_NUMBER (this query also uses a CTE)
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) as row_num

FROM PortfolioProject.dbo.NashvilleHousingData_V3
--ORDER BY ParcelID
)
--We've identified all the duplicate rows, now we delete them
DELETE
FROM RowNumCTE
WHERE row_num > 1

--Delete unused columns, first check to make sure which ones you want to delete
SELECT *
FROM PortfolioProject.dbo.NashvilleHousingData_V3

ALTER TABLE PortfolioProject.dbo.NashvilleHousingData_V3
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

--That's it! Data is clean and ready to be imported to the BI tool for visualizations. 