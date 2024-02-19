/*

Cleaning Data in SQL Queries

*/

SELECT * 
FROM PortfolioProjects.dbo.NashvilleHousing


------------------------------------------------------->


-- Standardize Date Format [Removing time stamp]

SELECT SaleDate, CONVERT(DATE,SaleDate)
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(DATE,SaleDate)


-- alternative (if Update not work)
-- Creating a New Column [SaleDateConverted] dtype = date

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)


---------------------------------------------------------->


-- Populate Property Address data

SELECT *
FROM PortfolioProjects..NashvilleHousing
-- WHERE PropertyAddress IS NULL
ORDER BY ParcelID                     -- We saw few ParcelId same with same address


-- Populating Property Address

-- Since UniqueID is diffrent so we check if ParcelId is same and UniqueID is different then populate

SELECT a.ParcelID,a.PropertyAddress, b.ParcelID, b.PropertyAddress
,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProjects.dbo.NashvilleHousing a
JOIN PortfolioProjects.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND A.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProjects.dbo.NashvilleHousing a
JOIN PortfolioProjects.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND A.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


--------------------------------------------------------------------->


-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProjects..NashvilleHousing

-- Seperating Address And City from ParcelAddress

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) AS City
FROM PortfolioProjects..NashvilleHousing


-- Crating 2 Column to Add seperated Address and City


-- PropertySplitAddress column will get Address

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);


-- updating PropertySplitAddress

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)



-- PropertySplitCity column will get City

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);


-- updating PropertySplitCity

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))




----------------------------------------------------------------------------------------------------------------------->




-- Extracting (Address, City, State) from OwnerAddress

SELECT OwnerAddress
FROM PortfolioProjects..NashvilleHousing


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProjects..NashvilleHousing


-- Adding  OwnerSplitAddress Column

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);


-- Updating OwnerSplitAddress Column

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)




-- Adding  OwnerSplitCity Column

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);


-- Updating OwnerSplitCity Column

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)



-- Adding  OwnerSplitState Column

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);


-- Updating OwnerSplitState Column

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



--------------------------------------------------------------------------------------------------->


-- Change Y and N to Yes and No in "Sold as Vacant" field


-- Showing How Many Mix Input We Got

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProjects.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2



-- Changing To Yes No

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM PortfolioProjects..NashvilleHousing


-- Updating 

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END



---------------------------------------------------------------------------------->

-- Remove Duplicate Data

WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
			     PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) ROW_NUM
FROM PortfolioProjects..NashvilleHousing
--ORDER BY ParcelID
)
SELECT *               -- DELETE
FROM RowNumCTE
WHERE ROW_NUM > 1
ORDER BY PropertyAddress    -- Have to comment when use Delete



----------------------------------------------------------------------------------->

-- Delete Unused Column

SELECT *
FROM PortfolioProjects..NashvilleHousing

-- Deleting 1 Column

ALTER TABLE PortfolioProjects..NashvilleHousing
DROP COLUMN SaleDate


-- Deleting Multiple Column

ALTER TABLE PortfolioProjects..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

