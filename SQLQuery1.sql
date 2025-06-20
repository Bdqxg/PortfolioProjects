create database demo;

use demo;



/*
Cleaning Data in SQL Queries
*/
select *
from [dbo].[Hausing];


---------------------------------

-- Standardize Data Format

select SaleDate, Convert(Date,SaleDate)
From demo.dbo.Hausing;

Update Hausing
Set SaleDate =  Convert(Date,SaleDate);

Alter Table Hausing
Add SaledateConverted Date;

Update Hausing
Set SaledateConverted =  Convert(Date,SaleDate);

select SaledateConverted, Convert(Date,SaleDate)
From demo.dbo.Hausing;


------------------------------------------------------
-- Population Property Address data

select *
From demo.dbo.Hausing
Where PropertyAddress is null;

select *
From demo.dbo.Hausing
order by ParcelID; -- same ParcelID may indicate the same Property address, pop up the null


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From demo.dbo.Hausing a
Join demo.dbo.Hausing b
   on a.ParcelID = b.ParcelID
   and a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null

Update a
Set propertyaddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From demo.dbo.Hausing a
Join demo.dbo.Hausing b
   on a.ParcelID = b.ParcelID
   and a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)--check if there is still null remaining in the result
From demo.dbo.Hausing a
Join demo.dbo.Hausing b
   on a.ParcelID = b.ParcelID
   and a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null -- all null value have been populated
-- is there are still null value you can fill it with ISNULL(a.PropertyAddress,'no address avaliable') or not, as you wish



---------------------------------------------------------------------------------------
--Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
From demo.dbo.Hausing


Select
SUBSTRING(PropertyAddress, 1,  CHARINDEX(',', PropertyAddress)-1   ) as Address --from the first value to the one position before the first ','
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress)  ) as Address
From demo.dbo.Hausing

Alter Table Hausing
Add PropertySplitAddress Nvarchar(255);

Update Hausing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1,  CHARINDEX(',', PropertyAddress)-1   )

Alter Table Hausing
Add PropertySplitCity Nvarchar(255);

Update Hausing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress)  )


select *
From Hausing

-----Alternative way
Select OwnerAddress
From Hausing

Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From Hausing

Alter Table Hausing
Add OwnerSplitAddress Nvarchar(255);

Update Hausing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Alter Table Hausing
Add OwnerSplitCity Nvarchar(255);

Update Hausing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Alter Table Hausing
Add OwnerSplitState Nvarchar(255);

Update Hausing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--------------------------------------------------------------------
--Change Y and N to Yes and No in "Sold as Vacant  Field"
Select Distinct (SoldAsVacant),Count(SoldAsVacant)
From Hausing
Group by SoldAsVacant
--Order by 2

Select SoldAsVacant
,Case when SoldAsVacant ='Y'Then 'Yes'
When SoldAsVacant ='N'Then 'No'
Else SoldAsVacant
End
From Hausing

Update Hausing
Set SoldAsVacant = Case when SoldAsVacant ='Y'Then 'Yes'
When SoldAsVacant ='N'Then 'No'
Else SoldAsVacant
End
From Hausing


--Select Distinct (SoldAsVacant),Count(SoldAsVacant)
--From Hausing
--Group by SoldAsVacant


----------------------------------------------------------
--Remove Duplicates

With RownumCTE AS(
Select *,
ROW_NUMBER() Over(
Partition by ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference  --if all these elements are the same then consider it as duplicates
			 Order By
			   UniqueID) row_num
from Hausing
--order by ParcelID
)
Delete
from RownumCTE
where row_num >1


With RownumCTE AS(
Select *,
ROW_NUMBER() Over(
Partition by ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference  --if all these elements are the same then consider it as duplicates
			 Order By
			   UniqueID) row_num
from Hausing
--order by ParcelID
)
Select*
from RownumCTE
where row_num >1  --none data, successfully remove duplicates


---------------------------------------------------------
-- Delect Unused Columns

Alter Table Hausing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress,SaleDate

Select*
From Hausing