#include<stdio.h>
#include <SQLAPI.h> // main SQLAPI++ header
int main(int argc, char* argv[])
{
	SAConnection con; // connection object to connect to database
	SACommandcmd; // create command object
	try
	{
		// connect to database (Oracle in our example)
		con.Connect("test", "tester", "tester", SA_Oracle_Client);

		// associate a command with connection
		// connection can also be specified in SACommand constructor
		cmd.setConnection(&con);

		// create table
		cmd.setCommandText("create table tbl(id number, name varchar(20));");
		cmd.Execute();

		// insert value
		cmd.setCommandText("Insert into tbl(id, name) values (1,”Vinay”)");
		cmd.setCommandText("Insert into tbl(id, name) values (2,”Kushal”)");
		cmd.setCommandText("Insert into tbl(id, name) values (3,”Saransh”)");
		cmd.Execute();

		// commit changes on success
		con.Commit();
		printf("Table created, row inserted!\n");
	}

	catch(SAException &x)
	{
		// SAConnection::Rollback()
		// can also throw an exception
		// (if a network error for example),
		// we will be ready
		try
		{
			// on error rollback changes
			con.Rollback();
		}
		catch(SAException &)
		{
		}
		// print error message

		printf("%s\n", (const char*)x.ErrText());
	}
	return 0;
}
