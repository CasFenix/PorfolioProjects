-- Cleaning data in SQL queries

Select *
From NashvilleHousing


-----------------------------------------------------------------------------------------------
-- Standardize data format

Select SaleDateC
From NashvilleHousing
Order by SaleDateC

-- Not working?
Update NashvilleHousing
SET SaleDate = CONVERT (date,SaleDate)


-- Try with this -- WORKED
ALTER TABLE NashvilleHousing
ADD SaleDateC Date;

Update NashvilleHousing
SET SaleDateC = CONVERT (date,SaleDate)


-- Populate Property Address

-- Check for NULL

Select *
from NashvilleHousing
where PropertyAddress is null

-- Entry without address still have data, check relationships with ParcelID


Select *
from NashvilleHousing
Order BY ParcelID

-- Since same ParcelID = same Property Address, we can populate NULLS if there is another entry with the same ParcelID

-- Start with a self join

Select 
a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Update Statement dopo aver verificato che ISNULL da il risultato sperato
UPDATE a
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	where a.PropertyAddress is null


-------------------------------------------------------------------


-- Breaking our addresses into individual columns (Address, City, State)

Select PropertyAddress
from NashvilleHousing


Select 
SUBSTRING (PropertyAddress, 1, CHARINDEX (',', PropertyAddress)-1) as Address, 
SUBSTRING (PropertyAddress, CHARINDEX (',', PropertyAddress)+1, LEN(PropertyAddress)) as City
from NashvilleHousing

-- Insert new column for Address And City, execute one at a time
ALTER TABLE NashvilleHousing
ADD PropriertySplitAddress nvarchar (255);

Update NashvilleHousing
SET PropriertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX (',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropriertySplitCity nvarchar (255);

Update NashvilleHousing
SET PropriertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX (',', PropertyAddress)+1, LEN(PropertyAddress))

Select PropriertySplitAddress, PropriertySplitCity
from NashvilleHousing




-- Alternative way to do the job illustrated with Owner Address WIth Parse Name

Select OwnerAddress
from NashvilleHousing

-- PARSENAME Cerca il carattere . per delimitare le parole, partendo dal fondo
Select 
PARSENAME (REPLACE (OwnerAddress, ',', '.'), 3),
PARSENAME (REPLACE (OwnerAddress, ',', '.'), 2),
PARSENAME (REPLACE (OwnerAddress, ',', '.'), 1)
From NashvilleHousing


-- Insert new column for Address And City, state execute one at a time
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar (255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME (REPLACE (OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar (255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME (REPLACE (OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar (255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME (REPLACE (OwnerAddress, ',', '.'), 1)

Select OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
from NashvilleHousing


-- Check Sold as vacant, 4 values (y, yes, n, no)

Select distinct SoldAsVacant, count (SoldAsVacant)
from NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
,	Case when SoldAsVacant = 'Y' THEN 'Yes'
		 when SoldAsVacant = 'N' THEN 'No'
		 Else SoldAsVacant
	End
from NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case when SoldAsVacant = 'Y' THEN 'Yes'
		 when SoldAsVacant = 'N' THEN 'No'
		 Else SoldAsVacant
		 End


-- Remove Duplicates and unused columns with CTE


-- Give 1 for unique, 2 or more for duplicates


WITH RowNumCTE as (
Select *,
ROW_NUMBER () OVER (
	PARTITION BY	ParcelID, 
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					Order by 
						UniqueID
						) row_number

from NashvilleHousing
) 


Select *
--Delete
from RowNumCTE
where row_number >1
--order by PropertyAddress


Select *
from NashvilleHousing



-- Delete unused columns

Select *
from NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate
