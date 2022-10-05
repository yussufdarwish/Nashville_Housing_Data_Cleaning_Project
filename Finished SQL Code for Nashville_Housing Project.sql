-- Populate Property Address data

SELECT *
FROM public.nashville_housing
ORDER BY parcelid;


SELECT n1.ParcelID, n1.PropertyAddress, n2.ParcelID, n2.PropertyAddress,
COALESCE(n1.PropertyAddress, n2.PropertyAddress)
FROM nashville_housing AS n1
--SELF JOIN to organize records to align properly and fill NULL values using COALESCE
INNER JOIN nashville_housing AS n2
	ON n1.parcelid = n2.parcelid
--Use this statement so the n1. values dont align with itsself...
--Only unique records will be in the same record/row
	AND n1.uniqueid <> n2.uniqueid;
	
--Updating the table with 2 SELF-JOINs in order to fill nulls in the propertyaddress column 
--with values from another column with the same parcelid, but a uniqueid being self joined 
--within each column

UPDATE nashville_housing AS n1
  SET propertyaddress = COALESCE(n1.PropertyAddress, n2.PropertyAddress)
FROM nashville_housing AS n2
WHERE n1.parcelid = n2.parcelid
  AND n1.uniqueid <> n2.uniqueid
  AND n1.propertyaddress IS NULL;

SELECT * 
FROM nashville_housing;

--Breaking out Addresses into individual columns (address, city, state) 
--from the propertyaddress column

SELECT
SPLIT_PART(propertyaddress, ',',1) AS address,
SPLIT_PART(propertyaddress, ',',2) AS city
FROM nashville_housing


--Altered and updated the table to include 2 new columns for the address and city from
--the property address column

ALTER TABLE nashville_housing
ADD property_split_address varchar;

ALTER TABLE nashville_housing
ADD split_city varchar;

UPDATE nashville_housing
SET property_split_address = SPLIT_PART(propertyaddress, ',',1);

UPDATE nashville_housing
SET split_city = SPLIT_PART(propertyaddress, ',',2);

SELECT *
FROM nashville_housing;

SELECT owneraddress
FROM nashville_housing;

SELECT
owneraddress,
split_part(owneraddress, ',', 1),
split_part(owneraddress, ',', 2),
split_part(owneraddress, ',', 3)
FROM nashville_housing;

--Altered and updated the table to include 3 new columns for the address, city, state from
--the owner address column

ALTER TABLE nashville_housing
ADD owner_split_address varchar;

ALTER TABLE nashville_housing
ADD owner_split_city varchar;

ALTER TABLE nashville_housing
ADD owner_split_state varchar;

UPDATE nashville_housing
SET owner_split_address = split_part(owneraddress, ',', 1);

UPDATE nashville_housing
SET owner_split_city = split_part(owneraddress, ',', 2);

UPDATE nashville_housing
SET owner_split_state = split_part(owneraddress, ',', 3)

SELECT *
FROM nashville_housing;


--There are multiple columns for Yes and No, that need to be combined into either 'Yes' or 'No'
SELECT DISTINCT soldasvacant, COUNT(soldasvacant)
FROM nashville_housing
GROUP BY soldasvacant
ORDER BY COUNT(soldasvacant) DESC;


--This case when statement combines 'Y' with 'Yes' and 'N' with 'No'
SELECT soldasvacant,
CASE WHEN soldasvacant = 'Y' THEN 'Yes'
WHEN soldasvacant = 'N' THEN 'No'
ELSE soldasvacant
END AS soldasvacant_updated
FROM nashville_housing

--Updated the table to have the soldasvacant column only include the 2 values of 'Yes' and 'No'

UPDATE nashville_housing
SET soldasvacant = 
CASE WHEN soldasvacant = 'Y' THEN 'Yes'
WHEN soldasvacant = 'N' THEN 'No'
ELSE soldasvacant
END;

SELECT soldasvacant, COUNT(soldasvacant)
FROM nashville_housing
GROUP BY soldasvacant
ORDER BY COUNT(soldasvacant) DESC;


--Removing Duplicate Values

SELECT *,
ROW_NUMBER() OVER(
	PARTITION BY parcelid, propertyaddress, saleprice, saledate, legalreference 
	ORDER BY uniqueid) AS row_num
FROM nashville_housing
ORDER BY row_num desc;

--Put the above query in a CTE so we can further filter it
WITH row_num_cte AS (
SELECT *,
ROW_NUMBER() OVER(
	PARTITION BY parcelid, propertyaddress, saleprice, saledate, legalreference 
	ORDER BY uniqueid) AS row_num
FROM nashville_housing)
--ORDER BY row_num desc);

--These are the rows that are duplicates and should be deleted
SELECT uniqueid 
FROM row_num_cte 
WHERE row_num > 1

--SELECT *
--FROM row_num_cte
--WHERE row_num > 1

--Same CTE  from query 133-140 but we run it alongside the DELETE syntax to remove duplicates
WITH row_num_cte AS (
SELECT *,
ROW_NUMBER() OVER(
	PARTITION BY parcelid, propertyaddress, saleprice, saledate, legalreference 
	ORDER BY uniqueid) AS row_num
FROM nashville_housing)
--ORDER BY row_num desc);

--this query along with the CTE worked
DELETE
FROM nashville_housing
WHERE uniqueid IN (SELECT uniqueid FROM row_num_cte WHERE row_num > 1);

SELECT *
FROM nashville_housing;

--Deleting unused columns
ALTER TABLE nashville_housing
DROP COLUMN owneraddress,
DROP COLUMN taxdistrict,
DROP COLUMN propertyaddress;

SELECT *
FROM nashville_housing;


