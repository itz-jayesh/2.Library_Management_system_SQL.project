# Library Management System using SQL Project --P2

## Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  
**Database**: `library_db`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.


## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup
![ERD](https://github.com/najirh/Library-System-Management---P2/blob/main/library_erd.png)

-- Library Management Project

create database library_management;
use library_management;

drop table if exists branch;
create table branch
	(
	 branch_id varchar(10) primary key,
	 manager_id varchar(10),
	 branch_address varchar(50),	
	 contact_no varchar(10)
	);

ALTER TABLE branch 
MODIFY contact_no VARCHAR(15);


drop table if exists employee;
create table employee
(
emp_id varchar(10) primary key,
emp_name varchar(20),
position varchar(10),
salary decimal(10,2),
branch_id varchar(10),
foreign key(branch_id) references branch(branch_id)
);

drop table if exists books;
create table books
(
isbn varchar(25) primary key,
book_title varchar(60),	
category varchar(20),
rental_price decimal(10,2),	
status varchar(10),	
author varchar(60),
publisher varchar(30)

);

drop table if exists members;
create table members
(
member_id varchar(10) primary key,	
member_name varchar(25)	,
member_address varchar(20),
reg_date date

);

drop table if exists issue_status;
create table issue_status
(
issued_id varchar(10) primary key,
issued_member_id varchar(30),
issued_book_name varchar(80),
issued_date date,
issued_book_isbn varchar(50),
issued_emp_id varchar(10),
foreign key (issued_member_id) references members(member_id),
foreign key(issued_book_isbn ) references books(isbn),
foreign key(issued_emp_id ) references employee(emp_id)
);
rename table issue_status to issued_status; 

drop table if exists return_status;
create table return_status
(
return_id varchar(10) primary key,	
issued_id varchar(10),	
return_book_name varchar(80),	
return_date date,	
return_book_isbn varchar(25),
foreign key (return_book_isbn) references books(isbn)
);
SELECT * FROM return_status;


-- Project TASK


-- ### 2. CRUD Operations


-- Task 1. Create a New Book Record
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

insert into books(isbn ,book_title,category ,rental_price ,status,author ,publisher)
values( '978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
select * from books;

-- Task 2: Update an Existing Member's Address
select * from members;
update members
set member_address = "112 mapple st"
where member_id = "C105";

-- Task 3: Delete a Record from the Issued Status Table
-- Objective: Delete the record with issued_id = 'IS104' from the issued_status table.
select * from issued_status where issued_id ="IS104";
delete from issued_status
where issued_id ="IS104";

-- Task 4: Retrieve All Books Issued by a Specific Employee
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
select * from issued_status
where issued_emp_id = 'E101';


-- Task 5: List Members Who Have Issued More Than One Book
-- Objective: Use GROUP BY to find members who have issued more than one book.
select issued_emp_id ,count(*)  
from issued_status 
group by issued_emp_id  
having count(*)>1; 


-- ### 3. CTAS (Create Table As Select)

-- Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt
select * from issued_status;
select * from books;

select
		b.isbn,
        count(ist.issued_id) as no_issue
from books as b
join issued_status as ist
on ist.issued_book_isbn = b.isbn
group by 1;

-- ### 4. Data Analysis & Findings

-- Task 7. **Retrieve All Books in a Specific Category:
SELECT * FROM books
WHERE category = 'Classic';



-- Task 8: Find Total Rental Income by Category:

select 
	b.category,
    sum(b.rental_price)
from books as b
join issued_status as ist
on ist.issued_book_isbn = b.isbn 
group by 1;

-- Task 9. **List Members Who Registered in the Last 180 Days**:
select * from members;
SELECT * FROM members
WHERE reg_date >= CURDATE() - INTERVAL 180 DAY;

-- Task 10: List Employees with Their Branch Manager's Name and their branch details**:
select * from employee;
select * from branch;
select 
e1.emp_id,
e1.emp_name,
e1.position as emp_position,
b.branch_id,
b.manager_id,
b.branch_address,
b.contact_no,
e2.emp_name as manager_name
from employee as e1
join
branch as b
on e1.branch_id = b.branch_id
join 
employee as e2
on e2.emp_id= b.manager_id

;

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold
select * from books;
create table price_greater_than7
as 
select * from books
where rental_price >7;

select * from price_greater_than7;

-- Task 12: Retrieve the List of Books Not Yet Returned

select * 
from issued_status as ist
left join return_status as rs
on ist.issued_id = rs.issued_id
where return_id is null;
    

### Advanced SQL Operations

/* Task 13: Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 30-day return period). 
-- Display the member's name, book title, issue date, and days overdue.*/

select  
 ist.issued_member_id,
 m.member_name,
 bk.book_title,
 ist.issued_date,
 datediff(curdate(),issued_date) as overdue_days
from 
issued_status as ist
join members as m
on m.member_id = ist.issued_member_id
join books as bk
on bk.isbn = ist.issued_book_isbn
left join return_status as rs
on rs.issued_id = ist.issued_id
where return_id is null
and  datediff(curdate(),issued_date)> 30
order by 1 ;

-- Task 14: Update Book Status on Return
-- Write a query to update the status of books in the books table to "available" when they are returned (based on entries in the return_status table).
DELIMITER $$

CREATE PROCEDURE add_return_records(
    IN p_return_id VARCHAR(10),
    IN p_issued_id VARCHAR(10),
    IN p_book_quality VARCHAR(10)
)
BEGIN
    DECLARE v_isbn VARCHAR(50);
    DECLARE v_book_name VARCHAR(80);

    -- Insert return record
    INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
    VALUES (p_return_id, p_issued_id, CURDATE(), p_book_quality);

    -- Fetch book ISBN and name from issued_status
    SELECT issued_book_isbn, issued_book_name
    INTO v_isbn, v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    -- Update book status to 'yes' (available)
    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn;

    -- Show a thank-you message
    SELECT CONCAT('Thank you for returning the book: ', v_book_name) AS message;
END$$

DELIMITER ;
-- calling function 
CALL add_return_records('RS138', 'IS135', 'Good');


SELECT * FROM return_status
WHERE issued_id = 'IS135';


/* Task 15: Branch Performance Report
 Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned,
 and the total revenue generated from book rentals.*/
 select * from issued_status;
  select * from return_status;
   select * from branch;
      select * from employee;

   
select 
br.branch_id,
e.emp_id,
count(distinct ist.issued_id) as issued_books,
count(distinct rs.return_id) as returend_books,
sum(bk.rental_price) as total_rent
from 
issued_status as ist 
join employee as e
	on  e.emp_id = ist.issued_emp_id
join branch as br
	on e.branch_id = br.branch_id
left join return_status as rs
	on  ist.issued_id=rs.issued_id 
join books as bk
on ist.issued_book_isbn = bk.isbn
GROUP BY br.branch_id, e.emp_id;


-- Task 16: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 6 months.
CREATE TABLE active_members AS
SELECT *
FROM members
WHERE member_id IN (
    SELECT DISTINCT issued_member_id
    FROM issued_status
    WHERE issued_date >= (CURRENT_DATE - INTERVAL 2 MONTH)
);

-- To view the result:
SELECT * FROM active_members;



-- Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.
select * from employee;
select * from books;
select * from branch;
select * from issued_status;
select 
e.emp_id,count(bk.isbn) as total_books, 
br.branch_id
from
employee as e
join issued_status as ist 
on e.emp_id = ist.issued_emp_id
join books as bk
on ist.issued_book_isbn= bk.isbn
join branch as br
on e.branch_id = br.branch_id
group by e.emp_id ;

-- Task 18: Identify Members Issuing High-Risk Books
-- Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.    


-- Task 19: Stored Procedure
-- Objective: Create a stored procedure to manage the status of books in a library system.
-- Description: Write a stored procedure that updates the status of a book based on its issuance or return. Specifically:
   --  If a book is issued, the status should change to 'no'.
	-- If a book is returned, the status should change to 'yes'.
    DELIMITER $$

CREATE PROCEDURE issue_book(
    IN p_issued_id VARCHAR(10), 
    IN p_issued_member_id VARCHAR(30), 
    IN p_issued_book_isbn VARCHAR(30), 
    IN p_issued_emp_id VARCHAR(10)
)
BEGIN
    DECLARE v_status VARCHAR(10);

    -- Get the book's current status
    SELECT status INTO v_status
    FROM books
    WHERE isbn = p_issued_book_isbn;

    -- Check if the book is available
    IF v_status = 'yes' THEN
        -- Insert into issued_status table
        INSERT INTO issued_status (
            issued_id, issued_member_id, issued_date, 
            issued_book_isbn, issued_emp_id
        )
        VALUES (
            p_issued_id, p_issued_member_id, CURDATE(), 
            p_issued_book_isbn, p_issued_emp_id
        );

        -- Update book status to 'no'
        UPDATE books
        SET status = 'no'
        WHERE isbn = p_issued_book_isbn;

        -- Output success message
        SELECT CONCAT('✅ Book issued successfully for ISBN: ', p_issued_book_isbn) AS message;
    ELSE
        -- Output error message
        SELECT CONCAT('❌ Book unavailable for ISBN: ', p_issued_book_isbn) AS message;
    END IF;
END$$

DELIMITER ;


/*Task 20: Create Table As Select (CTAS)
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.
Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines
*/
CREATE TABLE member_overdue_summary AS
SELECT 
    ist.issued_member_id AS member_id,
    
    -- Count of overdue books not yet returned
    COUNT(CASE 
            WHEN rs.return_id IS NULL 
             AND DATEDIFF(CURDATE(), ist.issued_date) > 30 
          THEN ist.issued_id 
         END) AS number_of_overdue_books,

    -- Total fines for overdue books
    SUM(CASE 
            WHEN rs.return_id IS NULL 
             AND DATEDIFF(CURDATE(), ist.issued_date) > 30 
          THEN (DATEDIFF(CURDATE(), ist.issued_date) - 30) * 0.5
          ELSE 0
        END) AS total_fines,

    -- Total number of books issued by member (regardless of return)
    COUNT(ist.issued_id) AS total_books_issued

FROM issued_status AS ist
LEFT JOIN return_status AS rs
    ON ist.issued_id = rs.issued_id
GROUP BY ist.issued_member_id;




 

