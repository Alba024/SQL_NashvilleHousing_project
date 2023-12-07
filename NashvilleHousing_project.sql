/*
Clening Data in SQL Queyries
*/

Select *
from [Portfolio-Project]..NashvilleHousingData

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Standardize Data Format


Select SaleDate, CONVERT(Date,SaleDate)
from [Portfolio-Project]..NashvilleHousingData

-----------

Update NashvilleHousingData
SET SaleDate = CONVERT(Date,SaleDate)


------------
ALTER TABLE NashvilleHousingData
Add SaleDateConverted Date;

Update NashvilleHousingData
SET SaleDateConverted = CONVERT(Date,SaleDate)

Select SaleDateConverted, CONVERT(Date,SaleDate)
from [Portfolio-Project]..NashvilleHousingData



--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Populate Property Address data

Select *
from [Portfolio-Project]..NashvilleHousingData
Where  PropertyAddress is null

---------

Select *
from [Portfolio-Project]..NashvilleHousingData
order by ParcelID                              --- In this queyri we found out that there are rows with same ParcelID and PropertyAddress...

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from [Portfolio-Project]..NashvilleHousingData a
JOIN [Portfolio-Project]..NashvilleHousingData b
    on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]    --- "<>" meaning No igual.
where a.PropertyAddress is null           ---- Here we found out that some ParcelID doesn't have PropertyAddress (it's NULL)



--- Let figuere out that with the function ISNULL:

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,ISNULL(a.PropertyAddress, b.PropertyAddress)
from [Portfolio-Project]..NashvilleHousingData a
JOIN [Portfolio-Project]..NashvilleHousingData b
    on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]    
where a.PropertyAddress is null      

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from [Portfolio-Project]..NashvilleHousingData a
JOIN [Portfolio-Project]..NashvilleHousingData b
    on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]    
where a.PropertyAddress is null     --- When you run this queyri it's going to be a empty table beacuse there is none NULL cell anymore.  



--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
from [Portfolio-Project]..NashvilleHousingData


SELECT                                                   
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address,
CHARINDEX(',', PropertyAddress)                      --- Here we will obtened the posición of the comma. For example, in the first row it's going to be "20"

From [Portfolio-Project]..NashvilleHousingData

--NOTE: 
--  SUBSTRING to extract a substring from the first character to the position of the first. This means that it will extract the part of the address before the first comma.
--  CHARINDEX used to find the position of a character or string within another text string


--- To remove the comma, we use -1:

SELECT                                                   
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
From [Portfolio-Project]..NashvilleHousingData


-------------------------

SELECT                                                   
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address
From [Portfolio-Project]..NashvilleHousingData

--NOTE: 
-- Third line:
----CHARINDEX(',', PropertyAddress) is to start the extraction of the substring from the character immediately after the comma.
----By adding +1, we get 6. This means that SUBSTRING will start extracting from the 6th character, i.e. after the comma.
----LEN is used here to indicate where the substring extraction will end.



--- Adding a new column to update the Address, using ALTER TABLE:


ALTER TABLE NashvilleHousingData
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

ALTER TABLE NashvilleHousingData
Add PropertySplitCity  Nvarchar(255);

Update NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))


Select *
From [Portfolio-Project]..NashvilleHousingData

----------


--- An easier way to do the previous process, by using PARSENAME and REPLACE:

Select OwnerAddress
From [Portfolio-Project]..NashvilleHousingData

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)  --- The count starts from left to right, that's why we write 3 first, so that it generates the name of the street in the first column
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From [Portfolio-Project]..NashvilleHousingData

--NOTE:
-- PARSENAME: in this case, it is being used to split the OwnerAddress column into parts based on the ',' (comma) delimiter.
-- REPLACE: Used to replace all occurrences of a character in a string with another character or string. Here, the commas (,) in the OwnerAddress column are replaced with periods (.)


--UPDATE

ALTER TABLE NashvilleHousingData
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE NashvilleHousingData
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousingData
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From [Portfolio-Project]..NashvilleHousingData





--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field by using CASE /WHEN /ELSE /END


Select Distinct(SoldAsVacant)
From [Portfolio-Project]..NashvilleHousingData


Select Distinct(SoldAsVacant), count(SoldAsVacant)
From [Portfolio-Project]..NashvilleHousingData
Group by SoldAsVacant
order by 2

---- Using CASE /WHEN /ELSE /END

Select SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
       when SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From [Portfolio-Project]..NashvilleHousingData


-- UPDATE

Update NashvilleHousingData
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
       when SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


	--- Confirmation of the table has been update through the below queyrie:

Select Distinct(SoldAsVacant), count(SoldAsVacant)
From [Portfolio-Project]..NashvilleHousingData
Group by SoldAsVacant
order by 2




--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



---- Remove Duplicates

WITH RowNumCTE AS(
Select *,           
   ROW_NUMBER() OVER(                  ---- ROW_NUMBER /PARTITION BY : It is typically used to identify and select duplicate data in a table.
   PARTITION BY ParcelID,              ---- What this query does is assign a row number (row_num) to each row in the NashvilleHousingData table
                PropertyAddress,       ---- PARTITION BY is a way to divide your data set into smaller groups based on the values ​​of one or more columns.
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
				   UniqueID
				   ) row_num
From [Portfolio-Project]..NashvilleHousingData
)
Select *
From RowNumCTE
Where row_num > 1                      --- Rows with row_num > 1 are those that have duplicates.
Order by PropertyAddress

Select *
From [Portfolio-Project]..NashvilleHousingData










--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



---Delete Unused Columns

Select *
From [Portfolio-Project]..NashvilleHousingData

ALTER TABLE [Portfolio-Project]..NashvilleHousingData
DROP COLUMN SaleDate, PropertyAddress