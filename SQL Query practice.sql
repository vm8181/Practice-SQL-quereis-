--SQL Commands in DBMS
/*	1.DDL(Data Definition Language) : DDL changes the structure of the table like creating a table, deleting a table, altering a table, etc
	All the command of DDL are auto-committed that means it permanently save all the changes in the database.
	Create, Alter, Drop, Rename, Truncate, Comment
	2.DML(Data Manipulating Language) : DML commands are used to modify the database. It is responsible for all form of changes in the database.
	The command of DML is not auto-committed that means it can't permanently save all the changes in the database. They can be rollback.
	Select, Insert, Update, Delete, Merge, Call, Explain Plan, Lock Table
	3.TCL(Transaction Control Language) :TCL commands can only use with DML commands like INSERT, DELETE and UPDATE only.
	These operations are automatically committed in the database that's why they cannot be used while creating tables or dropping them.
	Commit, Rollback, Savepoint
	DCL(Data Control Language) :DCL commands are used to grant and take back authority from any database user.
	Grant, Revoke
	DQL(Data Query Language): Use to extract selected information from data
	Select*/

use Task
select * from Employee;
--add a Id column to the Employee tbl
alter table Employee
add Id int identity(1,1);
--add constraint to id column as primary key
alter table Employee
add primary key (Id);
--change the name of first name and last name
sp_rename 'Employee.FirstName', 'First Name';
sp_rename 'Employee.LastName', 'Last Name';
--Fetch unique records using group by function
select 
	EMPLOYEE_ID, 
	[NAME], 
	SALARY 
from 
	tblEmployee 
group by 
	tblEmployee.EMPLOYEE_ID, [NAME], SALARY;
--fetch unique record using row_number fuction
/*The row_number function is used to provide consecutive number to the rows in result by ORDER selected
for each PARTITION specified in the over clause. It will assign value 1 for the first row and increase the 
number of subsequent rows*/
/*The OVER clause is used to determine which rows from the query are applied to the function, 
what order they are evaluated in by that function, and when the function's calculations should restart.*/
select
	EMPLOYEE_ID, 
	[NAME], 
	SALARY
from
	(select
		tblEmployee.EMPLOYEE_ID, 
		tblEmployee.[NAME], 
		tblEmployee.SALARY,
		ROW_NUMBER() over(partition by EMPLOYEE_ID, [NAME], SALARY order by EMPLOYEE_ID)as Id
	from 
	tblEmployee)a
where Id = 1;
--Create RowId column in table tblEmployee
alter table tblEmployee
add RowId int identity(1,1);
--find duplicates in tblEmployee table
--Method1
select 
	tblEmployee.EMPLOYEE_ID, 
	tblEmployee.NAME, 
	tblEmployee.SALARY,
	count(*) as repeated_record
from 
	tblEmployee
group by EMPLOYEE_ID, [NAME], SALARY
having count(*) > 1
--Method2
with cte as (select
	tblEmployee.EMPLOYEE_ID, 
	tblEmployee.[NAME], 
	tblEmployee.SALARY,
	ROW_NUMBER() over(partition by EMPLOYEE_ID, [NAME], SALARY order by EMPLOYEE_ID)as Id
from 
	tblEmployee)
select * from cte where Id > 1;
--Method3
select 
	RowId 
from (
	select
		tblEmployee.RowId,
		tblEmployee.EMPLOYEE_ID, 
		tblEmployee.[NAME], 
		tblEmployee.SALARY,
		ROW_NUMBER() over(partition by EMPLOYEE_ID, [NAME], SALARY order by EMPLOYEE_ID)as Id
	from 
		tblEmployee
		)a
where Id > 1
select * from tblEmployee
--delete duplicate records from a table
--Method1
with cte as (
  select 
    tblEmployee.EMPLOYEE_ID, 
    tblEmployee.[NAME], 
    tblEmployee.SALARY, 
    ROW_NUMBER() over(
      partition by EMPLOYEE_ID, 
      [NAME], 
      SALARY 
      order by 
        EMPLOYEE_ID
    ) as Id 
  from 
    tblEmployee
) 
delete from 
  cte 
where 
  id > 1
--Method2
delete from 
  tblEmployee 
where 
  RowId in (
    Select 
      RowId 
    from 
      (
        select 
          tblEmployee.RowId, 
          tblEmployee.EMPLOYEE_ID, 
          tblEmployee.[NAME], 
          tblEmployee.SALARY, 
          ROW_NUMBER() over(
            partition by EMPLOYEE_ID, 
            [NAME], 
            SALARY 
            order by 
              EMPLOYEE_ID
          ) as Id 
        from 
          tblEmployee
      ) a 
    where 
      Id > 1
  )
--Methon3
--you can take min or max aggregate function to delete the duplicates
/*Correlated subquery is used for row-by-row processing. With a normal nested subquery, the inner SELECT query runs once and 
executes first. The returning values will be used by the main query. A correlated subquery,however, executes once 
for every row of the outer query. In other words, the inner query is driven by the outer query.*/
begin tran
delete from 
	tblEmployee
where 
	RowId not in (
				select 
					max(RowId) MaxRowId 
				from 
					tblEmployee 
				group by EMPLOYEE_ID, [NAME], SALARY
				)
rollback 
--How to read top 5 records from the sql query
select 
	top 5 * 
from 
	tblDepartments
--How to last 5 records from the sql query
select 
	* 
from (
	select 
		top 5 * 
	from 
		tblDepartments 
	order by Department_ID desc
	)a 
order by Department_ID asc
--Join table
--Remember when we don't mention the type of join it performs as inner join bydefalt
/*Normal Join or Inner Join is the most common type of join. It returns the rows that are exact match between both the tables.*/
select
	a.ID, 
	b.Category,
	b.City
from 
	[TableA] a
join [TableB] b
on a.Category = b.Category
--Left join or left outer join
/*The Left Outer Join returns all the rows from the left table and only the matching rows from the right table. If there is 
no matching row found from the right table, the left outer join will have NULL values for the columns from right table.*/
select
	a.ID, 
	b.Category,
	b.City
from 
	[TableA] a
left join [TableB] b
on a.Category = b.Category
--Right join or right outer join
/*The Right Outer Join returns all the rows from the right table and only the matching rows from the left table. If there 
is no matching row found from the left table, the right outer join will have NULL values for the columns from left table.*/
select
	a.Category,
	b.City 
from 
	[TableA] a
Right join [TableB] b
on a.Category = b.Category
--Full join or full outer join
/*The Full Outer Join returns all the rows from both the right table and the left table. If there is no matching row found, 
the missing side columns will have NULL values.*/
select 
	a.Id,
	b.Category,
	b.City
from
	[TableA] a
full outer join [TableB] b on a.Category = b.Category
--Find the second maximum salary from Employee table
--Method1
select 
	max(salary) Second_largest_salary 
from 
	Employees 
where salary not in(select max(salary) from Employees)
--Find the employee with second maximum salary from Employee table
with cte as (
	select 
		max(salary) Second_Max_salary
	from 
		Employees 
	where salary not in(
		select 
			max(salary) MaxSalary
		from 
			Employees
			)
		)
select 
	a.* 
from 
	Employees a 
join cte c on a.salary = c.Second_Max_salary
--Method2
--by this method you can get top n number salary from the required table
/*The DENSE_RANK() is a window function that assigns a rank to each 
row within a partition of a result set. Unlike the RANK() function, the DENSE_RANK() function returns consecutive rank values.
Rows in each partition receive the same ranks if they have the same values.*/
select 
	emp_id, 
	[name], 
	salary 
from (
	select 
		e.*,
		DENSE_RANK() over(order by salary desc) as Salary_Ranking 
	from 
		Employees e)a
where salary_ranking = 2
--Find the third largest salary from the Employees table
select 
	max(Salary) ThirdMaxSalary 
from 
	Employees 
where Salary not in (
	select 
		top 2 max(salary) MaxSalary 
	from 
		Employees 
	group by [name] 
	order by MaxSalary desc
	)
--Find the employee with third largest salary from the Employees table
--Method1
with Temp as (
	select 
		max(Salary) ThirdMaxSalary 
	from 
		Employees 
	where Salary not in (
		select 
			top 2 max(salary) MaxSalary 
		from 
			Employees 
		group by [name] 
		order by MaxSalary desc
	)
		)
select 
	e.*
from
	Employees e
join Temp t
on e.salary = t.ThirdMaxSalary
--Method2
select 
	emp_id, 
	[name], 
	salary 
from (
	select 
		e.*,
		DENSE_RANK() over(order by salary desc) as Salary_Ranking 
	from 
		Employees e)a
where salary_ranking = 3	