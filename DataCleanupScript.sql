 /*
 Cleaning data in SQL Queries
 */
Select * 
From portfolio..NashvilleHousing
--------------------------------------------------------------------------------------------------------------

--Standardize Sale Date Format 

Select SaleDateConverted,CONVERT(Date,SaleDate)
From portfolio..NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


--------------------------------------------------------------------------------------------------------------

-- Populate Property Address data 

Select *
From portfolio..NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From portfolio..NashvilleHousing a
Join portfolio..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From portfolio..NashvilleHousing a
Join portfolio..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------

-- Breaking out the address into individual columns (address, city, state)

Select PropertyAddress
From portfolio..NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))
From portfolio..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))



Select OwnerAddress
From portfolio..NashvilleHousing

Select
PARSENAME(Replace(OwnerAddress,',','.') , 3),
PARSENAME(Replace(OwnerAddress,',','.') , 2),
PARSENAME(Replace(OwnerAddress,',','.') , 1)
From portfolio..NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);
Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.') , 3)



ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);
Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.') , 1)
--------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" Field 

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From portfolio..NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   END
From portfolio..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   END
--------------------------------------------------------------------------------------------------------------

--Removing Duplicates

WITH  RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 Saledate,
				 LegalReference
				 Order BY
					UniqueID
					) row_num
From portfolio..NashvilleHousing
--Order by ParcelID
)
--Delete
Select * 
from RowNumCTE
Where row_num > 1
--Order by PropertyAddress

--------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns
Select *  
From portfolio..NashvilleHousing

ALTER TABLE portfolio..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress,SaleDate



