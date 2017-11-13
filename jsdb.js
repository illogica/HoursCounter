.pragma library
.import QtQuick.LocalStorage 2.0 as Sql

//The database instance
var _db

//Opens the database and initialize tables if needed
function openDB() {
    //print("createDB()")
    _db = Sql.LocalStorage.openDatabaseSync("HoursCounterDb", "1.0", "DB of the Hours Counter app", 1000000);
    createClientsTable();
}

//Initialize tables if needed
function createClientsTable(){
    //print("createClientsTable()")
    _db.transaction(
                function(tx){
                    tx.executeSql("CREATE TABLE IF NOT EXISTS customers (customerId INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT);");
                    tx.executeSql("CREATE TABLE IF NOT EXISTS times (timeId INTEGER PRIMARY KEY AUTOINCREMENT, customer TEXT, begin TEXT, finish TEXT, note TEXT);");
                });
}

function clearClientsTable(){
    //print("clearClientsTable")
    _db.transaction(function(tx){
        tx.executeSql("DELETE FROM customers");
    })
}

function clearTimeTable(){
    //print("clearTimeTable")
    _db.transaction(function(tx){
        tx.executeSql("DELETE FROM times");
    })
}

function removeClientById(id){
    //print("removeClientById")
    _db.transaction(function(tx){
        tx.executeSql("DELETE FROM customers WHERE customerId = ?", [id]);
    })
}

function removeClientByName(name){
    //print("removeClientByName")
    _db.transaction(function(tx){
        tx.executeSql("DELETE FROM customers WHERE name = ?", [name]);
    })
}

function removeTimeById(id){
    //print("removeTimeById")
    _db.transaction(function(tx){
        tx.executeSql("DELETE FROM times WHERE timeId = ?", [id]);
    })
}

//Returns an array containing all the clients as objects
function readClients(){
    //print("readClients()")
    var items = []
    _db.transaction( function(tx){
        var rs = tx.executeSql("SELECT * FROM customers")
        //print(JSON.stringify(rs))
        for(var i=0; i<rs.rows.length; i++){
            var item = {}
            item.customerId = rs.rows.item(i).customerId
            item.name = rs.rows.item(i).name
            items[i] = item;
        }
    })
    return items;
}

//Returns an array containing all the times as objects
function readTimes(){
    //print("readTimes()")
    var items = []
    _db.transaction( function(tx){
        var rs = tx.executeSql("SELECT * FROM times")
        //print(JSON.stringify(rs))
        for(var i=0; i<rs.rows.length; i++){
            var item = {}
            item.timeId = rs.rows.item(i).timeId
            item.customer = rs.rows.item(i).customer
            item.begin = rs.rows.item(i).begin
            item.finish = rs.rows.item(i).finish
            item.note = rs.rows.item(i).note
            items[i] = item;
        }
    })
    return items;
}

function addClient(name){
    //print("addClient()")
    _db.transaction( function(tx){
        tx.executeSql("INSERT INTO customers(name) VALUES(?)", name);
    })
}

function addTime(client, startTime, stopTime, notes){
    //print("addTime() con " + client + " " + startTime + " " + stopTime + " " + notes)
    _db.transaction( function(tx){
        tx.executeSql("INSERT INTO times(customer, begin, finish, note) VALUES(?,?,?,?)", [client, startTime, stopTime, notes]);
    })
}

function updateTimeById(id, client, startTime, stopTime, notes){
    //print("Called updateTimeById with: " + id + " " + client + " " + startTime + " " + stopTime + " " + notes)
    _db.transaction( function(tx){
        tx.executeSql("UPDATE times SET customer = ?, begin = ?, finish = ?, note = ? WHERE timeId = ?", [client, startTime, stopTime, notes, id]);
    })
}

function countClients(){
    //print("countClients()")
    _db.readTransaction( function(tx){
        var rs = tx.executeSql("SELECT COUNT(*) AS cnt FROM customers");
        print(rs.rows.item(0).cnt)
    })
}

function countTimes(){
    //print("countTimes()")
    _db.readTransaction( function(tx){
        var rs = tx.executeSql("SELECT COUNT(*) AS cnt FROM times");
        print("times: " + rs.rows.item(0).cnt)
    })
}

function datetime(){
    var retval = ""
    //print("datetime()")
    _db.readTransaction( function(tx){
        var rs = tx.executeSql("SELECT datetime('now') AS cnt");
        retval =  rs.rows.item(0).cnt
    })
    return retval
}

