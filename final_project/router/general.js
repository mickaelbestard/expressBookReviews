const express = require('express');
let books = require("./booksdb.js");
let isValid = require("./auth_users.js").isValid;
let users = require("./auth_users.js").users;
const public_users = express.Router();

const axios = require('axios');


public_users.post("/register", (req,res) => {
    const username = req.body.username;
    const password = req.body.password;

    // Check if both username and password are provided
    if (username && password) {
        // Check if the user does not already exist
        if (!isValid(username)) {
            // Add the new user to the users array
            users.push({"username": username, "password": password});
            return res.status(200).json({message: "User successfully registered. Now you can login"});
        } else {
            return res.status(404).json({message: "User already exists!"});
        }
    }
    // Return error if username or password is missing
    return res.status(404).json({message: "Unable to register user."});
});

// Get the book list available in the shop
public_users.get('/',function (req, res) {
  res.send(JSON.stringify(books, null, 4));
});

// Get book details based on ISBN
public_users.get('/isbn/:isbn',function (req, res) {
    const isbn = req.params.isbn;
    res.send(JSON.stringify(books[isbn], null, 4));
 });
  
// Get book details based on author
public_users.get('/author/:author',function (req, res) {
    const author = req.params.author;
    const ISBNs = Object.keys(books);

    let booksbyauthor = {};

    for (let isbn of ISBNs) {           // for...of pour avoir les vraies valeurs
        if (books[isbn].author === author) { // comparer le bon champ
            booksbyauthor[isbn] = books[isbn];
        }
    }

  res.send(JSON.stringify(booksbyauthor, null, 4));
});

// Get all books based on title
public_users.get('/title/:title',function (req, res) {
    const title = req.params.title;
    const ISBNs = Object.keys(books);

    let booksbytitle = {};

    for (let isbn of ISBNs) {           // for...of pour avoir les vraies valeurs
        if (books[isbn].title === title) { // comparer le bon champ
            booksbytitle[isbn] = books[isbn];
        }
    }

  res.send(JSON.stringify(booksbytitle, null, 4));
});

//  Get book review
public_users.get('/review/:isbn',function (req, res) {
    const isbn = req.params.isbn;
    res.send(JSON.stringify(books[isbn].reviews, null, 4));
});



// Task 10 - Get all books (async/await)
public_users.get('/axios/allbooks', async (req, res) => {
    try {
        const response = await axios.get('http://localhost:5000/');
        res.send(response.data);
    } catch (error) {
        res.status(500).send({ message: "Error fetching books." });
    }
});

// Task 11 - Get book by ISBN (async/await)
public_users.get('/axios/isbn/:isbn', async (req, res) => {
    try {
        const response = await axios.get(`http://localhost:5000/isbn/${req.params.isbn}`);
        res.send(response.data);
    } catch (error) {
        res.status(500).send({ message: "Error fetching book by ISBN." });
    }
});

// Task 12 - Get books by author (async/await)
public_users.get('/axios/author/:author', async (req, res) => {
    try {
        const response = await axios.get(`http://localhost:5000/author/${req.params.author}`);
        res.send(response.data);
    } catch (error) {
        res.status(500).send({ message: "Error fetching books by author." });
    }
});

// Task 13 - Get books by title (async/await)
public_users.get('/axios/title/:title', async (req, res) => {
    try {
        const response = await axios.get(`http://localhost:5000/title/${req.params.title}`);
        res.send(response.data);
    } catch (error) {
        res.status(500).send({ message: "Error fetching books by title." });
    }
});



module.exports.general = public_users;
