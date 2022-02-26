

Select *
From wrkspc.dbo.NashvilleHousing

--Standardize Date Format-------------------------------------------------------------------------------------------------------------- 

Select SaleDateConvert, CONVERT(Date,Saledate)
From wrkspc.dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = Convert(Date,SaleDate)


Alter Table NashvilleHousing
Add SaleDateConvert Date; 

Update NashvilleHousing
Set SaleDateConvert = Convert(Date,SaleDate)


--Populating Property Address data by removing null columns-----------------------------------------------------------------------------

Select * 
From wrkspc.dbo.NashvilleHousing
order by ParcelID

Select a.ParcelId, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From wrkspc.dbo.NashvilleHousing a
Join wrkspc.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

Update a 
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From wrkspc.dbo.NashvilleHousing a
Join wrkspc.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

--Dividing Property Address into (Address and City)------------------------------------------------------------------------------- 

Select * 
From wrkspc.dbo.NashvilleHousing
--order by ParcelID

Select Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address
, Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From wrkspc.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add PAddress Nvarchar(255)

Update NashvilleHousing
Set PAddress = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

Alter Table NashvilleHousing
Add PACity Nvarchar(255); 

Update NashvilleHousing
Set PACity = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


Select * 
From wrkspc.dbo.NashvilleHousing

--Dividing Owner Address into (Address, City, State)------------------------------------------------------------------------------- 

Select OwnerAddress
From wrkspc.dbo.NashvilleHousing

Select 
Parsename(Replace(OwnerAddress, ',', '.') ,3)
,Parsename(Replace(OwnerAddress, ',', '.') ,2)
,Parsename(Replace(OwnerAddress, ',', '.') ,1)
From wrkspc.dbo.NashvilleHousing


Alter Table NashvilleHousing
Add OAddress Nvarchar(255)

Update NashvilleHousing
Set OAddress = Parsename(Replace(OwnerAddress, ',', '.') ,3)


Alter Table NashvilleHousing
Add OwnerCityAddress Nvarchar(255); 

Update NashvilleHousing
Set OwnerCityAddress = Parsename(Replace(OwnerAddress, ',', '.') ,2)


Alter Table NashvilleHousing
Add OwnerStateAddress Nvarchar(255); 

Update NashvilleHousing
Set OwnerStateAddress = Parsename(Replace(OwnerAddress, ',', '.') ,1)


Select * 
From wrkspc.dbo.NashvilleHousing


--Change Y and N to Yes and no for "Sold as Vacant" field---------------------------------------------------------------------------------

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From wrkspc.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, Case when SoldAsVacant = 'Y' Then 'Yes'
	   when SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End
From wrkspc.dbo.NashvilleHousing


Update NashvilleHousing  	
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End

--Remove Duplicates---------------------------------------

With RowNumCTE As(
Select *, Row_Number() Over(Partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference 
						Order by UniqueID)row_num 
From wrkspc.dbo.NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1 
Order by PropertyAddress

Select* From wrkspc.dbo.NashvilleHousing



--Delete Columns not used---------------------------------------------------------------------------------------
Select* 
From wrkspc.dbo.NashvilleHousing

Alter Table wrkspc.dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
