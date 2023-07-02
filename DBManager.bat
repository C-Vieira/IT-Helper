create database user_support;
\c user_support
drop table user_device;
create table user_device(
	date VARCHAR(100),
	time VARCHAR(100),
	operation_type VARCHAR(100),
	computer_name VARCHAR(100),
	user_domain VARCHAR(100),
	user_name VARCHAR(100),
	root_drive VARCHAR(100),
	processor_type VARCHAR(100),
	processor_architecture VARCHAR(100),
	number_of_cores VARCHAR(100),
	windows_dir VARCHAR(100));
\copy user_device from 'devices.csv' with delimiter ';' csv header;
select * from user_device;
