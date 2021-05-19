---
title: "To SQL or to NoSQL?"
date: 2021-05-18
hero: /images/posts/database.png
categories:
- Development
- Database
---

To SQL or to NoSQL? Is that the real question? Nah, the real war out there is to agree on how to pronounce it. Do you pronounce it “Ess-cue-ell” or maybe you pronounce it “sequel” like Bill Gates among others? If you want to know how I pronounce it… I use both just to bother people.

Jokes aside, let’s get on this post! Would you like to know the differences between these two database models? A lot of people are used to always using the same model because they use it at their work and since it is the one they know the most they use it on their personal projects too. It’s very common, so if you never went further on this and want a quick review then you are in the right place, my friend.

<br />

---
##### SQL databases:

SQL stands for Structured Query Language and it is a programming language with its own syntax to manipulate data on relational databases, so it is not a database system itself. It's main benefit is that it has a very good query system so you can manage data in a more flexible way.

SQL database systems are relational database systems and they store the data on tables, which are like Excel spreadsheets, that contain columns and rows. In order to be able to relate data between different tables we use foreign and primary keys. Since it has primary and foreing keys, data only needs to be written once so it is a good system where write performance is a must. On counterpart, it is slower reading since it needs to search the values among all the different tables.

However, readability slowness is only evident when we increase the amount of data in which point we will need to add more power to our server in order to scale our database vertically (scale-up). Since SQL databases use `ACID` transactions *(`A`tomic / `C`onsistent / `I`solated / `D`urable)* it is difficult to distribute the data among different servers and therefore being able to scale horizontally.

##### NoSQL databases:

NoSQL stands for Not Only SQL but it is normally used for refering to non relational databases. Unlike SQL, NoSQL is not a programming language so data needs to be managed by code, so it would be more difficult to manage for non coders. It also doesn't have an extensive query system so managing data will not be as flexible as on SQL systems but all of this is in order to gain it's most valuable strength: performance.

It can store data in different ways like Json documents, key-value pairs, graphs or tables with dynamic rows and columns. It can also be stored on independent collections so you can scale horizontally (scale-out) and not vertically making it quite cheaper because you don't need to upgrade a single machine adding more power to it but you can add more small machines as a server farm distributing the data across them. That is because it sacrifices the `ACID` transactions by following the `BASE` model *(`B`asically `A`vailable / `S`oft state / `E`ventually Consistent)*. Either it is not meant to, it doesn't mean it cannot support `ACID` transactions.

The developer has the responsibility of relating data between collections so it will need to query from them and after that join it using code. Data can also be nested inside your collections so that will make the system faster reading relevant data. For example, you can have a car and the owner's name. In counterpart it is also the developer responsibility to keep that owner name updated in case the car has been sold to another driver (or the owner has changed its name), so as you can imagine this database system will be slower writing data (again, it will be only evident when we increase a lot the amount of data). A common side effect is denormalization, data duplication, and eventual consistency, requiring complex access patterns or synchronization logic.

##### Comparison:

|                                   | *SQL*                                      | *NoSQL*                                           |
| :-------------                    | :----------:                               | :-----------:                                     |
| **ACID Transactions**             |       Yes                                  |       Yes, but not intended for it                |
| **BASE Transactions**             |       Yes, but not intended for it         |       Yes                                         |
| **Fast reading**                  |       No                                   |       Yes                                         |
| **Fast writing**                  |       Yes                                  |       No                                          |
| **Scalability**                   |       Vertical                             |       Horizontal                                  |
| **High performance**              |       No                                   |       Yes                                         |
| **Integrity**                     |       Yes                                  |       No                                          |
| **Query Flexibility**             |       Yes                                  |       No                                          |
| **Data duplication susceptible**  |       No                                   |       Yes                                         |
| **Data structure**                |       Tables                               |       Json, key-value pairs, graphs, etc.         |
| **Priorities**                    |       Integrity, consistency, stability    |       Scalability, performance                    |

*`NOTE: As said, this is considering big amounts of data and what these systems are intended for. i.e.: not being susceptible doesn't mean that relational databases cannot have duplicated data.`*

##### Conclusions:

* When we compare SQL and NoSQL we are comparing relational with non relational databases even if they don't mean relational and non relational per se.
* In my personal opinion, if you only have heard about SQL it is normal since it is commonly used for teaching relational databases at tech schools normally using MySQL or Microsoft SQL Server, but I'm pretty sure you have heard about MongoDB, DynamoDB and Redis which are NoSQL commonly used database stores.
* This comparison and the huge amount of posts comparing these two systems can help you decide which one of them fits your needs better. Everything (most of it) resides in the type of data your application is going to use, the amount of it and the amount of relations between the data.
* A very good point to take in consideration is how your data is going to scale.

##### Sources:

* https://learnsql.com/blog/sql-or-sequel/
* https://blogs.perficient.com/2021/02/10/to-sql-or-to-nosql-that-is-the-question/
* https://www.imaginarycloud.com/blog/sql-vs-nosql/
* https://www.ibm.com/cloud/blog/sql-vs-nosql
* https://www.youtube.com/watch?v=zmXl2dOGWL8

---
<br />

What database model do you use the most? In my case I mostly use NoSQL since applications in my job work with a lot of data that needs to be presented quickly in the UI and storage process is done in small amounts of data when the user performs certain actions. Anyway I like both but if I had to choose one I definitely would go for NoSQL. I just like it and find it easier. But, as I said at the beginning of this post, it is just because I'm used to it!

So, what is your point of view here? Don't hesitate to comment below. As always,... see you all in the next post!
