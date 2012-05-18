DELETE FROM roles WHERE name = 'librarian';
INSERT INTO roles(id, name) VALUES (40, 'ROLE_LIBRARIAN');

-- Create user with role 'librarian'. username=librarian, password=librarian
--INSERT INTO rpt_users(id, username, password) VALUES (41, 'librarian', '35fa1bcb6fbfa7aa343aa7f253507176');
--INSERT INTO user_roles(user_id, role_id) VALUES (41, 40);
--INSERT INTO user_roles(user_id, role_id) VALUES (41, 10);