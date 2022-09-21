use HousingData
go

-- Checking the table --

select * 
from Nashville_Housing

-- Change the date format --

select SaleDate
from Nashville_Housing


alter table Nashville_Housing
add SaleDate_Changed Date;


update Nashville_Housing
set SaleDate_Changed = convert(Date, SaleDate)


select SaleDate_Changed
from Nashville_Housing


-- Populate Property Address column --

select PropertyAddress
from Nashville_Housing
where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from Nashville_Housing a
join Nashville_Housing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set a.PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from Nashville_Housing a
join Nashville_Housing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Split Address column into individual columns (Address, City, State) --

select PropertyAddress
from Nashville_Housing


select
substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1) as Address,
substring(PropertyAddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress)) as City 
from Nashville_Housing


alter table Nashville_Housing
add PropertyAddressSplit Nvarchar(255);


update Nashville_Housing
set PropertyAddressSplit = substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1) 

alter table Nashville_Housing
add PropertyCitySplit Nvarchar(255);


update Nashville_Housing
set PropertyCitySplit = substring(PropertyAddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress)) 



-- Doing the same for the OwnerAddress but with a different way --

select OwnerAddress
from Nashville_Housing


select 
parsename(replace(OwnerAddress, ',','.'), 3),
parsename(replace(OwnerAddress, ',','.'), 2),
parsename(replace(OwnerAddress, ',','.'), 1)
from Nashville_Housing


alter table Nashville_Housing
add OwnerAddressSplit Nvarchar(255);

update Nashville_Housing
set OwnerAddressSplit = parsename(replace(OwnerAddress, ',','.'), 3)

alter table Nashville_Housing
add OwnerCitySplit Nvarchar(255);

update Nashville_Housing
set OwnerCitySplit = parsename(replace(OwnerAddress, ',','.'), 2)

alter table Nashville_Housing
add OwnerStateSplit Nvarchar(255);

update Nashville_Housing
set OwnerStateSplit = parsename(replace(OwnerAddress, ',','.'), 1)



-- Change Y and N to 'Yes' and 'No' in the SoldASVacant column --

select distinct(SoldAsVacant)
from Nashville_Housing


update Nashville_Housing
set SoldAsVacant = case 
	when SoldAsVacant = 'N' then 'No'
	when SoldAsVacant = 'Y' then 'Yes'
	else SoldAsVacant 
end 
from Nashville_Housing


-- Remove Duplicates --

with row_num_cte as (
select *,
row_number ()
over (
partition by ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
order by UniqueID
) row_num
from Nashville_Housing
)


delete 
from row_num_cte
where row_num > 1



-- Delete uneccessary columns --

alter table Nashville_Housing
drop column PropertyAddress, TaxDistrict, OwnerAddress, SaleDate
