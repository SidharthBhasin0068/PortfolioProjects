--cleaning data in sql 
use PortfolioProject
select *
from [NashvilleHousing]


--standarized date format
select SaleDateConverted , CONVERT(date,SaleDate)
from [NashvilleHousing]

update NashvilleHousing
set SaleDate = CONVERT(date,SaleDate)

alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = CONVERT(date,SaleDate)

select *
from [NashvilleHousing]


--populate property address data
select *
from [NashvilleHousing]
--where PropertyAddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--breaking out address into individual columns (address,city,state)
select PropertyAddress
from NashvilleHousing


select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1 ,len(PropertyAddress)) as Address
from NashvilleHousing


alter table NashvilleHousing
add PropertySplitAddress Nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 

alter table NashvilleHousing
add PropertySplitCity Nvarchar(255);

update NashvilleHousing
set PropertySplitCity =  SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1 ,len(PropertyAddress))



select *
from NashvilleHousing


select SUBSTRING(OwnerAddress,1,CHARINDEX(',',OwnerAddress)-1) as ownersplitaddress,
SUBSTRING(OwnerAddress,CHARINDEX(',',OwnerAddress)+1 ,len(OwnerAddress)) as OwnerCity
from NashvilleHousing


select 
PARSENAME(replace(OwnerAddress , ',' ,'.'),3),
PARSENAME(replace(OwnerAddress , ',' ,'.'),2),
PARSENAME(replace(OwnerAddress , ',' ,'.'),1)

from NashvilleHousing


alter table NashvilleHousing
add OwnerSplitAddress Nvarchar(255);
update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress , ',' ,'.'),3)


alter table NashvilleHousing
add OwnerCity Nvarchar(255);
update NashvilleHousing
set OwnerCity = PARSENAME(replace(OwnerAddress , ',' ,'.'),2)



alter table NashvilleHousing
add OwnerState Nvarchar(255);
update NashvilleHousing
set OwnerState = PARSENAME(replace(OwnerAddress , ',' ,'.'),1)

select *
from NashvilleHousing




-- change y and n yo yes and no 
select distinct(SoldAsVacant),COUNT(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2





select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end



--remove duplicates
with RowNumCTE as (
select *,
	ROW_NUMBER() over(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By
					UniqueID) row_num

from NashvilleHousing
)
select *
from RowNumCTE
where row_num > 1
--order by PropertyAddress






--delete unused columns
select *
from NashvilleHousing

alter table NashvilleHousing
drop column OwnerAddress,TaxDistrict,PropertyAddress,SaleDate

alter table NashvilleHousing
drop column SaleDate