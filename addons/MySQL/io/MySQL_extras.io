
MySQL do(
	queryThenMap := method(queryString, self query(queryString, true))

	host ::= "localhost"
	user ::= "root"
	password ::= nil
	name ::= nil
	port ::= nil 
	socket ::= nil

	tableNames := method(query("SHOW tables") flatten)

	tables := method(
		self tables := Map clone
		tableNames foreach(name, tables atPut(name, SqlTable clone setDb(self) setName(name)))
	)

	_connect := getSlot("connect")
	connect := method(
		_connect(host, user, password, name, port, socket)
		self
	)
)

SqlTable := Object clone do(
	db ::= nil
	name ::= nil
where ::= ""
//TODO: Refactor where

	fetchColumnNames := method(
		self columnNames := db query("SHOW columns FROM " .. name) map(first) flatten
	)

	columnNames := method(
		self columnNames := fetchColumnNames
	)

	show := method(
		writeln(list(name, columnNames))
	)

	foreachCacheSize ::= 100
	
	foreach := method(
		start := 0
		increment := foreachCacheSize
		loop(
			write(" <sql"); File standardOutput flush
			writeln("SELECT * FROM " .. name .. where .. " LIMIT " .. start .. ", " .. increment)
			rows := db queryThenMap("SELECT * FROM " .. name .. where .. " LIMIT " .. start .. ", " .. increment)
			write(">"); File standardOutput flush
			if(rows size == 0, break)
			rows foreach(row, 
				call sender setSlot(call message arguments first name, row)
				call sender doMessage(call message arguments second, call sender)
				//b call(row)
			)
			start = start + increment
		)
	)
)
