select *
from [NashVille_Housing Project]..HousingData

--------*Standarize Data Format*

select SaleDate
from [NashVille_Housing Project]..HousingData

select SaleDate, convert (Date, SaleDate) 
from [NashVille_Housing Project]..HousingData


--------*Added a new Column for the date

Alter table HousingData
Add newSaleDate date;

update HousingData
set newSaleDate= convert (Date, SaleDate)

--------*Populate Property Address Data

select *
from [NashVille_Housing Project]..HousingData
where PropertyAddress is NULL

select A.ParcelID,  A.PropertyAddress , B.ParcelID, B.PropertyAddress, isNull (A.PropertyAddress, B.PropertyAddress)
from  HousingData A
join HousingData B
	ON A.ParcelID= B.ParcelID
	and A.[UniqueID ]<> B.[UniqueID ]
	where A.PropertyAddress is Null 


update A
set PropertyAddress = isNull (A.PropertyAddress, B.PropertyAddress)
from  HousingData A
join HousingData B
	ON A.ParcelID= B.ParcelID
	and A.[UniqueID ]<> B.[UniqueID ]
	where A.PropertyAddress is Null 

--------*Breaking Out Address into individual columns (Address, city, State) 

Select PropertyAddress
from HousingData


Select
SUBSTRING (PropertyAddress, 1, charindex (',', PropertyAddress) -1) as Address
, SUBSTRING (PropertyAddress, charindex (',', PropertyAddress) +1, len (PropertyAddress)) as Address
from HousingData


Alter Table HousingData
add PropertySplitAddress nvarchar(255);

update HousingData
set PropertySplitAddress= SUBSTRING (PropertyAddress, 1, charindex (',', PropertyAddress) -1)


Alter Table HousingData
add PropertySplitCity nvarchar(255);

update HousingData
set PropertySplitCity=  SUBSTRING (PropertyAddress, charindex (',', PropertyAddress) +1, len (PropertyAddress))

select *
from [NashVille_Housing Project]..HousingData

--------*THE SECOND WAY TO SPLIT

--------Select 
--------Parsename (Replace (PropertyAddress, ',', '.'), 2)
--------,Parsename (Replace (PropertyAddress, ',', '.'), 1)
--------from HousingData


--------*Splitting Owner Address Using Parsename

Select 
Parsename (replace (OwnerAddress, ',', '.'), 3) As splitAddress
,Parsename (replace (OwnerAddress, ',', '.'), 2) As splitCity 
,Parsename (replace (OwnerAddress, ',', '.') ,1) As splitState
from HousingData


Alter Table HousingData
add SplitOwnerAddress nvarchar(255);

update HousingData
set SplitOwnerAddress= Parsename (replace (OwnerAddress, ',', '.'), 3)


Alter Table HousingData
add SplitOwnerCity nvarchar(255);

update HousingData
set SplitOwnerCity=  Parsename (replace (OwnerAddress, ',', '.'), 2)

Alter Table HousingData
add  SplitOwnerState nvarchar(255);

update HousingData
set  SplitOwnerState=  Parsename (replace (OwnerAddress, ',', '.') ,1)


--------*Change Y and N to Yes And No in SoldAsVacant Field

Select distinct(SoldAsVacant), count (SoldAsVacant)
from HousingData
group by SoldAsVacant
order by 2

Select SoldAsVacant
, Case when SoldAsVacant= 'Y' then 'Yes'
	when SoldAsVacant= 'N' then 'No'
	Else SoldAsVacant
	end
	from HousingData

Update HousingData
set SoldAsVacant = Case when SoldAsVacant= 'Y' then 'Yes'
	when SoldAsVacant= 'N' then 'No'
	Else SoldAsVacant
	end


--------*Remove Duplicates

with rownumCTE as (
Select *,

	row_number () over(partition by ParcelID, 
				  PropertyAddress, 
				  SalePrice,
				  SaleDate, 
				  LegalReference 
				  order by UniqueID) as row_num
from HousingData
----order by ParcelID
)
delete
FROM rownumCTE
where row_num >1 
--order by PropertyAddress


--------*Delete Unused Columns

Alter table HousingData
Drop Column OwnerAddress, TaxDistrict,  PropertyAddress


Alter table HousingData
Drop Column SaleDate

select * 
from HousingData