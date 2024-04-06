/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM [Portfolio project]..NashvilleHousing

-- Standardize Date format

SELECT SaleDateConverted, CONVERT(date, SaleDate)
FROM [Portfolio project]..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

-- Populate Property Address Data

SELECT *
FROM [Portfolio project]..NashvilleHousing
-- WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio project]..NashvilleHousing a
JOIN [Portfolio project]..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio project]..NashvilleHousing a
JOIN [Portfolio project]..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Breaking out Address into individual columns (Address, City, State)

SELECT PropertyAddress
FROM [Portfolio project]..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Address
FROM [Portfolio project]..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))