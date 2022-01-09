/*USEFUL COMMANDS:*/
/*MONGO DB*/

use mapreduce // Select the database.

//In this part will be explained the use of 'mapReduce' function.
db.example1.find()

// Example: We need to calculate how many persons there are for each age.
    // First. 'mapFunction', this fuction has an 'emit()' statement. This would be the records that we want to pass to the 'mapReduce' function
    var mapFunction = function() {
        emit(this.age, 1);
    };
    
    // Second. 'reduceFunction', this functions will tell to 'mapReduce' how to procede with the values. 
        // In this case, they will be returned as an array of sumed values.
    var reduceFunction = function(key, values) {
        return Array.sum(values);
    };
    
    // Third. Use 'mapReduce' function. It will create a new collection in the database with the specified name.
    db.example1.mapReduce(mapFunction, reduceFunction, { out: "map_reduce_1" })
    
    // Return all records from 'map_reduce_1'
    db.map_reduce_1.find({}).sort({_id: -1})
    db.map_reduce_1.aggregate([{$sort: {_id: -1}},{$project: {_id: 0, Age: "$_id", "Number of people": "$value"}}])

/* Example 2 */
db.nyse.find().limit(10)

    /* Part 1*/
    /* Calculate the number of entries for each stock_symbol */
    var mapFunction = function() {
        emit(this.stock_symbol, 1);
    }
    
    var reduceFunction = function(key, values){
        return Array.sum(values);   
    }
    
    db.nyse.mapReduce(mapFunction,reduceFunction, {out: "map_reduce_2"}).find()
    
    /* Part 2 */
    /* Calculate the maximum stock_price_close for each stock_symbol */
    var mapFunction = function() {
        emit(this.stock_symbol, this.stock_price_close);
    };
    
    var reduceFunction = function(key, values) {
        return Math.max(...values);   // spreadoperator 
    };
    
    db.nyse.mapReduce(mapFunction, reduceFunction, { out: "map_reduce_2" }).find()
    
    /* Part 3 */
    /* Calculate the maximum stock_price_close and the date 
    on which this stock_price_close was reached, for each stock_symbol */
    var mapFunction = function() {
        // the value is a tuple (instead of a single value)!
        emit(this.stock_symbol, {stock_price_close: this.stock_price_close, date: this.date});
    };
    
    var reduceFunction = function(key, values) {
        // the Javascript reduce function is called for each key!
        var max = values.reduce((result, value) => {
             return value.stock_price_close > result.stock_price_close ? value : result 
        }, {stock_price_close: 0, date: new Date()});
        return max;
    };
    
    db.nyse.mapReduce(mapFunction, reduceFunction, { out: "map_reduce_2" }).find()