-- Cleaning Data in SQL Queries

Select *
From PortfolioProject..NashvilleHousing

-- Standadize date format

Select SaleDate, convert(date, SaleDate) 
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
Set SaleDate = convert(date, SaleDate)

 -- Above query doesn't work because the SaleDate column is of type datetime, and you cannot directly update a datetime column with a date value.
 -- Instead, you can create a new column to store the standardized date format or update the existing column by converting it to a string format that represents only the date.

Alter Table NashvilleHousing
Add SaleDateConverted Date

Update NashvilleHousing
Set SaleDateConverted = convert(date, SaleDate)

Select SaleDateConverted
From PortfolioProject..NashvilleHousing

-- Populate Property Address data

Select *
From PortfolioProject..NashvilleHousing
Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null

-- Breaking out Address into Individual Coulms (Address, City, State)

-- Split PropertyAddress into Address and City using the comma as a delimiter

Select PropertyAddress
From PortfolioProject..NashvilleHousing

Select
Substring(PropertyAddress, 1, Charindex(',', PropertyAddress)-1) as Address,
Substring(PropertyAddress, Charindex(',', PropertyAddress)+1, Len(PropertyAddress)) as City
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255)

Update NashvilleHousing
Set PropertySplitAddress = Substring(PropertyAddress, 1, Charindex(',', PropertyAddress)-1)

Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255)

Update NashvilleHousing
Set PropertySplitCity = Substring(PropertyAddress, Charindex(',', PropertyAddress)+1, Len(PropertyAddress))

Select *
From PortfolioProject..NashvilleHousing

-- Split OwnerAddress into OwnerStreetAddress, OwnerCity, OwnerState using the comma as a delimiter

Select OwnerAddress
From PortfolioProject..NashvilleHousing

Select OwnerAddress,
Substring(OwnerAddress, 1, Charindex(',', OwnerAddress)-1) as OwnerAddress,
Substring(OwnerAddress, Charindex(',', OwnerAddress)+1, Len(OwnerAddress)) as OwnerCity
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255)

Update NashvilleHousing
Set OwnerSplitAddress = Substring(OwnerAddress, 1, Charindex(',', OwnerAddress)-1)

Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255)

Update NashvilleHousing
Set OwnerSplitCity = Substring(OwnerAddress, Charindex(',', OwnerAddress)+1, Len(OwnerAddress))

Select *
From PortfolioProject..NashvilleHousing

-- Alternative option to split OwnerAddress

Select
Parsename (Replace(OwnerAddress, ',', '.'), 3)
, Parsename (Replace(OwnerAddress, ',', '.'), 2)
, Parsename (Replace(OwnerAddress, ',', '.'), 1)
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress2 nvarchar(255)

Update NashvilleHousing
Set OwnerSplitAddress2 = Parsename (Replace(OwnerAddress, ',', '.'), 3)

Alter Table NashvilleHousing
Add OwnerSplitCity2 nvarchar(255)

Update NashvilleHousing
Set OwnerSplitCity2 = Parsename (Replace(OwnerAddress, ',', '.'), 2)

Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255)

Update NashvilleHousing
Set OwnerSplitState = Parsename (Replace(OwnerAddress, ',', '.'), 1)

Select *
From PortfolioProject..NashvilleHousing

-- Change Y and N to Yes and No in "SoldAsVacant" column

Select distinct SoldAsVacant, Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2 

Select SoldAsVacant,
Case When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
End as SoldAsVacant_Cleaned
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
End

Select distinct SoldAsVacant, Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant

-- Remove duplicates

-- Find out duplicate records

With RowNumCTE as
(
Select *,
Row_number() Over(
Partition by ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 Order by UniqueID) row_num
From PortfolioProject..NashvilleHousing
)
Select *
From RowNumCTE
where row_num > 1

-- Delete duplicate records

With RowNumCTE as
(
Select *,
Row_number() Over(
Partition by ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 Order by UniqueID) row_num
From PortfolioProject..NashvilleHousing
)
Delete
From RowNumCTE
where row_num > 1

-- Delete Unused Columns

Alter Table NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Select *
From PortfolioProject..NashvilleHousing