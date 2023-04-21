-- Cleaning Data in SQL Queries

select *
from nashvillehousing


-- Standardize Data Format --

select saledate, CONVERT(date,saledate)
from nashvillehousing

Update nashvillehousing
SET Saledate = CONVERT(Date,SaleDate)

ALTER TABLE nashvillehousing
add saledateconverted date;


-- Populate Property Address data --

select *
from nashvillehousing
--where propertyaddress is NULL
order by parcelid

select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, NVL(a.propertyaddress,b.propertyaddress)
from nashvillehousing a
JOIN nashvillehousing b
    on a.parcelid = b.parcelid and a.uniqueid_ <> b.uniqueid_
where a.propertyaddress is NULL    


UPDATE nashvillehousing n
    SET propertyaddress = (SELECT n2.propertyaddress
                           FROM nashvillehousing n2
                           WHERE n2.parcelid = n.parcelid AND
                                 n2.uniqueid_ <> n.uniqueid_ AND
                                 rownum = 1
                          )
    WHERE n.propertyaddress IS NULL AND
          EXISTS (SELECT n2.propertyaddress
                  FROM nashvillehousing n2
                  WHERE n2.parcelid = n.parcelid AND
                        n2.uniqueid_ <> n.uniqueid_
                 );
                 

-- Breaking out Address into individual columns (Address, city, state) --

select propertyaddress
from nashvillehousing

select
substr(propertyaddress, 0, instr(propertyaddress, ',')-1) as Address, 
substr(propertyaddress, instr(propertyaddress, ',')+1) as City
from nashvillehousing


ALTER TABLE nashvillehousing
Add PropertySplitAddress varchar(255);

UPDATE nashvillehousing
set PropertySplitAddress = substr(propertyaddress, 0, instr(propertyaddress, ',')-1)


ALTER TABLE nashvillehousing
Add PropertySplitCity varchar(255);

UPDATE nashvillehousing
set PropertySplitCity = substr(propertyaddress, instr(propertyaddress, ',')+1)


select owneraddress
from nashvillehousing


SELECT  REGEXP_SUBSTR (owneraddress, ('^[A-Z 0-9]+,*?'), 1) as Address
, SUBSTR(REGEXP_SUBSTR (owneraddress, (',.[A-Z]+')), 3) as City
, SUBSTR(REGEXP_SUBSTR (owneraddress, (',.[A-Z]+*$')), 3) as State
from nashvillehousing


ALTER TABLE nashvillehousing
Add OwnerSplitAddress varchar(255);

UPDATE nashvillehousing
set OwnerSplitAddress = REGEXP_SUBSTR (owneraddress, ('^[A-Z 0-9]+,*?'), 1)


ALTER TABLE nashvillehousing
Add OwnerSplitCity varchar(255);

UPDATE nashvillehousing
set OwnerSplitCity = SUBSTR(REGEXP_SUBSTR (owneraddress, (',.[A-Z]+')), 3)


ALTER TABLE nashvillehousing
Add OwnerSplitState varchar(255);

UPDATE nashvillehousing
set OwnerSplitState = SUBSTR(REGEXP_SUBSTR (owneraddress, (',.[A-Z]+*$')), 3)

select *
from nashvillehousing


-- Change Y and N to Yes and No in "Sold as Vacant" field --

select distinct(soldasvacant), count(soldasvacant)  
from nashvillehousing
group by soldasvacant
order by 2

select soldasvacant
, CASE when soldasvacant = 'Y' Then 'Yes'
       when soldasvacant = 'N' Then 'No'
       Else soldasvacant
       End
from nashvillehousing

update nashvillehousing
SET soldasvacant = CASE when soldasvacant = 'Y' Then 'Yes'
       when soldasvacant = 'N' Then 'No'
       Else soldasvacant
       End


-- Remove Duplicates --


WITH RowNumCTE as(
select *,
        ROW_NUMBER () OVER(
        PARTITION BY parcelid, 
                  propertyaddress, 
                  saleprice, 
                  saledate, 
                  legalreference
                  ORDER BY 
                        uniqueId_
                        ) row_num
from nashvillehousing
)
Select *
from RowNumCTE


DELETE FROM nashvillehousing
WHERE rowid not in
(SELECT MIN(rowid)
FROM nashvillehousing
GROUP BY parcelid, propertyaddress, saleprice, saledate, legalreference);


-- Delete Unused Columns --

select *
from nashvillehousing

alter table nashvillehousing
 DROP (owneraddress, taxdistrict, propertyaddress);

