-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 02, 2024 at 09:17 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `registration`
--

-- --------------------------------------------------------

--
-- Table structure for table `comment`
--

CREATE TABLE `comment` (
  `com_id` int(11) NOT NULL,
  `com_text` varchar(255) NOT NULL,
  `com_like` int(11) NOT NULL,
  `com_dislike` int(11) NOT NULL,
  `com_time` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `com_user_id` int(11) NOT NULL,
  `post_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `comment`
--

INSERT INTO `comment` (`com_id`, `com_text`, `com_like`, `com_dislike`, `com_time`, `com_user_id`, `post_id`) VALUES
(1, 'Their work is very much impressive.Hope You like it a Lot.', 0, 0, '2024-09-28 17:13:20', 225, 517),
(2, 'Yes, I want to buy this one.', 0, 0, '2024-09-28 17:15:14', 220, 517),
(4, 'Hope to see you soon and feel better for you.', 0, 0, '2024-09-28 17:16:25', 211, 517),
(5, 'Yes you will get soon.', 0, 0, '2024-09-28 17:17:28', 225, 517),
(6, 'thanks Everyone', 0, 0, '2024-10-02 18:46:03', 550, 517),
(7, 'good night', 0, 0, '2024-10-02 18:51:11', 550, 517);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `comment`
--
ALTER TABLE `comment`
  ADD PRIMARY KEY (`com_id`),
  ADD KEY `com_user_id` (`com_user_id`),
  ADD KEY `post_id` (`post_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `comment`
--
ALTER TABLE `comment`
  MODIFY `com_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `comment`
--
ALTER TABLE `comment`
  ADD CONSTRAINT `comment_ibfk_1` FOREIGN KEY (`com_user_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `comment_ibfk_2` FOREIGN KEY (`post_id`) REFERENCES `post` (`post_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
