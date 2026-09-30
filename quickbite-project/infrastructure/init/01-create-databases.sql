SELECT 'CREATE DATABASE quickbite_user_db'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'quickbite_user_db')\gexec

SELECT 'CREATE DATABASE quickbite_restaurant_db'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'quickbite_restaurant_db')\gexec

SELECT 'CREATE DATABASE quickbite_order_db'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'quickbite_order_db')\gexec

SELECT 'CREATE DATABASE quickbite_notification_db'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'quickbite_notification_db')\gexec
