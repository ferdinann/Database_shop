-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3309
-- Waktu pembuatan: 04 Jan 2025 pada 05.41
-- Versi server: 10.4.32-MariaDB
-- Versi PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `shop`
--

DELIMITER $$
--
-- Prosedur
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `CalculateCustomerPoint` (IN `Customer_Name` VARCHAR(255))   BEGIN
DECLARE Total_Spending BIGINT;

SET Total_Spending = (SELECT SUM(TotalPrice) FROM TrTransaction a JOIN TrCustomer b ON a.IDCustomer = b.IDCustomer WHERE Name = Customer_Name GROUP BY a.IDCustomer);

SELECT CASE
  WHEN Total_Spending < 100000 OR Total_Spending IS NULL THEN 0
  WHEN Total_Spending >= 100000 AND Total_Spending < 500000 THEN 20
  WHEN Total_Spending >= 500000 AND Total_Spending < 1000000 THEN 50 -- <= 999999
  ELSE 100
END AS Point;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CountProductInCustomerCart` (IN `Name` VARCHAR(255))   BEGIN
    SELECT b.Name, COALESCE(a.CountCustomer, 0) AS 'Count Customer'
    FROM (
        SELECT IDProduct, COUNT(IDCustomer) AS CountCustomer
        FROM TrCart
        GROUP BY IDProduct
    ) a
    RIGHT JOIN MsProduct b ON a.IDProduct = b.IDProduct
    WHERE b.Name = Name;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAverageReviewByProductName` (IN `Input_param` VARCHAR(255))   BEGIN
    SELECT b.Name as 'Product Name', AVG(a.Star) as 'Average Review Star'
    FROM TrReview a
    JOIN MsProduct b ON a.IDProduct = b.IDProduct
    WHERE b.Name = Input_param
    GROUP BY b.Name;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetTotalStockAndSoldProduct` ()   BEGIN
    SELECT b.IDProduct, b.IDShop, b.Name, b.Price, (b.Stock + a.TotalQty) AS 'Total Stock + Sold'
    FROM (
        SELECT IDProduct, COALESCE(SUM(Qty), 0) AS TotalQty -- NULL
        FROM TrTransaction
        GROUP BY IDProduct
    ) a
    JOIN MsProduct b ON a.IDProduct = b.IDProduct;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Search_Product` (IN `Input_param` VARCHAR(255))   BEGIN
    SELECT b.Name as 'Shop Name', a.IDProduct as 'Product ID', a.Name as 'Product Name', a.Stock, a.Price
    FROM MsProduct a
    JOIN TrShop b ON a.idshop = b.IDShop
    WHERE a.Name = Input_param;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Search_Shop` (IN `Input_param` VARCHAR(255))   BEGIN
    SELECT * FROM TrShop
    WHERE Name LIKE concat('%', Input_param, '%') OR 
    Owner LIKE concat('%', Input_param, '%');
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `msproduct`
--

CREATE TABLE `msproduct` (
  `IDProduct` int(11) NOT NULL,
  `IDShop` varchar(6) DEFAULT NULL,
  `Name` varchar(50) NOT NULL,
  `Stock` int(11) NOT NULL,
  `Price` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `msproduct`
--

INSERT INTO `msproduct` (`IDProduct`, `IDShop`, `Name`, `Stock`, `Price`) VALUES
(1, 'SH145N', 'Fidget Spinner', 110, 49000),
(2, 'SH145N', 'Fidget Box', 78, 39000),
(3, 'SH145N', 'Slime', 40, 12000),
(4, 'SH145N', 'Lego', 103, 56000),
(5, 'SH145N', 'Gundam Master Grade', 5, 405000),
(6, 'SH223Y', 'Computer', 5, 5000000),
(7, 'SH223Y', 'VGA', 26, 1000000),
(8, 'SH223Y', 'Mouse', 98, 340000),
(9, 'SH223Y', 'Keyboard', 63, 760000),
(10, 'SH223Y', 'Earphone', 120, 120000),
(11, 'SH359Y', 'Soap', 50, 5000),
(12, 'SH359Y', 'Shampoo', 45, 21000),
(13, 'SH359Y', 'Tooth Brush', 81, 140000),
(14, 'SH359Y', 'Tooth Paste', 20, 21000),
(15, 'SH359Y', 'Hair Conditioner', 30, 58000),
(16, 'SH483N', 'Guitar', 70, 550000),
(17, 'SH483N', 'Violin', 30, 450000),
(18, 'SH483N', 'Piano', 8, 1250000),
(19, 'SH483N', 'Drum', 5, 2600000),
(20, 'SH483N', 'Flute', 120, 55000),
(21, 'SH592Y', 'Chair', 25, 800000),
(22, 'SH592Y', 'Table', 14, 975000),
(23, 'SH592Y', 'Cupboard', 10, 1300000),
(24, 'SH592Y', 'Trash Can', 43, 23000),
(25, 'SH592Y', 'Door', 18, 600000),
(26, 'SH673N', 'Book', 30, 5000),
(27, 'SH673N', 'Paper', 100, 1000),
(28, 'SH673N', 'Pen', 20, 3000),
(29, 'SH673N', 'Pencil', 27, 2500),
(30, 'SH673N', 'Eraser', 25, 7500),
(31, 'SH778N', 'Racket', 15, 540000),
(32, 'SH778N', 'Jersey', 55, 450000),
(33, 'SH778N', 'Headband', 30, 35000),
(34, 'SH778N', 'Shoes', 7, 510000),
(35, 'SH778N', 'Socks', 12, 10000),
(36, 'SH832N', 'T-Shirt', 8, 340000),
(37, 'SH832N', 'Shirt', 15, 185000),
(38, 'SH832N', 'Trousers', 7, 380000),
(39, 'SH832N', 'Tie', 19, 60000),
(40, 'SH832N', 'Jacket', 5, 280000),
(41, 'SH912Y', 'Plate', 38, 40000),
(42, 'SH912Y', 'Fork', 60, 4000),
(43, 'SH912Y', 'Spoon', 54, 4500),
(44, 'SH912Y', 'Bowl', 25, 34000),
(45, 'SH912Y', 'Chopsticks', 56, 4000),
(46, 'SH102Y', 'Doll', 20, 140000),
(47, 'SH102Y', 'Balloon', 23, 9000),
(48, 'SH102Y', 'Key Chain', 50, 12000),
(49, 'SH102Y', 'Hand Bouquet', 35, 89000),
(50, 'SH102Y', 'Pillow', 43, 67000);

-- --------------------------------------------------------

--
-- Struktur dari tabel `trcart`
--

CREATE TABLE `trcart` (
  `IDCart` int(11) NOT NULL,
  `IDProduct` int(11) DEFAULT NULL,
  `IDCustomer` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `trcart`
--

INSERT INTO `trcart` (`IDCart`, `IDProduct`, `IDCustomer`) VALUES
(1, 1, 1),
(2, 3, 1),
(3, 4, 1),
(4, 5, 1),
(5, 7, 1),
(6, 12, 1),
(7, 33, 1),
(8, 44, 1),
(9, 25, 1),
(10, 17, 1),
(11, 21, 2),
(12, 33, 2),
(13, 45, 2),
(14, 50, 2),
(15, 37, 2),
(16, 31, 2),
(17, 32, 2),
(18, 45, 2),
(19, 50, 2),
(20, 37, 2),
(21, 23, 3),
(22, 13, 3),
(23, 25, 3),
(24, 40, 3),
(25, 36, 3),
(26, 21, 3),
(27, 33, 3),
(28, 45, 3),
(29, 50, 3),
(30, 37, 3),
(31, 25, 4),
(32, 38, 4),
(33, 47, 4),
(34, 50, 4),
(35, 32, 4),
(36, 21, 4),
(37, 31, 4),
(38, 41, 4),
(39, 45, 4),
(40, 33, 4),
(41, 1, 5),
(42, 13, 5),
(43, 25, 5),
(44, 30, 5),
(45, 47, 5),
(46, 50, 5),
(47, 23, 5),
(48, 15, 5),
(49, 10, 5),
(50, 17, 5),
(51, 11, 6),
(52, 23, 6),
(53, 35, 6),
(54, 40, 6),
(55, 50, 6),
(56, 29, 6),
(57, 38, 6),
(58, 47, 6),
(59, 16, 6),
(60, 31, 6),
(61, 11, 7),
(62, 12, 7),
(63, 13, 7),
(64, 14, 7),
(65, 15, 7),
(66, 16, 7),
(67, 17, 7),
(68, 18, 7),
(69, 19, 7),
(70, 20, 7),
(71, 21, 8),
(72, 33, 8),
(73, 25, 8),
(74, 30, 8),
(75, 47, 8),
(76, 11, 8),
(77, 23, 8),
(78, 15, 8),
(79, 10, 8),
(80, 27, 8),
(81, 21, 9),
(82, 22, 9),
(83, 23, 9),
(84, 24, 9),
(85, 25, 9),
(86, 26, 9),
(87, 27, 9),
(88, 28, 9),
(89, 29, 9),
(90, 30, 9),
(91, 31, 10),
(92, 32, 10),
(93, 33, 10),
(94, 34, 10),
(95, 35, 10),
(96, 36, 10),
(97, 37, 10),
(98, 38, 10),
(99, 39, 10),
(100, 40, 10);

-- --------------------------------------------------------

--
-- Struktur dari tabel `trcustomer`
--

CREATE TABLE `trcustomer` (
  `IDCustomer` int(11) NOT NULL,
  `Name` varchar(50) NOT NULL,
  `PhoneNumber` varchar(20) DEFAULT NULL,
  `Email` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `trcustomer`
--

INSERT INTO `trcustomer` (`IDCustomer`, `Name`, `PhoneNumber`, `Email`) VALUES
(1, 'Christiana Willis Cockle', '202-555-0106', 'christiana@email.com'),
(2, 'James Butterscotch', '202-555-0174', 'james@email.com'),
(3, 'Suzanne Jones Greenway', '202-555-0102', 'suzanne@email.com'),
(4, 'Morwenna Doop', '202-555-0170', 'morwenna@email.com'),
(5, 'Beth Giantbulb Barlow', '202-555-0140', 'beth@email.com'),
(6, 'Morwenna Doop', '202-555-0160', 'morwenna@email.com'),
(7, 'Jeff Ferguson Platt', '202-555-0120', 'jeff@email.com'),
(8, 'Jenna Thornhill', '202-555-01900', 'jenna@email.com'),
(9, 'Charlotte Donaldson Hemingway', '202-555-0270', 'charlotte@email.com'),
(10, 'Steven Smith', '202-555-0820', 'steven@email.com');

-- --------------------------------------------------------

--
-- Struktur dari tabel `trreview`
--

CREATE TABLE `trreview` (
  `IDReview` int(11) NOT NULL,
  `IDProduct` int(11) DEFAULT NULL,
  `Comment` varchar(50) DEFAULT NULL,
  `Star` int(11) NOT NULL
) ;

--
-- Dumping data untuk tabel `trreview`
--

INSERT INTO `trreview` (`IDReview`, `IDProduct`, `Comment`, `Star`) VALUES
(1, 1, 'Good', 5),
(2, 1, 'Nice', 4),
(3, 2, 'I dont like it', 2),
(4, 2, 'Best product', 5),
(5, 3, 'Not really..', 3),
(6, 3, 'Never buy this item again', 1),
(7, 4, 'Good job', 5),
(8, 4, 'Awesome', 5),
(9, 5, 'Terrible', 2),
(10, 5, 'OK', 3),
(11, 6, 'Good', 5),
(12, 6, 'Nice', 4),
(13, 7, 'Best product', 5),
(14, 7, 'Not really..', 3),
(15, 8, 'Never buy this item again', 1),
(16, 8, 'Good job', 5),
(17, 9, 'Awesome', 5),
(18, 9, 'Terrible', 2),
(19, 10, 'OK', 3),
(20, 10, 'Nice', 4),
(21, 11, 'Never buy this item again', 1),
(22, 11, 'Nice', 3),
(23, 12, 'Never buy this item again', 5),
(24, 12, 'Good job', 1),
(25, 13, 'Not really..', 3),
(26, 13, 'est product', 5),
(27, 14, 'Not really..', 3),
(28, 14, 'Awesome', 4),
(29, 15, 'Terrible', 1),
(30, 15, 'OK', 3),
(31, 16, 'Good', 5),
(32, 16, 'Nice', 3),
(33, 17, 'Best product', 3),
(34, 17, 'Not really..', 3),
(35, 18, 'Awesome', 4),
(36, 18, 'Good job', 5),
(37, 19, 'Bad', 1),
(38, 19, 'Terrible', 2),
(39, 20, 'Best', 5),
(40, 20, 'Nice', 4),
(41, 21, 'Terrible', 1),
(42, 21, 'Bad', 2),
(43, 22, 'I dont like it', 3),
(44, 22, 'Thank you', 5),
(45, 23, 'Nice', 5),
(46, 23, 'Best Product', 5),
(47, 24, 'Not Really...', 2),
(48, 24, 'OK', 3),
(49, 25, 'Best', 4),
(50, 25, 'OK', 4),
(51, 26, 'So Bad', 1),
(52, 26, 'Bad', 2),
(53, 27, 'Best product', 5),
(54, 27, 'OK', 4),
(55, 28, 'Terrible', 2),
(56, 28, 'OK', 3),
(57, 29, 'Awesome', 5),
(58, 29, 'Good', 4),
(59, 30, 'OK', 3),
(60, 30, 'Nice', 4),
(61, 31, 'Terrible', 1),
(62, 31, 'Terrible', 2),
(63, 32, 'Good', 3),
(64, 32, 'Best product', 5),
(65, 33, 'Nice', 4),
(66, 33, 'Terrible', 2),
(67, 34, 'Good job', 4),
(68, 34, 'Awesome', 1),
(69, 35, 'Terrible', 2),
(70, 35, 'Terrible', 2),
(71, 36, 'Good', 3),
(72, 36, 'Nice', 4),
(73, 37, 'Best product', 5),
(74, 37, 'Not really..', 3),
(75, 38, 'Never buy this item again', 1),
(76, 38, 'Good job', 4),
(77, 39, 'Best product', 5),
(78, 39, 'Good', 3),
(79, 40, 'OK', 3),
(80, 40, 'Nice', 4),
(81, 41, 'Nice', 4),
(82, 41, 'Nice', 4),
(83, 42, 'Best product', 5),
(84, 42, 'Best product', 5),
(85, 43, 'Terrible', 1),
(86, 43, 'Never buy this item again', 2),
(87, 44, 'Not really..', 3),
(88, 44, 'Terrible', 1),
(89, 45, 'Nice', 4),
(90, 45, 'Good', 5),
(91, 46, 'Good', 5),
(92, 46, 'Nice', 4),
(93, 47, 'Nice', 4),
(94, 47, 'Not really..', 3),
(95, 48, 'Never buy this item again', 2),
(96, 48, 'Good job', 5),
(97, 49, 'Awesome', 4),
(98, 49, 'Never buy this item again', 2),
(99, 50, 'Never buy this item again', 2),
(100, 50, 'Nice', 4);

-- --------------------------------------------------------

--
-- Struktur dari tabel `trshop`
--

CREATE TABLE `trshop` (
  `IDShop` varchar(6) NOT NULL,
  `Name` varchar(50) NOT NULL,
  `Owner` varchar(50) NOT NULL,
  `isOfficial` int(11) NOT NULL,
  `Address` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `trshop`
--

INSERT INTO `trshop` (`IDShop`, `Name`, `Owner`, `isOfficial`, `Address`) VALUES
('SH102Y', 'Fushion Shop', 'Alex Fish', 1, '89068 Fir Butte Rd, Eugene, OR, 97402'),
('SH145N', 'Fortune Shop', 'Clarke Platt', 0, '204 Peed Smith Rd, Hamilton, GA, 31811'),
('SH223Y', 'Jaya Shop', 'Fred Wilson', 1, '4932 Reuter St, Dearborn, MI, 48126'),
('SH359Y', 'Surya Shop', 'Naomi Rockatansky', 1, '4971 Good Luck Rd, Aynor, SC, 29511'),
('SH483N', 'Sinar Shop', 'Jenna Vader', 0, '5401 A Tech Cir, Moorpark, CA, 93021'),
('SH592Y', 'Terang Shop', 'Mary Parkes', 1, '7120 Crestwood Ave, Jenison, MI, 49428'),
('SH673N', 'Parlor Shop', 'Sophia Willis', 0, '185 Red Maple Dr, Hampton, GA, 30228'),
('SH778N', 'Inn Shop', 'Suzanne Ball', 0, '106 Southwind Dr, Pleasant Hill, CA, 94523'),
('SH832N', 'Deli Shop', 'Alex Barker', 0, '2337 School House Rd, Fairmont, WV, 26554'),
('SH912Y', 'Buzz Shop', 'Sandie Doop', 1, '5544 East Torino, Port Saint Lucie, FL, 34986');

-- --------------------------------------------------------

--
-- Struktur dari tabel `trtransaction`
--

CREATE TABLE `trtransaction` (
  `IDTransaction` varchar(5) NOT NULL,
  `IDProduct` int(11) DEFAULT NULL,
  `IDCustomer` int(11) DEFAULT NULL,
  `TransactionDate` datetime DEFAULT NULL,
  `Qty` int(11) NOT NULL,
  `TotalPrice` bigint(20) NOT NULL,
  `Done` bit(1) NOT NULL,
  `PaymentMethod` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `trtransaction`
--

INSERT INTO `trtransaction` (`IDTransaction`, `IDProduct`, `IDCustomer`, `TransactionDate`, `Qty`, `TotalPrice`, `Done`, `PaymentMethod`) VALUES
('TR001', 1, 1, '2018-03-12 12:23:01', 2, 98000, b'0', 'Credit Card'),
('TR002', 2, 2, '2018-05-01 07:21:01', 1, 39000, b'1', 'Debit'),
('TR003', 3, 3, '2018-02-23 20:45:56', 1, 12000, b'1', 'Credit Card'),
('TR004', 4, 4, '2018-09-15 17:38:59', 1, 56000, b'1', 'Credit Card'),
('TR005', 5, 5, '2018-08-05 10:11:01', 2, 105000, b'0', 'Debit'),
('TR006', 6, 1, '2018-01-23 12:23:31', 1, 5000000, b'0', 'Debit'),
('TR007', 7, 2, '2018-02-10 17:38:41', 2, 2000000, b'1', 'Debit'),
('TR008', 8, 3, '2018-03-22 20:23:17', 3, 1020000, b'0', 'Debit'),
('TR009', 9, 4, '2018-08-27 01:38:12', 1, 760000, b'1', 'Credit Card'),
('TR010', 10, 5, '2018-10-01 10:01:51', 2, 24000, b'0', 'Debit'),
('TR011', 31, 6, '2018-12-01 18:43:56', 2, 1080000, b'1', 'Credit Card'),
('TR012', 32, 7, '2018-11-25 07:26:41', 5, 2250000, b'0', 'Debit'),
('TR013', 33, 8, '2018-10-17 23:25:26', 2, 70000, b'0', 'Debit'),
('TR014', 34, 9, '2018-09-12 21:37:59', 1, 510000, b'1', 'Credit Card'),
('TR015', 35, 6, '2018-08-08 14:31:39', 3, 30000, b'0', 'Debit'),
('TR016', 36, 6, '2018-07-24 15:24:21', 2, 680000, b'1', 'Credit Card'),
('TR017', 37, 7, '2018-05-12 18:11:51', 3, 555000, b'1', 'Debit'),
('TR018', 38, 8, '2018-03-11 11:35:26', 4, 1520000, b'1', 'Credit Card'),
('TR019', 39, 9, '2018-01-29 19:37:19', 2, 120000, b'1', 'Debit'),
('TR020', 40, 7, '2018-11-30 23:18:23', 1, 280000, b'0', 'Debit');

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `vw_creditcarddonetransaction`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `vw_creditcarddonetransaction` (
`IDTransaction` varchar(5)
,`IDProduct` int(11)
,`IDCustomer` int(11)
,`TransactionDate` datetime
,`Qty` int(11)
,`TotalPrice` bigint(20)
,`Done` bit(1)
,`PaymentMethod` varchar(50)
);

-- --------------------------------------------------------

--
-- Struktur untuk view `vw_creditcarddonetransaction`
--
DROP TABLE IF EXISTS `vw_creditcarddonetransaction`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_creditcarddonetransaction`  AS SELECT `trtransaction`.`IDTransaction` AS `IDTransaction`, `trtransaction`.`IDProduct` AS `IDProduct`, `trtransaction`.`IDCustomer` AS `IDCustomer`, `trtransaction`.`TransactionDate` AS `TransactionDate`, `trtransaction`.`Qty` AS `Qty`, `trtransaction`.`TotalPrice` AS `TotalPrice`, `trtransaction`.`Done` AS `Done`, `trtransaction`.`PaymentMethod` AS `PaymentMethod` FROM `trtransaction` WHERE `trtransaction`.`PaymentMethod` = 'Credit Card' AND `trtransaction`.`Done` = 1 ;

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `msproduct`
--
ALTER TABLE `msproduct`
  ADD PRIMARY KEY (`IDProduct`),
  ADD KEY `IDShop` (`IDShop`);

--
-- Indeks untuk tabel `trcart`
--
ALTER TABLE `trcart`
  ADD PRIMARY KEY (`IDCart`),
  ADD KEY `IDProduct` (`IDProduct`),
  ADD KEY `IDCustomer` (`IDCustomer`);

--
-- Indeks untuk tabel `trcustomer`
--
ALTER TABLE `trcustomer`
  ADD PRIMARY KEY (`IDCustomer`);

--
-- Indeks untuk tabel `trreview`
--
ALTER TABLE `trreview`
  ADD PRIMARY KEY (`IDReview`),
  ADD KEY `IDProduct` (`IDProduct`);

--
-- Indeks untuk tabel `trshop`
--
ALTER TABLE `trshop`
  ADD PRIMARY KEY (`IDShop`);

--
-- Indeks untuk tabel `trtransaction`
--
ALTER TABLE `trtransaction`
  ADD PRIMARY KEY (`IDTransaction`),
  ADD KEY `IDProduct` (`IDProduct`),
  ADD KEY `IDCustomer` (`IDCustomer`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `msproduct`
--
ALTER TABLE `msproduct`
  MODIFY `IDProduct` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=51;

--
-- AUTO_INCREMENT untuk tabel `trcart`
--
ALTER TABLE `trcart`
  MODIFY `IDCart` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=101;

--
-- AUTO_INCREMENT untuk tabel `trcustomer`
--
ALTER TABLE `trcustomer`
  MODIFY `IDCustomer` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT untuk tabel `trreview`
--
ALTER TABLE `trreview`
  MODIFY `IDReview` int(11) NOT NULL AUTO_INCREMENT;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `msproduct`
--
ALTER TABLE `msproduct`
  ADD CONSTRAINT `msproduct_ibfk_1` FOREIGN KEY (`IDShop`) REFERENCES `trshop` (`IDShop`);

--
-- Ketidakleluasaan untuk tabel `trcart`
--
ALTER TABLE `trcart`
  ADD CONSTRAINT `trcart_ibfk_1` FOREIGN KEY (`IDProduct`) REFERENCES `msproduct` (`IDProduct`),
  ADD CONSTRAINT `trcart_ibfk_2` FOREIGN KEY (`IDCustomer`) REFERENCES `trcustomer` (`IDCustomer`);

--
-- Ketidakleluasaan untuk tabel `trreview`
--
ALTER TABLE `trreview`
  ADD CONSTRAINT `trreview_ibfk_1` FOREIGN KEY (`IDProduct`) REFERENCES `msproduct` (`IDProduct`);

--
-- Ketidakleluasaan untuk tabel `trtransaction`
--
ALTER TABLE `trtransaction`
  ADD CONSTRAINT `trtransaction_ibfk_1` FOREIGN KEY (`IDProduct`) REFERENCES `msproduct` (`IDProduct`),
  ADD CONSTRAINT `trtransaction_ibfk_2` FOREIGN KEY (`IDCustomer`) REFERENCES `trcustomer` (`IDCustomer`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
