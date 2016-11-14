# as3-mysql

Actionscript 3 MySQL Driver (originally known as asSQL)

as3-mysql is an Actionscript 3 MySQL Driver that allows you to work with MySQL databases directly from your AIR app.


## Example Usage

Sample usage of the MySQL driver.

Declare the database connection object
```
private var con:Connection;
```

Connect to the database server
```
private function onCreationComplete():void {
	con = new Connection("localhost", 3306, "root", "password", "database name");
	on.addEventListener(Event.CONNECT, handleConnect);
	con.addEventListener(MySqlErrorEvent.SQL_ERROR, handleConnectionError);
	con.connect();
}

private function handleConnect(e:Event):void { 
	//woop! were connected, do something here
}

private function handleConnectionError(e:MySqlErrorEvent):void {
	Alert.show("Connection Error: " + e.text, "Error");
}
```

Query using a statement and responders
```
private function sampleQuery1():void {
	var st:Statement = con.createStatement();
	st.executeQuery("SELECT * FROM users", new MySqlResponser(

		// when done 
		function (e:MySqlEvent):void {
			Alert.show("Returned: " + e.resultSet.size() + " rows!");
		},
		
		// when error
		function (e:MySqlErrorEvent):void {
			Alert.show("Error: " + e.text);
		}
	));
}
```

Query using a statement, responders, and parameters
```
private function sampleQuery2():void {
	var st:Statement = con.createStatement();
	st.sql = "SELECT * FROM users WHERE userID = ?";
	st.setNumber(1, 5);
	st.executeQuery(null, new MySqlResponser(

		// when done 
		function (e:MySqlEvent):void {
			Alert.show("Returned: " + e.resultSet.size() + " rows!");
		},

		// when error
		function (e:MySqlErrorEvent):void {
			Alert.show("Error: " + e.text);
		}
	)); 
}
```

Query using a statement and event listeners

```
private function sampleQuery3():void {
	var st:Statement = con.createStatement();
	st.addEventListener(MySqlEvent.RESULT, handleResult);
	st.executeQuery("SELECT * FROM users");
}
```


## Examples

Examples of using asSQL


### MySqlService Example

This example is using MySqlService and DataGrid. The data grid's columns property and dataProvider property are bound to the MySqlService lastResult (ArrayCollection of Rows) and lastResultSet (The actual ResultSet).

```

    <mx:Script>
    <![CDATA[
        import mx.controls.Alert;
        import com.maclema.mysql.events.MySqlErrorEvent;
        import com.maclema.util.ResultsUtil;

        private function handleConnected(e:Event):void {
            service.send("SELECT * FROM employees2 LIMIT 10");
        }

        private function handleError(e:MySqlErrorEvent):void {
            Alert.show(e.text);
        }
    ]]>
    </mx:Script>

    <assql:MySqlService id="service"
            hostname="localhost" 
            username="root"
            password=""
            database="assql-test"
            autoConnect="true"
            connect="handleConnected(event)" 
            sqlError="handleError(event)" />

    <mx:DataGrid id="grid" left="10" right="10" top="10" bottom="10"
            dataProvider="{service.lastResult}"
            columns="{ResultsUtil.getDataGridColumns(service.lastResultSet)}" />
```

### Token Responder Example 1

This is an example of using an AsyncResponder to handle a query.

```
import com.maclema.mysql.Statement; import com.maclema.mysql.Connection; import com.maclema.mysql.ResultSet; import mx.controls.Alert; import mx.rpc.AsyncResponder; import com.maclema.mysql.MySqlToken; import com.maclema.util.ResultsUtil;

//The MySql Connection private var con:Connection;

private function onCreationComplete():void { con = new Connection("localhost", 3306, "root", "", "assql-test"); con.addEventListener(Event.CONNECT, handleConnected); con.connect(); }

private function handleConnected(e:Event):void { var st:Statement = con.createStatement();

var token:MySqlToken = st.executeQuery("SELECT * FROM employees");

token.addResponder(new AsyncResponder(
    function(data:Object, token:Object):void {
        var rs:ResultSet = ResultSet(data);
        Alert.show("Found " + rs.size() + " employees!");
    },

    function(info:Object, token:Object):void {
        Alert.show("Error: " + info);
    },

    token
));
}
```

### Token Responder Example 2

This is a more in depth example. With each statement, an info property is set on the MySqlToken. This way all queries and responses can be handled with the same result and fault handlers. This example also uses a statement that uses parameters.

```
import com.maclema.mysql.Statement;
import com.maclema.mysql.Connection;
import com.maclema.mysql.ResultSet;
import mx.controls.Alert;
import mx.rpc.AsyncResponder;
import com.maclema.mysql.MySqlToken;
import com.maclema.util.ResultsUtil;

//The MySql Connection
private var con:Connection;

private function onCreationComplete():void {
	con = new Connection("localhost", 3306, "root", "", "assql-test");
	con.addEventListener(Event.CONNECT, handleConnected);
	con.connect();
}

private function handleConnected(e:Event):void {
	getAllEmployees();
}

private function getAllEmployees():void {
	var st:Statement = con.createStatement();

	var token:MySqlToken = st.executeQuery("SELECT * FROM employees");
	token.info = "GetAllEmployees";
	token.addResponder(new AsyncResponder(result, fault, token));
}

private function getEmployee(employeeID:int):void {
	var st:Statement = con.createStatement();
	st.sql = "SELECT * FROM employees WHERE employeeID = ?";
	st.setNumber(1, employeeID);

	var token:MySqlToken = st.executeQuery();
	token.info = "GetEmployee";
	token.employeeID = employeeID;
	token.addResponder(new AsyncResponder(result, fault, token));
}

private function result(data:Object, token:Object):void { var rs:ResultSet;

	if ( token.info == "GetAllEmployees" ) {
		rs = ResultSet(data);
		Alert.show("Found " + rs.size() + " employees!");   
	}
	else if ( token.info == "GetEmployee" ) {
		rs = ResultSet(data);
		if ( rs.next() ) {
			Alert.show("Employee " + token.employeeID + " username is '" + rs.getString("username") + "'");
		}
		else {
			Alert.show("No such employee for id " + token.employeeID);
		}
	}
}

private function fault(info:Object, token:Object):void {
	Alert.show(token.info + " Error: " + info);
}
```

### Inserting Binary Data Example

This is an example of inserting binary data.

```
import com.maclema.mysql.Statement;
import com.maclema.mysql.Connection;
import com.maclema.mysql.ResultSet;
mport mx.controls.Alert;
import mx.rpc.AsyncResponder;
import com.maclema.mysql.MySqlToken;
import com.maclema.util.ResultsUtil;

//The MySql Connection private var con:Connection;

private function onCreationComplete():void {
	con = new Connection("localhost", 3306, "root", "", "assql-test");
	con.addEventListener(Event.CONNECT, handleConnected);
	con.connect();
}

private function handleConnected(e:Event):void {
	//do something here
}

private function setEmployeePhoto(employeeID:int, photoFile:File):void {
	//the file bytes var filedata:ByteArray = new ByteArray();

	//read the file
	var fs:FileStream = new FileStream();
	fs.open(photoFile, FileMode.READ);
	fs.readBytes(filedata);
	fs.close();

	//execute the query
	var st:Statement = con.createStatement();
	st.sql = "UPDATE employees SET photo = ? WHERE employeeID = ?";
	st.setBinary(1, filedata);
	st.setNumber(2, employeeID);

	var token:MySqlToken = st.executeQuery();
	token.employeeID = employeeID;
	token.addResponder(new AsyncResponder(
		function (data:Object, token:Object):void {
			Alert.show("Employee " + token.employeeID + "'s photo updated! Affected Rows: " + data.affectedRows);
		},
		function (info:Object, token:Object):void {
			Alert.show("Error updating photo: " + info);
		},
		token
	));
}
```

### Selecting Binary Data Example

This is an example of selecting binary data.

```
import com.maclema.mysql.Statement;
import com.maclema.mysql.Connection;
import com.maclema.mysql.ResultSet;
import mx.controls.Alert;
import mx.rpc.AsyncResponder;
import com.maclema.mysql.MySqlToken;
import com.maclema.util.ResultsUtil;

//The MySql Connection
private var con:Connection;

private function onCreationComplete():void {
	con = new Connection("localhost", 3306, "root", "", "assql-test");
	con.addEventListener(Event.CONNECT, handleConnected);
	con.connect();
}

private function handleConnected(e:Event):void {
	//do something here
}

private function getEmployeePhoto(employeeID:int, writeToFile:File):void {
	//execute the query var st:Statement = con.createStatement();
	st.sql = "SELECT photo FROM employees WHERE employeeID = ?";
	st.setNumber(1, employeeID);

	var token:MySqlToken = st.executeQuery();
	token.employeeID = employeeID;
	token.writeToFile = writeToFile;
	token.addResponder(new AsyncResponder(
		function (data:Object, token:Object):void {
			var rs:ResultSet = ResultSet(data);
			if ( rs.next() ) {
				//get the outFile from the token
				var outFile:File = token.writeToFile;

				//get the file data from the result set
				var filedata:ByteArray = rs.getBinary("photo");

				//write the file
				var fs:FileStream = new FileStream();
				fs.open(outFile, FileMode.WRITE);
				fs.writeBytes(filedata);
				fs.close();

				Alert.show("Photo written to: " + outFile.nativePath);
			}
			else {
				Alert.show("Employee " + token.employeeID + " not found!");
			}
		},
		function (info:Object, token:Object):void {
			Alert.show("Error getting photo: " + info);
		},
		token
	));
}
```

### Stored Procedure Example

This is an example of calling a stored procedure that returns a ResultSet as well as output parameters.

```
import com.maclema.mysql.Statement;
import com.maclema.mysql.Connection;
import com.maclema.mysql.ResultSet;
import mx.controls.Alert;
import mx.rpc.AsyncResponder;
import com.maclema.mysql.MySqlToken;
import com.maclema.mysql.MySqlResponse;
import com.maclema.mysql.MySqlOutputParams;
import com.maclema.util.ResultsUtil;

//The MySql Connection
private var con:Connection;

private function onCreationComplete():void {
	con = new Connection("localhost", 3306, "root", "", "assql-test");
	con.addEventListener(Event.CONNECT, handleConnected);
	con.connect();
}

private function handleConnected(e:Event):void {
	var st:Statement = con.createStatement();
	st.sql = "CALL getEmployeeList(@LastUpdated)";
	st.registerOutputParameter("@LastUpdated");

	var token:MySqlToken = st.executeQuery();

	token.addResponder(new AsyncResponder(
		function(data:Object, token:Object):void {
			if ( data is ResultSet ) {
				//handle the results returned.
			}
			else if ( data is MySqlResponse ) {
				//check the affectedRows of the procedure
			}
			else if ( data is MySqlOutputParams ) {
				//get the output parameter.
				var lastUpdated:String = data.getParam("@LastUpdated");
			}
		},

		function(info:Object, token:Object):void {
			Alert.show("Error: " + info);
		},

		token
	));
}
```

### Streaming Results

This is an example of streaming a very large ResultSet and updating a DataGrid every time we receive 500 new rows.

```

    <mx:Script>
    <![CDATA[
        import mx.controls.Alert;
        import mx.rpc.AsyncResponder;
        import mx.collections.ArrayCollection;
        import com.maclema.mysql.ResultSet;
        import com.maclema.util.ResultsUtil;
        import com.maclema.mysql.events.MySqlEvent;
        import com.maclema.mysql.MySqlToken;
        import com.maclema.mysql.Statement;
        import com.maclema.mysql.Connection;

        private var con:Connection;

        private function onCreationComplete():void {
            con = new Connection("localhost", 3306, "root", "", "assql-test");
            con.addEventListener(Event.CONNECT, handleConnected);
            con.connect();  
        }

        private function handleConnected(e:Event):void {
            var st:Statement = con.createStatement();

            //turn on results streaming
            st.streamResults = true;

            //dispatch new rows event every 500 new rows
            st.streamingInterval = 500;

            //execute a query
            var token:MySqlToken = st.executeQuery("SELECT * FROM employees");

            //listen for our result set columns
            token.addEventListener(MySqlEvent.COLUMNDATA, function(e:MySqlEvent):void {
                grid.columns = ResultsUtil.getDataGridColumns( e.resultSet );
                grid.dataProvider = new ArrayCollection();
            });

            //listen for new rows
            token.addEventListener(MySqlEvent.ROWDATA, function(e:MySqlEvent):void {
                addNewRows(e.resultSet);
            });             

            //add a responder
            token.addResponder(new AsyncResponder(
                function(data:Object, token:Object):void {
                    //call add new rows again to ensure we have all the rows
                    addNewRows(ResultSet(data));
                },
                function(info:Object, token:Object):void {
                    Alert.show("Error: " + info);
                },
                token
            ));
        }

        private function addNewRows(rs:ResultSet):void {
            //get our data provider
            var dp:ArrayCollection = grid.dataProvider as ArrayCollection;

            //get the collection of new rows
            var newRows:ArrayCollection = rs.getRows(false, dp.length, (rs.size()-dp.length));

            //concat our current source, and our new rows source
            dp.source = dp.source.concat( newRows.source );

            //refresh our data provider
            dp.refresh();
        }
    ]]>
    </mx:Script>

    <mx:DataGrid id="grid" left="10" right="10" top="10" bottom="10" />
```

## Flash Player Policy Server

If you are using Flash Player, then to use this library you need to connect to a "policy server" that allows the sockets.

Here is the absolute simplest configuration for the socket policy file:

	<?xml version="1.0"?> <!DOCTYPE cross-domain-policy SYSTEM "/xml/dtds/cross-domain-policy.dtd"> <cross-domain-policy> <allow-access-from domain="*" to-ports="3306" /> </cross-domain-policy>

The policy file needs to be served from a socket, listening on port 843 (TCP). Flash will send the request `"<policy-file-request/>\0"`, when the server receives this string, it should return the policy file, followed by a null byte.

PHP Flash Policy Daemon:

http://ammonlauritzen.com/blog/2008/04/22/flash-policy-service-daemon/

C# Flash Policy Server:

http://giantflyingsaucer.com/blog/?p=15

VB.NET Flash Policy Server:

http://www.gamedev.net/community/forums/topic.asp?topic_id=455949

Python / Perl Flash Policy Servers:

http://www.adobe.com/devnet/flashplayer/articles/socket_policy_files.html

More Information:

http://www.adobe.com/devnet/flashplayer/articles/fplayer9_security_04.html


### Sample Java Flash Policy File Server

This is a simple Java servlet, that opens a server socket on port 843 when the web application is started. It listens for `<policy-file-request/>\0` requests, and writes the policy file to the connected client.

The policy file is read from "/tomcat/policyserver/ROOT/flashpolicy.xml", this can be changed in the servlet code.

Here is what you will need in web.xml:

```
PolicyServerServlet com.maclema.flash.PolicyServerServlet 1
PolicyServerServlet /policyserver
```

and here is the servlet code:

```
package com.maclema.flash;

import java.io.BufferedReader; import java.io.File; import java.io.FileReader; import java.io.InputStream; import java.io.OutputStream; import java.net.ServerSocket; import java.net.Socket;

import javax.servlet.http.HttpServlet;

public class PolicyServerServlet extends HttpServlet { private static final long serialVersionUID = 1L;

private static ServerSocket serverSock;
private static boolean listening = true;
private static Thread serverThread;

static {
    try {
        serverThread = new Thread(new Runnable(){
            public void run() {
                try {
                    System.out.println("PolicyServerServlet: Starting...");
                    serverSock = new ServerSocket(843, 50);

                    while ( listening ) {
                        System.out.println("PolicyServerServlet: Listening...");
                        final Socket sock = serverSock.accept();

                        Thread t = new Thread(new Runnable() {
                            public void run() {
                                try {
                                    System.out.println("PolicyServerServlet: Handling Request...");

                                    sock.setSoTimeout(10000);

                                    InputStream in = sock.getInputStream();

                                    byte[] buffer = new byte[23];

                                    if ( in.read(buffer) != -1 && (new String(buffer)).startsWith("<policy-file-request/>") ) {
                                        System.out.println("PolicyServerServlet: Serving Policy File...");

                                        //get the local tomcat path, and the path to our flashpolicy.xml file
                                        File policyFile = new File("/tomcat/policyserver/ROOT/flashpolicy.xml");

                                        BufferedReader fin = new BufferedReader(new FileReader(policyFile));

                                        OutputStream out = sock.getOutputStream();

                                        String line;
                                        while ( (line=fin.readLine()) != null ) {
                                            out.write(line.getBytes());
                                        }

                                        fin.close();

                                        out.write(0x00);

                                        out.flush();
                                        out.close();
                                    }
                                    else {
                                        System.out.println("PolicyServerServlet: Ignoring Invalid Request");
                                        System.out.println("  " + (new String(buffer)));
                                    }

                                }
                                catch ( Exception ex ) {
                                    System.out.println("PolicyServerServlet: Error: " + ex.toString());
                                }
                                finally {
                                    try { sock.close(); } catch ( Exception ex2 ) {}
                                }
                            }
                        });
                        t.start();
                    }
                }
                catch ( Exception ex ) {
                    System.out.println("PolicyServerServlet: Error: " + ex.toString());
                }
            }
        });
        serverThread.start();

    }
    catch ( Exception ex ) {
        System.out.println("PolicyServerServlet Error---");
        ex.printStackTrace(System.out);
    }
}

public void destroy() {
    System.out.println("PolicyServerServlet: Shutting Down...");

    if ( listening ) {
        listening = false;
    }

    if ( !serverSock.isClosed() ) {
        try { serverSock.close(); } catch ( Exception ex ) {}
    }
}
}
```

and this is my flashpolicy.xml:

```
<?xml version="1.0"?> <!DOCTYPE cross-domain-policy SYSTEM "/xml/dtds/cross-domain-policy.dtd"> <cross-domain-policy> <allow-access-from domain="*" to-ports="3306" /> </cross-domain-policy>
```
