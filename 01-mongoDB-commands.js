/*USEFUL COMMANDS:*/
/*MONGO DB*/

use info // Select the database.

db.zips.find({}) // Return all records from one collection

db.zips.find({city:'NEW YORK'}) //All record which has the city: 'NEW YORK'

db.zips.find({}).limit(1) // Return just 1 record

db.zips.count() // Return the total number of records at the collection

db.zips.count({state : "MA"}) // Total number which has the state 'MA'

db.zips.distinct("state") // Return all the distincts states in the collection

db.zips.distinct("state").length // Return the number of differents states

/*Aggregation Pipeline*/
/*Example: Return States with Populations above 10 Million*/
db.zips.aggregate([
    {$group: {_id: "$state", totalPop: {$sum: "$pop"}}},
    {$match: {totalPop: {$gte: 1000000}}}
])
                   
/* Example: Return the States and the number of cities for the states who have more than 1500 cities, only show top 5 states */
db.zips.aggregate([
    {$group : {_id : "$state", count : {$sum : 1}}}, //$sum: 1, simule 'count' function from SQL, it ads 1 every time there is a record matching.
    {$match: {count: {$gte: 1500}}},
    {$sort : {count : -1}}, 
    {$limit : 5},
    {$project: { _id: 0, State: "$_id", "Number of Cities": "$count"}} // $project, is just a stetical function. 
])

/*Example: Return the Five Most Common “Likes” */
db.users.aggregate([
    { $unwind : "$likes" }
])
// $unwind, separates each value in the 'likes' array, and creates a new version of the source document for every element in the array.   

db.users.aggregate(
  [
    {$unwind : "$likes" },
    {$group : { _id : "$likes" , number : { $sum : 1 } } },
    {$sort : { number : -1 } },
    {$limit : 5 },
    {$project: {_id: 0, likes: "$_id", "Number of people who like": "$number"}}
  ]
)
