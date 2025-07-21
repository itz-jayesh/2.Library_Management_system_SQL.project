-- INSERT INTO book_issued in last 30 days
-- SELECT * from employees;
-- SELECT * from books;
-- SELECT * from members;
-- SELECT * from issued_status
-- Disable safe update mode temporarily
-- Disable safe update mode for this session
SET SQL_SAFE_UPDATES = 0;

-- Insert data into issued_status table
INSERT INTO issued_status(issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id)
VALUES
('IS151', 'C118', 'The Catcher in the Rye', CURDATE() - INTERVAL 24 DAY, '978-0-553-29698-2', 'E108'),
('IS152', 'C119', 'The Catcher in the Rye', CURDATE() - INTERVAL 13 DAY, '978-0-553-29698-2', 'E109'),
('IS153', 'C106', 'Pride and Prejudice', CURDATE() - INTERVAL 7 DAY, '978-0-14-143951-8', 'E107'),
('IS154', 'C105', 'The Road', CURDATE() - INTERVAL 32 DAY, '978-0-375-50167-0', 'E101');

-- Add new column to return_status table
ALTER TABLE return_status
ADD COLUMN book_quality VARCHAR(15) DEFAULT 'Good';

-- Update book_quality where issued_id matches
UPDATE return_status
SET book_quality = 'Damaged'
WHERE issued_id IN ('IS112', 'IS117', 'IS118');

-- View the updated return_status table
SELECT * FROM return_status;

-- (Optional) Re-enable safe update mode after updates
SET SQL_SAFE_UPDATES = 1;



