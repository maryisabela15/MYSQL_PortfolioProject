/*
  Project 2: Data Cleaning
  Data: Nashville Housing Data for Data Cleaning
  Language: MySQL
*/

-- Explore Data
    
SELECT * 
FROM PortafolioProject.NashvilleHousing;

-- 1) Standardize Data Format

-- UPDATE PortafolioProject.NashvilleHousing
-- SET SaleDate = CONVERT(SaleDate,Date);

ALTER TABLE PortafolioProject.NashvilleHousing
ADD SaleDateConverted Date;

UPDATE PortafolioProject.NashvilleHousing
SET SaleDateConverted = CONVERT(SaleDate,Date);

SELECT SaleDateConverted, CONVERT(SaleDate,Date)
FROM PortafolioProject.NashvilleHousing;

-- --------------------------------------------------

-- Populated Property Address Data
-- There are some NULL values in Property Address
-- Self Join to see where are the NULL Values

SELECT *
FROM PortafolioProject.NashvilleHousing;

SELECT Tab1.ParcelID, Tab1.PropertyAddress, Tab2.ParcelID, Tab2.PropertyAddress,
	   IFNULL(Tab1.PropertyAddress, Tab2.PropertyAddress)
FROM PortafolioProject.NashvilleHousing AS Tab1
JOIN PortafolioProject.NashvilleHousing AS Tab2
     ON Tab1.ParcelID = Tab2.ParcelID
     AND Tab1.UniqueID <> Tab2.UniqueID  
WHERE Tab1.PropertyAddress IS NULL;     

-- Update the NULL values with the real values

UPDATE PortafolioProject.NashvilleHousing AS Tab1
JOIN PortafolioProject.NashvilleHousing AS Tab2
     ON Tab1.ParcelID = Tab2.ParcelID
     AND Tab1.UniqueID <> Tab2.UniqueID
SET Tab1.PropertyAddress =  IFNULL(Tab1.PropertyAddress, Tab2.PropertyAddress)
WHERE Tab1.PropertyAddress IS NULL;     

-- -----------------------------------------------------------------------

-- Separate Property Address into different columns
-- I use SUBSTRING and LOCATE Functions to separate substrings

 SELECT PropertyAddress
 FROM PortafolioProject.NashvilleHousing;
 
SELECT
SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress)+1, LENGTH(PropertyAddress)) AS City
FROM PortafolioProject.NashvilleHousing;
 
 -- Create two new columns to add Address and City 
 
ALTER TABLE PortafolioProject.NashvilleHousing
ADD Address nvarchar(255);

UPDATE PortafolioProject.NashvilleHousing
SET Address = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress)-1);

ALTER TABLE PortafolioProject.NashvilleHousing
ADD City nvarchar(255);

UPDATE PortafolioProject.NashvilleHousing
SET City = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress)+1, LENGTH(PropertyAddress));

SELECT PropertyAddress, Address, City
FROM PortafolioProject.NashvilleHousing;

-- ----------------------------------------------
-- Separate Owners Address into different columns
-- I use SUSTRING_INDEX Function

SELECT OwnerAddress
FROM PortafolioProject.NashvilleHousing;

SELECT
SUBSTRING_INDEX(OwnerAddress, ',',1) AS Address,
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',',2),',',-1) AS City,
SUBSTRING_INDEX(OwnerAddress, ',',-1) AS State
FROM PortafolioProject.NashvilleHousing;     

 -- Create three new columns to add Address, City, and State
 
ALTER TABLE PortafolioProject.NashvilleHousing
ADD OwnerAddress2 nvarchar(255);

UPDATE PortafolioProject.NashvilleHousing
SET OwnerAddress2 = SUBSTRING_INDEX(OwnerAddress, ',',1);

ALTER TABLE PortafolioProject.NashvilleHousing
ADD OwnerCity nvarchar(255);

UPDATE PortafolioProject.NashvilleHousing
SET OwnerCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',',2),',',-1);

ALTER TABLE PortafolioProject.NashvilleHousing
ADD OwnerState nvarchar(255);

UPDATE PortafolioProject.NashvilleHousing
SET OwnerState = SUBSTRING_INDEX(OwnerAddress, ',',-1);	

SELECT OwnerAddress, OwnerAddress2, OwnerCity, OwnerState
FROM PortafolioProject.NashvilleHousing;

-- ---------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as vacant" field

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM PortafolioProject.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldASVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
	END
FROM PortafolioProject.NashvilleHousing;

-- Update the column with the new values

UPDATE PortafolioProject.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
                        WHEN SoldAsVacant = 'N' THEN 'No'
                        ELSE SoldAsVacant
			       END;
                        
-- -----------------------------------------------------------      
                  
 -- Remove Duplicate values   
 -- I use the ROW_NUMBER Function to search the duplicate values

 
SELECT *
FROM PortafolioProject.NashvilleHousing;

-- Search duplicate values

SELECT *
FROM (
	SELECT *,
		ROW_NUMBER() OVER (PARTITION BY ParcelID, 
							    PropertyAddress, 
                                SalePrice, 
                                SaleDate, 
                                LegalReference
                   ORDER BY UniqueID) RowNumber
FROM PortafolioProject.NashvilleHousing
) Tab1
WHERE RowNumber > 1;

-- Delete duplicate values

DELETE FROM PortafolioProject.NashvilleHousing 
WHERE 
	UniqueID IN (
	SELECT 
		UniqueID 
	FROM (
		SELECT *,
		ROW_NUMBER() OVER (PARTITION BY ParcelID, 
							    PropertyAddress, 
                                SalePrice, 
                                SaleDate, 
                                LegalReference
                   ORDER BY UniqueID) RowNumber
FROM PortafolioProject.NashvilleHousing
) Tab1
    WHERE RowNumber > 1
);

                   
-- ------------------------------------------------------------------------------

-- Remove unwanted columns

SELECT *
FROM PortafolioProject.NashvilleHousing;

ALTER TABLE  PortafolioProject.NashvilleHousing
DROP COLUMN PropertyAddress;

ALTER TABLE  PortafolioProject.NashvilleHousing
DROP COLUMN OwnerAddress;

