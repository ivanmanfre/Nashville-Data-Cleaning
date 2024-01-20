-- Standardize Date Format

UPDATE nashvilleofexcel
SET "SaleDate" = CAST("SaleDate" as Date)
-- And data type
ALTER TABLE nashvilleofexcel
ALTER COLUMN "SaleDate" TYPE DATE USING "SaleDate"::DATE;

--------

-- Populate Property Address Data

SELECT a."ParcelID", a."PropertyAddress", b."ParcelID", b."PropertyAddress",
CASE
   WHEN a."PropertyAddress" = '' THEN b."PropertyAddress"  -- If empty then replace
   ELSE a."PropertyAddress"
END AS AVER
FROM nashvilleofexcel AS a
INNER JOIN nashvilleofexcel AS b
   ON a."ParcelID" = b."ParcelID"
   AND a."UniqueID" <> b."UniqueID"
WHERE a."PropertyAddress" = ''




UPDATE nashvilleofexcel a
SET "PropertyAddress" = 
  CASE
    WHEN a."PropertyAddress" = '' THEN b."PropertyAddress"
    ELSE a."PropertyAddress"
  END
FROM nashvilleofexcel b
WHERE a."ParcelID" = b."ParcelID"
  AND a."UniqueID" <> b."UniqueID"
  AND a."PropertyAddress" = '';

-------

-- Breaking out Address into individual columns (Address, City)
-- PropertyAddress

SELECT 
SUBSTRING("PropertyAddress", 1, strpos("PropertyAddress",',' )-1) AS address, -- Until the comma, then remove the comma
SUBSTRING("PropertyAddress",strpos("PropertyAddress",',' )+1) AS City
FROM nashvilleofexcel
ORDER BY "ParcelID"


ALTER TABLE nashvilleofexcel
ADD "PropertySplitAddress" varchar(255);

UPDATE nashvilleofexcel
SET "PropertySplitAddress" =SUBSTRING("PropertyAddress", 1, strpos("PropertyAddress",',' )-1)

ALTER TABLE nashvilleofexcel
ADD "PropertySplitCity" Varchar(255)

UPDATE nashvilleofexcel
SET "PropertySplitCity" =SUBSTRING("PropertyAddress",strpos("PropertyAddress",',' )+1)

--- Owner Address

SELECT
    "OwnerAddress",
    SPLIT_PART("OwnerAddress", ', ', 1) AS "OwnerAddress",
    SPLIT_PART("OwnerAddress", ', ', 2) AS "OwnerCity",
    SPLIT_PART("OwnerAddress", ', ', 3) AS "OwnerState",
FROM nashvilleofexcel;

ALTER TABLE nashvilleofexcel
ADD COLUMN "NewOwnerAddress" VARCHAR(255),
ADD COLUMN "NewOwnerCity" VARCHAR(255),
ADD COLUMN "NewOwnerState" VARCHAR(255);

UPDATE nashvilleofexcel
SET
    "NewOwnerAddress" = SPLIT_PART("OwnerAddress", ', ', 1),
    "NewOwnerCity" = SPLIT_PART("OwnerAddress", ', ', 2),
    "NewOwnerState" = SPLIT_PART("OwnerAddress", ', ', 3);

-------------------
--- Change Y and N to Yes and No in "Sold as Vacant" column fields

UPDATE nashvilleofexcel
SET "SoldAsVacant" =
  CASE
    WHEN "SoldAsVacant" = 'Y' THEN 'Yes'
    WHEN "SoldAsVacant" = 'N' THEN 'No'
    ELSE "SoldAsVacant"
END;
--------------

--- Remove Duplicates
WITH RowNumCTE AS(
SELECT *,
     ROW_NUMBER() OVER(PARTITION BY 
					   "ParcelID", 
					   "PropertyAddress",
					   "SalePrice",
					   "SaleDate", 
					   "LegalReference" -- Find duplicated rows in these columns. 
			ORDER BY "UniqueID") row_num  -- If repeated row is found then next row number is asigned
FROM nashvilleofexcel)
DELETE FROM nashvilleofexcel
USING RowNumCTE
WHERE nashvilleofexcel."ParcelID" = RowNumCTE."ParcelID" AND RowNumCTE.row_num > 1;


-------

-- Delete Unused Columns

ALTER TABLE nashvilleofexcel
DROP COLUMN "OwnerAddress",
DROP COLUMN "TaxDistrict",
DROP COLUMN "PropertyAddress";

---------
SELECT *
FROM nashvilleofexcel
ORDER BY "ParcelID"


